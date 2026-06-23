import Foundation
import IOKit.pwr_mgt

/// Abstraction over the IOKit power-assertion calls so the success/failure
/// paths can be exercised in tests without touching the real power manager.
protocol PowerAssertion {
    /// Creates a "no display sleep" assertion. Mirrors `IOPMAssertionCreateWithName`.
    func create(name: String) -> (result: IOReturn, id: IOPMAssertionID)
    /// Releases a previously created assertion. Mirrors `IOPMAssertionRelease`.
    func release(_ id: IOPMAssertionID)
}

/// Production `PowerAssertion` backed by IOKit.
struct IOKitPowerAssertion: PowerAssertion {
    func create(name: String) -> (result: IOReturn, id: IOPMAssertionID) {
        var id: IOPMAssertionID = 0
        let result = IOPMAssertionCreateWithName(
            kIOPMAssertionTypeNoDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            name as CFString,
            &id
        )
        return (result, id)
    }

    func release(_ id: IOPMAssertionID) {
        IOPMAssertionRelease(id)
    }
}

final class CaffeinateManager: SleepPreventing {
    private let powerAssertion: PowerAssertion
    private var assertionID: IOPMAssertionID = 0
    private(set) var isActive: Bool = false

    init(powerAssertion: PowerAssertion = IOKitPowerAssertion()) {
        self.powerAssertion = powerAssertion
    }

    func activate() {
        guard !isActive else { return }
        let (result, id) = powerAssertion.create(name: "Caffeinate sleep prevention")
        guard result == kIOReturnSuccess else { return }
        assertionID = id
        isActive = true
    }

    func deactivate() {
        guard isActive else { return }
        powerAssertion.release(assertionID)
        assertionID = 0
        isActive = false
    }

    deinit {
        if isActive {
            powerAssertion.release(assertionID)
        }
    }
}
