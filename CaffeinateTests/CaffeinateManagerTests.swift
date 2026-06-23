import XCTest
import IOKit.pwr_mgt
@testable import Caffeinate

final class CaffeinateManagerTests: XCTestCase {

    func testActivateSetsIsActiveTrue() {
        let manager = CaffeinateManager()
        manager.activate()
        XCTAssertTrue(manager.isActive)
        manager.deactivate()
    }

    func testDeactivateSetsIsActiveFalse() {
        let manager = CaffeinateManager()
        manager.activate()
        manager.deactivate()
        XCTAssertFalse(manager.isActive)
    }

    func testActivateIsIdempotentNoAssertionStacking() {
        let manager = CaffeinateManager()
        manager.activate()
        manager.activate()
        XCTAssertTrue(manager.isActive)
        // Only one assertion should be held; deactivate once should return to inactive.
        manager.deactivate()
        XCTAssertFalse(manager.isActive)
    }

    func testDeactivateWhileInactiveIsNoOp() {
        let manager = CaffeinateManager()
        manager.deactivate()
        XCTAssertFalse(manager.isActive)
    }

    func testIsActiveFalseOnInit() {
        let manager = CaffeinateManager()
        XCTAssertFalse(manager.isActive)
    }

    // MARK: - Injected power-assertion behavior

    func testActivateStaysInactiveWhenAssertionCreationFails() {
        let assertion = FakePowerAssertion()
        assertion.resultToReturn = kIOReturnError
        let manager = CaffeinateManager(powerAssertion: assertion)

        manager.activate()

        XCTAssertFalse(manager.isActive)
        XCTAssertEqual(assertion.createCount, 1)
        // No assertion was stored, so nothing should be released on deactivate.
        manager.deactivate()
        XCTAssertEqual(assertion.releaseCount, 0)
    }

    func testDeactivateReleasesStoredAssertionID() {
        let assertion = FakePowerAssertion()
        assertion.idToReturn = 99
        let manager = CaffeinateManager(powerAssertion: assertion)

        manager.activate()
        manager.deactivate()

        XCTAssertEqual(assertion.releaseCount, 1)
        XCTAssertEqual(assertion.releasedIDs, [99])
    }

    func testDeinitReleasesAssertionWhenActive() {
        let assertion = FakePowerAssertion()
        assertion.idToReturn = 7
        var manager: CaffeinateManager? = CaffeinateManager(powerAssertion: assertion)
        manager?.activate()

        manager = nil // trigger deinit

        XCTAssertEqual(assertion.releaseCount, 1)
        XCTAssertEqual(assertion.releasedIDs, [7])
    }

    func testDeinitDoesNotReleaseWhenInactive() {
        let assertion = FakePowerAssertion()
        var manager: CaffeinateManager? = CaffeinateManager(powerAssertion: assertion)

        manager = nil // trigger deinit without ever activating

        XCTAssertEqual(assertion.releaseCount, 0)
    }
}
