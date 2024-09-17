// CustomView.swift

import Cocoa
import Foundation
import Network

class CustomView: NSView {
    // MARK: - UI Components

    private let label = NSTextField(labelWithString: "Public IP:")
    private let flagLabel = NSTextField(labelWithString: "")
    private let resultLabel = NSTextField(labelWithString: "Loading...")
    private let homeCountryLabel = NSTextField(labelWithString: "Home Country:")
    private let homeCountryResultLabel = NSTextField(labelWithString: "Not set")
    private let speedTestLabel = NSTextField(labelWithString: "Speed Test:")
    private let progressLabel = NSTextField(labelWithString: "")
    private let progressBar = NSProgressIndicator()
    private var isRunningSpeedTest = false
    var currentCountry: String?

    // MARK: - Network Monitoring Properties

    private var networkMonitor: NWPathMonitor?
    private var isNetworkAvailable = false
    private var lastKnownIP: String?
    private var retryTimer: Timer?
    private var isRetrying = false
    private var ipCheckTimer: Timer?
    private var isHomeCountrySet: Bool = false

    private var retryCount = 0
    private let maxRetryCount = 5
    private let initialRetryDelay: TimeInterval = 1.0

    private var currentPath: NWPath?
    private var currentDataTask: URLSessionDataTask?

    // MARK: - UI Layout Properties

    private var gridView: NSGridView!
    private var isSpeedTestRowAdded = false

