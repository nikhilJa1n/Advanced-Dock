# <img src="screenshots/app_icon.jpg" width="48" height="48" align="center" style="border-radius:10px; margin-right:10px; box-shadow: 0 4px 12px rgba(0,0,0,0.15);" /> AdvancedDock

[![Platform](https://img.shields.io/badge/platform-macOS%2014.0%2B-blue.svg?style=flat-square)](https://apple.com)
[![Language](https://img.shields.io/badge/language-Swift%205.9-orange.svg?style=flat-square)](https://swift.org)
[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat-square)](LICENSE)
[![Build Status](https://img.shields.io/badge/build-passing-brightgreen.svg?style=flat-square)](.github/workflows/build.yml)

**AdvancedDock** is a premium, open-source macOS utility that redefines window switching and dock interactions. It replaces the default macOS app switcher and dock behaviors with a modern, glassmorphic HUD panel featuring a clean flat card list layout, live CPU/RAM host telemetry tracking, and interactive dock hover window previews.

Built natively in Swift and SwiftUI, AdvancedDock runs as a highly efficient background agent that overlays seamlessly across all workspaces and full-screen spaces.

> [!NOTE]
> AdvancedDock operates as a background element (`LSUIElement = true`), meaning it stays out of your active Dock space, stays lightweight, and doesn't steal focus while you are working.

---

## 🌟 Key Features

### 1. Smart App Switcher (`⌥ + Tab`)
*   **Quick Switch**: Hold `⌥ (Option)` and tap `Tab` to cycle between windows. Release `⌥` to switch immediately.
*   **Tracked MRU Sorting**: The default "Recently Used" layout is sorted by your custom tracked MRU history (`mruWindowIDs`). This guarantees that recently used windows always show up first, preventing lag or incorrect window order shuffling caused by the OS Window Server.
*   **Grid Layout Mode**: Toggle between standard horizontally paginated single row switcher (5 columns) and a dynamic 2D multi-row grid switcher (4 columns). Grid mode dynamically adjusts window dimensions, centers items, and aligns columns cleanly on the final row using layout placeholders.
*   **Dynamic Arrow Navigation**: Cycle through card highlights using Left (←) / Right (→) or Up (↓) / Down (↑) arrow keys, with grid boundaries adjusting automatically depending on the active layout mode.
*   **Window Cards & Thumbnails**: Real-time window preview cards featuring app-badge icons. Drag a card upwards to close the window instantly. (Hover highlights have been removed to ensure selection changes only occur via deliberate keyboard controls or mouse clicks).
*   **Aero Action Panel**: Quick window controls directly from the card (Close, Minimize, Maximize, Exit Full-Screen, Force Quit).
*   **Window Snapping**: Snap windows to the left half, right half, or maximize them instantly with one click.

### 2. Interactive Dock Previews
*   Hover over any active Dock icon to see real-time floating thumbnails of that application's open windows.
*   **App Header**: Displays the application name, icon, and the total count of open windows.
*   **Smart Grid Layout**: Arranges thumbnails dynamically in a multi-column wrapping grid (up to 3 columns) when multiple windows are open, preventing the panel from stretching offscreen.
*   Select, close, or snap windows directly from the dock hover preview panel.
*   **Customizable Sizing**: Adjust the dock hover preview thumbnail size independently from 70% to 200% using a dedicated slider in the Control Panel settings.

### 3. Personalization & Control
*   **Segmented Control Panel Dashboard**: Fully redesigned tabbed navigation separating General settings, Dock Previews, Hotkeys & Exclusions, Diagnostics, and Help.
*   **App Snapping Presets (Grid Manager)**: Instantly snap all open windows of any running application into a clean layout: *2x2 Grid*, *3-Column Split*, or *70/30 Split* via the General Preferences dashboard.
*   **Customizable Hotkeys**: Record your own global activation shortcut (e.g. `⌥ + Space` or `⌘ + Tab`) via the settings shortcut recorder.
*   **App Exclusions Blocklist & Search**: Filter and exclude running applications from showing up in the switcher HUD cycle.
*   **Adjustable Dock Preview Delay**: Defer hover previews using a slider setting (0.1s to 1.5s) to prevent accidental overlays.
*   **System Diagnostics & Telemetry**: Monitor real-time CPU and RAM utilization directly inside the Diagnostics tab with sleek linear meters.
*   **Settings Factory Reset**: Restore the entire app to pristine native configurations with a single click.
*   **Modern ScreenCaptureKit & AppleScript Previews**: Uses Apple's modern, performant `ScreenCaptureKit` API for capturing window thumbnails, and incorporates an AppleScript fallback activation for all applications (including Chrome and Notes) when standard AX window raising fails.
*   **Live Resource Widget**: Real-time glassmorphic CPU and RAM statistics monitor located in the top-right corner of the switcher HUD.

---

## 📸 Preview & Aesthetics

The interface is built with native macOS visual effects (frosted glass) and premium transitions to ensure it looks and feels like a native part of macOS:

### 1. App Switcher HUD

![AdvancedDock Switcher HUD](screenshots/switcher_hud.png)

### 2. Control Panel & Preferences Dashboard

AdvancedDock includes a comprehensive 5-tab Control Panel dashboard to configure settings, review telemetry, and monitor system permissions:

*   **General Preferences**: Customize arrow navigation, hover switching, window sorting, card scaling, and trigger grid snapping presets.
*   **Dock Previews**: Adjust sizing scale and activation delays (0.1s to 1.5s).
*   **Hotkeys & Exclusions**: Record custom shortcuts and manage cycle exclusions with active search filtering.
*   **System Diagnostics**: View real-time CPU/RAM meters, review accessibility/screen recording grants, and test key modifiers.
*   **How to Use**: Reference helper guides and keyboard shortcut legends.

---

## ⌨️ Control & Shortcuts Guide

| Action | Shortcut / Gesture |
| :--- | :--- |
| **Open Switcher / Cycle Forward** | `⌥ + Tab` |
| **Cycle Backward** | `⌥ + ⇧ + Tab` (Option + Shift + Tab) |
| **Arrow Key Navigation** | `←` / `→` or `↑` / `↓` |
| **Select Highlighted Window** | Release `⌥` (or press `Space` / `Enter` if pinned) |
| **Cancel & Dismiss** | Press `⎋ (Esc)` |
| **Close Window (Gesture)** | Drag the window card upwards and release |
| **Trigger Snapping** | Hover over card, click a layout button in the action panel |

---

## ⚙️ System Requirements & Permissions

*   **Operating System**: macOS 14.0 (Sonoma) or newer.
*   **Permissions Required**:

> [!WARNING]
> Due to macOS sandbox restrictions, the following permissions must be explicitly granted on the first launch for the app to function:

1.  **Accessibility**: Required to retrieve window titles, control windows (minimize, close, maximize), and perform window snapping.
2.  **Screen Recording (Screen Capture)**: Required to capture real-time window thumbnails and previews. *(No screen data is saved, uploaded, or transmitted; previews are generated strictly locally in-memory).*

---

## 🏗️ Technical Architecture & Under-the-Hood

AdvancedDock is engineered for speed, low energy impact, and seamless macOS integration:
- **`HotkeyManager`**: Uses a low-level Cocoa `CGEventTap` to intercept `⌥ + Tab` keystrokes globally without blocking the system's event dispatch queue.
- **`WindowList`**: Queries window states using the macOS Accessibility API (`AXUIElement`) and bridges them with the CoreGraphics Window List (`CGWindowListCopyWindowInfo`).
- **`ScreenCaptureKit` / `CGWindowListCreateImage`**: Captures fast, hardware-accelerated window thumbnails on demand, caching them efficiently to prevent high RAM/CPU usage.
- **`SwitcherWindow`**: A custom `NSPanel` subclass configured as a `.nonactivatingPanel` with a status bar level to overlay over active spaces and full-screen spaces.

---

## 🛠️ Build & Installation

### Prerequisites
*   Xcode 15.0 or newer (specifically `swift` compiler tools version 5.9+).
*   A self-signed or developer certificate named `AdvancedDockDeveloper` to code-sign the app (required for Screen Capture API permissions).

### Building from Source

To compile, package, and install AdvancedDock into your Applications folder:

1.  Clone the repository:
    ```bash
    git clone https://github.com/yourusername/AdvancedDock.git
    cd AdvancedDock
    ```

2.  Run the build, signing, and packaging script:
    ```bash
    chmod +x build.sh
    ./build.sh
    ```

This compiles the release binary, signs it, and packages it into a ready-to-distribute compressed disk image: **`AdvancedDock.dmg`**.

3.  Double-click **`AdvancedDock.dmg`** and drag-and-drop the application into your **Applications** folder to install it.

### Publishing Releases

AdvancedDock includes a fully automated and idempotent release publisher script (`release.sh`) that manages tags, commits, updates version config files, and publishes assets directly to GitHub Releases.

#### Prerequisites
*   A **GitHub Personal Access Token (PAT)** with `repo` scope.

#### Publishing Steps
1.  Run the release script:
    ```bash
    chmod +x release.sh
    ./release.sh
    ```
2.  Enter your GitHub PAT when prompted (or pass it directly via environment variable: `GITHUB_TOKEN=your_pat ./release.sh`).

#### What the script automates:
*   **Version Bumping**: Automatically writes release info to `update.json`.
*   **Git Lifecycle**: Bumps commits, tags the commit locally, pushes `main`, and force-pushes the release tag (`v$VERSION`) to ensure the tag points to the final release commit.
*   **Self-Healing / Idempotency**: If the release tag already exists on GitHub, the script fetches the existing release, queries the release assets, deletes any attached `AdvancedDock.dmg` asset, and uploads the fresh package without throwing errors.

---

## 🛡️ License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

## 🤝 Contributing

Contributions are welcome! Please feel free to open Issues or submit Pull Requests to help improve AdvancedDock.
