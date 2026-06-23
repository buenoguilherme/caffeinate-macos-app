# Feature Specification: Status Bar Sleep Toggle

**Feature Branch**: `001-status-bar-sleep-toggle`

**Created**: 2026-06-23

**Status**: Draft

**Input**: User description: "Caffeinate macOS status bar app — coffee cup status bar icon with no Dock presence, ON/OFF toggle for sleep prevention, icon reflects state, prevents idle and display sleep, Launch at Login toggle, Quit menu item that releases the keep-awake before exiting, state persists while running."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Keep the Mac awake with one click (Priority: P1)

A user wants to stop their Mac from going to sleep (e.g. during a download, presentation, or
long-running task). They click the coffee cup icon in the status bar, choose to turn sleep
prevention ON, and the system stays awake — both the computer and the display — until they
turn it OFF again.

**Why this priority**: This is the entire reason the app exists. Without it there is no
product. It is the minimum viable slice that delivers value on its own.

**Independent Test**: With the app running, open the status bar menu, toggle sleep prevention
ON, leave the Mac idle past its normal sleep timeout, and confirm it does not sleep; toggle
OFF and confirm normal sleep resumes.

**Acceptance Scenarios**:

1. **Given** the app is running and sleep prevention is OFF, **When** the user selects the
   toggle in the menu, **Then** sleep prevention becomes ON and the system will not idle-sleep
   or display-sleep.
2. **Given** sleep prevention is ON, **When** the user selects the toggle again, **Then** sleep
   prevention becomes OFF and the system returns to its normal sleep behavior.
3. **Given** sleep prevention is ON, **When** the Mac remains idle past its configured sleep
   timeout, **Then** neither the system nor the display sleeps.

---

### User Story 2 - See the current state at a glance (Priority: P2)

A user wants to know, without opening the menu, whether sleep prevention is currently active.
The coffee cup icon in the status bar looks visibly different when ON versus OFF.

**Why this priority**: Confidence that the toggle worked is essential for trust, but the core
keep-awake function (P1) technically works without it. It is the next most important slice.

**Independent Test**: Toggle sleep prevention ON and OFF and confirm the status bar icon
changes appearance to reflect each state without opening the menu.

**Acceptance Scenarios**:

1. **Given** sleep prevention is OFF, **When** the user views the status bar, **Then** the icon
   shows the inactive appearance.
2. **Given** sleep prevention is ON, **When** the user views the status bar, **Then** the icon
   shows the active appearance distinct from the inactive one.
3. **Given** the menu is open, **When** the user views the toggle item, **Then** it clearly
   indicates the current ON/OFF state (e.g. a checkmark or label).

---

### User Story 3 - Start automatically at login (Priority: P3)

A user who relies on the app regularly wants it to be available every time they log in,
without launching it manually. They enable a "Launch at Login" option from the menu.

**Why this priority**: A convenience that improves retention and daily usefulness, but the app
is fully functional when launched manually, so it ranks below core behavior and state display.

**Independent Test**: Enable "Launch at Login", log out and back in (or restart), and confirm
the app's status bar icon appears automatically; disable it and confirm it no longer
auto-starts.

**Acceptance Scenarios**:

1. **Given** "Launch at Login" is disabled, **When** the user enables it, **Then** the app is
   registered to start at the next login.
2. **Given** "Launch at Login" is enabled, **When** the user logs in, **Then** the app starts
   automatically and appears in the status bar.
3. **Given** "Launch at Login" is enabled, **When** the user disables it, **Then** the app no
   longer starts automatically at login.

---

### User Story 4 - Quit cleanly without leaving the Mac awake (Priority: P2)

A user is done and wants to close the app. They choose "Quit Caffeinate" from the menu. The app
exits and the Mac returns to its normal sleep behavior — it does not remain stuck awake.

**Why this priority**: A keep-awake utility that leaves the system awake after quitting is a
correctness and trust defect; releasing the keep-awake on quit is required for the app to be
considered correct.

**Independent Test**: Turn sleep prevention ON, choose "Quit Caffeinate", then leave the Mac
idle and confirm it sleeps normally (the keep-awake was released).

**Acceptance Scenarios**:

1. **Given** the app is running with sleep prevention ON, **When** the user chooses "Quit
   Caffeinate", **Then** the keep-awake is released and the app exits.
