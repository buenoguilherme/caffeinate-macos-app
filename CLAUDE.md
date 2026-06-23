<!-- SPECKIT START -->
For additional context about technologies to be used, project structure,
shell commands, and other important information, read the current plan:
`specs/001-status-bar-sleep-toggle/plan.md`

Active feature: **Status Bar Sleep Toggle** (`specs/001-status-bar-sleep-toggle/`).
Stack: Swift 5.9+ / AppKit (`NSStatusItem` + `NSMenu`), IOKit power assertions,
`SMAppService` for Launch at Login; menu-bar-only agent (`LSUIElement = YES`),
macOS 13.0+, Apple SDK only (no third-party deps). See plan.md, data-model.md,
contracts/internal-interfaces.md, and quickstart.md in that feature directory.
<!-- SPECKIT END -->
