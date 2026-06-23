# Phase 0 Research: Status Bar Sleep Toggle

No open `NEEDS CLARIFICATION` items remained from the spec or Technical Context. This document
records the key technical decisions and the alternatives considered, so the design is traceable.

## 1. Sleep-prevention mechanism

**Decision**: Use IOKit `IOPMAssertionCreateWithName` with assertion type
`kIOPMAssertPreventUserIdleSystemSleep` to prevent idle system sleep, and additionally hold
`kIOPMAssertPreventUserIdleDisplaySleep` to keep the display awake. Release with
`IOPMAssertionRelease` and store the returned `IOPMAssertionID`.

**Rationale**: Constitution Principle IV mandates the native IOKit API rather than spawning the
`caffeinate` binary. Spec FR-003 requires preventing *both* idle system sleep *and* idle display
sleep, which maps to the two assertion types above. Display assertion implies system stays awake,
but holding both makes intent explicit and robust.

**Alternatives considered**:
- Shelling out to `/usr/bin/caffeinate` — rejected by constitution (subprocess fragility,
  process management, security surface).
- `kIOPMAssertionTypePreventSystemSleep` (prevents sleep even on AC/battery transitions) —
  rejected; it is heavier and intended for system-level work, not user idle prevention.

**Implementation notes**: One assertion ID held at a time (FR-012). `activate()` is a no-op if
already active; `deactivate()` releases and clears the ID; idempotent in both directions.

## 2. No Dock icon / menu-bar-only

**Decision**: Set `LSUIElement = YES` (Application is agent) in `Info.plist`. Use `NSStatusItem`
from `NSStatusBar.system` for the menu bar presence. No `WindowGroup` / no windows.

**Rationale**: Constitution Principle II. `LSUIElement` removes the Dock icon and app menu bar
while keeping the process able to own a status item and respond to events.

**Alternatives considered**: Calling `NSApp.setActivationPolicy(.accessory)` at runtime — works,
but `LSUIElement` in Info.plist is declarative, applies from launch (no Dock flash), and is the
constitution-aligned choice. We may still set `.accessory` defensively in code.

## 3. SwiftUI vs AppKit for the entry point

**Decision**: SwiftUI `App` with `@main` and an `NSApplicationDelegateAdaptor`, but the UI is
built entirely with AppKit (`NSStatusItem` + `NSMenu`) inside the delegate/controller. No
`WindowGroup` or `Settings` scene is declared (or an empty scene is used) so no window appears.

**Rationale**: User input specifies a SwiftUI app. The status-bar menu is best served by AppKit's
`NSMenu` (reliable, native menu behavior, lightweight). Mixing is standard and keeps the binary
small (Principle III). `@Published` state from an `ObservableObject` drives icon updates.

**Alternatives considered**:
- Pure SwiftUI `MenuBarExtra` (macOS 13+) — viable and very simple, but gives less control over
  the template-image icon swap and menu item states than `NSStatusItem`/`NSMenu`, and the user
  explicitly asked for `NSStatusItem + NSMenu`. Deferred; could be a future simplification.
- Pure AppKit `@NSApplicationMain` — fine, but user asked for a SwiftUI app shell.

## 4. Launch at Login

**Decision**: Use `SMAppService.mainApp.register()` / `.unregister()`; read current state via
`SMAppService.mainApp.status` to reflect the toggle's checkmark. Handle thrown errors by leaving
the toggle in its prior state and not crashing.

**Rationale**: `SMAppService` is the modern (macOS 13+) replacement for the deprecated
`SMLoginItemSetEnabled` / login-item helper bundles. Matches the constitution's macOS 13.0 floor
and avoids an embedded helper app (Principle III).

**Alternatives considered**: `SMLoginItemSetEnabled` + helper login item — deprecated, requires a
bundled helper target, heavier. Rejected.

## 5. Releasing the assertion on termination

**Decision**: Release the assertion in `applicationWillTerminate(_:)` on the `AppDelegate`, and
also in `CaffeinateManager.deinit` as a backstop. The "Quit Caffeinate" menu item calls
`NSApp.terminate(nil)`, which triggers `applicationWillTerminate`.

**Rationale**: Spec FR-009/FR-010 require the keep-awake to never outlive the process. The OS
also auto-releases IOKit assertions when the owning process dies (kernel-tracked), which covers
crash/force-quit; the explicit release covers clean quit and makes intent verifiable.

**Alternatives considered**: Relying solely on kernel auto-release — works for crashes but is not
explicit for clean quit and is harder to assert in tests; we do both.

## 6. Icon states

**Decision**: Two template images in `Assets.xcassets` — inactive (outline cup) and active
(filled cup). Swap `NSStatusItem.button.image` when `@Published isPreventingSleep` changes. Use
SF Symbols (`cup.and.saucer` / `cup.and.saucer.fill`) or custom template PDFs; render the active
state with an accent tint while keeping menu-bar light/dark adaptivity.

**Rationale**: FR-005 requires a glanceable visual difference. Template images adapt to menu bar
appearance automatically; an accent tint on the active state gives the "filled, accented"
distinction the user described.

**Alternatives considered**: Single image with opacity change — too subtle, would fail SC-004
(95% glance recognition). Text label in the status item — clutters the menu bar; rejected.
