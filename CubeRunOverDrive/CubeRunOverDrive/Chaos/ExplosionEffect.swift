import SpriteKit

/// Short-lived burst sprites (no extra physics bodies).
enum ExplosionEffect {
    private static let particleCount = 7
    private static let lifetime: TimeInterval = 0.45

    @discardableResult
    static func play(
        at position: CGPoint,
        in parent: SKNode,
        intensity: CGFloat = 1
    ) -> SKNode {
        let container = SKNode()
        container.position = position
        container.zPosition = 50
        parent.addChild(container)

        let baseSize = 10 + 6 * intensity
        for index in 0..<particleCount {
            let particle = SKSpriteNode(
                color: index.isMultiple(of: 2)
                    ? SKColor(red: 1, green: 0.55, blue: 0.1, alpha: 1)
                    : SKColor(red: 1, green: 0.25, blue: 0.15, alpha: 1),
                size: CGSize(width: baseSize, height: baseSize)
            )
            let angle = (CGFloat(index) / CGFloat(particleCount)) * .pi * 2
            let distance = 40 + 30 * intensity
            particle.position = CGPoint(x: cos(angle) * 12, y: sin(angle) * 12)
            particle.zPosition = 1
            container.addChild(particle)

            let move = SKAction.moveBy(
                x: cos(angle) * distance,
                y: sin(angle) * distance + 20,
                duration: lifetime
            )
            let fade = SKAction.fadeOut(withDuration: lifetime)
            let scale = SKAction.scale(to: 0.2, duration: lifetime)
            particle.run(SKAction.group([move, fade, scale]))
        }

        container.run(.sequence([
            .wait(forDuration: lifetime),
            .removeFromParent()
        ]))
        return container
    }
}
