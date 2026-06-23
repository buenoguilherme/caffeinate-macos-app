import Foundation
import IOKit.pwr_mgt

final class CaffeinateManager {
    private var assertionID: IOPMAssertionID = 0
    private(set) var isActive: Bool = false

    func activate() {
        guard !isActive else { return }
        var id: IOPMAssertionID = 0
        let result = IOPMAssertionCreateWithName(
            kIOPMAssertionTypeNoDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            "Caffeinate sleep prevention" as CFString,
            &id
        )
        guard result == kIOReturnSuccess else { return }
        assertionID = id
        isActive = true
    }

    func deactivate() {
        guard isActive else { return }
        IOPMAssertionRelease(assertionID)
        assertionID = 0
        isActive = false
    }

    deinit {
        if isActive {
            IOPMAssertionRelease(assertionID)
        }
    }
}
