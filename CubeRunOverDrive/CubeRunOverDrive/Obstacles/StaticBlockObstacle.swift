import SpriteKit

/// Static block sitting on the ground.
@MainActor
final class StaticBlockObstacle: SKSpriteNode, ExplodableObstacle {
    private(set) var isDestroyed = false

    init() {
        let blockSize = CGSize(width: 50, height: 50)
        super.init(texture: nil, color: SKColor(red: 0.9, green: 0.35, blue: 0.3, alpha: 1), size: blockSize)
        configureAsObstacle(size: blockSize)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        nil
    }

    func placeOnGround(at x: CGFloat, groundTopY: CGFloat) {
        position = CGPoint(x: x, y: groundTopY + size.height / 2)
    }

    func explode() {
        guard !isDestroyed else { return }
        isDestroyed = true
        physicsBody = nil
        run(.sequence([
            .group([
                .scale(to: 1.35, duration: 0.08),
                .fadeOut(withDuration: 0.12)
            ]),
            .removeFromParent()
        ]))
    }
}
