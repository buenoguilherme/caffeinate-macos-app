import XCTest
@testable import Caffeinate

/// Smoke tests for the SMAppService-backed wrapper. The real SMAppService can't
/// be meaningfully mocked, so these only verify the wrapper conforms to the
/// protocol and reads its state without crashing. The branching launch-at-login
/// logic is covered through AppStateTests with a fake.
final class LaunchAtLoginTests: XCTestCase {

    func testSystemLaunchAtLoginConformsToProtocol() {
        let wrapper: LaunchAtLoginManaging = SystemLaunchAtLogin()
        // Reading status must not crash; value depends on the host environment.
        _ = wrapper.isEnabled
    }

    func testLaunchAtLoginIsEnabledMatchesWrapper() {
        XCTAssertEqual(SystemLaunchAtLogin().isEnabled, LaunchAtLogin.isEnabled)
    }
}
