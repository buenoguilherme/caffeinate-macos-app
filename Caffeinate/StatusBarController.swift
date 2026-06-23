import AppKit
import Combine
import ServiceManagement

final class StatusBarController {
    private let statusItem: NSStatusItem
    let menu = NSMenu()
    private let appState: AppState
    private var cancellables = Set<AnyCancellable>()

    let preventSleepItem = NSMenuItem(
        title: "Prevent Sleep",
        action: #selector(toggleSleepPrevention),
        keyEquivalent: ""
    )
    let launchAtLoginItem = NSMenuItem(
        title: "Launch at Login",
        action: #selector(toggleLaunchAtLogin),
        keyEquivalent: ""
    )

    init(appState: AppState) {
        self.appState = appState
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        configureMenu()
        configureButton()
        observeState()
    }

    private func configureMenu() {
        preventSleepItem.target = self
        launchAtLoginItem.target = self

        menu.addItem(preventSleepItem)
        menu.addItem(launchAtLoginItem)
        menu.addItem(.separator())

        let quitItem = NSMenuItem(
            title: "Quit Caffeinate",
            action: #selector(quitApp),
            keyEquivalent: ""
        )
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    private func configureButton() {
        updateButton(isActive: false)
    }

    private func observeState() {
        appState.$isPreventingSleep
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isActive in
                self?.updateButton(isActive: isActive)
                self?.updateMenuItems(isActive: isActive)
            }
            .store(in: &cancellables)
    }

    private func updateButton(isActive: Bool) {
        let symbolName = isActive ? "cup.and.saucer.fill" : "cup.and.saucer"
        let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)
        image?.isTemplate = !isActive
        statusItem.button?.image = image

        let label = isActive ? "Caffeinate: On" : "Caffeinate: Off"
        statusItem.button?.toolTip = label
        statusItem.button?.setAccessibilityLabel(label)
    }

    private func updateMenuItems(isActive: Bool) {
        preventSleepItem.state = isActive ? .on : .off
        launchAtLoginItem.state = appState.isLaunchAtLoginEnabled ? .on : .off
    }

    @objc func toggleSleepPrevention() {
        appState.toggleSleepPrevention()
        launchAtLoginItem.state = appState.isLaunchAtLoginEnabled ? .on : .off
    }

    @objc func toggleLaunchAtLogin() {
        let newValue = !appState.isLaunchAtLoginEnabled
        appState.setLaunchAtLogin(newValue)

        // If approval is required, direct the user to System Settings.
        if SMAppService.mainApp.status == .requiresApproval {
            SMAppService.openSystemSettingsLoginItems()
        }

        launchAtLoginItem.state = appState.isLaunchAtLoginEnabled ? .on : .off
    }

    @objc func quitApp() {
        NSApp.terminate(nil)
    }
}
