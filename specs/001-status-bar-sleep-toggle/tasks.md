---

description: "Task list for Status Bar Sleep Toggle implementation"
---

# Tasks: Status Bar Sleep Toggle

**Input**: Design documents from `/specs/001-status-bar-sleep-toggle/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/internal-interfaces.md, quickstart.md

**Tests**: Included — the feature request explicitly asks for unit tests of `CaffeinateManager` state transitions. Other test types are out of scope for v1.

**Organization**: Tasks are grouped by user story (US1, US2, US4, US3) to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to
- All paths are relative to repository root.

## Path Conventions

- App target source lives under `Caffeinate/`
- Unit tests live under `CaffeinateTests/`
- Xcode project: `Caffeinate.xcodeproj/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Create the Xcode project and configure the agent-app environment.

- [x] T001 Create Xcode project `Caffeinate.xcodeproj` at repo root — SwiftUI app template, product name "Caffeinate", bundle ID `com.yourname.caffeinate`, deployment target macOS 13.0, Swift 5.9+; produces the `Caffeinate/` source group.
- [x] T002 [P] Configure `Caffeinate/Info.plist`: set `LSUIElement = YES` (no Dock icon) and `LSMinimumSystemVersion = 13.0`; confirm no network entitlements or ATS exceptions are present (constitution Principle V).
- [x] T003 [P] In the Caffeinate target's "Frameworks, Libraries, and Embedded Content", link `IOKit.framework` and `ServiceManagement.framework`.
- [x] T004 [P] Add a `CaffeinateTests` unit-test target to the project (XCTest), with `Caffeinate` as the host/testable target.
- [x] T005 [P] Configure signing in the Caffeinate target: select a Developer ID Application signing identity and enable **Hardened Runtime** (required for notarization in T025 and for reliable `SMAppService` registration in US3). *(Gap added — distribution prerequisite.)*

**Checkpoint**: Project builds and launches as an agent (no Dock icon, no window).

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: App entry, delegate, observable state skeleton, and the status item shell that every UI story builds on.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [x] T006 Create `Caffeinate/CaffeinateApp.swift` — `@main struct CaffeinateApp: App` using `@NSApplicationDelegateAdaptor(AppDelegate.self)`; declare no `WindowGroup` (use an empty `Settings {}` scene or equivalent) so no window appears.
- [x] T007 Create `Caffeinate/AppDelegate.swift` — `NSApplicationDelegate`; in `applicationDidFinishLaunching` set `NSApp.setActivationPolicy(.accessory)`, instantiate `AppState`, and create the `StatusBarController` holding a reference to `AppState`.
- [x] T008 [P] Create `Caffeinate/AppState.swift` — `final class AppState: ObservableObject` with `@Published private(set) var isActive: Bool = false` and `@Published var launchAtLogin: Bool = false` (skeleton; method bodies wired in story phases per contracts/internal-interfaces.md).
- [x] T009 Create `Caffeinate/StatusBarController.swift` — owns an `NSStatusItem` from `NSStatusBar.system` with `.variableLength`, attaches an empty `NSMenu`, and sets a placeholder button image. (Depends on T007 for instantiation.)

**Checkpoint**: A coffee-cup status item appears with an empty menu; foundation ready for stories.

---

## Phase 3: User Story 1 - Keep the Mac awake with one click (Priority: P1) 🎯 MVP

**Goal**: User toggles sleep prevention ON/OFF from the menu; the Mac is kept awake (idle system + display sleep) while ON.

**Independent Test**: Toggle "Prevent Sleep" ON, leave the Mac idle past its sleep timeout → it stays awake; toggle OFF → normal sleep resumes.

### Tests for User Story 1 ⚠️

> Write these FIRST and confirm they FAIL before implementing T011.

- [x] T010 [P] [US1] Create `CaffeinateTests/CaffeinateManagerTests.swift` — assert: `activate()` sets `isActive == true`; `deactivate()` sets `isActive == false`; `activate(); activate()` holds exactly one assertion (no stacking, FR-012); `deactivate()` while inactive is a no-op; **`isActive` stays `false` if assertion creation fails** (IOReturn error path). *(Gap added — failure-path coverage.)*

### Implementation for User Story 1

