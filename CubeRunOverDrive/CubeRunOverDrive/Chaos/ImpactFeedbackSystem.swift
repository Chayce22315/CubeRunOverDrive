import SpriteKit

/// Screen shake and flash on big impacts (respects photosensitive-safe mode).
final class ImpactFeedbackSystem {
    private let cameraNode: SKCameraNode
    private let flashOverlay: SKSpriteNode
    private var shakeTimer: TimeInterval = 0

    init(cameraNode: SKCameraNode, sceneSize: CGSize) {
        self.cameraNode = cameraNode
        flashOverlay = SKSpriteNode(color: .white, size: sceneSize)
        flashOverlay.alpha = 0
        flashOverlay.zPosition = 200
        flashOverlay.name = "impactFlash"
        cameraNode.addChild(flashOverlay)
    }

    func updateLayout(sceneSize: CGSize) {
        flashOverlay.size = sceneSize
    }

    func playImpact(intensity: CGFloat) {
        let safe = PhotosensitiveSettings.isSafeModeEnabled
        let clamped = min(max(intensity, 0.2), 1.4)

        if !safe {
            let flashAlpha = 0.15 + 0.25 * clamped
            flashOverlay.removeAllActions()
            flashOverlay.alpha = 0
            flashOverlay.run(.sequence([
                .fadeAlpha(to: flashAlpha, duration: 0.03),
                .fadeAlpha(to: 0, duration: 0.12)
            ]))
        }

        let shakeAmount = safe ? 2 * clamped : 8 * clamped
        guard shakeTimer <= 0 else { return }
        shakeTimer = 0.18

        let shake = SKAction.sequence([
            .moveBy(x: shakeAmount, y: 0, duration: 0.03),
            .moveBy(x: -shakeAmount * 2, y: 0, duration: 0.03),
            .moveBy(x: shakeAmount, y: 0, duration: 0.03)
        ])
        cameraNode.run(shake)
    }

    func update(deltaTime: TimeInterval) {
        if shakeTimer > 0 { shakeTimer -= deltaTime }
    }
}
