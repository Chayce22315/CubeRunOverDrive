import CoreGraphics
import UIKit

/// Scene-relative layout for iPhone (simulator and physical devices).
struct GameLayout: Sendable {
    let sceneSize: CGSize
    let safeAreaInsets: UIEdgeInsets

    init(sceneSize: CGSize, safeAreaInsets: UIEdgeInsets = .zero) {
        self.sceneSize = sceneSize
        self.safeAreaInsets = safeAreaInsets
    }

    /// Top of the walkable ground in scene coordinates.
    var groundTopY: CGFloat {
        max(96, sceneSize.height * 0.14)
    }

    var playerStartX: CGFloat { max(100, sceneSize.width * 0.12) }

    var hudScorePosition: CGPoint {
        CGPoint(
            x: -sceneSize.width * 0.42,
            y: sceneSize.height * 0.5 - safeAreaInsets.top - 16
        )
    }

    var kickButtonPosition: CGPoint {
        CGPoint(
            x: sceneSize.width * 0.38,
            y: -sceneSize.height * 0.5 + safeAreaInsets.bottom + 72
        )
    }

    var photosensitiveTogglePosition: CGPoint {
        CGPoint(
            x: sceneSize.width * 0.32,
            y: sceneSize.height * 0.5 - safeAreaInsets.top - 56
        )
    }
}
