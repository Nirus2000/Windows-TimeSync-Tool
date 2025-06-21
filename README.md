# Windows-TimeSync-Tool

A simple batch script to configure and synchronize the Windows system time using a custom NTP server.  
Supports Windows 7, 8, 10, and 11.

## Features

- Select from predefined NTP servers (PTB, Cloudflare, NIST, etc.)
- Or manually enter your own time server
- Automatically configures Windows Time Service (W32Time)
- Starts and repairs the service if needed
- Adjusts registry settings for synchronization
- Displays detailed system and sync information
- Fully standalone, no dependencies

## Requirements

- Windows 7 or newer
- Administrator rights

## How to Use

1. Download or clone the repository.
2. Right-click the batch file and select **"Run as administrator"**.
3. Choose a time server (or enter one manually).
4. The script configures the system and syncs the time immediately.

## Example Servers

- `ptbtime1.ptb.de` (Germany, Physikalisch-Technische Bundesanstalt)
- `time.cloudflare.com` (Cloudflare, global)
- `time.windows.com` (Microsoft default)
- `time.nist.gov` (NIST, USA)

## License

This project is open source and free to use under the MIT License.

## Author

Created and maintained by [Nirus2000](https://github.com/Nirus2000).
