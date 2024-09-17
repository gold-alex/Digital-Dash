
       ___      _      __ _     _      _                _              ___                    _      
      |   \    (_)    / _` |   (_)    | |_    __ _     | |     ___    |   \   __ _     ___   | |_    
      | |) |   | |    \__, |   | |    |  _|  / _` |    | |    |___|   | |) | / _` |   (_-<   | ' \   
      |___/   _|_|_   |___/   _|_|_   _\__|  \__,_|   _|_|_   _____   |___/  \__,_|   /__/_  |_||_|    _      
     |"""""|_|"""""|_|"""""|_|"""""|_|"""""|_|"""""|_|"""""|_|     |_|"""""|_|"""""|_|"""""|_|"""""|      
    "`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-' 

Digital Dash is a macOS menu bar application that provides real-time information about your network status, including your current public IP address and location. It's an essential tool for digital nomads, travelers, and anyone who wants to keep track of their network details and VPN status.

https://github.com/user-attachments/assets/c719c553-419b-4e04-bdb5-1d054ac46c58

## Features

- Displays your current public IP address in the menu bar
- Shows the country flag associated with your IP
- Allows you to set a home location
- Compares your current location with your home location
- Updates automatically when network changes are detected
- Provides detailed network information with a single click
- Minimal and unobtrusive design

## Features (Additional)

- Built-in speed test for measuring download and upload speeds
- Easy home country selection from a comprehensive list of countries
- Visual indicator in the menu bar for quick location status check

## Requirements

- macOS 13.0 or later

## Installation

1. Download the latest release from the GitHub releases page.
2. Drag Digital Dash to your Applications folder.
3. Launch Digital Dash from your Applications folder or Spotlight.

## Usage

1. After launching, Digital Dash will appear in your menu bar.
2. Click on the menu bar icon to see your current IP, country, and other network details.
3. Use the "Set Home Location" option in the preferences to define your home location.
4. The menu bar icon will update to reflect your current location status.
5. Use the "Run Speed Test" option to check your current download and upload speeds.
6. The menu bar icon will show ":)" if you're in your home country, or ":(" if you're not.

## License

This project is open source and available under the [MIT License](LICENSE).

## Privacy

Digital Dash prioritizes your privacy. While some network checks require external API calls, no personal data is collected or stored by the application itself. All information is displayed locally and is not retained or shared with third parties.

External services used:

1. IP Address Lookup: We use the ipify API (https://api.ipify.org) to determine your public IP address.
2. Geolocation: We use the ipapi service (https://ipapi.co) to determine your country and location information.
3. Speed Test: We use Cloudflare's speed test service (https://speed.cloudflare.com) for download and upload speed measurements.

These services are used solely for displaying real-time information and are not used to track or store your data. For more information on their privacy practices, please refer to their respective privacy policies:

- ipify Privacy Policy: https://www.ipify.org/privacy
- ipapi Privacy Policy: https://ipapi.co/privacy/
- Cloudflare Privacy Policy: https://www.cloudflare.com/privacypolicy/

All other functionalities, including home location comparison and network status monitoring, are performed locally on your device.

Please note that while we strive to use services that respect user privacy, we recommend reviewing the privacy policies of these third-party services for the most up-to-date information on their data handling practices.


## For Developers

### Build and Run

1. Clone the repository
2. Open the project in Xcode
3. Ensure you have the latest version of Xcode and macOS
4. Build and run the project (Cmd + R)

Note: The app is designed for macOS 13.0 and later.


