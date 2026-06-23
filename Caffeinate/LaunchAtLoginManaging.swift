import Foundation

/// Abstraction over launch-at-login management so `AppState` can be tested
/// without touching the real `SMAppService`.
protocol LaunchAtLoginManaging {
    var isEnabled: Bool { get }
    func enable() throws
    func disable() throws
}

/// Production `LaunchAtLoginManaging` that forwards to the `SMAppService`-backed
/// `LaunchAtLogin` wrapper.
struct SystemLaunchAtLogin: LaunchAtLoginManaging {
    var isEnabled: Bool { LaunchAtLogin.isEnabled }
    func enable() throws { try LaunchAtLogin.enable() }
    func disable() throws { try LaunchAtLogin.disable() }
}
