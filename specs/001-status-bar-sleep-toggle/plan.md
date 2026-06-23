# Implementation Plan: Status Bar Sleep Toggle

**Branch**: `001-status-bar-sleep-toggle` | **Date**: 2026-06-23 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-status-bar-sleep-toggle/spec.md`

## Summary

Caffeinate is a menu-bar-only macOS app that prevents idle system and display sleep. The
primary requirement: a user toggles sleep prevention ON/OFF from a coffee-cup status bar icon,
the icon reflects state, and the keep-awake is always released on quit. Technical approach: a
layered Swift/AppKit app with an `LSUIElement` agent process — a thin IOKit wrapper
(`CaffeinateManager`) at the bottom, an `@Published` observable state holder in the middle, and
an `NSStatusItem` + `NSMenu` UI on top. Launch-at-Login uses `SMAppService.mainApp`. Built
bottom-up: IOKit wrapper → state → UI.

## Technical Context

**Language/Version**: Swift 5.9+ (Xcode 15+)

**Primary Dependencies**: Apple SDK only — AppKit (`NSStatusItem`, `NSMenu`), IOKit power
management (`IOPMAssertionCreateWithName` / `IOPMAssertionRelease`), ServiceManagement
(`SMAppService`). No third-party packages (constitution Principle III).

**Storage**: N/A. Sleep-prevention state is in-memory only (resets to OFF each launch).
Launch-at-Login state is owned by the OS via `SMAppService` (no app-managed persistence file).

**Testing**: XCTest for unit tests of `CaffeinateManager` and state logic; manual verification
per `quickstart.md` for status-bar/no-Dock/sleep behavior (UI-less agent makes automated UI
tests low-value for v1).

**Target Platform**: macOS 13.0 Ventura and later.

**Project Type**: Native macOS desktop app (menu-bar agent, single target).

**Performance Goals**: Negligible idle footprint — no work while idle beyond holding one IOKit
assertion and rendering the menu (constitution Principle III). Toggle reflects in the icon
effectively instantly (<100ms perceived).

**Constraints**: No Dock icon, no windows (`LSUIElement = YES`). Offline only — zero network,
analytics, telemetry. At most one IOKit assertion active at any time; assertion never outlives
the process.

**Scale/Scope**: Single-user, single-machine utility. ~5 source files, one menu with ~4 items
(toggle, Launch at Login, separator, Quit).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Compliance | Notes |
|-----------|-----------|-------|
| I. Simplicity for Non-Engineers | ✅ PASS | One menu, ON/OFF toggle as primary action; plain-language items, no setup. |
| II. Menu Bar Only | ✅ PASS | `LSUIElement = YES`; `NSStatusItem` only; no windows, no Dock icon. |
| III. Lightweight & Dependency-Minimal | ✅ PASS | Apple frameworks only; no third-party deps; idle = one assertion + menu. |
| IV. Native Sleep Prevention (IOKit) | ✅ PASS | `IOPMAssertionCreateWithName`/`Release`; no `caffeinate` subprocess. |
| V. Privacy by Default | ✅ PASS | No network, analytics, or telemetry; fully offline. |
| Technology & Platform Constraints | ✅ PASS | Swift, macOS 13.0 target, `.dmg` distribution, `SMAppService` (13+). |

**Result**: PASS — no violations. Complexity Tracking not required.

## Project Structure

### Documentation (this feature)

```text
specs/001-status-bar-sleep-toggle/
├── plan.md              # This file
├── spec.md              # Feature specification
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output (internal interface contracts)
│   └── internal-interfaces.md
└── checklists/
    └── requirements.md
```

### Source Code (repository root)

```text
Caffeinate.xcodeproj/                 # Xcode project
Caffeinate/
├── CaffeinateApp.swift               # @main App entry; sets up AppDelegate, no WindowGroup
├── AppDelegate.swift                 # NSApplicationDelegate; status item lifecycle;
│                                     #   applicationWillTerminate releases assertion
├── CaffeinateManager.swift           # IOKit wrapper: activate()/deactivate(), isActive
├── AppState.swift                    # ObservableObject; @Published isPreventingSleep;
│                                     #   bridges manager + login + UI
├── LaunchAtLogin.swift               # SMAppService.mainApp register/unregister + status
├── StatusMenuController.swift        # NSStatusItem + NSMenu construction & actions
├── Assets.xcassets/
│   └── StatusIcons (cup.outline, cup.filled as template/symbol images)
└── Info.plist                        # LSUIElement = YES, LSMinimumSystemVersion = 13.0

CaffeinateTests/
└── CaffeinateManagerTests.swift      # Unit tests: activate/deactivate idempotency, no-stack
```

**Structure Decision**: Single native macOS app target plus a unit-test target. Files map 1:1
to the dependency layers (IOKit wrapper → state → UI + lifecycle), matching the user's
bottom-up build order. No `src/models|services|cli` web-style layout — this is a small desktop
agent, so a flat per-responsibility file layout under `Caffeinate/` is the simplest fit
(constitution Principle III).

## Complexity Tracking

> No constitution violations. Section intentionally empty.
