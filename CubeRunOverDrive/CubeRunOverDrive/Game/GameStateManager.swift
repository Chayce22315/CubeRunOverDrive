import SpriteKit

/// Manages start menu, playing, and game over overlays.
@MainActor
final class GameStateManager {
    private(set) var state: GameState = .startMenu

    private let overlayLabel: SKLabelNode
    private let subtitleLabel: SKLabelNode

    var onStartPlaying: (() -> Void)?
    var onRestart: (() -> Void)?
    var onGameOver: (() -> Void)?

    init() {
        overlayLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        overlayLabel.fontSize = 32
        overlayLabel.fontColor = .white
        overlayLabel.verticalAlignmentMode = .center
        overlayLabel.horizontalAlignmentMode = .center
        overlayLabel.position = CGPoint(x: 0, y: 40)

        subtitleLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        subtitleLabel.fontSize = 18
        subtitleLabel.fontColor = SKColor(white: 0.85, alpha: 1)
        subtitleLabel.verticalAlignmentMode = .center
        subtitleLabel.horizontalAlignmentMode = .center
        subtitleLabel.position = CGPoint(x: 0, y: 0)

        updateOverlayText()
    }

    func attach(to camera: SKCameraNode) {
        let container = SKNode()
        container.name = "overlay"
        container.addChild(overlayLabel)
        container.addChild(subtitleLabel)
        camera.addChild(container)
    }

    func transitionToPlaying() {
        guard state == .startMenu else { return }
        state = .playing
        overlayLabel.isHidden = true
        subtitleLabel.isHidden = true
        onStartPlaying?()
    }

    func die() {
        guard state == .playing else { return }
        state = .gameOver
        overlayLabel.isHidden = false
        subtitleLabel.isHidden = false
        updateOverlayText()
        onGameOver?()
    }

    func restartFromTap() {
        guard state == .gameOver else { return }
        state = .playing
        overlayLabel.isHidden = true
        subtitleLabel.isHidden = true
        onRestart?()
    }

    func resetToStartMenu() {
        state = .startMenu
        overlayLabel.isHidden = false
        subtitleLabel.isHidden = false
        updateOverlayText()
    }

    private func updateOverlayText() {
        switch state {
        case .startMenu:
            overlayLabel.text = "CUBE RUN"
            subtitleLabel.text = "TAP TO START · TOGGLE SAFE FX"
        case .playing:
            overlayLabel.text = ""
            subtitleLabel.text = ""
        case .gameOver:
            overlayLabel.text = "GAME OVER"
            subtitleLabel.text = "TAP TO RESTART"
        }
    }
}
