# Changelog

All notable changes to Caffeinate are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-06-23

### Added

- One-click menu-bar toggle to prevent idle system and display sleep, backed by
  an IOKit `PreventUserIdleSystemSleep` + `NoDisplaySleep` power assertion.
- Status icon reflects state at a glance: filled coffee cup when active, outline when off.
- **Launch at Login** option via `SMAppService` (macOS 13+).
- Clean quit that releases the keep-awake assertion immediately on exit.
- Menu-bar-only agent (`LSUIElement`) — no Dock icon, no window.
- Fully offline: no network, analytics, or telemetry. Apple SDK only, no third-party dependencies.

[Unreleased]: https://github.com/buenoguilherme/caffeinate-macos-app/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/buenoguilherme/caffeinate-macos-app/releases/tag/v1.0.0
