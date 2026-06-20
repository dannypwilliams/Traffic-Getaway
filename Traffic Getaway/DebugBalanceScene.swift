import SpriteKit
import UIKit

final class DebugBalanceScene: SKScene {
    private let contentNode = SKNode()
    private let feedback = UIImpactFeedbackGenerator(style: .heavy)
    private var isTransitioning = false

    override func didMove(to view: SKView) {
        anchorPoint = .zero
        AudioManager.shared.configure()
        buildDebug()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        guard oldSize != .zero else { return }
        buildDebug()
    }

    private func buildDebug() {
        removeAllChildren()
        contentNode.removeAllChildren()
        addChild(contentNode)
        backgroundColor = SKColor(red: 0.025, green: 0.015, blue: 0.035, alpha: 1)

        let title = UIHelpers.label("BALANCE TOOLS", size: 31, color: SKColor(red: 1, green: 0.82, blue: 0.08, alpha: 1), width: size.width - 32)
        title.position = CGPoint(x: size.width / 2, y: size.height - 64)
        contentNode.addChild(title)

        let save = SaveManager.shared.data
        let status = UIHelpers.bodyLabel("Cash $\(save.totalCash)  Level \(save.playerLevel)  Remove Ads \(save.removeAdsOwned ? "ON" : "OFF")", size: 12, color: .white, width: size.width - 34)
        status.position = CGPoint(x: size.width / 2, y: size.height - 96)
        contentNode.addChild(status)

        let forcedLevel = LevelCatalog.level(id: AppConfig.forcedLevelID)?.name ?? "AUTO"
        let forced = UIHelpers.bodyLabel("City \(AppConfig.forcedCity.displayName)  Wanted \(AppConfig.forcedWantedLevel == 0 ? "AUTO" : "\(AppConfig.forcedWantedLevel)")  Level \(forcedLevel)", size: 12, color: SKColor.cyan, width: size.width - 34)
        forced.position = CGPoint(x: size.width / 2, y: size.height - 118)
        contentNode.addChild(forced)

        let report = ReleaseReadinessManager.shared.runChecks()
        let shot = ScreenshotMode.shared.state
        let readiness = UIHelpers.bodyLabel("Release: \(report.summary)  Screenshot \(shot.enabled ? "ON" : "OFF")", size: 11, color: report.isReady ? UITheme.Color.green : UITheme.Color.gold, width: size.width - 34)
        readiness.position = CGPoint(x: size.width / 2, y: size.height - 140)
        contentNode.addChild(readiness)

        if let issue = report.issues.first {
            let issueLabel = UIHelpers.bodyLabel("First issue: \(issue.title) - \(issue.detail)", size: 10, color: UITheme.Color.gold, width: size.width - 34)
            issueLabel.position = CGPoint(x: size.width / 2, y: size.height - 160)
            contentNode.addChild(issueLabel)
        }

        let actions: [(String, String)] = [
            ("ADD $1,000", "debug.cash.1000"),
            ("ADD $10,000", "debug.cash.10000"),
            ("ADD XP", "debug.xp"),
            ("UNLOCK ALL", "debug.unlockAll"),
            ("LOCK STARTER", "debug.lockCars"),
            ("RESET MISSIONS", "debug.resetMissions"),
            ("RESET ACHIEVEMENTS", "debug.resetAchievements"),
            ("RESET DAILY", "debug.resetDaily"),
            ("RESET SAVE", "debug.resetSave"),
            ("REMOVE ADS", "debug.removeAds"),
            ("FORCE CITY", "debug.forceCity"),
            ("FORCE WANTED", "debug.forceWanted"),
            ("FORCE LEVEL", "debug.forceLevel"),
            ("FORCE EXIT", "debug.forceExit"),
            ("HEATMAP", "debug.heatmap"),
            ("OPEN PATHS", "debug.openPaths"),
            ("SPAWN LOG", "debug.spawnLog"),
            ("TEST HAPTICS", "debug.haptics"),
            ("TEST AUDIO", "debug.audio"),
            ("CHECK RELEASE", "debug.releaseCheck"),
            ("REPAIR SAVE", "debug.releaseRepair"),
            ("SHOT MODE", "debug.shotMode"),
            ("SHOT HUD", "debug.shotHUD"),
            ("SHOT WEATHER", "debug.shotWeather"),
            ("SHOT COMBO", "debug.shotCombo"),
            ("SHOT TRAFFIC", "debug.shotTraffic")
        ]

        let buttonWidth = min((size.width - 54) / 2, 168)
        let startY = size.height - (report.isReady ? 188 : 204)
        for (index, action) in actions.enumerated() {
            let column = index % 2
            let row = index / 2
            let x = size.width / 2 + (column == 0 ? -buttonWidth / 2 - 7 : buttonWidth / 2 + 7)
            let y = startY - CGFloat(row) * 32
            let button = UIHelpers.button(text: action.0, name: action.1, size: CGSize(width: buttonWidth, height: 28), fill: SKColor.white.withAlphaComponent(0.1), stroke: SKColor.magenta.withAlphaComponent(0.8))
            button.position = CGPoint(x: x, y: y)
            contentNode.addChild(button)
        }

        let back = UIHelpers.button(text: "BACK", name: "debug.back", size: CGSize(width: 124, height: 38), fill: SKColor.white.withAlphaComponent(0.12), stroke: .white)
        back.position = CGPoint(x: size.width / 2, y: 38)
        contentNode.addChild(back)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isTransitioning,
              let location = touches.first?.location(in: self),
              let name = UIHelpers.nodeName(at: location, in: self) else { return }

        AudioManager.shared.play(.menuClick, volume: 0.72, cooldown: 0.04)

        switch name {
        case "debug.back":
            isTransitioning = true
            UIHelpers.present(MainMenuScene(size: size), from: self)
        case "debug.cash.1000":
            SaveManager.shared.addCash(1_000)
            buildDebug()
        case "debug.cash.10000":
            SaveManager.shared.addCash(10_000)
            buildDebug()
        case "debug.xp":
            _ = SaveManager.shared.addXP(1_000)
            buildDebug()
        case "debug.unlockAll":
            SaveManager.shared.unlockAllCarsAndPaints()
            _ = AchievementManager.shared.updateStoredProgress()
            buildDebug()
        case "debug.lockCars":
            SaveManager.shared.lockAllNonStarterCars()
            buildDebug()
        case "debug.resetMissions":
            SaveManager.shared.resetMissionProgress()
            MissionManager.shared.ensureActiveMissions()
            buildDebug()
        case "debug.resetAchievements":
            SaveManager.shared.resetAchievementProgress()
            buildDebug()
        case "debug.resetDaily":
            SaveManager.shared.resetDailyChallenge()
            _ = DailyChallengeManager.shared.currentCard()
            buildDebug()
        case "debug.resetSave":
            SaveManager.shared.resetSaveData()
            buildDebug()
        case "debug.removeAds":
            SaveManager.shared.setRemoveAdsOwned(!SaveManager.shared.data.removeAdsOwned)
            buildDebug()
        case "debug.forceCity":
            AppConfig.forcedCity = AppConfig.forcedCity.next
            buildDebug()
        case "debug.forceWanted":
            AppConfig.forcedWantedLevel = AppConfig.forcedWantedLevel >= 6 ? 0 : AppConfig.forcedWantedLevel + 1
            buildDebug()
        case "debug.forceLevel":
            AppConfig.cycleForcedLevel()
            buildDebug()
        case "debug.forceExit":
            AppConfig.forceExitEvent.toggle()
            buildDebug()
        case "debug.heatmap":
            AppConfig.showTrafficSpawnHeatmap.toggle()
            buildDebug()
        case "debug.openPaths":
            AppConfig.showOpenLaneAnalysis.toggle()
            buildDebug()
        case "debug.spawnLog":
            AppConfig.printRejectedTrafficWaves.toggle()
            buildDebug()
        case "debug.haptics":
            if AudioManager.shared.isHapticsEnabled {
                feedback.impactOccurred(intensity: 1)
                feedback.prepare()
            }
        case "debug.audio":
            AudioManager.shared.play(.powerUp, volume: 1)
        case "debug.releaseCheck":
            printReleaseReport()
            buildDebug()
        case "debug.releaseRepair":
            ReleaseReadinessManager.shared.repairSafeIssues()
            buildDebug()
        case "debug.shotMode":
            ScreenshotMode.shared.setEnabled(!ScreenshotMode.shared.state.enabled)
            buildDebug()
        case "debug.shotHUD":
            ScreenshotMode.shared.toggleHideHUD()
            buildDebug()
        case "debug.shotWeather":
            ScreenshotMode.shared.cycleWeather()
            buildDebug()
        case "debug.shotCombo":
            ScreenshotMode.shared.cycleCombo()
            buildDebug()
        case "debug.shotTraffic":
            ScreenshotMode.shared.toggleShowcaseTraffic()
            buildDebug()
        default:
            break
        }
    }

    private func printReleaseReport() {
        let report = ReleaseReadinessManager.shared.runChecks()
        print("[ReleaseReadiness] \(report.summary)")
        for issue in report.issues {
            print("[ReleaseReadiness] \(issue.title): \(issue.detail)")
        }
    }
}
