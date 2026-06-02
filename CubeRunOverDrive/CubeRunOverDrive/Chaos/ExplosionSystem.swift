import SpriteKit

/// Spawns visual explosions with a hard cap for stable frame rate.
@MainActor
final class ExplosionSystem {
    private weak var worldNode: SKNode?
    private var activeCount = 0
    private let maxActive = 14

    init(worldNode: SKNode) {
        self.worldNode = worldNode
    }

    func spawn(at position: CGPoint, intensity: CGFloat = 1) {
        guard let worldNode, activeCount < maxActive else { return }
        activeCount += 1
        let node = ExplosionEffect.play(at: position, in: worldNode, intensity: intensity)
        node.run(.sequence([
            .wait(forDuration: 0.5),
            .run { [weak self] in
                guard let self else { return }
                self.activeCount = max(0, self.activeCount - 1)
            }
        ]))
    }

    func reset() {
        activeCount = 0
    }
}