    // MARK: - Initialization

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupUI()
        setupNetworkMonitor()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupNetworkMonitor()
    }

    // MARK: - UI Setup

    private func setupUI() {
        // Set fonts
        let boldFont = NSFont.boldSystemFont(ofSize: NSFont.systemFontSize)
        label.font = boldFont
        homeCountryLabel.font = boldFont
        speedTestLabel.font = boldFont

        // Configure labels
        [label, flagLabel, resultLabel, homeCountryLabel, homeCountryResultLabel, speedTestLabel, progressLabel].forEach {
            $0.isEditable = false
            $0.isBordered = false
            $0.drawsBackground = false
        }

        // Align labels to the left, values to the right
        [label, homeCountryLabel, speedTestLabel].forEach { $0.alignment = .left }
        [resultLabel, homeCountryResultLabel, progressLabel].forEach { $0.alignment = .right }

        // Create a horizontal stack for the flag and IP address
        let ipValueStack = NSStackView(views: [flagLabel, resultLabel])
        ipValueStack.orientation = .horizontal
        ipValueStack.spacing = 5
        ipValueStack.alignment = .centerY

        // Create Grid View
        gridView = NSGridView(views: [
            [label, ipValueStack],
            [homeCountryLabel, homeCountryResultLabel]
        ])
        gridView.translatesAutoresizingMaskIntoConstraints = false

        // Adjust column alignments
        gridView.column(at: 0).xPlacement = .leading   // Left-align labels
        gridView.column(at: 1).xPlacement = .trailing  // Right-align values

        // Adjust row spacing to ensure consistent vertical spacing
        gridView.rowSpacing = 5
        gridView.columnSpacing = 10

        addSubview(gridView)

        // Constraints for Grid View
        NSLayoutConstraint.activate([
            gridView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            gridView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            gridView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            gridView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10)
        ])

        // Set content hugging and compression resistance priorities
        gridView.setContentHuggingPriority(.required, for: .vertical)
        gridView.setContentCompressionResistancePriority(.required, for: .vertical)

        // Set the view's translatesAutoresizingMaskIntoConstraints to false
        self.translatesAutoresizingMaskIntoConstraints = false
    }

    override var intrinsicContentSize: NSSize {
        let gridSize = gridView.fittingSize
        // Add padding values used in constraints
        let width = gridSize.width + 30  // Left and right padding: 15 + 15
        let height = gridSize.height + 20 // Top and bottom padding: 10 + 10
        return NSSize(width: width, height: height)
    }

    // MARK: - Network Monitoring and Data Fetching

    private func setupNetworkMonitor() {
        networkMonitor = NWPathMonitor()
        networkMonitor?.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                let previousPath = self?.currentPath
                self?.currentPath = path

                self?.isNetworkAvailable = (path.status == .satisfied)
                print("Network status changed: isNetworkAvailable = \(self?.isNetworkAvailable ?? false)")

                if path.status == .satisfied {
                    if previousPath == nil || path != previousPath {
                        // Network became available or path changed (e.g., VPN enabled)
                        self?.retryTimer?.invalidate()
                        self?.isRetrying = false
                        self?.retryCount = 0
                        // Add a slight delay before refreshing IP
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            self?.forceIPRefresh()
                        }
                    }
                } else {
                    self?.handleNetworkUnavailable()
                }
            }
        }
        networkMonitor?.start(queue: DispatchQueue.global())

        // Start periodic IP checks
        startIPCheckTimer()
    }

    private func startIPCheckTimer() {
        ipCheckTimer?.invalidate()
        ipCheckTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            self?.checkForIPChange()
        }
    }

    public func forceIPRefresh() {
        lastKnownIP = nil
        fetchPublicIP()
    }

    private func checkForIPChange() {
        guard isNetworkAvailable else { return }

        guard let url = URL(string: "https://api.ipify.org?format=json") else {
            return
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let ip = json["ip"] as? String else {
                return
            }

            DispatchQueue.main.async {
                if ip != self?.lastKnownIP {
                    self?.forceIPRefresh()
                }
            }
        }
        task.resume()
    }

    private func handleNetworkUnavailable() {
        currentDataTask?.cancel() // Cancel any ongoing data tasks
        resultLabel.stringValue = "Network unavailable"
        flagLabel.stringValue = ""
        currentCountry = nil
        compareCountries()
        startRetryTimer()
    }

    private func startRetryTimer() {
        retryTimer?.invalidate()
        isRetrying = true
        let delay = calculateRetryDelay()
        retryTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            self?.checkNetworkAndFetchIP()
        }
    }

    private func calculateRetryDelay() -> TimeInterval {
        let delay = initialRetryDelay * pow(2.0, Double(retryCount))
        retryCount = min(retryCount + 1, maxRetryCount)
        return min(delay, 60.0) // Cap the delay at 60 seconds
    }

    private func checkNetworkAndFetchIP() {
        if isNetworkAvailable {
            retryTimer?.invalidate()
            isRetrying = false
            retryCount = 0
            fetchPublicIP()
        } else {
            startRetryTimer()
        }
    }

    func fetchPublicIP() {
        // Cancel any existing task
        currentDataTask?.cancel()

        guard isNetworkAvailable else {
            handleNetworkUnavailable()
            return
        }

        guard let url = URL(string: "https://api.ipify.org?format=json") else {
            resultLabel.stringValue = "Error: Invalid URL"
            return
        }

        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        let session = URLSession(configuration: configuration)

        currentDataTask = session.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                if let error = error as NSError?, error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled {
                    // Task was cancelled, do not update resultLabel
                    return
                }

                guard let data = data else {
                    self?.resultLabel.stringValue = "Error: No data received"
                    self?.flagLabel.stringValue = ""
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let ip = json["ip"] as? String {
                        self?.lastKnownIP = ip
                        self?.resultLabel.stringValue = ip
                        self?.fetchCountryInfo(for: ip)
                    } else {
                        self?.resultLabel.stringValue = "Error: Unable to parse IP"
                        self?.flagLabel.stringValue = ""
                    }
                } catch {
                    self?.handleNetworkError(error: error)
                }
            }
        }

        currentDataTask?.resume()
    }

    func fetchCountryInfo(for ip: String) {
        guard isNetworkAvailable else {
            handleNetworkUnavailable()
            return
        }

        guard let url = URL(string: "https://ipapi.co/\(ip)/json/") else {
            flagLabel.stringValue = ""
            return
        }

        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        let session = URLSession(configuration: configuration)

        let task = session.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                self?.resultLabel.stringValue = ip
                self?.flagLabel.stringValue = ""

                if let error = error {
                    self?.handleNetworkError(error: error)
                    return
                }

                guard let data = data else {
                    self?.handleNetworkError(error: NSError(domain: "CustomViewError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let countryCode = json["country_code"] as? String,
                       let country = json["country_name"] as? String {
                        self?.flagLabel.stringValue = self?.countryFlag(from: countryCode) ?? ""
                        self?.currentCountry = country
                        self?.compareCountries()
                    } else {
                        self?.handleNetworkError(error: NSError(domain: "CustomViewError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to parse country info"]))
                    }
                } catch {
                    self?.handleNetworkError(error: error)
                }
            }
        }

        task.resume()
    }

    private func handleNetworkError(error: Error) {
        print("Network error: \(error.localizedDescription)")
        resultLabel.stringValue = "Error: \(error.localizedDescription)"
        flagLabel.stringValue = ""
        currentCountry = nil
        compareCountries()
        if !isRetrying {
            startRetryTimer()
        }
    }

    // MARK: - Speed Test Functionality

    func runSpeedTest() {
        guard isNetworkAvailable else {
            progressLabel.stringValue = "Network unavailable"
            return
        }

        guard !isRunningSpeedTest else { return }
        isRunningSpeedTest = true
        progressBar.isHidden = false
        progressBar.doubleValue = 0
        progressLabel.stringValue = "Initializing..."

        // Add the "Speed Test:" row if not already added
        if !isSpeedTestRowAdded {
            // Configure progressBar
            progressBar.isIndeterminate = false
            progressBar.minValue = 0
            progressBar.maxValue = 100
            progressBar.doubleValue = 0
            progressBar.controlSize = .small
            progressBar.isDisplayedWhenStopped = false
            progressBar.style = .bar

            let progressStack = NSStackView(views: [progressBar, progressLabel])
            progressStack.orientation = .horizontal
            progressStack.spacing = 5
            progressStack.alignment = .centerY

            let speedTestRow = [speedTestLabel, progressStack]
            gridView.addRow(with: speedTestRow)
            isSpeedTestRowAdded = true

            // Adjust grid view constraints after adding a new row
            gridView.layoutSubtreeIfNeeded()
            invalidateIntrinsicContentSize() // Important to recalculate size
        }

        // Increase the file sizes to improve accuracy
        let downloadURL = "https://speed.cloudflare.com/__down?bytes=50000000" // 50 MB
        let uploadURL = "https://speed.cloudflare.com/__up"

        func runDownloadTest(completion: @escaping (Double) -> Void) {
            guard let url = URL(string: downloadURL) else {
                print("Invalid download URL")
                completion(0)
                return
            }

            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForResource = 15
            let session = URLSession(configuration: configuration)

            let startTime = Date()
            let task = session.dataTask(with: url) { data, response, error in
                let endTime = Date()
                let timeInterval = endTime.timeIntervalSince(startTime)

                DispatchQueue.main.async {
                    if let error = error {
                        print("Download error: \(error.localizedDescription)")
                        self.progressLabel.stringValue = "Download failed"
                        completion(0)
                    } else if let data = data, let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) {
                        let bytesReceived = Double(data.count)
                        let megabitsReceived = (bytesReceived * 8) / 1_000_000
                        let speedMbps = megabitsReceived / timeInterval
                        completion(speedMbps)
                    } else {
                        self.progressLabel.stringValue = "Download failed"
                        completion(0)
                    }
                }
            }
            task.resume()
        }

        func runUploadTest(completion: @escaping (Double) -> Void) {
            guard let url = URL(string: uploadURL) else {
                completion(0)
                return
            }

            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForResource = 15
            let session = URLSession(configuration: configuration)

            let dataSize = 5 * 1024 * 1024 // 5 MB
            let data = Data(count: dataSize)

            var request = URLRequest(url: url)
            request.httpMethod = "POST"

            let startTime = Date()
            let task = session.uploadTask(with: request, from: data) { _, response, error in
                let endTime = Date()
                let timeInterval = endTime.timeIntervalSince(startTime)

                DispatchQueue.main.async {
                    if let error = error {
                        print("Upload error: \(error.localizedDescription)")
                        self.progressLabel.stringValue = "Upload failed"
                        completion(0)
                    } else if let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) {
                        let bytesSent = Double(dataSize)
                        let megabitsSent = (bytesSent * 8) / 1_000_000
                        let speedMbps = megabitsSent / timeInterval
                        completion(speedMbps)
                    } else {
                        self.progressLabel.stringValue = "Upload failed"
                        completion(0)
                    }
                }
            }
            task.resume()
        }

        // Update the progress label during the test
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.progressLabel.stringValue = "Testing download..."
        }

        runDownloadTest { [weak self] downloadSpeed in
            guard let self = self else { return }
            self.progressLabel.stringValue = "Testing upload..."

            runUploadTest { [weak self] uploadSpeed in
                guard let self = self else { return }

                if downloadSpeed > 0 || uploadSpeed > 0 {
                    self.progressLabel.stringValue = String(format: "↓%.2f Mbps ↑%.2f Mbps", downloadSpeed, uploadSpeed)
                } else {
                    self.progressLabel.stringValue = "Test failed"
                }

                self.isRunningSpeedTest = false
                self.progressBar.isHidden = true
            }
        }
    }

    // MARK: - Country Comparison and Utilities

    func compareCountries() {
        let homeCountry = UserDefaults.standard.string(forKey: "homeCountry")
        isHomeCountrySet = homeCountry != nil && homeCountry != "Not set"

        if isHomeCountrySet, let currentCountry = self.currentCountry, let homeCountry = homeCountry {
            let title = currentCountry == homeCountry ? ":)" : ":("
            updateStatusItemTitle(title: title)
        } else {
            updateStatusItemTitle(title: "Digital Dash")
        }
    }

    func updateStatusItemTitle(title: String) {
        // Update the status item title if applicable
        if let appDelegate = AppDelegate.shared {
            appDelegate.updateStatusItemTitle(title: title)
        } else {
            print("CustomView: Failed to get AppDelegate")
        }
    }

    func countryFlag(from countryCode: String) -> String {
        let base: UInt32 = 127397
        var s = ""
        for v in countryCode.uppercased().unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }
        return String(s)
    }

    func updateHomeCountry(_ country: String) {
        homeCountryResultLabel.stringValue = country
        UserDefaults.standard.set(country, forKey: "homeCountry")
        isHomeCountrySet = country != "Not set"
        compareCountries()
    }

    func loadHomeCountry() {
        let homeCountry = UserDefaults.standard.string(forKey: "homeCountry") ?? "Not set"
        updateHomeCountry(homeCountry)
    }

    // MARK: - Deinitialization

    deinit {
        networkMonitor?.cancel()
        retryTimer?.invalidate()
        ipCheckTimer?.invalidate()
    }
}
