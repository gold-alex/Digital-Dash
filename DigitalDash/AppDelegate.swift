import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    static var shared: AppDelegate?
    var statusItem: NSStatusItem?
    var customView: CustomView?

    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.shared = self
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        let menu = NSMenu()

        let customViewItem = NSMenuItem()
        customView = CustomView(frame: NSRect(x: 0, y: 0, width: 380, height: 150))
        customViewItem.view = customView
        menu.addItem(customViewItem)

        // Create a custom view for the speed test button
        let speedTestView = NSView(frame: NSRect(x: 0, y: 0, width: 380, height: 30))
        let speedTestButton = NSButton(frame: NSRect(x: 0, y: 0, width: 380, height: 30))
        speedTestButton.title = "Run Speed Test"
        speedTestButton.bezelStyle = .rounded
        speedTestButton.target = self
        speedTestButton.action = #selector(runSpeedTest)
        speedTestView.addSubview(speedTestButton)

        // Create a custom menu item with the speed test button
        let speedTestItem = NSMenuItem()
        speedTestItem.view = speedTestView

        // Add the custom speed test item to the menu
        menu.addItem(speedTestItem)

        // Add a separator item
        menu.addItem(NSMenuItem.separator())

        // Add the "Set Home Country" menu item
        menu.addItem(NSMenuItem(title: "Set Home Country", action: #selector(openCountrySelector), keyEquivalent: "C"))
      
        // Add a separator item
        menu.addItem(NSMenuItem.separator())

        // Add the Quit button
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApplication), keyEquivalent: "q"))

        statusItem?.menu = menu

        // Set the initial title
        updateStatusItemTitle(title: "Digital Dash")

        // Load the home country
        customView?.loadHomeCountry()

        // Explicitly call fetchPublicIP here
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.customView?.fetchPublicIP()
        }
    }

    func updateStatusItemTitle(title: String) {
        DispatchQueue.main.async { [weak self] in
            self?.statusItem?.button?.title = title
            print("Status item title updated to: \(title)")
        }
    }

    @objc func quitApplication() {
        NSApplication.shared.terminate(nil)
    }

    @objc func runSpeedTest() {
        customView?.runSpeedTest()
        // Keep the menu open
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
                self.customView?.updateHomeCountry(selectedCountry)
            }
        }
    }
}

extension AppDelegate: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        customView?.forceIPRefresh()
    }
}