- [x] T011 [US1] Create `Caffeinate/CaffeinateManager.swift` — singleton with `activate()` / `deactivate()` calling `IOPMAssertionCreateWithName` using `kIOPMAssertionTypeNoDisplaySleep` and `kIOPMAssertPreventUserIdleSystemSleep`, storing `assertionID: IOPMAssertionID?`. **Check the returned `IOReturn`; only set state/store the ID on `kIOReturnSuccess`, otherwise leave inactive** (FR-012, no half-state). Idempotent both directions; expose `var isActive: Bool`. (Makes T010 pass.) *(Gap added — IOReturn error handling.)*
- [x] T012 [US1] Implement `AppState.toggleSleepPrevention()` in `Caffeinate/AppState.swift` — flips state, calls `CaffeinateManager.activate()`/`deactivate()`, updates `@Published isActive` to mirror the manager's actual `isActive` (so a failed activate is reflected).
- [x] T013 [US1] In `Caffeinate/StatusBarController.swift`, add the "Prevent Sleep" `NSMenuItem` whose action calls `AppState.toggleSleepPrevention()` (target/action wired to the controller).

**Checkpoint**: US1 fully functional — sleep prevention can be toggled and verifiably keeps the Mac awake. MVP reached.

---

## Phase 4: User Story 2 - See the current state at a glance (Priority: P2)

**Goal**: The status bar icon and menu visibly reflect ON vs OFF without opening (or while opening) the menu.

**Independent Test**: Toggle ON/OFF and confirm the icon changes (outline ↔ filled/accent) and the menu item shows a checkmark only when ON.

### Implementation for User Story 2

- [x] T014 [P] [US2] Add icon assets to `Caffeinate/Assets.xcassets`: `caffeinate-off` (outline cup, "Render As: Template Image") and `caffeinate-on` (filled cup, accent-colored). (SF Symbols `cup.and.saucer` / `.fill` are an acceptable code-only alternative per research.md §6 — if used, skip this asset task.)
- [x] T015 [US2] Wire `AppState` → `StatusBarController` in `Caffeinate/StatusBarController.swift`: observe `@Published isActive` (Combine sink or KVO), swap `statusItem.button?.image` between the off/on icons, and set the "Prevent Sleep" menu item's `.state` (`.on`/`.off`) accordingly (FR-005, FR-006).
- [x] T016 [P] [US2] In `Caffeinate/StatusBarController.swift`, set the status item button's `accessibilityLabel` and `toolTip` to reflect the current state (e.g. "Caffeinate: On"/"Off") so the state is conveyed to VoiceOver and on hover. *(Gap added — accessibility / glanceability for SC-004.)*

**Checkpoint**: US1 + US2 both work — state is glanceable.

---

## Phase 5: User Story 4 - Quit cleanly without leaving the Mac awake (Priority: P2)

**Goal**: "Quit Caffeinate" releases any active keep-awake before the process exits; no assertion outlives the app.

**Independent Test**: Toggle ON, choose Quit, then `pmset -g assertions` shows no Caffeinate assertion and the Mac sleeps normally.

### Implementation for User Story 4

- [x] T017 [US4] In `Caffeinate/StatusBarController.swift`, add the "Quit Caffeinate" `NSMenuItem` whose action calls `NSApp.terminate(nil)`.
- [x] T018 [US4] Implement `AppState.prepareForTermination()` (releases assertion if active) and call it from `AppDelegate.applicationWillTerminate(_:)` in `Caffeinate/AppDelegate.swift`; add a `deinit` release backstop in `Caffeinate/CaffeinateManager.swift` (FR-009, FR-010).

**Checkpoint**: US1 + US2 + US4 work — clean teardown guaranteed.

---

## Phase 6: User Story 3 - Start automatically at login (Priority: P3)

**Goal**: A "Launch at Login" menu toggle registers/unregisters the app via `SMAppService`, with the checkmark reflecting actual status.

**Independent Test**: Enable "Launch at Login", log out/in (or reboot) → app auto-starts; disable → it no longer auto-starts.

### Implementation for User Story 3

- [x] T019 [P] [US3] Create `Caffeinate/LaunchAtLogin.swift` — `enum LaunchAtLogin` with `static var isEnabled` (`SMAppService.mainApp.status == .enabled`), `static func enable() throws` (`register()`), `static func disable() throws` (`unregister()`).
- [x] T020 [US3] In `Caffeinate/AppState.swift`, implement `setLaunchAtLogin(_:)` and initialize `launchAtLogin` from `LaunchAtLogin.isEnabled`; tolerate thrown errors by re-reading actual status (no crash, FR-007/FR-008).
- [x] T021 [US3] In `Caffeinate/StatusBarController.swift`, add the "Launch at Login" `NSMenuItem`; reflect `AppState.launchAtLogin` as its `.state` and toggle it via `AppState.setLaunchAtLogin(_:)`. **Handle the `SMAppService` `.requiresApproval` status by opening System Settings → Login Items** (`SMAppService.openSystemSettingsLoginItems()`) so the user can approve. *(Gap added — approval flow.)*

