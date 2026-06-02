import SpriteKit

/// Toggle for photosensitive-safe mode (start menu + visible indicator in HUD corner).
@MainActor
final class PhotosensitiveToggleNode: SKNode {
    private let background: SKShapeNode
    private let label: SKLabelNode
    private let hitSize = CGSize(width: 200, height: 36)

    override init() {
        super.init()
        background = SKShapeNode(rectOf: hitSize, cornerRadius: 8)
        background.fillColor = SKColor(white: 0.1, alpha: 0.75)
        background.strokeColor = SKColor(white: 0.5, alpha: 1)
        background.lineWidth = 1

        label = SKLabelNode(fontNamed: "AvenirNext-Medium")
        label.fontSize = 13
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center

        super.init()
        name = "photosensitiveToggle"
        zPosition = 150
        addChild(background)
        addChild(label)
        refreshLabel()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        nil
    }

    func apply(layout: GameLayout) {
        position = layout.photosensitiveTogglePosition
    }

    func refreshLabel() {
        let state = PhotosensitiveSettings.isSafeModeEnabled ? "ON" : "OFF"
        label.text = "SAFE FX: \(state)"
        background.strokeColor = PhotosensitiveSettings.isSafeModeEnabled
            ? SKColor(red: 0.3, green: 0.85, blue: 0.5, alpha: 1)
            : SKColor(white: 0.5, alpha: 1)
    }

    func contains(pointInCameraSpace point: CGPoint) -> Bool {
        let halfW = hitSize.width / 2
        let halfH = hitSize.height / 2
        return point.x >= position.x - halfW && point.x <= position.x + halfW
            && point.y >= position.y - halfH && point.y <= position.y + halfH
    }

    func toggle() {
        PhotosensitiveSettings.toggle()
        refreshLabel()
    }
}
