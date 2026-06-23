import Foundation
import Combine

final class AppState: ObservableObject {
    @Published private(set) var isPreventingSleep: Bool = false

    var isLaunchAtLoginEnabled: Bool {
        LaunchAtLogin.isEnabled
    }

    private let manager = CaffeinateManager()

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
                try LaunchAtLogin.enable()
            } else {
                try LaunchAtLogin.disable()
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