**Checkpoint**: All four user stories independently functional.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Validation, distribution, and final checks.

- [x] T022 Run `xcodebuild test -project Caffeinate.xcodeproj -scheme Caffeinate -destination 'platform=macOS'` and confirm `CaffeinateManagerTests` pass.
- [ ] T023 Execute the full validation guide in `specs/001-status-bar-sleep-toggle/quickstart.md` (US1–US4 scenarios + edge cases), including `pmset -g assertions` (no leak) and `nettop` (zero network, FR-013).
- [x] T024 [P] Add an `AppIcon` image set to `Caffeinate/Assets.xcassets` (used by Finder and the `.dmg` even though there is no Dock icon at runtime). *(Gap added — bundle/Finder icon.)*
- [ ] T025 Build the distributable `.dmg`: Xcode Archive → export with Developer ID → **notarize and staple** (`xcrun notarytool` + `stapler`), then package via `create-dmg` (or Disk Utility) per constitution (.dmg direct download).
- [x] T026 [P] Final code review against the constitution: no Dock icon/window (Principle II), Apple SDK only / no third-party deps (Principle III), native IOKit only / no `caffeinate` subprocess (Principle IV), no network/analytics (Principle V).
- [x] T027 [P] Create `README.md` (what the app does + one-screenshot usage) and `BUILD.md` (build, sign, notarize, package steps from T025) at repo root. *(Gap added — user/maintainer docs.)*

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately.
- **Foundational (Phase 2)**: Depends on Setup — BLOCKS all user stories.
- **User Stories (Phases 3–6)**: All depend on Foundational. Recommended order P1 → P2 → P2 → P3; US2/US4/US3 can proceed in parallel once Foundational is done (they touch mostly distinct concerns, though all add items to `StatusBarController.swift` — see note below).
- **Polish (Phase 7)**: Depends on the desired user stories being complete.

### User Story Dependencies

- **US1 (P1)**: After Foundational. No dependency on other stories. MVP.
- **US2 (P2)**: After Foundational. Best after US1 (needs the toggle/state to visualize), but icon assets (T014) are independent.
- **US4 (P2)**: After Foundational. Independent of US2/US3; logically pairs with US1's assertion.
- **US3 (P3)**: After Foundational. Fully independent feature.

### Within Each User Story

- Tests (US1) written and failing before implementation.
- `CaffeinateManager` (T011) before `AppState` wiring (T012) before menu wiring (T013).

### Parallel Opportunities

- Setup: T002, T003, T004, T005 in parallel (after T001).
- US1 test T010 written before T011 (no blocker).
- Cross-story: T014 (assets) and T019 (`LaunchAtLogin.swift`) are separate files — parallelizable.
- ⚠️ Serialization note: T013, T015, T016, T017, T021 all edit `Caffeinate/StatusBarController.swift`. These are NOT [P] with each other — sequence edits to that file to avoid conflicts.

---

## Parallel Example: Setup Phase

```bash
# After T001 (project created), run in parallel:
Task: "Configure Info.plist LSUIElement + min version (T002)"
Task: "Link IOKit + ServiceManagement frameworks (T003)"
Task: "Add CaffeinateTests target (T004)"
Task: "Configure Developer ID signing + Hardened Runtime (T005)"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Phase 1: Setup.
2. Phase 2: Foundational.
3. Phase 3: US1 → **STOP and VALIDATE** (toggle keeps Mac awake).
4. Ship/demo MVP.

### Incremental Delivery

1. Setup + Foundational → foundation ready.
2. US1 → test → demo (MVP).
3. US2 (icon feedback) → test → demo.
4. US4 (clean quit) → test → demo.
5. US3 (launch at login) → test → demo.
6. Polish → build `.dmg`.

---

## Notes

- [P] = different files, no dependencies. Most `StatusBarController.swift` edits are intentionally sequential.
- [Story] label maps each task to a spec user story for traceability.
- Verify the US1 unit test fails before implementing `CaffeinateManager`.
- The bundle ID `com.yourname.caffeinate` is a placeholder — replace `yourname` with the real org identifier before T005/T025 (signing/notarization).
- Commit after each task or logical group; validate at each checkpoint.
- **Gaps added beyond the requested list**: T005 (signing/Hardened Runtime), IOReturn error handling in T010/T011, T016 (accessibility label/tooltip), T021 `.requiresApproval` handling, T024 (app/Finder icon), T027 (README + BUILD docs).
