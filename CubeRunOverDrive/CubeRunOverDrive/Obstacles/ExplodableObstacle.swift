import SpriteKit

/// Obstacle that can be destroyed by explosions / chain reactions.
protocol ExplodableObstacle: AnyObject {
    var isDestroyed: Bool { get }
    func explode()
}
