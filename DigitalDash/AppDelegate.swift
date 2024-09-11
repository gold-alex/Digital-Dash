import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    static var shared: AppDelegate?
    var statusItem: NSStatusItem?
    var customView: NSView?  // Change this back to NSView

    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.shared = self
        // Create a status item in the menu bar with a variable length
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        // Create a new NSMenu instance to be displayed when the status item is clicked
        let menu = NSMenu()

        // Create a custom menu item that contains the CustomView for public IP
        let customViewItem = NSMenuItem()
        customView = CustomView(frame: NSRect(x: 0, y: 0, width: 380, height: 150)) // Increase height to accommodate new labels
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

        // Assign the menu to the status item
        statusItem?.menu = menu

        // Add this line to load the home country when the app starts
        (customView as? CustomView)?.loadHomeCountry()

        // Update status item title
        updateStatusItemTitle(title: nil)

        // Set the rounded dock icon
        setRoundedDockIcon()
    }

    @objc func quitApplication() {
        NSApplication.shared.terminate(nil)
    }

   @objc func runSpeedTest() {
    (customView as? CustomView)?.runSpeedTest()
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
        ].sorted()  // This sorts the array alphabetically
        
        let alert = NSAlert()
        alert.messageText = "Select Home Country"
        alert.informativeText = "Choose your home country from the list below:"
        
        // Create a custom view to hold the icon and popup button
        let customView = NSView(frame: NSRect(x: 0, y: 0, width: 230, height: 30))
        
        // Create the location icon using SF Symbols
        let iconView = NSImageView(frame: NSRect(x: 0, y: 2, width: 25, height: 25))
        if let locationImage = NSImage(systemSymbolName: "location.fill", accessibilityDescription: "Location icon") {
            iconView.image = locationImage
            iconView.contentTintColor = .labelColor // This will make the icon adapt to light/dark mode
        }
        customView.addSubview(iconView)
        
        // Create the popup button
        let popUpButton = NSPopUpButton(frame: NSRect(x: 30, y: 0, width: 200, height: 25))
        popUpButton.addItems(withTitles: countries)
        
        // Set the default selected option to the current home country
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
                (self.customView as? CustomView)?.updateHomeCountry(selectedCountry)
                (self.customView as? CustomView)?.compareCountries()
            }
        }
    }

    func updateStatusItemTitle(title: String? = nil) {
        print("Updating status item title")
        guard let customView = customView as? CustomView else {
            print("CustomView is nil or not of type CustomView")
            statusItem?.button?.title = "Digital Dash"
            return
        }

        print("Current country: \(customView.currentCountry ?? "nil")")
        print("Home country: \(UserDefaults.standard.string(forKey: "homeCountry") ?? "nil")")
        
        if let title = title {
            print("Setting title to: \(title)")
            statusItem?.button?.title = title
        } else if let publicCountry = customView.currentCountry,
                  let homeCountry = UserDefaults.standard.string(forKey: "homeCountry"),
                  homeCountry != "Not set" {
            let newTitle = publicCountry == homeCountry ? ":)" : ":("
            print("Setting title to: \(newTitle)")
            statusItem?.button?.title = newTitle
        } else {
            print("Setting title to: Digital Dash")
            statusItem?.button?.title = "Digital Dash"
        }
    }

    func setRoundedDockIcon() {
        if let appIcon = NSImage(named: "AppIcon") {
            let size = NSSize(width: 96, height: 96)  // Reduced from 128x128 to 96x96
            let roundedIcon = NSImage(size: size)
            
            roundedIcon.lockFocus()
            let bounds = NSRect(origin: .zero, size: size)
            NSBezierPath(roundedRect: bounds, xRadius: 15, yRadius: 15).addClip()  // Reduced corner radius
            appIcon.draw(in: bounds, from: NSRect(origin: .zero, size: appIcon.size), operation: .copy, fraction: 1.0)
            roundedIcon.unlockFocus()
            
            let iconView = NSImageView(frame: NSRect(origin: .zero, size: size))
            iconView.image = roundedIcon
            
        
            NSApp.dockTile.contentView = iconView
            NSApp.dockTile.display()
        }
    }
}






