import SpriteKit
import UIKit

final class GameViewController: UIViewController {
    override func loadView() {
        view = SKView(frame: UIScreen.main.bounds)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let skView = view as? SKView else { return }
        AnalyticsManager.shared.appLaunched()
        let shouldShowOnboarding = AppConfig.forceOnboarding || !SaveManager.shared.data.hasCompletedOnboarding
        let scene: SKScene = shouldShowOnboarding ? OnboardingScene(size: skView.bounds.size) : MainMenuScene(size: skView.bounds.size)
        scene.scaleMode = .resizeFill

        skView.presentScene(scene)
        skView.ignoresSiblingOrder = true
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
