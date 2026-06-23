# Quickstart & Validation Guide: Status Bar Sleep Toggle

How to build, run, and validate that the feature works end-to-end. Implementation details live in
`tasks.md` and the source files; this is a run/verify guide.

## Prerequisites

- macOS 13.0 Ventura or later
- Xcode 15+ (Swift 5.9+)
- No third-party tooling or package manager (Apple SDK only)

## Build & run

```sh
# Open in Xcode
open Caffeinate.xcodeproj

# Or build/run from the command line
xcodebuild -project Caffeinate.xcodeproj -scheme Caffeinate -configuration Debug build
# then launch the built .app, or press ⌘R in Xcode
```

On launch: a coffee-cup icon appears in the status bar, **no Dock icon**, **no window**.

## Validation scenarios

Map directly to the spec's user stories and success criteria.

### US1 — Keep the Mac awake (P1)
1. Click the status bar coffee-cup icon → menu opens.
2. Click **Prevent Sleep** → item becomes checked, icon switches to the filled/accented cup.
3. Temporarily set a short idle sleep in System Settings → Lock Screen / Battery (e.g. 1 min),
   leave the Mac idle past it.
   - **Expected**: neither the system nor the display sleeps (FR-003, SC-002).
4. Click **Prevent Sleep** again → unchecked, icon returns to outline; Mac sleeps normally (FR-004).

### US2 — State at a glance (P2)
- Toggle ON/OFF and confirm the icon is clearly different without opening the menu (FR-005, SC-004).
- With the menu open, the toggle shows a checkmark only when ON (FR-006).

### US4 — Quit releases the keep-awake (P2)
1. Toggle **Prevent Sleep** ON.
2. Choose **Quit Caffeinate**.
   - **Expected**: app exits; status bar icon disappears.
3. Leave the Mac idle past the sleep timeout → it sleeps normally (FR-009/FR-010, SC-003).
4. Verify no lingering assertion:
   ```sh
   pmset -g assertions    # should show no Caffeinate-owned PreventUserIdle* assertion
   ```

### US3 — Launch at Login (P3)
1. Open menu → toggle **Launch at Login** ON (checkmark appears).
2. Log out and back in (or reboot).
   - **Expected**: the coffee-cup icon appears automatically (FR-007/FR-008, SC-005).
3. Toggle **Launch at Login** OFF → it no longer auto-starts.
   - Confirm registration state:
   ```sh
   # Login item shows under System Settings → General → Login Items,
   # or check the app's SMAppService status in a debug log line.
   ```

### Edge cases to spot-check
- Rapidly toggle ON/OFF several times → final state matches the icon; `pmset -g assertions` shows
  at most one Caffeinate assertion when ON, none when OFF (FR-012).
- Force-quit the app (Activity Monitor) while ON → `pmset -g assertions` shows the assertion gone
  (kernel auto-release); Mac sleeps normally.

### Privacy / constitution check
```sh
# While running and toggling, confirm zero network activity (FR-013, Principle V):
nettop -p "$(pgrep Caffeinate)"     # no connections expected
```
Also confirm in code review: no analytics SDKs, no network entitlements in Info.plist.

## Unit tests

```sh
xcodebuild test -project Caffeinate.xcodeproj -scheme Caffeinate -destination 'platform=macOS'
```
Covers `CaffeinateManager` activate/deactivate idempotency and the no-stacking invariant.
