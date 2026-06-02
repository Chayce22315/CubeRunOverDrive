import SpriteKit

/// Smooth camera follow with forward bias.
@MainActor
final class CameraController {
    let cameraNode: SKCameraNode

    var forwardBias: CGFloat = 120
    var verticalOffset: CGFloat = 40
    var lerpFactor: CGFloat = 0.12

    init() {
        cameraNode = SKCameraNode()
        cameraNode.name = "camera"
    }

    func update(target: CGPoint) {
        let desired = CGPoint(x: target.x + forwardBias, y: target.y + verticalOffset)
        cameraNode.position = cameraNode.position.lerp(to: desired, factor: lerpFactor)
    }

    func snap(to target: CGPoint) {
        cameraNode.position = CGPoint(x: target.x + forwardBias, y: target.y + verticalOffset)
    }
}
