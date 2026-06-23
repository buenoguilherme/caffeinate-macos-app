import Foundation
import Combine

final class AppState: ObservableObject {
    @Published private(set) var isPreventingSleep: Bool = false

    var isLaunchAtLoginEnabled: Bool {
        launchAtLogin.isEnabled
    }

    private let manager: SleepPreventing
    private let launchAtLogin: LaunchAtLoginManaging

    init(manager: SleepPreventing = CaffeinateManager(),
         launchAtLogin: LaunchAtLoginManaging = SystemLaunchAtLogin()) {
        self.manager = manager
        self.launchAtLogin = launchAtLogin
    }

    func toggleSleepPrevention() {
        if manager.isActive {
            manager.deactivate()
        } else {
            manager.activate()
        }
        isPreventingSleep = manager.isActive
    }

    func setLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try launchAtLogin.enable()
            } else {
                try launchAtLogin.disable()
            }
        } catch {
            // Reflect the actual state after any error (e.g. requires approval)
        }
    }

    func prepareForTermination() {
        if manager.isActive {
            manager.deactivate()
        }
    }
}
