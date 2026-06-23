# Phase 1 Data Model: Status Bar Sleep Toggle

This app has no persistent datastore. "Entities" here are in-memory state holders and the OS-owned
login-item state. They map directly to the spec's Key Entities.

## Entity: Sleep Prevention State

The single source of truth for whether the keep-awake is active. Drives the status bar icon and
the menu toggle indicator.

| Field | Type | Description | Validation / Rules |
|-------|------|-------------|--------------------|
| `isPreventingSleep` | `Bool` | Whether sleep prevention is currently ON | Defaults to `false` at launch (FR-011 / assumption: starts OFF each launch). Changes only via explicit user toggle. |
| `assertionID` | `IOPMAssertionID?` | The active IOKit assertion handle, if any | Non-nil iff `isPreventingSleep == true`. At most one at a time (FR-012). Owned by `CaffeinateManager`, not exposed to UI. |

**Lifecycle / state transitions**:

```text
        toggle ON (activate)
 OFF ───────────────────────▶ ON
  ▲   create assertion, set ID   │
  │                              │
  └──────────────────────────────┘
        toggle OFF (deactivate)
     release assertion, clear ID

 Quit / terminate (from any state): if ON → release assertion → exit
 Re-entrancy: activate() while ON = no-op; deactivate() while OFF = no-op
```

**Invariants**:
- `isPreventingSleep == (assertionID != nil)` at all times.
- Never more than one live assertion (no stacking).
- On process exit, `assertionID` is released (explicitly on clean quit; kernel-released on crash).

## Entity: Launch-at-Login Preference

Whether the app is registered to start at login. Persisted and owned by the OS via `SMAppService`;
the app reads/writes it but does not store its own copy.

| Field | Type | Description | Validation / Rules |
|-------|------|-------------|--------------------|
| `isEnabled` (derived) | `Bool` | Whether the app is registered as a login item | Derived from `SMAppService.mainApp.status == .enabled`. Persists across restarts/reboots (FR-008). |

**Transitions**:

```text
 disabled ──register()──▶ enabled
 enabled  ─unregister()─▶ disabled
 (read SMAppService.mainApp.status to reflect current value in the menu checkmark)
```

**Error handling**: If `register()`/`unregister()` throws (e.g. user-approval required), the menu
toggle reflects the actual post-call `status` rather than an optimistic value; no crash.

## Relationships

- `AppState` (ObservableObject) owns the **Sleep Prevention State** (`@Published isPreventingSleep`)
  and delegates the assertion mechanics to `CaffeinateManager`.
- `AppState` also exposes the **Launch-at-Login Preference** by querying/mutating `LaunchAtLogin`
  (a thin `SMAppService` wrapper).
- `StatusMenuController` observes `AppState` to update the icon and menu item states; it never
  mutates state except in response to explicit user menu actions.
