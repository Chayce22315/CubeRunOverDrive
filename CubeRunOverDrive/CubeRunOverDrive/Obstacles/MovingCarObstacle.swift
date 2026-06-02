import SpriteKit

/// Car that moves left across the lane.
final class MovingCarObstacle: SKSpriteNode, ExplodableObstacle {
    let moveSpeed: CGFloat
    private(set) var isDestroyed = false

    init(moveSpeed: CGFloat = 180) {
        self.moveSpeed = moveSpeed
        let carSize = CGSize(width: 90, height: 45)
        super.init(texture: nil, color: SKColor(red: 0.95, green: 0.75, blue: 0.15, alpha: 1), size: carSize)
        configureAsObstacle(size: carSize)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        nil
    }

    func placeOnGround(at x: CGFloat, groundTopY: CGFloat) {
        position = CGPoint(x: x, y: groundTopY + size.height / 2)
    }

    func update(deltaTime: TimeInterval) {
        guard !isDestroyed else { return }
        position.x -= moveSpeed * CGFloat(deltaTime)
    }

    func explode() {
        guard !isDestroyed else { return }
        isDestroyed = true
        physicsBody = nil
        run(.sequence([
            .group([
                .rotate(byAngle: .pi / 6, duration: 0.1),
                .fadeOut(withDuration: 0.14)
            ]),
            .removeFromParent()
        ]))
    }
}
