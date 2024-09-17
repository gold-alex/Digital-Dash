// AppDelegate.swift

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    static var shared: AppDelegate?
    var statusItem: NSStatusItem!
    var customView: CustomView!

    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.shared = self

        // Initialize the status item with variable length
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        // Create the menu and assign it to the status item
        let menu = NSMenu()
        menu.delegate = self
        statusItem.menu = menu

        // Set the initial title
        updateStatusItemTitle(title: "Digital Dash")

        // Create the custom view item
        let customViewItem = NSMenuItem()
        customView = CustomView()
        customView.translatesAutoresizingMaskIntoConstraints = false

        // Create a container view for customView
        let customViewContainer = NSView()
        customViewContainer.translatesAutoresizingMaskIntoConstraints = false
        customViewContainer.addSubview(customView)

        // Add constraints to pin customView to its container
        NSLayoutConstraint.activate([
            customView.topAnchor.constraint(equalTo: customViewContainer.topAnchor),
            customView.leadingAnchor.constraint(equalTo: customViewContainer.leadingAnchor),
            customView.trailingAnchor.constraint(equalTo: customViewContainer.trailingAnchor),
            customView.bottomAnchor.constraint(equalTo: customViewContainer.bottomAnchor)
        ])

        // Set the container view's size to match customView's intrinsic content size
        let customViewSize = customView.intrinsicContentSize
        customViewContainer.setFrameSize(customViewSize)

        customViewItem.view = customViewContainer
        menu.addItem(customViewItem)

        // Create the speed test button item
        let speedTestItem = NSMenuItem()
        let speedTestButton = NSButton(title: "Run Speed Test", target: self, action: #selector(runSpeedTest))
        speedTestButton.bezelStyle = .rounded
        speedTestButton.translatesAutoresizingMaskIntoConstraints = false

        let speedTestView = NSView()
        speedTestView.translatesAutoresizingMaskIntoConstraints = false
        speedTestView.addSubview(speedTestButton)

        // Add constraints to center the button in its container
        NSLayoutConstraint.activate([
            speedTestButton.centerXAnchor.constraint(equalTo: speedTestView.centerXAnchor),
            speedTestButton.centerYAnchor.constraint(equalTo: speedTestView.centerYAnchor),
            speedTestView.widthAnchor.constraint(equalTo: speedTestButton.widthAnchor),
            speedTestView.heightAnchor.constraint(equalTo: speedTestButton.heightAnchor)
        ])

        speedTestItem.view = speedTestView
        menu.addItem(speedTestItem)

        // Add a separator item
        menu.addItem(NSMenuItem.separator())

        // Add the "Set Home Country" menu item
        let setHomeCountryItem = NSMenuItem(title: "Set Home Country", action: #selector(openCountrySelector), keyEquivalent: "")
        setHomeCountryItem.target = self
        menu.addItem(setHomeCountryItem)

        // Add another separator item
        menu.addItem(NSMenuItem.separator())

        // Add the Quit menu item
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApplication), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        // Load the home country
        customView.loadHomeCountry()

        // Explicitly call fetchPublicIP after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.customView.fetchPublicIP()
        }
    }

    // MARK: - NSMenuDelegate

    func menuWillOpen(_ menu: NSMenu) {
        customView.forceIPRefresh()
    }

    // MARK: - Status Item Title Update

    func updateStatusItemTitle(title: String) {
        DispatchQueue.main.async { [weak self] in
            self?.statusItem.button?.title = title
            print("Status item title updated to: \(title)")
        }
    }

    // MARK: - Actions

    @objc func quitApplication() {
        NSApplication.shared.terminate(nil)
    }

    @objc func runSpeedTest() {
        customView.runSpeedTest()
        // Keep the menu open after clicking the button
        if let statusItem = statusItem, let button = statusItem.button {
            statusItem.menu?.popUp(positioning: nil, at: NSPoint(x: 0, y: button.frame.height), in: button)
        }
    }

    @objc func openCountrySelector() {
        let countries = [
            "Afghanistan", "Algeria", "Angola", "Argentina", "Australia", "Austria", "Azerbaijan",
            "Bangladesh", "Belarus", "Belgium", "Benin", "Bolivia", "Brazil", "Burkina Faso", "Burundi",
            "Cambodia", "Cameroon", "Canada", "Chad", "Chile", "China", "Colombia", "Côte d'Ivoire", "Cuba", "Czech Republic (Czechia)",
            "DR Congo", "Dominican Republic",
            "Ecuador", "Egypt", "Ethiopia",
            "France",
            "Germany", "Ghana", "Greece", "Guatemala", "Guinea",
            "Haiti", "Honduras", "Hungary",
            "India", "Indonesia", "Iran", "Iraq", "Israel", "Italy",
            "Japan", "Jordan",
            "Kazakhstan", "Kenya",
            "Madagascar", "Malawi", "Malaysia", "Mali", "Mexico", "Morocco", "Mozambique", "Myanmar",
            "Nepal", "Netherlands", "Niger", "Nigeria", "North Korea",
            "Pakistan", "Papua New Guinea", "Peru", "Philippines", "Poland", "Portugal",
            "Romania", "Russia", "Rwanda",
            "Saudi Arabia", "Senegal", "Serbia", "Sierra Leone", "Somalia", "South Africa", "South Korea", "South Sudan", "Spain", "Sri Lanka", "Sudan", "Sweden", "Switzerland", "Syria",
            "Taiwan", "Tajikistan", "Tanzania", "Thailand", "Togo", "Tunisia", "Turkey",
            "Uganda", "Ukraine", "United Arab Emirates", "United Kingdom", "United States", "Uzbekistan",
            "Venezuela", "Vietnam",
            "Yemen",
            "Zambia", "Zimbabwe"
        ].sorted()

        let alert = NSAlert()
        alert.messageText = "Select Home Country"
        alert.informativeText = "Choose your home country from the list below:"

        let customView = NSView(frame: NSRect(x: 0, y: 0, width: 230, height: 30))

        let iconView = NSImageView(frame: NSRect(x: 0, y: 2, width: 25, height: 25))
        if let locationImage = NSImage(systemSymbolName: "location.fill", accessibilityDescription: "Location icon") {
            iconView.image = locationImage
            iconView.contentTintColor = .labelColor
        }
        customView.addSubview(iconView)

        let popUpButton = NSPopUpButton(frame: NSRect(x: 30, y: 0, width: 200, height: 25))
        popUpButton.addItems(withTitles: countries)

        if let currentHomeCountry = UserDefaults.standard.string(forKey: "homeCountry"),
           let index = countries.firstIndex(of: currentHomeCountry) {
            popUpButton.selectItem(at: index)
        }

        customView.addSubview(popUpButton)

        alert.accessoryView = customView
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")

        let response = alert.runModal()

        if response == .alertFirstButtonReturn {
            if let selectedCountry = popUpButton.selectedItem?.title {
                print("Selected country: \(selectedCountry)")
                self.customView.updateHomeCountry(selectedCountry)
            }
        }
    }
}
