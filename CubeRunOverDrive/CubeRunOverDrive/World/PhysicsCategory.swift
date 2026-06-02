import Foundation

/// Physics collision bit masks for SpriteKit bodies.
enum PhysicsCategory {
    static let none: UInt32 = 0
    static let player: UInt32 = 0b1
    static let ground: UInt32 = 0b10
    static let obstacle: UInt32 = 0b100
    static let kickHitbox: UInt32 = 0b1000
}
