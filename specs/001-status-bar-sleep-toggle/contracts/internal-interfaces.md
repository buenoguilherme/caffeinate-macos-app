# Internal Interface Contracts: Status Bar Sleep Toggle

This is a self-contained desktop agent with no external/public API, no network endpoints, and no
IPC. The relevant contracts are the **internal Swift interfaces** between the dependency layers
(IOKit wrapper → state → UI), plus the **UI contract** (what the user sees in the status bar/menu)
and the **system contract** (Info.plist keys). These define the boundaries tasks must implement to.

## Layer 1 — `CaffeinateManager` (IOKit wrapper)

Owns the IOKit assertion. Knows nothing about UI or login items.

```swift
final class CaffeinateManager {
    /// True iff an assertion is currently held.
    var isActive: Bool { get }

    /// Create the keep-awake assertion (prevent idle system + display sleep).
    /// No-op if already active. Idempotent.
    func activate()

    /// Release the keep-awake assertion. No-op if not active. Idempotent.
    func deactivate()

    // deinit MUST release any held assertion (backstop for FR-010).
}
```

**Contract guarantees**:
- After `activate()`, `isActive == true` and exactly one IOKit assertion is held.
- After `deactivate()`, `isActive == false` and no assertion is held.
- `activate(); activate()` holds exactly one assertion (FR-012 — no stacking).
- `deinit` releases the assertion if held.

## Layer 2 — `AppState` (ObservableObject)

Bridges the manager + login item to the UI. The only writable state surface.

```swift
final class AppState: ObservableObject {
    @Published private(set) var isPreventingSleep: Bool   // mirrors CaffeinateManager.isActive

    var isLaunchAtLoginEnabled: Bool { get }              // derived from SMAppService status

    /// Flip sleep prevention; updates isPreventingSleep and drives the assertion.
    func toggleSleepPrevention()

    /// Register/unregister at login; tolerant of thrown errors (reflects real status).
    func setLaunchAtLogin(_ enabled: Bool)

    /// Called on app termination — releases assertion if active.
    func prepareForTermination()
}
```

**Contract guarantees**:
- `isPreventingSleep` defaults to `false` on init (starts OFF each launch).
- `isPreventingSleep == CaffeinateManager.isActive` at all times.
- Only `toggleSleepPrevention()` changes `isPreventingSleep`; no incidental menu action does
  (FR-011).

## Layer 3 — `LaunchAtLogin` (SMAppService wrapper)

```swift
enum LaunchAtLogin {
    static var isEnabled: Bool { get }     // SMAppService.mainApp.status == .enabled
    static func enable() throws            // SMAppService.mainApp.register()
    static func disable() throws           // SMAppService.mainApp.unregister()
}
```

## UI Contract — Status bar item & menu

The status bar item and menu MUST present:

| Element | Inactive (OFF) | Active (ON) |
|---------|----------------|-------------|
| Status bar icon | Outline coffee cup (template image) | Filled coffee cup, accent tint (FR-005) |
| Toggle menu item | "Prevent Sleep" — unchecked | "Prevent Sleep" — checked (FR-006) |
| "Launch at Login" item | Checkmark reflects `LaunchAtLogin.isEnabled` (FR-007) | (same) |
| Separator | — | — |
| "Quit Caffeinate" item | Calls terminate; releases assertion first (FR-009) | (same) |

**Behaviors**:
- Clicking the status bar icon opens the menu (FR-002).
- Selecting the toggle calls `AppState.toggleSleepPrevention()`; icon + checkmark update from the
  resulting `@Published` change.
- "Quit Caffeinate" → `AppState.prepareForTermination()` → `NSApp.terminate(nil)`.

## System Contract — Info.plist

| Key | Value | Requirement |
|-----|-------|-------------|
| `LSUIElement` | `YES` | No Dock icon, agent app (FR-001, Principle II) |
| `LSMinimumSystemVersion` | `13.0` | macOS 13.0 Ventura floor |
| (no network entitlements / ATS exceptions) | — | Offline only (FR-013, Principle V) |
