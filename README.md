# Windows-TimeSync-Tool

**Author:** [Nirus2000 on GitHub](https://github.com/Nirus2000)  
**License:** MIT (Open Source)  
**Version:** 1.0  
**Supported OS:** Windows 7 / 8 / 10 / 11  
**Language:** Batch (`.bat`)

---

## Description

This batch script allows administrators and technicians to configure and synchronize the Windows system time using a specified NTP server. It adjusts registry settings and service configurations to ensure proper synchronization with selected or custom time servers.

Ideal for environments where accurate system time is essential, such as labs, test setups, embedded devices, or domain-independent systems.

---

## Features

- Compatible with Windows 7 to Windows 11  
- Choose from predefined NTP servers or enter a custom one  
- Verifies and configures the Windows Time Service (W32Time)  
- Automatically starts and repairs the service if needed  
- Sets sync intervals and service behavior  
- Displays detailed network and system sync info  
- Fully portable – no installation required

---

## Usage Instructions

1. Right-click the script file and select  
   **“Run as administrator”**.

2. Choose a time server from the list or enter a custom one manually.

3. The script applies configuration changes and immediately synchronizes the system time.

---

## Example Servers

- `ptbtime1.ptb.de` (Germany, Physikalisch-Technische Bundesanstalt)  
- `time.cloudflare.com` (Cloudflare, global)  
- `time.windows.com` (Microsoft default)  
- `time.nist.gov` (NIST, USA)

---

## License

This project is open source and free to use under the MIT License.

---

## Author

Created and maintained by [Nirus2000](https://github.com/Nirus2000).
