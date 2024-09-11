import Cocoa
import Foundation
import SystemConfiguration

class CustomView: NSView {
    private let containerView: NSView
    private let label: NSTextField
    private let flagLabel: NSTextField
    private let resultLabel: NSTextField
    private let homeCountryLabel: NSTextField
    private let homeCountryResultLabel: NSTextField
    private let speedTestLabel: NSTextField
    private let speedTestResultLabel: NSTextField
    private let downloadSpeedLabelText: NSTextField
    private let uploadSpeedLabelText: NSTextField
    private let downloadSpeedValue: NSTextField
    private let uploadSpeedValue: NSTextField
    private var isRunningSpeedTest = false
    var currentCountry: String?
    
    private var networkObserver: NSObjectProtocol?
    private var reachability: SCNetworkReachability?

    override init(frame frameRect: NSRect) {
        // Initialize the UI components
        containerView = NSView()
        label = NSTextField(labelWithString: "Public IP:")
        flagLabel = NSTextField(labelWithString: "") 
        resultLabel = NSTextField(labelWithString: "Loading...")
        homeCountryLabel = NSTextField(labelWithString: "Home Country:")
        homeCountryResultLabel = NSTextField(labelWithString: "Not set")
        speedTestLabel = NSTextField(labelWithString: "Speed Test:")
        speedTestResultLabel = NSTextField(labelWithString: "")
        downloadSpeedLabelText = NSTextField(labelWithString: "Download:")
        uploadSpeedLabelText = NSTextField(labelWithString: "Upload:")
        downloadSpeedValue = NSTextField(labelWithString: "")
        uploadSpeedValue = NSTextField(labelWithString: "")

        super.init(frame: frameRect)
        
        // Set bold font for "Public IP:" and "Home Country:" labels
        let boldFont = NSFont.boldSystemFont(ofSize: NSFont.systemFontSize)
        label.font = boldFont
        homeCountryLabel.font = boldFont
        
        // Disable autoresizing mask translation to use Auto Layout
        containerView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        flagLabel.translatesAutoresizingMaskIntoConstraints = false
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        homeCountryLabel.translatesAutoresizingMaskIntoConstraints = false
        homeCountryResultLabel.translatesAutoresizingMaskIntoConstraints = false
        speedTestLabel.translatesAutoresizingMaskIntoConstraints = false
        speedTestResultLabel.translatesAutoresizingMaskIntoConstraints = false
        downloadSpeedLabelText.translatesAutoresizingMaskIntoConstraints = false
        uploadSpeedLabelText.translatesAutoresizingMaskIntoConstraints = false
        downloadSpeedValue.translatesAutoresizingMaskIntoConstraints = false
        uploadSpeedValue.translatesAutoresizingMaskIntoConstraints = false

        // Configure speed test labels
        speedTestLabel.isEditable = false
        speedTestLabel.isBordered = false
        speedTestLabel.drawsBackground = false
        speedTestResultLabel.isEditable = false
        speedTestResultLabel.isBordered = false
        speedTestResultLabel.drawsBackground = false
        speedTestResultLabel.alignment = .right
        downloadSpeedLabelText.isEditable = false
        downloadSpeedLabelText.isBordered = false
        downloadSpeedLabelText.drawsBackground = false
        downloadSpeedValue.isEditable = false
        downloadSpeedValue.isBordered = false
        downloadSpeedValue.drawsBackground = false
        downloadSpeedValue.alignment = .right
        uploadSpeedLabelText.isEditable = false
        uploadSpeedLabelText.isBordered = false
        uploadSpeedLabelText.drawsBackground = false
        uploadSpeedValue.isEditable = false
        uploadSpeedValue.isBordered = false
        uploadSpeedValue.drawsBackground = false
        uploadSpeedValue.alignment = .right
    

        // Configure labels
        label.isEditable = false
        label.isBordered = false
        label.drawsBackground = false
        flagLabel.isEditable = false
        flagLabel.isBordered = false
        flagLabel.drawsBackground = false
        resultLabel.isEditable = false
        resultLabel.isBordered = false
        resultLabel.drawsBackground = false
        resultLabel.alignment = .left
        homeCountryLabel.isEditable = false
        homeCountryLabel.isBordered = false
        homeCountryLabel.drawsBackground = false
        homeCountryResultLabel.isEditable = false
        homeCountryResultLabel.isBordered = false
        homeCountryResultLabel.drawsBackground = false
        homeCountryResultLabel.alignment = .left

        // Add the components to the view
        containerView.addSubview(label)
        containerView.addSubview(flagLabel)
        containerView.addSubview(resultLabel)
        containerView.addSubview(homeCountryLabel)
        containerView.addSubview(homeCountryResultLabel)
        self.addSubview(containerView)
        containerView.addSubview(speedTestLabel)
        containerView.addSubview(speedTestResultLabel)
        containerView.addSubview(downloadSpeedLabelText)
        containerView.addSubview(downloadSpeedValue)
        containerView.addSubview(uploadSpeedLabelText)
        containerView.addSubview(uploadSpeedValue)

        // Set up Auto Layout constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: self.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            label.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),

            flagLabel.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 5),
            flagLabel.centerYAnchor.constraint(equalTo: label.centerYAnchor),