2. **Given** the app has quit, **When** the Mac is left idle past its sleep timeout, **Then**
   the system sleeps normally.

---

### Edge Cases

- **Quit while OFF**: If the user quits while sleep prevention is OFF, the app exits cleanly with
  no lingering effect on system sleep.
- **Unexpected termination**: If the app is force-quit or crashes while ON, the keep-awake must
  not outlive the app process; the system must return to normal sleep behavior.
- **Repeated/rapid toggling**: Toggling ON/OFF repeatedly must always converge to the displayed
  state, with at most one keep-awake active at a time (no stacking).
- **System-initiated sleep**: When sleep prevention is OFF, manual sleep (closing the lid, Apple
  menu → Sleep) must still work normally; the app only prevents *idle/automatic* sleep when ON.
- **Display sleep vs system sleep**: When ON, both idle system sleep and display sleep are
  prevented while the app is running.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The app MUST present a coffee-cup icon in the macOS status bar (menu bar) whenever
  it is running, with no Dock icon and no application windows.
- **FR-002**: The app MUST provide a menu, opened from the status bar icon, containing a toggle
  to turn sleep prevention ON or OFF.
- **FR-003**: When sleep prevention is ON, the app MUST prevent both idle system sleep and idle
  display sleep for as long as it remains ON and the app is running.
- **FR-004**: When sleep prevention is OFF, the app MUST allow the system to follow its normal
  sleep behavior.
- **FR-005**: The status bar icon MUST visually distinguish the ON state from the OFF state so
  the user can determine the current state without opening the menu.
- **FR-006**: The menu MUST clearly indicate the current ON/OFF state of sleep prevention.
- **FR-007**: The app MUST provide a "Launch at Login" toggle that registers or unregisters the
  app to start automatically when the user logs in.
- **FR-008**: The "Launch at Login" setting MUST persist across app restarts and reboots.
- **FR-009**: The app MUST provide a "Quit Caffeinate" menu item that releases any active
  keep-awake before the process exits.
- **FR-010**: The app MUST ensure no keep-awake outlives the app process, including on normal
  quit and on unexpected termination.
- **FR-011**: The ON/OFF sleep-prevention state MUST persist for the lifetime of the running app
  and MUST change only when the user explicitly toggles it; opening or closing the menu and
  selecting non-toggle items MUST NOT change it.
- **FR-012**: At most one keep-awake MUST be active at any time, regardless of how many times the
  user toggles.
- **FR-013**: The app MUST operate fully offline with no network calls, analytics, or telemetry.

### Key Entities

- **Sleep Prevention State**: Represents whether the keep-awake is currently active (ON/OFF).
  In-memory for the running session; the source of truth for both the icon appearance and menu
  indicator.
- **Launch-at-Login Preference**: Represents whether the app is registered to start at login.
  Persisted across restarts and reboots.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A first-time user can turn sleep prevention ON within 10 seconds of seeing the
  status bar icon, using a single menu interaction.
- **SC-002**: When sleep prevention is ON, the Mac stays awake through 100% of idle periods that
  exceed its normal sleep timeout, until the user turns it OFF.
- **SC-003**: After quitting the app, the Mac resumes normal sleep behavior 100% of the time
  (no lingering keep-awake).
- **SC-004**: A user can correctly identify whether sleep prevention is ON or OFF by glancing at
  the status bar icon, without opening the menu, in at least 95% of attempts.
- **SC-005**: With "Launch at Login" enabled, the app appears in the status bar automatically
  after 100% of logins until the setting is disabled.
- **SC-006**: The app makes zero network connections during normal operation.

## Assumptions

- Target users are non-technical macOS users on macOS 13.0 Ventura or later (per project
  constitution); the app is a single-user, single-machine utility.
- "Sleep prevention" for v1 means preventing idle/automatic system sleep and display sleep while
  the app is running and ON. It does not override the user manually sleeping the Mac or closing
  the lid.
- The status bar icon is the only UI surface; there are no preferences windows or onboarding
  screens in v1.
- The keep-awake remains tied to the running app process — there is no persistence of the ON/OFF
  state across app launches (the app starts OFF on each launch). Only "Launch at Login" persists.
- Out of scope for v1: timers, scheduling/automatic durations, display-only (keep display on but
  allow system sleep) mode, and menu bar icon customization.
- Distribution is via direct `.dmg` download (per project constitution); App Store constraints
  do not apply to v1.
