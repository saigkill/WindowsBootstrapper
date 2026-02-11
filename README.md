# 🚀 Windows Bootstrap

![Logo](https://raw.githubusercontent.com/saigkill/WindowsBootstrapper/develop/Assets/WindowsBootstrapper.png
)

windows-bootstrap is a lightweight but powerful PowerShell framework designed to automate the complete setup of a new Windows machine.
It installs applications, applies system tweaks, manages package sources, downloads external tools, and even updates itself automatically.

Perfect for developers, power users, sysadmins, and anyone who regularly provisions Windows systems.

| W | W |
| --- | --- |
| Code | <https://dev.azure.com/saigkill/WindowsBootstrapper> |
| Language | ![Lang](https://img.shields.io/badge/PowerShell-7%2B-blue?logo=powershell) |
| OS | ![Windows](https://img.shields.io/badge/Windows-10%20%2F%2011-0078D6?logo=windows) |
| License | ![License](https://img.shields.io/badge/License-MIT-green) |
| Status | ![Status](https://img.shields.io/badge/Status-Active-success) |
| Maintained | ![Maintained](https://img.shields.io/badge/Maintained-Yes-brightgreen) |
| Continuous Integration Dev | [![Build status](https://dev.azure.com/saigkill/WindowsBootstrapper/_apis/build/status/WindowsBootstrapper-Dev)](https://dev.azure.com/saigkill/WindowsBootstrapper/_build/latest?definitionId=90) |
| Continuous Integration Prod | [![Build status](https://dev.azure.com/saigkill/WindowsBootstrapper/_apis/build/status/WindowsBootstrapper-Prod)](https://dev.azure.com/saigkill/WindowsBootstrapper/_build/latest?definitionId=92)|
| Bugreports | [![GitHub issues](https://img.shields.io/github/issues/saigkill/WindowsBootstrapper)](https://github.com/saigkill/WindowsBootstrapper/issues) |
| Downloads all | ![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/saigkill/WindowsBootstrapper/total) |
| Blog | [![Blog](https://img.shields.io/badge/Blog-Saigkill-blue)](https://saschamanns.de) |

File a bug report [on Github](https://github.com/saigkill/WindowsBootstrapper/issues).

## ✨ Features

* Modular architecture  
Clean separation between core utilities, installers, system tweaks, and auto‑update logic.

* JSON‑based configuration  
All apps and settings are defined in external config files.

* Environment support  
Automatically loads config.Development.json if present, otherwise falls back to config.json.

* Multiple package sources supported
  * Winget
  * Microsoft Store
  * Chocolatey
  * Scoop
  * External ZIP installers
  * External EXE installers
  * System tweaks
  * Explorer optimizations
  * Registry adjustments
  * Context menu enhancements
  * Dark mode
  * ShellBag cleanup
  * And more

* Self‑updating
The bootstrapper checks GitHub Releases and updates itself automatically.

* Unified logging
Consistent, structured logging across all modules.

## 📁 Project Structure

```text
windows-bootstrap/
│
├── bootstrap.ps1               # Main entry point
├── version.json                # Version for auto-update
│
├── config/
│   └── config.json             # Default configuration
│
├── modules/
│   ├── core.psm1               # Logging, config loading, utilities
│   ├── installers.psm1         # Winget, Store, Choco, Scoop, ZIP, EXE
│   ├── tweaks.psm1             # Windows tweaks and registry changes
│   └── update.psm1             # Auto-update logic
│
└── README.md
```

## 🚀 Getting Started

1. Download and extract the latest release on <https://github.com/saigkill/WindowsBootstrapper/releases/>
2. Modify the /config/config.json.
As Exsample:

```json
   {
    "WingetApps": [
       { "Id": "Google.Chrome", "Source": "winget" },
       { "Id": "Microsoft.PowerToys", "Source": "winget" }
    ],
    "StoreApps": [
       { "Id": "9WZDNCRFJ3PT", "Source": "msstore" }
    ]
  }
```

3. Run in Powershell `./bootstrap.ps1`

## 🔄 Auto‑Update

The bootstrapper automatically:

* Checks GitHub Releases
* Compares versions
* Downloads the latest bootstrapper
* Replaces itself
* Restarts automatically

## 🧩 Modules Overview

`core.psm1`

* Logging
* Config loader
* Utility functions

`installers.psm1`

* Winget installer
* Microsoft Store installer
* Chocolatey installer
* Scoop installer
* ZIP installer
* EXE installer

`tweaks.psm1`

* Explorer tweaks
* Registry optimizations
* Context menu additions
* Dark mode
* ShellBag cleanup

`update.psm1`

* Version detection
* GitHub API integration
* Self‑update logic

## 🛠 Requirements

* Windows 10 or Windows 11
* PowerShell 7+
* Administrator privileges
* Internet connection
