# Caffeinate

A tiny macOS menu-bar app that keeps your Mac awake with one click — no Dock icon, no window, no nonsense.

## Features

- **One-click toggle** — prevent idle system and display sleep from the menu bar
- **Status at a glance** — filled cup icon when active, outline when off
- **Launch at Login** — optionally start automatically on login via `SMAppService`
- **Clean quit** — releases the keep-awake assertion immediately on exit
- **Zero network** — fully offline, no analytics or telemetry of any kind
- **Lightweight** — a single menu-bar agent; Apple SDK only, no third-party dependencies

## Requirements

- macOS 13.0 Ventura or later

## Installation

### Option 1 — Download (recommended)

1. Go to the [Releases](../../releases) page.
2. Download the latest `Caffeinate.dmg`.
3. Open the `.dmg`, drag **Caffeinate.app** to your Applications folder.
4. Launch it — a coffee-cup icon appears in the menu bar.

> **First launch note:** macOS may show a Gatekeeper prompt since the app is distributed outside the App Store. Go to **System Settings → Privacy & Security** and click **Open Anyway**.

### Option 2 — Build from source

**Prerequisites:** Xcode 15+ (Swift 5.9+)

```sh
git clone https://github.com/buenoguilherme/caffeinate-macos-app.git
cd caffeinate-macos-app
open Caffeinate.xcodeproj
```

Press **⌘R** in Xcode to build and run, or use the command line:

```sh
xcodebuild -project Caffeinate.xcodeproj \
  -scheme Caffeinate \
  -configuration Release \
  build
```

Run the unit tests:

```sh
xcodebuild test -project Caffeinate.xcodeproj \
  -scheme Caffeinate \
  -destination 'platform=macOS'
```

See [`BUILD.md`](BUILD.md) for signing, notarization, and packaging a distributable `.dmg`.

## Usage

1. Launch **Caffeinate.app** — a coffee-cup icon appears in the menu bar.
2. Click the icon to open the menu.
3. Click **Prevent Sleep** to toggle the keep-awake on or off.
4. Optionally enable **Launch at Login** so the app starts automatically.
5. Click **Quit Caffeinate** (or Cmd+Q) to exit — the keep-awake is released immediately.

## How it works

Caffeinate uses [`IOPMAssertionCreateWithName`](https://developer.apple.com/documentation/iokit/1557134-iopmassertioncreatewitname) from Apple's IOKit framework to hold a `PreventUserIdleSystemSleep` + `NoDisplaySleep` assertion while active. No subprocess, no shell commands — just a native power assertion that the kernel releases automatically if the app ever crashes.

Launch at Login is handled by [`SMAppService`](https://developer.apple.com/documentation/servicemanagement/smappservice) (macOS 13+).

## License

MIT — see [`LICENSE`](LICENSE).
