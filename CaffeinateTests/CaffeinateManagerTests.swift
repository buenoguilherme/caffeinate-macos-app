import XCTest
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
}
