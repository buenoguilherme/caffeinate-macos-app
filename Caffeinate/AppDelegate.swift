import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var appState: AppState?
    private var statusBarController: StatusBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        let state = AppState()
        appState = state
        statusBarController = StatusBarController(appState: state)
    }

    func applicationWillTerminate(_ notification: Notification) {
        appState?.prepareForTermination()
    }
}
