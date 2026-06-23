<!--
SYNC IMPACT REPORT
==================
Version change: (none) → 1.0.0
Rationale: Initial ratification of the Caffeinate project constitution. MAJOR baseline.

Modified principles: N/A (initial adoption)
Added principles:
  - I. Simplicity for Non-Engineers
  - II. Menu Bar Only
  - III. Lightweight & Dependency-Minimal
  - IV. Native Sleep Prevention (IOKit)
  - V. Privacy by Default
Added sections:
  - Technology & Platform Constraints
  - Development Workflow & Quality Gates
  - Governance

Templates requiring updates:
  - .specify/templates/plan-template.md ✅ aligned (generic Constitution Check gate, no change needed)
  - .specify/templates/spec-template.md ✅ aligned (no mandatory-section conflicts)
  - .specify/templates/tasks-template.md ✅ aligned (task categories compatible)
  - .specify/templates/checklist-template.md ✅ aligned

Follow-up TODOs: none
-->

# Caffeinate Constitution

Caffeinate is a macOS status bar app that prevents the system from sleeping, built for
non-technical users who want a single, obvious control with zero configuration.

## Core Principles

### I. Simplicity for Non-Engineers
The product MUST be usable by people with no technical background. Core behavior MUST be
reachable in one click from the status bar menu. The app MUST be either ON or OFF as the
primary mental model; any additional options (e.g. timed durations) MUST be optional,
clearly labeled in plain language, and never required to accomplish the core task. No
jargon, no settings the user must understand to get value, no setup wizard.

Rationale: The entire reason this app exists is to replace cryptic Terminal commands with
something a non-engineer can use instantly. Complexity that demands explanation is a defect.

### II. Menu Bar Only
The app MUST run as a status bar (menu bar) agent with no Dock icon and no application
windows. The Info.plist MUST set `LSUIElement` (Application is agent) to `true`. There MUST
be no main window, no preferences window that behaves like a document window, and no
window-management surface area. All interaction happens through the status bar item and its
menu.

Rationale: A sleep-prevention utility should be ambient and out of the way. Windows and a
Dock icon add visual clutter and cognitive load that contradict Principle I.

### III. Lightweight & Dependency-Minimal
The app MUST keep a minimal memory and CPU footprint and MUST do no work while idle beyond
maintaining its single sleep assertion and rendering its menu. Third-party dependencies are
disallowed by default; any proposed dependency MUST be justified in writing against what it
replaces and why the platform SDK is insufficient. Prefer Apple frameworks (AppKit,
Foundation, IOKit) over external packages.

Rationale: A utility that quietly runs all day must not be a resource burden, and every
dependency is attack surface, binary weight, and a maintenance liability.

### IV. Native Sleep Prevention (IOKit)
Sleep prevention MUST be implemented via the IOKit power-management API
(`IOPMAssertionCreateWithName`) and released with `IOPMAssertionRelease`. The app MUST NOT
shell out to the `caffeinate` binary or any other subprocess to achieve its core function.
Assertions MUST be released on deactivation and on app termination so the system never
remains awake after the user turns the app off or quits.

Rationale: Using the native API is more reliable, faster, lower-overhead, and avoids the
fragility and security concerns of spawning subprocesses. Leaked assertions would defeat the
user's intent and drain power.

### V. Privacy by Default
The app MUST NOT make network calls, collect analytics, or emit telemetry of any kind. It
MUST function fully offline. No usage data, crash pings, or identifiers leave the device.
Any future feature that would require network access MUST be re-evaluated against this
constitution before implementation.

Rationale: A local sleep utility has no legitimate need for the network. Zero data
collection is a trust guarantee and a selling point for the target audience.

## Technology & Platform Constraints

- Language: Swift. UI via AppKit (`NSStatusItem` / `NSMenu`); SwiftUI MAY be used only where
  it does not introduce a window or violate Principle II.
- Minimum OS: macOS 13.0 Ventura. APIs newer than the deployment target MUST be guarded or
  avoided.
- Sleep API: IOKit `IOPMAssertionCreateWithName` (see Principle IV).
- Distribution: direct `.dmg` download for v1. The App Store is explicitly out of scope for
  v1; sandbox/App-Store-only constraints MUST NOT drive v1 design decisions. Builds intended
  for public release SHOULD be signed and notarized for Gatekeeper.
- No external runtime dependencies without justification (see Principle III).

## Development Workflow & Quality Gates

- Every feature plan MUST pass the Constitution Check gate in `plan-template.md` before
  implementation; violations MUST be recorded and justified in the plan's Complexity Tracking
  section or the feature MUST be redesigned.
- Changes that touch sleep-assertion lifecycle MUST verify that assertions are correctly
  created on enable and released on disable, quit, and unexpected termination paths.
- Changes MUST be manually verified on macOS 13.0 (or with a 13.0 deployment target) for the
  status-bar-only behavior: no Dock icon, no stray windows.
- Reviewers MUST confirm no network calls, analytics SDKs, or telemetry are introduced.

## Governance

This constitution supersedes other development practices for the Caffeinate project. When a
proposed change conflicts with a principle, the principle wins unless the constitution is
formally amended first.

Amendments MUST be proposed as an explicit change to this file, including the rationale and
the resulting version bump. Versioning follows semantic versioning:
- MAJOR: backward-incompatible removal or redefinition of a principle or governance rule.
- MINOR: a new principle or section, or materially expanded guidance.
- PATCH: clarifications and wording fixes that do not change meaning.

All plans, specs, and reviews MUST verify compliance with these principles. Complexity that
deviates from Principles I–V MUST be justified in writing or rejected. Use the current
feature plan and the `.specify/templates/` artifacts for runtime development guidance.

**Version**: 1.0.0 | **Ratified**: 2026-06-23 | **Last Amended**: 2026-06-23
