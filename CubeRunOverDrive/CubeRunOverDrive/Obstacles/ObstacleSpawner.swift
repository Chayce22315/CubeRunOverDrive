import SpriteKit

/// Spawns static blocks and moving cars ahead of the player; density scales with chaos level.
@MainActor
final class ObstacleSpawner {
    weak var worldNode: SKNode?

    private var spawnTimer: TimeInterval = 0
    private var nextSpawnInterval: TimeInterval = 2
    private let spawnAhead: CGFloat = 500
    private let despawnMargin: CGFloat = 400

    private(set) var obstacles: [SKNode] = []
    private var layout = GameLayout(sceneSize: CGSize(width: 375, height: 812))
    private let trafficDensity = TrafficDensityController()

    var trafficController: TrafficDensityController { trafficDensity }

    func configure(layout: GameLayout) {
        self.layout = layout
    }

    func reset() {
        obstacles.forEach { $0.removeFromParent() }
        obstacles.removeAll()
        spawnTimer = 0
        nextSpawnInterval = 2
        trafficDensity.reset()
    }

    func removeObstacle(_ node: SKNode) {
        node.removeFromParent()
        obstacles.removeAll { $0 === node }
    }

    func update(
        deltaTime: TimeInterval,
        playerX: CGFloat,
        cameraX: CGFloat,
        score: Int,
        isPlaying: Bool
    ) {
        guard isPlaying, let worldNode else { return }

        trafficDensity.update(score: score)

        spawnTimer += deltaTime
        let maxAlive = trafficDensity.maxAlive
        if spawnTimer >= nextSpawnInterval, obstacles.count < maxAlive {
            spawnTimer = 0
            let range = trafficDensity.spawnIntervalRange
            nextSpawnInterval = TimeInterval.random(in: range)
            spawnObstacle(near: playerX + spawnAhead, in: worldNode)
        }

        var alive: [SKNode] = []
        for node in obstacles {
            if let car = node as? MovingCarObstacle {
                car.update(deltaTime: deltaTime)
            }
            if node.position.x < cameraX - despawnMargin {
                node.removeFromParent()
            } else {
                alive.append(node)
            }
        }
        obstacles = alive
    }

    private func spawnObstacle(near x: CGFloat, in parent: SKNode) {
        let spawnX = x + CGFloat.random(in: 0...200)
        let groundY = layout.groundTopY
        let node: SKNode

        if Double.random(in: 0...1) < trafficDensity.carSpawnWeight {
            let car = MovingCarObstacle(moveSpeed: 160 + CGFloat(trafficDensity.chaosLevel) * 12)
            car.placeOnGround(at: spawnX + CGFloat.random(in: 80...220), groundTopY: groundY)
            node = car
        } else {
            let block = StaticBlockObstacle()
            block.placeOnGround(at: spawnX, groundTopY: groundY)
            node = block
        }

        parent.addChild(node)
        obstacles.append(node)
    }
}
