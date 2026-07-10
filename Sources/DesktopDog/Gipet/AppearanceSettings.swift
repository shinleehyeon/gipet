import Foundation
import Combine

/// User-adjustable dog size, as a uniform scale multiplier applied to the
/// whole sprite (1.0 = the original size, unchanged proportions).
final class AppearanceSettings: ObservableObject {
    static let shared = AppearanceSettings()

    static let allowedScales: [Double] = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]

    @Published var sizeScale: Double { didSet { save() } }

    private init() {
        let stored = UserDefaults.standard.double(forKey: "b.sizeScale")
        sizeScale = stored > 0 ? stored : 1.0
    }

    private func save() {
        UserDefaults.standard.set(sizeScale, forKey: "b.sizeScale")
        NotificationCenter.default.post(name: .appearanceSettingsChanged, object: nil)
    }
}

extension Notification.Name {
    static let appearanceSettingsChanged = Notification.Name("AppearanceSettingsChanged")
}
