import SpriteKit

extension SKSpriteNode {
    func configureAsObstacle(size: CGSize) {
        name = "obstacle"
        zPosition = 5
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        physicsBody?.collisionBitMask = PhysicsCategory.player | PhysicsCategory.obstacle
        physicsBody?.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.obstacle
    }
}
