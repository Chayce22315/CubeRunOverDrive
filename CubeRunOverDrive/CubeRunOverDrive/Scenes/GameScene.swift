import SpriteKit

/// Main game scene — Phase 1 core + Phase 2 chaos systems.
@MainActor
final class GameScene: SKScene, SKPhysicsContactDelegate {
    private let worldNode = SKNode()
    private let player = PlayerNode()
    private lazy var playerController = PlayerController(player: player)
    private let cameraController = CameraController()
    private let gameStateManager = GameStateManager()
    private let obstacleSpawner = ObstacleSpawner()
    private let scoreSystem = ScoreSystem()
    private let hud = HUDNode()
    private let kickButton = KickButtonNode()
    private let photosensitiveToggle = PhotosensitiveToggleNode()

    private var gameLayout: GameLayout
    private var explosionSystem: ExplosionSystem!
    private var impactFeedback: ImpactFeedbackSystem!
    private var chainReaction: ChainReactionManager!

    private var holdTouch: UITouch?
    private var holdDuration: TimeInterval = 0
    private let holdThreshold: TimeInterval = 0.12
    private var lastUpdateTime: TimeInterval = 0

    private var playerStartPosition: CGPoint {
        CGPoint(x: gameLayout.playerStartX, y: gameLayout.groundTopY + PlayerNode.size.height / 2)
    }

    private let dropKickHitRadius: CGFloat = 70

    init(size: CGSize) {
        gameLayout = GameLayout(sceneSize: size)
        super.init(size: size)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        nil
    }

