import Foundation

/// Abstraction over the object responsible for preventing system sleep,
/// allowing `AppState` to be tested with a fake in place of `CaffeinateManager`.
protocol SleepPreventing: AnyObject {
    var isActive: Bool { get }
    func activate()
    func deactivate()
}
