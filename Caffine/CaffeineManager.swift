import Foundation
import IOKit.pwr_mgt

class CaffeineManager: ObservableObject {
    static let shared = CaffeineManager()
    @Published var isActive = false
    private var assertionID: IOPMAssertionID = 0

    func activate() {
        guard !isActive else { return }
        let result = IOPMAssertionCreateWithName(
            kIOPMAssertionTypePreventUserIdleDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            "Caffeine: preventing sleep" as CFString,
            &assertionID
        )
        isActive = (result == kIOReturnSuccess)
    }

    func deactivate() {
        guard isActive else { return }
        IOPMAssertionRelease(assertionID)
        assertionID = 0
        isActive = false
    }

    func toggle() {
        isActive ? deactivate() : activate()
    }
}
