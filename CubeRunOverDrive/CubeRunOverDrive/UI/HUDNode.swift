import SpriteKit

/// On-screen HUD (score) fixed to camera space.
@MainActor
final class HUDNode: SKNode {
    private let scoreLabel: SKLabelNode
    private let chaosLabel: SKLabelNode

    override init() {
        super.init()
        scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.fontSize = 28
        scoreLabel.fontColor = .white
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.verticalAlignmentMode = .top

        chaosLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        chaosLabel.fontSize = 14
        chaosLabel.fontColor = SKColor(red: 1, green: 0.6, blue: 0.2, alpha: 1)
        chaosLabel.horizontalAlignmentMode = .left
        chaosLabel.verticalAlignmentMode = .top
        chaosLabel.text = ""

        super.init()
        name = "hud"
        addChild(scoreLabel)
        addChild(chaosLabel)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        nil
    }

    func apply(layout: GameLayout) {
        scoreLabel.position = layout.hudScorePosition
        chaosLabel.position = CGPoint(x: layout.hudScorePosition.x, y: layout.hudScorePosition.y - 28)
    }

    func updateScore(_ score: Int) {
        scoreLabel.text = "\(score)"
    }

    func updateChaos(level: Int) {
        chaosLabel.text = level > 0 ? "CHAOS x\(level)" : ""
    }
}
