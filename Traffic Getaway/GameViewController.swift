import SpriteKit
import UIKit

final class GameViewController: UIViewController {
    private var hasPresentedInitialScene = false

    override func loadView() {
        let skView = SKView(frame: UIScreen.main.bounds)
        skView.backgroundColor = UITheme.Color.background
        let launchScene = BrandedLaunchScene(size: skView.bounds.size == .zero ? UIScreen.main.bounds.size : skView.bounds.size)
        launchScene.scaleMode = .resizeFill
        skView.presentScene(launchScene)
        view = skView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let skView = view as? SKView else { return }
        AnalyticsManager.shared.appLaunched()

        skView.ignoresSiblingOrder = true
        skView.allowsTransparency = false
        presentInitialSceneIfNeeded()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        presentInitialSceneIfNeeded()
    }

    private func presentInitialSceneIfNeeded() {
        guard !hasPresentedInitialScene,
              let skView = view as? SKView,
              skView.bounds.width > 0,
              skView.bounds.height > 0 else {
            return
        }

        hasPresentedInitialScene = true
        let sceneSize = skView.bounds.size
        let scene: SKScene
        if AppConfig.debugMode,
           let level = LevelCatalog.level(id: AppConfig.debugAutoStartLevelID) {
            applyDebugAutoStartVehicleSelection()
            SaveManager.shared.setOnboardingCompleted(true)
            scene = GameScene(size: sceneSize, mode: .storyChase, level: level)
        } else {
            let shouldShowOnboarding = AppConfig.forceOnboarding || !SaveManager.shared.data.hasCompletedOnboarding
            scene = shouldShowOnboarding ? OnboardingScene(size: sceneSize) : MainMenuScene(size: sceneSize)
        }
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }

    private func applyDebugAutoStartVehicleSelection() {
        guard AppConfig.debugMode else { return }
        let vehicleID = AppConfig.debugAutoStartVehicleID
        guard !vehicleID.isEmpty, CarCatalog.cars.contains(where: { $0.id == vehicleID }) else { return }
        if !SaveManager.shared.data.unlockedCarIDs.contains(vehicleID) {
            SaveManager.shared.unlockCar(vehicleID)
        }
        SaveManager.shared.selectCar(vehicleID)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

private final class BrandedLaunchScene: SKScene {
    override func didMove(to view: SKView) {
        anchorPoint = .zero
        backgroundColor = UITheme.Color.background

        let roadWidth = min(size.width * 0.64, 260)
        let road = SKShapeNode(rectOf: CGSize(width: roadWidth, height: size.height + 120), cornerRadius: 18)
        road.position = CGPoint(x: size.width / 2, y: size.height / 2)
        road.fillColor = UITheme.Color.panelDeep
        road.strokeColor = UITheme.Color.cyan.withAlphaComponent(0.36)
        road.lineWidth = 2
        road.zPosition = 0
        addChild(road)

        for offset in stride(from: -size.height * 0.45, through: size.height * 0.45, by: 72) {
            let dash = SKShapeNode(rectOf: CGSize(width: 4, height: 34), cornerRadius: 2)
            dash.position = CGPoint(x: size.width / 2, y: size.height / 2 + offset)
            dash.fillColor = UITheme.Color.gold.withAlphaComponent(0.72)
            dash.strokeColor = .clear
            dash.zPosition = 1
            addChild(dash)
        }

        let title = SKLabelNode(fontNamed: UITheme.Font.title)
        title.text = "TRAFFIC GETAWAY"
        title.fontSize = min(36, max(24, size.width * 0.082))
        title.fontColor = UITheme.Color.gold
        title.horizontalAlignmentMode = .center
        title.verticalAlignmentMode = .center
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.56)
        title.zPosition = 3
        addChild(title)

        let subtitle = SKLabelNode(fontNamed: UITheme.Font.body)
        subtitle.text = "READ THE GAP"
        subtitle.fontSize = 14
        subtitle.fontColor = UITheme.Color.cyan
        subtitle.horizontalAlignmentMode = .center
        subtitle.verticalAlignmentMode = .center
        subtitle.position = CGPoint(x: size.width / 2, y: title.position.y - 34)
        subtitle.zPosition = 3
        addChild(subtitle)
    }
}
