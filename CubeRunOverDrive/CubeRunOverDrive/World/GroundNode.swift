import SpriteKit

/// Long static floor for the runner.
final class GroundNode: SKNode {
    private static let segmentWidth: CGFloat = 2000

    init(layout: GameLayout, length: CGFloat = 50_000) {
        super.init()
        name = "ground"
        let groundTopY = layout.groundTopY

        var x: CGFloat = 0
        while x < length {
            let segment = SKSpriteNode(
                color: SKColor(red: 0.15, green: 0.18, blue: 0.22, alpha: 1),
                size: CGSize(width: Self.segmentWidth, height: 80)
            )
            segment.position = CGPoint(x: x + Self.segmentWidth / 2, y: groundTopY - 40)
            segment.zPosition = -10

            segment.physicsBody = SKPhysicsBody(rectangleOf: segment.size)
            segment.physicsBody?.isDynamic = false
            segment.physicsBody?.categoryBitMask = PhysicsCategory.ground
            segment.physicsBody?.collisionBitMask = PhysicsCategory.player
            segment.physicsBody?.contactTestBitMask = PhysicsCategory.none

            addChild(segment)
            x += Self.segmentWidth
        }
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        nil
    }
}
