import AppKit
import Combine
import ServiceManagement

class MenuBarManager {
    private var statusItem: NSStatusItem
    private let caffeineManager: CaffeineManager
    private let timerManager: TimerManager
    private var cancellables = Set<AnyCancellable>()

    init(caffeineManager: CaffeineManager, timerManager: TimerManager) {
        self.caffeineManager = caffeineManager
        self.timerManager = timerManager
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        updateIcon()
        buildMenu()
        subscribe()
    }

    private func subscribe() {
        caffeineManager.$isActive
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateIcon()
                self?.buildMenu()
            }
            .store(in: &cancellables)

        timerManager.$remainingSeconds
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateTitle()
            }
            .store(in: &cancellables)
    }

    private func updateIcon() {
        let symbolName = caffeineManager.isActive ? "cup.and.saucer.fill" : "cup.and.saucer"
        let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: "Caffine")
        image?.isTemplate = true
        statusItem.button?.image = image
        updateTitle()
    }

    private func updateTitle() {
        if let remaining = timerManager.formattedRemaining {
            statusItem.button?.title = " \(remaining)"
        } else {
            statusItem.button?.title = ""
        }
    }

    func buildMenu() {
        let menu = NSMenu()

        let toggleTitle = caffeineManager.isActive ? "Caffine is ON" : "Caffine is OFF"
        let toggleItem = NSMenuItem(title: toggleTitle, action: #selector(toggleCaffine), keyEquivalent: "")
        toggleItem.target = self
        toggleItem.state = caffeineManager.isActive ? .on : .off
        menu.addItem(toggleItem)

        menu.addItem(.separator())

        let header = NSMenuItem(title: "Active for:", action: nil, keyEquivalent: "")
        header.isEnabled = false
        menu.addItem(header)

        for duration in Duration.allCases {
            let item = NSMenuItem(title: "  \(duration.label)", action: #selector(selectDuration(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = duration
            item.state = (caffeineManager.isActive && timerManager.selectedDuration == duration) ? .on : .off
            menu.addItem(item)
        }

        menu.addItem(.separator())

        let loginItem = NSMenuItem(title: "Launch at Login", action: #selector(toggleLaunchAtLogin), keyEquivalent: "")
        loginItem.target = self
        loginItem.state = isLoginEnabled ? .on : .off
        menu.addItem(loginItem)

        menu.addItem(.separator())

        menu.addItem(NSMenuItem(title: "Quit Caffine", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem.menu = menu
    }

    @objc private func toggleCaffine() {
        if caffeineManager.isActive {
            caffeineManager.deactivate()
            timerManager.stop()
        } else {
            caffeineManager.activate()
            timerManager.start(duration: timerManager.selectedDuration)
        }
    }

    @objc private func selectDuration(_ sender: NSMenuItem) {
        guard let duration = sender.representedObject as? Duration else { return }
        timerManager.start(duration: duration)
        if !caffeineManager.isActive {
            caffeineManager.activate()
        }
    }

    @objc private func toggleLaunchAtLogin() {
        do {
            if isLoginEnabled {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }
            buildMenu()
        } catch {
            // User can manage this in System Settings > General > Login Items
        }
    }

    private var isLoginEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }
}
