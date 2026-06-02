import SpriteKit
import UIKit

/// Hosts the SpriteKit view — sizes the scene to the real device / simulator screen.
@MainActor
final class GameViewController: UIViewController {
    private var gameScene: GameScene?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        guard let skView = view as? SKView else { return }
        skView.ignoresSiblingOrder = true
        #if DEBUG
        skView.showsFPS = true
        skView.showsNodeCount = true
        #else
        skView.showsFPS = false
        skView.showsNodeCount = false
        #endif
        skView.preferredFramesPerSecond = 60
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let skView = view as? SKView else { return }

        let size = skView.bounds.size
        guard size.width > 0, size.height > 0 else { return }

        let layout = GameLayout(sceneSize: size, safeAreaInsets: view.safeAreaInsets)

        if let gameScene {
            gameScene.size = size
            gameScene.applyLayout(layout)
            return
        }

        let scene = GameScene(size: size)
        scene.scaleMode = .resizeFill
        scene.applyLayout(layout)
        gameScene = scene
        skView.presentScene(scene)
    }

    override func loadView() {
        view = SKView()
    }

    override var prefersStatusBarHidden: Bool { true }
    override var prefersHomeIndicatorAutoHidden: Bool { true }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }
}
