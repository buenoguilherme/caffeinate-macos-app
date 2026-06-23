import Foundation
import IOKit.pwr_mgt
@testable import Caffeinate

/// Fake sleep preventer that records calls and lets tests drive `isActive`.
final class FakeSleepPreventer: SleepPreventing {
    private(set) var isActive: Bool = false
    private(set) var activateCount = 0
    private(set) var deactivateCount = 0

    /// When false, `activate()` simulates a failed assertion (stays inactive).
    var activateSucceeds = true

    func activate() {
        activateCount += 1
        guard activateSucceeds else { return }
        isActive = true
    }

    func deactivate() {
        deactivateCount += 1
        isActive = false
    }
}

/// Fake launch-at-login manager that records calls and can simulate failures.
final class FakeLaunchAtLogin: LaunchAtLoginManaging {
    var isEnabled: Bool
    private(set) var enableCount = 0
    private(set) var disableCount = 0

    /// When set, `enable()`/`disable()` throw to exercise the error branch.
    var errorToThrow: Error?

    init(isEnabled: Bool = false) {
        self.isEnabled = isEnabled
    }

    func enable() throws {
        enableCount += 1
        if let errorToThrow { throw errorToThrow }
        isEnabled = true
    }

    func disable() throws {
        disableCount += 1
        if let errorToThrow { throw errorToThrow }
        isEnabled = false
    }
}

/// Fake power assertion that records create/release calls and lets tests force
/// a non-success `IOReturn`.
final class FakePowerAssertion: PowerAssertion {
    var resultToReturn: IOReturn = kIOReturnSuccess
    var idToReturn: IOPMAssertionID = 42

    private(set) var createCount = 0
    private(set) var releaseCount = 0
    private(set) var releasedIDs: [IOPMAssertionID] = []

    func create(name: String) -> (result: IOReturn, id: IOPMAssertionID) {
        createCount += 1
        return (resultToReturn, idToReturn)
    }

    func release(_ id: IOPMAssertionID) {
        releaseCount += 1
        releasedIDs.append(id)
    }
}

enum TestError: Error { case forced }
