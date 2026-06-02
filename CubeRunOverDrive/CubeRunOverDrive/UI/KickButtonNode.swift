import SpriteKit

/// Drop-kick button in camera space; visible only when airborne.
@MainActor
final class KickButtonNode: SKNode {
    private let background: SKShapeNode
    private let label: SKLabelNode
    private let hitSize = CGSize(width: 64, height: 64)

    override init() {
        super.init()
        background = SKShapeNode(rectOf: hitSize, cornerRadius: 12)
        background.fillColor = SKColor(red: 0.95, green: 0.4, blue: 0.1, alpha: 0.9)
        background.strokeColor = .white
        background.lineWidth = 2

        label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = "KICK"
        label.fontSize = 14
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center

        super.init()
        name = "kickButton"
        isHidden = true
        addChild(background)
        addChild(label)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        nil
    }

    func apply(layout: GameLayout) {
        position = layout.kickButtonPosition
    }

    func setAirborneVisible(_ visible: Bool) {
        isHidden = !visible
    }

    func contains(pointInCameraSpace point: CGPoint) -> Bool {
        let halfW = hitSize.width / 2
        let halfH = hitSize.height / 2
        return point.x >= position.x - halfW && point.x <= position.x + halfW
            && point.y >= position.y - halfH && point.y <= position.y + halfH
    }
}
