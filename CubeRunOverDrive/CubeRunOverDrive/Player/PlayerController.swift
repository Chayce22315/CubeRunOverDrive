import SpriteKit

/// Handles auto-run, jump, dive, and drop kick for the player.
@MainActor
final class PlayerController {
    let player: PlayerNode

    var isHolding = false
    private(set) var isDropKicking = false

    let runSpeed: CGFloat = 300
    let jumpImpulse: CGFloat = 420
    let diveSpeed: CGFloat = -520
    let dropKickDownImpulse: CGFloat = -180
    let dropKickForwardImpulse: CGFloat = 120

    private var dropKickTimer: TimeInterval = 0
    private let dropKickDuration: TimeInterval = 0.25

    init(player: PlayerNode) {
        self.player = player
    }

    func reset() {
        isHolding = false
        isDropKicking = false
        dropKickTimer = 0
    }

    func jump() {
        guard player.canJump else { return }
        player.physicsBody?.velocity.dy = 0
        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: jumpImpulse))
        player.consumeCoyote()
    }

    func performDropKick() {
        guard !player.isGrounded, !isDropKicking else { return }
        isDropKicking = true
        dropKickTimer = dropKickDuration

        player.physicsBody?.velocity.dy = min(player.physicsBody?.velocity.dy ?? 0, 0)
        player.physicsBody?.applyImpulse(CGVector(dx: dropKickForwardImpulse, dy: dropKickDownImpulse))

        let flash = SKAction.sequence([
            SKAction.colorize(with: SKColor.orange, colorBlendFactor: 0.6, duration: 0.05),
            SKAction.colorize(withColorBlendFactor: 0, duration: 0.15)
        ])
        player.run(flash)
    }

    func update(deltaTime: TimeInterval, isPlaying: Bool) {
        player.updateGroundedState(deltaTime: deltaTime)

        guard isPlaying, let body = player.physicsBody else { return }

        if dropKickTimer > 0 {
            dropKickTimer -= deltaTime
            if dropKickTimer <= 0 {
                isDropKicking = false
            }
        }

        var velocity = body.velocity
        velocity.dx = runSpeed

        if isHolding {
            velocity.dy = min(velocity.dy, diveSpeed)
        }

        body.velocity = velocity
    }

    func freezeForMenu() {
        player.physicsBody?.velocity = .zero
    }
}