            resultLabel.leadingAnchor.constraint(equalTo: flagLabel.trailingAnchor, constant: 2),
            resultLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            resultLabel.centerYAnchor.constraint(equalTo: label.centerYAnchor),

            homeCountryLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            homeCountryLabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10),

            homeCountryResultLabel.leadingAnchor.constraint(equalTo: homeCountryLabel.trailingAnchor, constant: 5),
            homeCountryResultLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            homeCountryResultLabel.centerYAnchor.constraint(equalTo: homeCountryLabel.centerYAnchor),

            speedTestLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            speedTestLabel.topAnchor.constraint(equalTo: homeCountryLabel.bottomAnchor, constant: 10),

            speedTestResultLabel.leadingAnchor.constraint(equalTo: speedTestLabel.trailingAnchor, constant: 5),
            speedTestResultLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            speedTestResultLabel.centerYAnchor.constraint(equalTo: speedTestLabel.centerYAnchor),

            downloadSpeedLabelText.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            downloadSpeedLabelText.topAnchor.constraint(equalTo: speedTestLabel.bottomAnchor, constant: 10),
            
            downloadSpeedValue.leadingAnchor.constraint(equalTo: downloadSpeedLabelText.trailingAnchor, constant: 5),
            downloadSpeedValue.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            downloadSpeedValue.centerYAnchor.constraint(equalTo: downloadSpeedLabelText.centerYAnchor),

            uploadSpeedLabelText.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            uploadSpeedLabelText.topAnchor.constraint(equalTo: downloadSpeedLabelText.bottomAnchor, constant: 5),
            
            uploadSpeedValue.leadingAnchor.constraint(equalTo: uploadSpeedLabelText.trailingAnchor, constant: 5),
            uploadSpeedValue.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            uploadSpeedValue.centerYAnchor.constraint(equalTo: uploadSpeedLabelText.centerYAnchor),
            uploadSpeedValue.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -10)
        ])

        // Set up network change observer
        setupNetworkObserver()

        // Display the public IP address and home country
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.fetchPublicIP()
            self?.loadHomeCountry()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func fetchPublicIP() {
        guard let url = URL(string: "https://api.ipify.org?format=json") else {
            resultLabel.stringValue = "Error: Invalid URL"
            return
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.resultLabel.stringValue = "Error: \(error.localizedDescription)"
                    self?.flagLabel.stringValue = ""
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
                        self?.resultLabel.stringValue = ip
                        self?.fetchCountryInfo(for: ip)
                    } else {
                        self?.resultLabel.stringValue = "Error: Unable to parse IP"
                        self?.flagLabel.stringValue = ""
                    }
                } catch {
                    self?.resultLabel.stringValue = "Error: \(error.localizedDescription)"
                    self?.flagLabel.stringValue = ""
                }
            }
        }

        task.resume()
    }

    func fetchCountryInfo(for ip: String) {
        guard let url = URL(string: "https://ipapi.co/\(ip)/json/") else {
            flagLabel.stringValue = ""
            return
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.resultLabel.stringValue = ip
                self?.flagLabel.stringValue = ""

                guard let data = data, error == nil else {
                    print("Error fetching country info: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let countryCode = json["country_code"] as? String,
                       let country = json["country_name"] as? String {
                        self?.flagLabel.stringValue = self?.countryFlag(from: countryCode) ?? ""
                        self?.currentCountry = country
                        print("Current country set to: \(country)")
                        self?.compareCountries()
                    }
                } catch {
                    print("Error parsing country info: \(error.localizedDescription)")
                }
            }
        }

        task.resume()
    }

    func runSpeedTest() {
        guard !isRunningSpeedTest else { return }
        guard isNetworkReachable() else {
            speedTestResultLabel.stringValue = "Error: No network connection"
            downloadSpeedValue.stringValue = "Error"
            uploadSpeedValue.stringValue = "Error"
            return
        }
        isRunningSpeedTest = true
        speedTestResultLabel.stringValue = "Running..."
        downloadSpeedValue.stringValue = "Running..."
        uploadSpeedValue.stringValue = "Running..."

        // Use a larger file for download test (500MB)
        let downloadURL = "https://speed.cloudflare.com/__down?bytes=500000000"
        let uploadURL = "https://speed.cloudflare.com/__up"
        
        func runDownloadTest(completion: @escaping (Double) -> Void) {
            guard let url = URL(string: downloadURL) else {
                print("Invalid download URL")
                completion(0)
                return
            }

            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForResource = 120 // 120 seconds timeout
            let session = URLSession(configuration: configuration)

            // Warm-up request
            session.dataTask(with: url) { _, _, _ in
                // Actual test with multiple samples
                let numberOfSamples = 3
                var speeds: [Double] = []

                func runSample(sampleIndex: Int) {
                    let startTime = DispatchTime.now()
                    let task = session.dataTask(with: url) { data, response, error in
                        let endTime = DispatchTime.now()
                        let nanoTime = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
                        let timeInterval = Double(nanoTime) / 1_000_000_000 // Convert to seconds

                        if let error = error {
                            print("Download error: \(error.localizedDescription)")
                        } else if let data = data, let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) {
                            let bytesReceived = Double(data.count)
                            let megabitsReceived = (bytesReceived * 8) / 1_000_000
                            let speedMbps = megabitsReceived / timeInterval
                            speeds.append(speedMbps)
                            print("Sample \(sampleIndex + 1) speed: \(speedMbps) Mbps")
                        }

                        if sampleIndex < numberOfSamples - 1 {
                            runSample(sampleIndex: sampleIndex + 1)
                        } else {
                            let averageSpeed = speeds.reduce(0, +) / Double(speeds.count)
                            completion(averageSpeed)
                        }
                    }
                    task.resume()
                }

                runSample(sampleIndex: 0)
            }.resume()
        }

        func runUploadTest(completion: @escaping (Double) -> Void) {
            guard let url = URL(string: uploadURL) else {
                completion(0)
                return
            }

            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForResource = 120 // 120 seconds timeout
            let session = URLSession(configuration: configuration)

            // Generate 50MB of random data for upload
            let dataSize = 50 * 1024 * 1024
            let data = Data(count: dataSize)

            let numberOfSamples = 3
            var speeds: [Double] = []

            func runSample(sampleIndex: Int) {
                var request = URLRequest(url: url)
                request.httpMethod = "POST"

                let startTime = DispatchTime.now()
                let task = session.uploadTask(with: request, from: data) { _, response, error in
                    let endTime = DispatchTime.now()
                    let nanoTime = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
                    let timeInterval = Double(nanoTime) / 1_000_000_000 // Convert to seconds

                    if let error = error {
                        print("Upload error: \(error.localizedDescription)")
                    } else if let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) {
                        let bytesSent = Double(dataSize)
                        let megabitsSent = (bytesSent * 8) / 1_000_000
                        let speedMbps = megabitsSent / timeInterval
                        speeds.append(speedMbps)
                        print("Sample \(sampleIndex + 1) speed: \(speedMbps) Mbps")
                    }

                    if sampleIndex < numberOfSamples - 1 {
                        runSample(sampleIndex: sampleIndex + 1)
                    } else {
                        let averageSpeed = speeds.reduce(0, +) / Double(speeds.count)
                        completion(averageSpeed)
                    }
                }
                task.resume()
            }

            runSample(sampleIndex: 0)
        }

        runDownloadTest { downloadSpeed in
            DispatchQueue.main.async {
                self.downloadSpeedValue.stringValue = String(format: "%.2f Mbps", downloadSpeed)
            }
            
            runUploadTest { uploadSpeed in
                DispatchQueue.main.async {
                    self.uploadSpeedValue.stringValue = String(format: "%.2f Mbps", uploadSpeed)
                    self.speedTestResultLabel.stringValue = String(format: "↓%.2f Mbps ↑%.2f Mbps", downloadSpeed, uploadSpeed)
                    self.isRunningSpeedTest = false
                }
            }
        }
    }

    func isNetworkReachable() -> Bool {
        guard let reachability = SCNetworkReachabilityCreateWithName(nil, "www.apple.com") else {
            return false
        }
        var flags = SCNetworkReachabilityFlags()
        SCNetworkReachabilityGetFlags(reachability, &flags)
        return flags.contains(.reachable)
    }

    func compareCountries() {
        if let currentCountry = self.currentCountry,
           let homeCountry = UserDefaults.standard.string(forKey: "homeCountry"),
           homeCountry != "Not set" {
            let title = currentCountry == homeCountry ? ":)" : ":("
            updateStatusItemTitle(title: title)
        } else {
            updateStatusItemTitle(title: "Digital Dash")
        }
    }

    func updateStatusItemTitle(title: String) {
        print("CustomView: Updating status item title to \(title)")
        if let appDelegate = AppDelegate.shared {
            appDelegate.updateStatusItemTitle(title: title)
        } else {
            print("CustomView: Failed to get AppDelegate")
        }
    }

    func countryFlag(from countryCode: String) -> String {
        let base : UInt32 = 127397
        var s = ""
        for v in countryCode.uppercased().unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }
        return String(s)
    }

    func updateHomeCountry(_ country: String) {
        homeCountryResultLabel.stringValue = country
        UserDefaults.standard.set(country, forKey: "homeCountry")
        compareCountries()  // This will call updateStatusItemTitle with the correct title
    }

    func loadHomeCountry() {
        updateHomeCountry(UserDefaults.standard.string(forKey: "homeCountry") ?? "Not set")
    }
    
    deinit {
        if let observer = networkObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
        }
        if let reachability = reachability {
            SCNetworkReachabilityUnscheduleFromRunLoop(reachability, CFRunLoopGetMain(), CFRunLoopMode.commonModes.rawValue)
        }
    }

    private func setupNetworkObserver() {
        guard let reachability = SCNetworkReachabilityCreateWithName(nil, "www.apple.com") else {
            print("Failed to create network reachability object")
            return
        }

        self.reachability = reachability

        var context = SCNetworkReachabilityContext(version: 0, info: Unmanaged.passUnretained(self).toOpaque(), retain: nil, release: nil, copyDescription: nil)
        
        if !SCNetworkReachabilitySetCallback(reachability, { (_, flags, info) in
            guard let info = info else { return }
            let customView = Unmanaged<CustomView>.fromOpaque(info).takeUnretainedValue()
            DispatchQueue.main.async {
                customView.networkStatusChanged()
            }
        }, &context) {
            print("Failed to set network reachability callback")
            return
        }

        if !SCNetworkReachabilityScheduleWithRunLoop(reachability, CFRunLoopGetMain(), CFRunLoopMode.commonModes.rawValue) {
            print("Failed to schedule network reachability")
            return
        }

        print("Network observer set up successfully")
    }

    private func networkStatusChanged() {
        print("Network status changed")
        fetchPublicIP()
    }
}



