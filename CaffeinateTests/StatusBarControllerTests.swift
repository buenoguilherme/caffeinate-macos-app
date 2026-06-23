import XCTest
import AppKit
@testable import Caffeinate

/// These run inside the Caffeinate test host app, so `NSStatusBar.system` and
/// `NSApp` are available.
final class StatusBarControllerTests: XCTestCase {

    private func makeController(login: FakeLaunchAtLogin = FakeLaunchAtLogin())
        -> (controller: StatusBarController, state: AppState, manager: FakeSleepPreventer) {
        let manager = FakeSleepPreventer()
        let state = AppState(manager: manager, launchAtLogin: login)
        let controller = StatusBarController(appState: state)
        return (controller, state, manager)
    }

    func testMenuHasExpectedItems() {
        let (controller, _, _) = makeController()
        let items = controller.menu.items

        XCTAssertEqual(items.count, 4)
        XCTAssertEqual(items[0].title, "Prevent Sleep")
        XCTAssertEqual(items[1].title, "Launch at Login")
        XCTAssertTrue(items[2].isSeparatorItem)
        XCTAssertEqual(items[3].title, "Quit Caffeinate")
    }

    func testMenuItemTargetsAreController() {
        let (controller, _, _) = makeController()
        XCTAssertTrue(controller.preventSleepItem.target === controller)
        XCTAssertTrue(controller.launchAtLoginItem.target === controller)
    }

    func testInitialPreventSleepItemIsOff() {
        let (controller, _, _) = makeController()
        XCTAssertEqual(controller.preventSleepItem.state, .off)
    }

    func testStateChangeUpdatesPreventSleepItem() {
        let (controller, state, _) = makeController()

        state.toggleSleepPrevention()

        // The sink is delivered on the main queue; enqueue after it (FIFO) and wait.
        let exp = expectation(description: "menu updated")
        DispatchQueue.main.async { exp.fulfill() }
        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(controller.preventSleepItem.state, .on)
    }

    func testToggleSleepPreventionActionTogglesState() {
        let (controller, state, manager) = makeController()

        controller.toggleSleepPrevention()

        XCTAssertTrue(state.isPreventingSleep)
        XCTAssertEqual(manager.activateCount, 1)
    }

    func testToggleLaunchAtLoginActionEnablesAndUpdatesMenuItem() {
        let login = FakeLaunchAtLogin(isEnabled: false)
        let (controller, _, _) = makeController(login: login)

        controller.toggleLaunchAtLogin()

        XCTAssertEqual(login.enableCount, 1)
        XCTAssertEqual(controller.launchAtLoginItem.state, .on)
    }
}
