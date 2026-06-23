import XCTest
import AppKit
@testable import Caffeinate

/// Runs inside the Caffeinate test host app, so `NSApp` is available.
final class AppDelegateTests: XCTestCase {

    func testApplicationDidFinishLaunchingSetsAccessoryPolicy() {
        let delegate = AppDelegate()

        delegate.applicationDidFinishLaunching(
            Notification(name: NSApplication.didFinishLaunchingNotification)
        )

        XCTAssertEqual(NSApp.activationPolicy(), .accessory)
    }

    func testApplicationWillTerminateRunsCleanupWithoutCrashing() {
        let delegate = AppDelegate()
        delegate.applicationDidFinishLaunching(
            Notification(name: NSApplication.didFinishLaunchingNotification)
        )

        // Exercises prepareForTermination on the wired-up AppState; must not crash.
        delegate.applicationWillTerminate(
            Notification(name: NSApplication.willTerminateNotification)
        )
    }
}