    func applyLayout(_ layout: GameLayout) {
        gameLayout = layout
        hud.apply(layout: layout)
        kickButton.apply(layout: layout)
        photosensitiveToggle.apply(layout: layout)
        obstacleSpawner.configure(layout: layout)
        impactFeedback?.updateLayout(sceneSize: layout.sceneSize)
    }

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.08, green: 0.1, blue: 0.14, alpha: 1)
        physicsWorld.gravity = CGVector(dx: 0, dy: -18)
        physicsWorld.contactDelegate = self

        addChild(worldNode)
        worldNode.addChild(GroundNode(layout: gameLayout))
        worldNode.addChild(player)

        camera = cameraController.cameraNode
        addChild(cameraController.cameraNode)

        explosionSystem = ExplosionSystem(worldNode: worldNode)
        impactFeedback = ImpactFeedbackSystem(cameraNode: cameraController.cameraNode, sceneSize: size)
        chainReaction = ChainReactionManager(
            explosionSystem: explosionSystem,
            impactFeedback: impactFeedback
        )

        gameStateManager.attach(to: cameraController.cameraNode)
        cameraController.cameraNode.addChild(hud)
        cameraController.cameraNode.addChild(kickButton)
        cameraController.cameraNode.addChild(photosensitiveToggle)

        hud.apply(layout: gameLayout)
        kickButton.apply(layout: gameLayout)
        photosensitiveToggle.apply(layout: gameLayout)

        obstacleSpawner.worldNode = worldNode
        obstacleSpawner.configure(layout: gameLayout)

        wireStateCallbacks()
        resetRun(keepMenu: true)
    }

    private func wireStateCallbacks() {
        gameStateManager.onStartPlaying = { [weak self] in
            self?.beginRun()
        }
        gameStateManager.onRestart = { [weak self] in
            self?.resetRun(keepMenu: false)
            self?.beginRun()
        }
        gameStateManager.onGameOver = { [weak self] in
            self?.clearHold()
            self?.playerController.freezeForMenu()
            self?.player.physicsBody?.velocity = .zero
        }
    }

    private func resetRun(keepMenu: Bool) {
        player.resetToStart(position: playerStartPosition)
        playerController.reset()
        scoreSystem.reset()
        obstacleSpawner.reset()
        explosionSystem.reset()
        chainReaction.reset()
        hud.updateScore(0)
        hud.updateChaos(level: 0)
        kickButton.setAirborneVisible(false)
        photosensitiveToggle.refreshLabel()
        cameraController.snap(to: player.position)
        _ = keepMenu
    }

    private func beginRun() {
        player.resetToStart(position: playerStartPosition)
        playerController.reset()
        scoreSystem.reset()
        obstacleSpawner.reset()
        explosionSystem.reset()
        chainReaction.reset()
        hud.updateScore(0)
        hud.updateChaos(level: 0)
    }

    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        let delta = min(currentTime - lastUpdateTime, 1.0 / 30.0)
        lastUpdateTime = currentTime

        if holdTouch != nil, gameStateManager.state == .playing {
            holdDuration += delta
            if holdDuration >= holdThreshold {
                playerController.isHolding = true
            }
        }

        let isPlaying = gameStateManager.state == .playing

        if !isPlaying {
            playerController.freezeForMenu()
        }

        playerController.update(deltaTime: delta, isPlaying: isPlaying)
        cameraController.update(target: player.position)
        obstacleSpawner.update(
            deltaTime: delta,
            playerX: player.position.x,
            cameraX: cameraController.cameraNode.position.x,
            score: scoreSystem.score,
            isPlaying: isPlaying
        )
        scoreSystem.update(playerX: player.position.x, startX: playerStartPosition.x, isPlaying: isPlaying)
        hud.updateScore(scoreSystem.score)
        hud.updateChaos(level: obstacleSpawner.trafficController.chaosLevel)
        kickButton.setAirborneVisible(isPlaying && !player.isGrounded)
        impactFeedback.update(deltaTime: delta)

        if isPlaying, playerController.isDropKicking {
            checkDropKickHits()
        }
    }

    private func checkDropKickHits() {
        let kickPoint = CGPoint(x: player.position.x + 36, y: player.position.y - 8)
        for node in obstacleSpawner.obstacles {
            guard let explodable = node as? any ExplodableObstacle,
                  !explodable.isDestroyed,
                  distance(node.position, kickPoint) <= dropKickHitRadius else { continue }
            chainReaction.trigger(at: node.position, primary: node, spawner: obstacleSpawner, depth: 0)
            return
        }
    }

    private func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        hypot(a.x - b.x, a.y - b.y)
    }

    // MARK: - Touch

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let cameraPoint = touch.location(in: cameraController.cameraNode)

        if photosensitiveToggle.contains(pointInCameraSpace: cameraPoint) {
            photosensitiveToggle.toggle()
            return
        }

        if kickButton.contains(pointInCameraSpace: cameraPoint), gameStateManager.state == .playing {
            playerController.performDropKick()
            return
        }

        switch gameStateManager.state {
        case .startMenu:
            gameStateManager.transitionToPlaying()
        case .gameOver:
            gameStateManager.restartFromTap()
        case .playing:
            holdTouch = touch
            holdDuration = 0
            playerController.isHolding = false
            playerController.jump()
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard gameStateManager.state == .playing, holdTouch != nil else { return }
        if touches.contains(where: { $0 === holdTouch }) {
            holdDuration = holdThreshold
            playerController.isHolding = true
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let holdTouch, touches.contains(where: { $0 === holdTouch }) {
            clearHold()
        }
    }

    private func clearHold() {
        playerController.isHolding = false
        holdTouch = nil
        holdDuration = 0
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if holdTouch != nil {
            clearHold()
        }
    }

    // MARK: - Physics

    func didBegin(_ contact: SKPhysicsContact) {
        let maskA = contact.bodyA.categoryBitMask
        let maskB = contact.bodyB.categoryBitMask
        let pair = maskA | maskB

        if pair & PhysicsCategory.ground != 0, pair & PhysicsCategory.player != 0 {
            resolveGroundContact(contact, began: true)
        }

        if pair & PhysicsCategory.obstacle != 0, pair & PhysicsCategory.player != 0 {
            let playerBody = contact.bodyA.categoryBitMask == PhysicsCategory.player ? contact.bodyA : contact.bodyB
            guard playerBody.node === player else { return }
            gameStateManager.die()
            impactFeedback.playImpact(intensity: 1.2)
            return
        }

        if pair & PhysicsCategory.obstacle != 0,
           maskA & PhysicsCategory.obstacle != 0,
           maskB & PhysicsCategory.obstacle != 0 {
            let nodeA = contact.bodyA.node
            let nodeB = contact.bodyB.node
            guard let nodeA, let nodeB else { return }
            chainReaction.handleObstacleCollision(nodeA, nodeB, spawner: obstacleSpawner)
        }
    }

    func didEnd(_ contact: SKPhysicsContact) {
        let maskA = contact.bodyA.categoryBitMask
        let maskB = contact.bodyB.categoryBitMask
        let pair = maskA | maskB

        if pair & PhysicsCategory.ground != 0, pair & PhysicsCategory.player != 0 {
            resolveGroundContact(contact, began: false)
        }
    }

    private func resolveGroundContact(_ contact: SKPhysicsContact, began: Bool) {
        let playerBody = contact.bodyA.categoryBitMask == PhysicsCategory.player ? contact.bodyA : contact.bodyB
        guard playerBody.node === player else { return }

        if began {
            player.groundContactCount += 1
        } else {
            player.groundContactCount = max(0, player.groundContactCount - 1)
        }
    }
}
