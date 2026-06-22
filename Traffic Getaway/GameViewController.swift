import SpriteKit
import UIKit

final class GameViewController: UIViewController {
    private var hasPresentedInitialScene = false

    override func loadView() {
        let skView = SKView(frame: UIScreen.main.bounds)
        skView.backgroundColor = .black
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
        let shouldShowOnboarding = AppConfig.forceOnboarding || !SaveManager.shared.data.hasCompletedOnboarding
        let sceneSize = skView.bounds.size
        let scene: SKScene = shouldShowOnboarding ? OnboardingScene(size: sceneSize) : MainMenuScene(size: sceneSize)
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
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
