import XCTest
import Combine
@testable import Caffeinate

final class AppStateTests: XCTestCase {

    func testToggleFromOffActivates() {
        let manager = FakeSleepPreventer()
        let state = AppState(manager: manager, launchAtLogin: FakeLaunchAtLogin())

        state.toggleSleepPrevention()

        XCTAssertEqual(manager.activateCount, 1)
        XCTAssertTrue(state.isPreventingSleep)
    }

    func testToggleFromOnDeactivates() {
        let manager = FakeSleepPreventer()
        let state = AppState(manager: manager, launchAtLogin: FakeLaunchAtLogin())

        state.toggleSleepPrevention() // on
        state.toggleSleepPrevention() // off

        XCTAssertEqual(manager.deactivateCount, 1)
        XCTAssertFalse(state.isPreventingSleep)
    }

    func testIsPreventingSleepPublishesOnChange() {
        let state = AppState(manager: FakeSleepPreventer(), launchAtLogin: FakeLaunchAtLogin())
        var received: [Bool] = []
        var cancellables = Set<AnyCancellable>()
        state.$isPreventingSleep.sink { received.append($0) }.store(in: &cancellables)

        state.toggleSleepPrevention()

        XCTAssertEqual(received, [false, true])
    }

    func testSetLaunchAtLoginTrueEnables() {
        let login = FakeLaunchAtLogin(isEnabled: false)
        let state = AppState(manager: FakeSleepPreventer(), launchAtLogin: login)

        state.setLaunchAtLogin(true)

        XCTAssertEqual(login.enableCount, 1)
        XCTAssertTrue(login.isEnabled)
    }

    func testSetLaunchAtLoginFalseDisables() {
        let login = FakeLaunchAtLogin(isEnabled: true)
        let state = AppState(manager: FakeSleepPreventer(), launchAtLogin: login)

        state.setLaunchAtLogin(false)

        XCTAssertEqual(login.disableCount, 1)
        XCTAssertFalse(login.isEnabled)
    }

    func testSetLaunchAtLoginSwallowsErrors() {
        let login = FakeLaunchAtLogin()
        login.errorToThrow = TestError.forced
        let state = AppState(manager: FakeSleepPreventer(), launchAtLogin: login)

        // Should not throw / crash.
        state.setLaunchAtLogin(true)

        XCTAssertEqual(login.enableCount, 1)
        XCTAssertFalse(login.isEnabled)
    }

    func testIsLaunchAtLoginEnabledReflectsManager() {
        let login = FakeLaunchAtLogin(isEnabled: true)
        let state = AppState(manager: FakeSleepPreventer(), launchAtLogin: login)

        XCTAssertTrue(state.isLaunchAtLoginEnabled)
        login.isEnabled = false
        XCTAssertFalse(state.isLaunchAtLoginEnabled)
    }

    func testPrepareForTerminationDeactivatesWhenActive() {
        let manager = FakeSleepPreventer()
        let state = AppState(manager: manager, launchAtLogin: FakeLaunchAtLogin())
        state.toggleSleepPrevention() // active

        state.prepareForTermination()

        XCTAssertEqual(manager.deactivateCount, 1)
        XCTAssertFalse(manager.isActive)
    }

    func testPrepareForTerminationIsNoOpWhenInactive() {
        let manager = FakeSleepPreventer()
        let state = AppState(manager: manager, launchAtLogin: FakeLaunchAtLogin())

        state.prepareForTermination()

        XCTAssertEqual(manager.deactivateCount, 0)
    }
}
