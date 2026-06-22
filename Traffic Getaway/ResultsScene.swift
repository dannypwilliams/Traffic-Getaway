import SpriteKit

final class ResultsScene: SKScene {
    private let result: ProgressionResult
    private let contentNode = SKNode()
    private let overlayNode = SKNode()
    private var doubleCashClaimed = false
    private var isDoublingCash = false
    private var isTransitioning = false

    init(size: CGSize, result: ProgressionResult) {
        self.result = result
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    override func didMove(to view: SKView) {
        anchorPoint = .zero
        buildResults()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        guard oldSize != .zero else { return }
        buildResults()
    }

    private func buildResults() {
        removeAllChildren()
        contentNode.removeAllChildren()
        overlayNode.removeAllChildren()
        addChild(contentNode)
        addChild(overlayNode)
        overlayNode.zPosition = 100
        let theme = resultWorldTheme
        let metrics = GameLayoutMetrics(sceneSize: size, safeAreaInsets: view?.safeAreaInsets ?? .zero)
        backgroundColor = theme.palette.panel

        buildBackground(theme: theme)

        let isStoryRun = result.runStats.gameMode == .storyChase
        let isLevelComplete = result.runStats.levelCompleted && result.completedLevel != nil
        let failedLevel = isStoryRun && !result.runStats.levelCompleted
        let titleText = outcomeTitle(isLevelComplete: isLevelComplete, failedLevel: failedLevel)
        let titleColor = outcomeColor(isLevelComplete: isLevelComplete, failedLevel: failedLevel, theme: theme)
        let title = UIHelpers.label(titleText, size: 34, color: titleColor, width: size.width - 32)
        title.position = CGPoint(x: size.width / 2, y: metrics.safeContentFrame.maxY - 28)
        contentNode.addChild(title)

        let levelLine: String
        if let level = result.runStats.levelID.flatMap(LevelCatalog.level) {
            let rating = isLevelComplete ? "  \(starText(result.levelStarRating))" : ""
            levelLine = "\(level.name)  \(level.worldTheme.displayName)\(rating)"
        } else {
            levelLine = result.runStats.cityReached.displayName
        }
        let levelLabel = UIHelpers.bodyLabel(levelLine, size: 14, color: UITheme.Color.secondaryText, width: size.width - 34)
        levelLabel.position = CGPoint(x: size.width / 2, y: title.position.y - 34)
        contentNode.addChild(levelLabel)

        let actionBaseY = metrics.safeContentFrame.minY + 24
        let primaryY = actionBaseY + 52
        let doubleCashY = actionBaseY + 96
        let panelBottom = doubleCashY + 34
        let panelTop = levelLabel.position.y - 34
        let panelHeight = max(238, min(470, panelTop - panelBottom))
        let panelSize = CGSize(width: min(metrics.safeContentFrame.width, 370), height: panelHeight)
        let panel = UIHelpers.panel(size: panelSize, fill: UITheme.Color.panelDeep.withAlphaComponent(0.94), stroke: theme.palette.accent.withAlphaComponent(0.75))
        panel.position = CGPoint(x: size.width / 2, y: panelBottom + panelHeight / 2)
        contentNode.addChild(panel)

        let bikeRun = result.runStats.selectedVehicleClass == .motorcycle
        var rows: [(String, String, Bool)] = [
            ("Vehicle", CarCatalog.car(id: result.runStats.selectedCarID).displayName, false),
            ("Score", "\(result.runStats.score)", true),
            ("Distance", "\(result.runStats.distance)", true),
            ("Cash", "$\(result.finalCashEarned)", true),
            ("XP", "\(result.finalXPEarned) XP", true),
            ("Near Misses", "\(result.runStats.nearMisses)", false),
            ("Best Combo", "x\(result.runStats.highestCombo)", false),
            ("Wanted", bikeRun ? "MOTO \(result.runStats.wantedLevelReached)" : "LEVEL \(result.runStats.wantedLevelReached)", false)
        ]
        if bikeRun {
            rows.insert(("Lane Splits", "\(result.runStats.laneSplits)", false), at: 6)
        }
        if failedLevel {
            rows.insert(("Reason", failureText(result.runStats.failureReason), false), at: 1)
        }

        let progressLine = progressionLine()
        let unlockLine = unlockPreviewLine()
        rows.append(("Progress", progressLine, false))
        rows.append(("Next", unlockLine, false))

        let topRowY = panel.position.y + panelSize.height / 2 - 30
        let available = max(1, panelSize.height - 62)
        let spacing = min(28, max(18, available / CGFloat(max(1, rows.count - 1))))
        let rowWidth = panelSize.width - 38
        for (index, row) in rows.enumerated() {
            addMetricRow(title: row.0, value: row.1, y: topRowY - CGFloat(index) * spacing, width: rowWidth, counting: row.2)
        }

        let doubleCash = UIHelpers.button(
            text: doubleCashClaimed ? "CASH DOUBLED" : "DOUBLE CASH",
            name: doubleCashClaimed ? "results.noop" : "results.doubleCash",
            size: CGSize(width: 170, height: 38),
            fill: doubleCashClaimed ? SKColor.green.withAlphaComponent(0.18) : SKColor(red: 1, green: 0.84, blue: 0.16, alpha: 0.2),
            stroke: doubleCashClaimed ? .green : SKColor(red: 1, green: 0.84, blue: 0.16, alpha: 1)
        )
        doubleCash.position = CGPoint(x: size.width / 2, y: doubleCashY)
        contentNode.addChild(doubleCash)

        let primaryText: String
        let primaryName: String
        if isLevelComplete, result.nextLevel != nil {
            primaryText = result.primaryUnlockVehicleID == CarCatalog.starterBikeID ? "USE BIKE" : "NEXT LEVEL"
            primaryName = "results.nextLevel"
        } else if isStoryRun {
            primaryText = result.runStats.levelCompleted ? "RETRY RATING" : "RETRY LEVEL"
            primaryName = "results.play"
        } else {
            primaryText = "PLAY AGAIN"
            primaryName = "results.play"
        }
        let primaryStroke = failedLevel ? SKColor.red : theme.palette.accent
        let playAgain = UIHelpers.button(text: primaryText, name: primaryName, size: CGSize(width: 158, height: 42), fill: primaryStroke.withAlphaComponent(0.28), stroke: primaryStroke)
        playAgain.position = CGPoint(x: size.width / 2, y: primaryY)
        contentNode.addChild(playAgain)

        let garage = UIHelpers.button(text: "GARAGE", name: "results.garage", size: CGSize(width: 98, height: 36), fill: theme.palette.secondAccent.withAlphaComponent(0.18), stroke: theme.palette.secondAccent)
        garage.position = CGPoint(x: size.width / 2 - 116, y: actionBaseY)
        contentNode.addChild(garage)

        let levelSelect = UIHelpers.button(text: "LEVEL SELECT", name: "results.levelSelect", size: CGSize(width: 126, height: 36), fill: theme.palette.accent.withAlphaComponent(0.16), stroke: theme.palette.accent)
        levelSelect.position = CGPoint(x: size.width / 2, y: actionBaseY)
        contentNode.addChild(levelSelect)

        let menu = UIHelpers.button(text: "MENU", name: "results.menu", size: CGSize(width: 98, height: 36), fill: SKColor.white.withAlphaComponent(0.12), stroke: .white)
        menu.position = CGPoint(x: size.width / 2 + 116, y: actionBaseY)
        contentNode.addChild(menu)
    }

    private func outcomeTitle(isLevelComplete: Bool, failedLevel: Bool) -> String {
        if isLevelComplete {
            return "ESCAPED"
        }

        guard failedLevel else {
            return "RUN COMPLETE"
        }

        switch result.runStats.failureReason {
        case "police", "police_caught":
            return "CAPTURED"
        case "missed_exit":
            return "MISSED EXIT"
        case "traffic", "collision", "roadblock":
            return "CRASHED"
        default:
            return "BUSTED"
        }
    }

    private func outcomeColor(isLevelComplete: Bool, failedLevel: Bool, theme: WorldTheme) -> SKColor {
        if isLevelComplete {
            return theme.palette.accent
        }
        if failedLevel {
            return SKColor(red: 1, green: 0.18, blue: 0.16, alpha: 1)
        }
        return UITheme.Color.gold
    }

    private func addMetricRow(title: String, value: String, y: CGFloat, width: CGFloat, counting: Bool) {
        let compact = size.height < 650
        let titleLabel = UIHelpers.bodyLabel(title.uppercased(), size: compact ? 11 : 12, color: SKColor(white: 0.72, alpha: 1))
        titleLabel.horizontalAlignmentMode = .left
        titleLabel.position = CGPoint(x: size.width / 2 - width / 2, y: y)
        contentNode.addChild(titleLabel)

        let valueLabel = UIHelpers.label(counting ? "0" : value, size: compact ? 14 : 16, color: .white, width: width * 0.58)
        valueLabel.horizontalAlignmentMode = .right
        valueLabel.position = CGPoint(x: size.width / 2 + width / 2, y: y)
        contentNode.addChild(valueLabel)

        guard counting else { return }
        let numeric = Int(String(value.filter { $0.isNumber })) ?? 0
        let prefix = value.hasPrefix("$") ? "$" : ""
        let suffix = value.hasSuffix(" XP") ? " XP" : ""
        runCountUp(label: valueLabel, value: numeric, prefix: prefix, suffix: suffix)
    }

    private func progressionLine() -> String {
        let save = SaveManager.shared.data
        if result.levelAfter > result.levelBefore {
            return "Level \(result.levelBefore) -> \(result.levelAfter)"
        }

        let xp = SaveManager.xpProgress(totalXP: save.totalXP, level: save.playerLevel)
        return "Level \(save.playerLevel)  \(xp.current)/\(xp.required) XP"
    }

    private func unlockPreviewLine() -> String {
        if let unlockID = result.primaryUnlockVehicleID {
            let car = CarCatalog.car(id: unlockID)
            if car.vehicleClass == .motorcycle {
                return "\(car.displayName) unlocked: split lanes"
            }
            return "\(car.displayName) unlocked"
        }

        if let completedLevel = result.completedLevel, let nextLevel = result.nextLevel {
            if nextLevel.city != completedLevel.city {
                return "\(nextLevel.worldTheme.displayName) unlocked"
            }
            return "\(nextLevel.name) unlocked"
        }

        let save = SaveManager.shared.data
        guard let nextCar = CarCatalog.cars
            .filter({ !save.unlockedCarIDs.contains($0.id) })
            .sorted(by: { $0.unlockCost < $1.unlockCost })
            .first else {
            return "Garage complete"
        }

        let remaining = max(0, nextCar.unlockCost - save.totalCash)
        return remaining == 0 ? "\(nextCar.displayName) ready" : "\(nextCar.displayName) $\(remaining) left"
    }

    private var resultWorldTheme: WorldTheme {
        if let level = result.runStats.levelID.flatMap(LevelCatalog.level) {
            return level.worldTheme
        }
        return WorldThemeCatalog.legacyTheme(for: result.runStats.cityReached)
    }

    private func buildBackground(theme: WorldTheme) {
        for index in 0..<18 {
            let line = SKShapeNode(rectOf: CGSize(width: CGFloat.random(in: 1.4...3), height: CGFloat.random(in: 90...180)), cornerRadius: 1)
            line.fillColor = (index.isMultiple(of: 2) ? theme.palette.accent : theme.palette.secondAccent).withAlphaComponent(0.13)
            line.strokeColor = .clear
            line.glowWidth = 5
            line.position = CGPoint(x: CGFloat.random(in: 0...max(size.width, 1)), y: CGFloat.random(in: 0...max(size.height, 1)))
            contentNode.addChild(line)
        }
    }

    private func addCountingRow(title: String, value: Int, prefix: String = "", suffix: String = "", y: CGFloat) {
        let titleLabel = UIHelpers.bodyLabel(title.uppercased(), size: 13, color: SKColor(white: 0.72, alpha: 1))
        titleLabel.horizontalAlignmentMode = .right
        titleLabel.position = CGPoint(x: size.width / 2 - 14, y: y)
        contentNode.addChild(titleLabel)

        let valueLabel = UIHelpers.label("\(prefix)0\(suffix)", size: 18, color: .white)
        valueLabel.horizontalAlignmentMode = .left
        valueLabel.position = CGPoint(x: size.width / 2 + 18, y: y)
        contentNode.addChild(valueLabel)
        runCountUp(label: valueLabel, value: value, prefix: prefix, suffix: suffix)
    }

    private func addStaticRow(title: String, value: String, y: CGFloat) {
        let titleLabel = UIHelpers.bodyLabel(title.uppercased(), size: 13, color: SKColor(white: 0.72, alpha: 1))
        titleLabel.horizontalAlignmentMode = .right
        titleLabel.position = CGPoint(x: size.width / 2 - 14, y: y)
        contentNode.addChild(titleLabel)

        let valueLabel = UIHelpers.label(value, size: 18, color: .white)
        valueLabel.horizontalAlignmentMode = .left
        valueLabel.position = CGPoint(x: size.width / 2 + 18, y: y)
        contentNode.addChild(valueLabel)
    }

    private func addProgressionSummary(y: CGFloat, width: CGFloat) {
        let save = SaveManager.shared.data
        let levelText = result.levelAfter > result.levelBefore ? "LEVEL UP \(result.levelBefore) -> \(result.levelAfter)" : "LEVEL \(save.playerLevel)"
        let level = UIHelpers.label(levelText, size: 17, color: SKColor(red: 0.35, green: 1, blue: 0.42, alpha: 1), width: width)
        level.position = CGPoint(x: size.width / 2, y: y)
        contentNode.addChild(level)
        if result.levelAfter > result.levelBefore {
            level.run(.repeat(.sequence([.scale(to: 1.08, duration: 0.16), .scale(to: 1, duration: 0.16)]), count: 3))
        }

        let xp = SaveManager.xpProgress(totalXP: save.totalXP, level: save.playerLevel)
        let bar = UIHelpers.progressBar(width: width, height: 8, progress: CGFloat(xp.current) / CGFloat(max(1, xp.required)), fill: SKColor(red: 0.35, green: 1, blue: 0.42, alpha: 1))
        bar.position = CGPoint(x: size.width / 2, y: y - 25)
        contentNode.addChild(bar)

        let detail = UIHelpers.bodyLabel("\(xp.current) / \(xp.required) XP   Total Cash $\(save.totalCash)", size: 11, color: SKColor(white: 0.75, alpha: 1), width: width)
        detail.position = CGPoint(x: size.width / 2, y: y - 45)
        contentNode.addChild(detail)

        if result.levelCashBonus > 0 {
            let bonus = UIHelpers.bodyLabel("Level bonus +$\(result.levelCashBonus)", size: 11, color: SKColor(red: 1, green: 0.84, blue: 0.2, alpha: 1))
            bonus.position = CGPoint(x: size.width / 2, y: y - 63)
            contentNode.addChild(bonus)
        }
    }

    private func addUpdateSummary(y: CGFloat, width: CGFloat) {
        var lines: [String] = []
        if let completedLevel = result.completedLevel {
            lines.append("Escaped: \(completedLevel.name)")
            if result.levelStarRating > result.previousBestStarRating {
                lines.append("New rating: \(starText(result.levelStarRating))")
            }
            if let nextLevel = result.nextLevel {
                if nextLevel.city != completedLevel.city {
                    lines.append("New city unlocked: \(nextLevel.worldTheme.displayName) - \(nextLevel.name)")
                } else {
                    lines.append("Next chase unlocked: \(nextLevel.name)")
                }
            }
        }
        if !result.missionUpdates.isEmpty {
            if let completed = result.missionUpdates.first(where: \.completed) {
                lines.append("Mission complete: \(completed.title)")
            } else {
                lines.append("Missions progressed: \(result.missionUpdates.count)")
            }
        }
        let unlockedAchievements = result.achievementUpdates.filter(\.completed)
        if !unlockedAchievements.isEmpty {
            lines.append("Achievement unlocked: \(unlockedAchievements[0].name)")
        }
        if let daily = result.dailyUpdate {
            lines.append(daily.completed ? "Daily complete: \(daily.title)" : "Daily progress: \(daily.progress)/\(daily.target)")
        }

        if lines.isEmpty {
            lines.append("Missions and daily challenge ready on Main Menu")
        }

        for (index, line) in lines.prefix(3).enumerated() {
            let label = UIHelpers.bodyLabel(line, size: 12, color: SKColor(white: 0.82, alpha: 1), width: width)
            label.position = CGPoint(x: size.width / 2, y: y - CGFloat(index) * 20)
            contentNode.addChild(label)
        }
    }

    private func addNextUnlockPreview(y: CGFloat, width: CGFloat) {
        let save = SaveManager.shared.data
        guard let nextCar = CarCatalog.cars
            .filter({ !save.unlockedCarIDs.contains($0.id) })
            .sorted(by: { $0.unlockCost < $1.unlockCost })
            .first else {
            let complete = UIHelpers.bodyLabel("Garage complete. Keep chasing high scores.", size: 12, color: UITheme.Color.gold, width: width)
            complete.position = CGPoint(x: size.width / 2, y: y)
            contentNode.addChild(complete)
            return
        }

        let remaining = max(0, nextCar.unlockCost - save.totalCash)
        let progress = CGFloat(save.totalCash) / CGFloat(max(1, nextCar.unlockCost))
        let title = remaining == 0 ? "\(nextCar.displayName) ready to unlock" : "Next unlock: \(nextCar.displayName)  $\(remaining) left"
        let label = UIHelpers.bodyLabel(title, size: 12, color: nextCar.rarity.color, width: width)
        label.position = CGPoint(x: size.width / 2, y: y)
        contentNode.addChild(label)

        let bar = UIHelpers.progressBar(width: width, height: 6, progress: progress, fill: nextCar.rarity.color)
        bar.position = CGPoint(x: size.width / 2, y: y - 20)
        bar.xScale = 0.05
        contentNode.addChild(bar)
        bar.run(.scaleX(to: 1, duration: 0.45))
    }

    private func starText(_ stars: Int) -> String {
        let clamped = max(0, min(3, stars))
        return String(repeating: "*", count: clamped) + String(repeating: "-", count: 3 - clamped)
    }

    private func failureText(_ reason: String?) -> String {
        switch reason {
        case "traffic":
            return "Traffic Collision"
        case "roadblock":
            return "Roadblock Hit"
        case "police", "police_caught":
            return "Caught by Police"
        case "missed_exit":
            return "Missed Exit"
        case "collision":
            return "Collision"
        default:
            return "Chase Failed"
        }
    }

    private func runCountUp(label: SKLabelNode, value: Int, prefix: String, suffix: String) {
        let duration: TimeInterval = 0.75
        label.run(.customAction(withDuration: duration) { node, elapsed in
            guard let label = node as? SKLabelNode else { return }
            let progress = min(1, elapsed / CGFloat(duration))
            let shown = Int(CGFloat(value) * progress)
            label.text = "\(prefix)\(shown)\(suffix)"
        }) {
            label.text = "\(prefix)\(value)\(suffix)"
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isTransitioning, !isDoublingCash,
              let location = touches.first?.location(in: self),
              let name = UIHelpers.nodeName(at: location, in: self) else { return }

        UIHelpers.animatePress(nodes(at: location).first { $0.name == name }?.parent?.name == name ? nodes(at: location).first { $0.name == name }?.parent : nodes(at: location).first { $0.name == name })
        AudioManager.shared.play(.menuClick, volume: 0.72, cooldown: 0.04)

        switch name {
        case "results.play":
            isTransitioning = true
            let replayLevel = result.runStats.levelID.flatMap(LevelCatalog.level)
            UIHelpers.present(GameScene(size: size, mode: result.runStats.gameMode, level: replayLevel), from: self, transition: .doorsOpenVertical(withDuration: 0.28))
        case "results.nextLevel":
            isTransitioning = true
            UIHelpers.present(GameScene(size: size, mode: .storyChase, level: result.nextLevel), from: self, transition: .doorsOpenVertical(withDuration: 0.28))
        case "results.garage":
            isTransitioning = true
            UIHelpers.present(GarageScene(size: size), from: self)
        case "results.levelSelect":
            isTransitioning = true
            UIHelpers.present(LevelSelectScene(size: size), from: self)
        case "results.menu":
            isTransitioning = true
            UIHelpers.present(MainMenuScene(size: size), from: self)
        case "results.doubleCash":
            doubleCash()
        default:
            break
        }
    }

    private func doubleCash() {
        guard !doubleCashClaimed, result.finalCashEarned > 0 else { return }
        isDoublingCash = true
        showMessage(MonetizationManager.shared.isRemoveAdsOwned() ? "Applying bonus..." : "Loading reward...")
        MonetizationManager.shared.showRewardedAd(type: .doubleCash) { [weak self] success in
            guard let self else { return }
            self.isDoublingCash = false
            self.overlayNode.removeAllChildren()
            guard success else {
                self.showMessage("Reward unavailable.")
                return
            }

            SaveManager.shared.applyDoubleCashBonus(self.result.finalCashEarned)
            self.doubleCashClaimed = true
            AudioManager.shared.play(.powerUp, volume: 0.82, cooldown: 0.1)
            self.buildResults()
            self.showMessage("+$\(self.result.finalCashEarned) added.")
        }
    }

    private func showMessage(_ text: String) {
        overlayNode.removeAllChildren()
        let panel = UIHelpers.panel(size: CGSize(width: min(size.width - 54, 300), height: 92), stroke: .cyan)
        panel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlayNode.addChild(panel)

        let label = UIHelpers.bodyLabel(text, size: 15, color: .white, width: panel.frame.width - 28)
        label.position = panel.position
        overlayNode.addChild(label)

        panel.setScale(0.92)
        panel.run(.sequence([.scale(to: 1, duration: 0.12), .wait(forDuration: 0.9), .fadeOut(withDuration: 0.2), .removeFromParent()]))
        label.run(.sequence([.wait(forDuration: 1.02), .fadeOut(withDuration: 0.2), .removeFromParent()]))
    }
}
