import SpriteKit

/// Square player cube with physics body.
final class PlayerNode: SKSpriteNode {
    static let size = CGSize(width: 40, height: 40)

    private(set) var isGrounded = false
    private(set) var coyoteTimeRemaining: TimeInterval = 0

    var groundContactCount = 0

    init() {
        super.init(texture: nil, color: SKColor(red: 0.2, green: 0.85, blue: 0.95, alpha: 1), size: Self.size)
        name = "player"
        zPosition = 10

        physicsBody = SKPhysicsBody(rectangleOf: Self.size)
        physicsBody?.allowsRotation = false
        physicsBody?.restitution = 0
        physicsBody?.friction = 0.2
        physicsBody?.linearDamping = 0
        physicsBody?.categoryBitMask = PhysicsCategory.player
        physicsBody?.collisionBitMask = PhysicsCategory.ground | PhysicsCategory.obstacle
        physicsBody?.contactTestBitMask = PhysicsCategory.ground | PhysicsCategory.obstacle
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        nil
    }

    func resetToStart(position: CGPoint) {
        self.position = position
        physicsBody?.velocity = .zero
        physicsBody?.angularVelocity = 0
        groundContactCount = 0
        isGrounded = false
        coyoteTimeRemaining = 0
    }

    func updateGroundedState(deltaTime: TimeInterval) {
        isGrounded = groundContactCount > 0
        if isGrounded {
            coyoteTimeRemaining = 0.1
        } else if coyoteTimeRemaining > 0 {
            coyoteTimeRemaining -= deltaTime
        }
    }

    var canJump: Bool {
        isGrounded || coyoteTimeRemaining > 0
    }

    func consumeCoyote() {
        coyoteTimeRemaining = 0
    }
}
