import AppIntents

struct ActivateCaffeineIntent: AppIntent {
    static var title: LocalizedStringResource = "Activate Caffine"
    static var description = IntentDescription("Prevents your Mac display from sleeping.")
    static var openAppWhenRun: Bool = false

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        CaffeineManager.shared.activate()
        TimerManager.shared.start(duration: TimerManager.shared.selectedDuration)
        return .result(dialog: "Caffine is on.")
    }
}

struct DeactivateCaffeineIntent: AppIntent {
    static var title: LocalizedStringResource = "Deactivate Caffine"
    static var description = IntentDescription("Allows your Mac display to sleep normally.")
    static var openAppWhenRun: Bool = false

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        CaffeineManager.shared.deactivate()
        TimerManager.shared.stop()
        return .result(dialog: "Caffine is off.")
    }
}

struct ToggleCaffeineIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Caffine"
    static var description = IntentDescription("Toggles Caffine on or off.")
    static var openAppWhenRun: Bool = false

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let caffeine = CaffeineManager.shared
        let timer = TimerManager.shared
        if caffeine.isActive {
            caffeine.deactivate()
            timer.stop()
            return .result(dialog: "Caffine is off.")
        } else {
            caffeine.activate()
            timer.start(duration: timer.selectedDuration)
            return .result(dialog: "Caffine is on.")
        }
    }
}

struct CaffeineShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ToggleCaffeineIntent(),
            phrases: ["Toggle \(.applicationName)"],
            shortTitle: "Toggle Caffine",
            systemImageName: "cup.and.saucer.fill"
        )
        AppShortcut(
            intent: ActivateCaffeineIntent(),
            phrases: ["Activate \(.applicationName)", "Turn on \(.applicationName)"],
            shortTitle: "Activate Caffine",
            systemImageName: "cup.and.saucer.fill"
        )
        AppShortcut(
            intent: DeactivateCaffeineIntent(),
            phrases: ["Deactivate \(.applicationName)", "Turn off \(.applicationName)"],
            shortTitle: "Deactivate Caffine",
            systemImageName: "cup.and.saucer"
        )
    }
}
