import SpriteKit

/// Obstacle explosions and chain reactions with depth limit.
@MainActor
final class ChainReactionManager {
    private let explosionSystem: ExplosionSystem
    private let impactFeedback: ImpactFeedbackSystem
    private var visited = Set<ObjectIdentifier>()
    private let chainRadius: CGFloat = 130
    private let maxDepth = 4

    init(explosionSystem: ExplosionSystem, impactFeedback: ImpactFeedbackSystem) {
        self.explosionSystem = explosionSystem
        self.impactFeedback = impactFeedback
    }

    func reset() {
        visited.removeAll()
    }

    func handleObstacleCollision(_ nodeA: SKNode, _ nodeB: SKNode, spawner: ObstacleSpawner) {
        guard let a = nodeA as? any ExplodableObstacle,
              let b = nodeB as? any ExplodableObstacle,
              !a.isDestroyed, !b.isDestroyed else { return }

        let midpoint = CGPoint(
            x: (nodeA.position.x + nodeB.position.x) / 2,
            y: (nodeA.position.y + nodeB.position.y) / 2
        )
        trigger(at: midpoint, primary: nodeA, spawner: spawner, depth: 0)
        _ = b
    }

    func trigger(
        at position: CGPoint,
        primary: SKNode?,
        spawner: ObstacleSpawner,
        depth: Int
    ) {
        guard depth <= maxDepth else { return }

        let intensity = 0.55 + CGFloat(depth) * 0.2
        explosionSystem.spawn(at: position, intensity: intensity)
        impactFeedback.playImpact(intensity: intensity)

        if let primary, let explodable = primary as? any ExplodableObstacle, !explodable.isDestroyed {
            destroy(explodable, node: primary, in: spawner)
        }

        var chainTargets: [(SKNode, any ExplodableObstacle)] = []
        for node in spawner.obstacles {
            if let primary, node === primary { continue }
            guard let explodable = node as? any ExplodableObstacle,
                  !explodable.isDestroyed,
                  distance(node.position, position) <= chainRadius else { continue }
            let id = ObjectIdentifier(explodable)
            guard !visited.contains(id) else { continue }
            visited.insert(id)
            chainTargets.append((node, explodable))
        }

        for (node, explodable) in chainTargets {
            let targetPosition = node.position
            let nextDepth = depth + 1
            node.run(.sequence([
                .wait(forDuration: TimeInterval(nextDepth) * 0.05),
                .run { [weak self] in
                    guard let self, !explodable.isDestroyed else { return }
                    self.destroy(explodable, node: node, in: spawner)
                    self.explosionSystem.spawn(at: targetPosition, intensity: intensity * 0.85)
                    self.trigger(at: targetPosition, primary: nil, spawner: spawner, depth: nextDepth)
                }
            ]))
        }
    }

    private func destroy(_ obstacle: any ExplodableObstacle, node: SKNode, in spawner: ObstacleSpawner) {
        obstacle.explode()
        spawner.removeObstacle(node)
    }

    private func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        hypot(a.x - b.x, a.y - b.y)
    }
}
