import Foundation

/// Photosensitive-safe mode: reduces or disables rapid full-screen flashes and heavy screen shake.
enum PhotosensitiveSettings {
    private static let key = "photosensitive_safe_mode"

    static var isSafeModeEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }

    static func toggle() {
        isSafeModeEnabled.toggle()
    }
}
