# Caffeinate

A menu-bar app for macOS that keeps your Mac awake with one click.

![Status bar toggle demo](docs/screenshot.png)

## What it does

Click the coffee-cup icon in the menu bar to toggle sleep prevention on or off.
When active, the Mac will not idle-sleep or dim the display. Toggle off to
restore normal sleep behavior. Quit cleanly releases the keep-awake assertion
immediately.

## Features

- **Prevent Sleep** — toggle idle system and display sleep on/off
- **Launch at Login** — optionally start automatically at login via `SMAppService`
- **No Dock icon, no window** — lives entirely in the menu bar
- **Zero network** — fully offline; no analytics or telemetry

## Requirements

- macOS 13.0 Ventura or later
- Xcode 15+ (Swift 5.9+) to build from source

## Usage

1. Launch `Caffeinate.app`
2. Click the coffee-cup icon in the menu bar
3. Select **Prevent Sleep** to toggle the keep-awake on or off

See `BUILD.md` for how to build, sign, and distribute the app.
