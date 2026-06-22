import SpriteKit

private enum MainMenuOverlay {
    case none
    case missions
    case achievements
}

final class MainMenuScene: SKScene {
    private let backgroundNode = SKNode()
    private let contentNode = SKNode()
    private let overlayNode = SKNode()
    private var overlay: MainMenuOverlay = .none
    private var achievementPage = 0
    private let achievementsPerPage = 5
    private var isTransitioning = false
    private var titleTouchStartTime: TimeInterval?

    override func didMove(to view: SKView) {
        anchorPoint = .zero
        MissionManager.shared.ensureActiveMissions()
        _ = DailyChallengeManager.shared.currentCard()
        _ = AchievementManager.shared.updateStoredProgress()
        buildMenu()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            AudioManager.shared.configure()
        }
    }

    override func didChangeSize(_ oldSize: CGSize) {
        guard oldSize != .zero else { return }
        buildMenu()
    }

    private func buildMenu() {
        removeAllChildren()
        backgroundNode.removeAllChildren()
        contentNode.removeAllChildren()
        overlayNode.removeAllChildren()
        overlay = .none
        isTransitioning = false

        backgroundColor = UITheme.Color.background
        backgroundNode.zPosition = -20
        contentNode.zPosition = 0
        overlayNode.zPosition = 50
        addChild(backgroundNode)
        addChild(contentNode)
        addChild(overlayNode)

        buildBackground()
        buildHeader()
        buildSelectedCarCard()
        buildDailyCard()
        buildButtons()
    }

    private func buildBackground() {
        let nextLevel = LevelCatalog.nextPlayableLevel(completedIDs: SaveManager.shared.data.completedLevelIDs)
        let theme = nextLevel.worldTheme
        buildSkyline(theme: theme)
        buildMenuTraffic(theme: theme)
        buildHelicopter(theme: theme)

        for index in 0..<18 {
            let line = SKShapeNode(rectOf: CGSize(width: CGFloat.random(in: 1.5...3.5), height: CGFloat.random(in: 90...190)), cornerRadius: 1)
            line.fillColor = (index.isMultiple(of: 2) ? theme.palette.accent : theme.palette.secondAccent).withAlphaComponent(0.12)
            line.strokeColor = .clear
            line.glowWidth = 5
            line.position = CGPoint(x: CGFloat.random(in: 0...max(size.width, 1)), y: CGFloat.random(in: 0...max(size.height, 1)))
            backgroundNode.addChild(line)

            let drift = SKAction.moveBy(x: CGFloat.random(in: -10...10), y: CGFloat.random(in: -16...16), duration: TimeInterval.random(in: 2.8...4.8))
            line.run(.repeatForever(.sequence([drift, drift.reversed()])))
        }
    }

    private func buildSkyline(theme: WorldTheme) {
        let horizon = size.height * 0.67
        for layer in 0..<2 {
            let count = 10 + layer * 3
            let alpha: CGFloat = layer == 0 ? 0.32 : 0.18
            let yBase = horizon + CGFloat(layer) * 28
            for index in 0..<count {
                let width = size.width / CGFloat(count) * CGFloat.random(in: 0.74...1.08)
                let height = CGFloat.random(in: 46...128) * (layer == 0 ? 1 : 0.72)
                let building = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 2)
                building.fillColor = SKColor(red: 0.025, green: 0.035, blue: 0.09, alpha: alpha)
                building.strokeColor = (index.isMultiple(of: 2) ? theme.palette.accent : theme.palette.secondAccent).withAlphaComponent(0.16)
                building.lineWidth = 1
                building.position = CGPoint(x: CGFloat(index) / CGFloat(max(1, count - 1)) * size.width, y: yBase - height / 2)
                backgroundNode.addChild(building)

                if layer == 0 && index.isMultiple(of: 2) {
                    let antenna = SKShapeNode(rectOf: CGSize(width: 3, height: 24), cornerRadius: 1)
                    antenna.fillColor = theme.palette.accent.withAlphaComponent(0.4)
                    antenna.strokeColor = .clear
                    antenna.position = CGPoint(x: building.position.x, y: building.position.y + height / 2 + 12)
                    backgroundNode.addChild(antenna)
                }
            }
        }
    }

    private func buildMenuTraffic(theme: WorldTheme) {
        let roadSize = CGSize(width: min(size.width * 0.72, 290), height: size.height * 0.72)
        let road = ArcadeArt.makeRoadSample(size: roadSize, theme: theme)
        road.alpha = 0.72
        road.position = CGPoint(x: size.width / 2, y: size.height * 0.36)
        backgroundNode.addChild(road)

        for lane in -1...1 {
            let x = size.width / 2 + CGFloat(lane) * roadSize.width * 0.22
            for index in 0..<4 {
                let dash = SKShapeNode(rectOf: CGSize(width: 4, height: 28), cornerRadius: 2)
                dash.fillColor = ArcadeArt.Palette.cream.withAlphaComponent(0.24)
                dash.strokeColor = .clear
                dash.position = CGPoint(x: x, y: CGFloat(index) * 120 - 40)
                backgroundNode.addChild(dash)
                dash.run(.repeatForever(.sequence([
                    .moveBy(x: 0, y: -120, duration: 1.9),
                    .moveBy(x: 0, y: 120, duration: 0)
                ])))
            }
        }

        for index in 0..<6 {
            let type: VehicleType = [.compact, .sedan, .suv, .pickup, .sportCoupe].randomElement() ?? .sedan
            let spec = ArcadeArt.trafficSpec(for: type, laneWidth: 30, world: theme)
            let car = ArcadeArt.makeVehicleSprite(spec: spec)
            car.alpha = 0.48
            car.setScale(0.78)
            car.position = CGPoint(
                x: size.width / 2 + CGFloat([-1, 0, 1].randomElement() ?? 0) * roadSize.width * 0.22,
                y: CGFloat(index) * 135 - 60
            )
            backgroundNode.addChild(car)
            car.run(.repeatForever(.sequence([
                .moveBy(x: 0, y: -size.height - 120, duration: TimeInterval.random(in: 4.6...6.8)),
                .moveBy(x: 0, y: size.height + 120, duration: 0)
            ])))
        }
    }

    private func buildHelicopter(theme: WorldTheme) {
        let helicopter = SKNode()
        helicopter.position = CGPoint(x: size.width * 0.78, y: size.height * 0.79)
        backgroundNode.addChild(helicopter)

        let spotlight = SKShapeNode()
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: -10))
        path.addLine(to: CGPoint(x: -36, y: -180))
        path.addLine(to: CGPoint(x: 44, y: -180))
        path.closeSubpath()
        spotlight.path = path
        spotlight.fillColor = SKColor.white.withAlphaComponent(0.065)
        spotlight.strokeColor = SKColor.white.withAlphaComponent(0.09)
        spotlight.glowWidth = 10
        helicopter.addChild(spotlight)

        let body = SKShapeNode(ellipseOf: CGSize(width: 48, height: 24))
        body.fillColor = SKColor.black.withAlphaComponent(0.72)
        body.strokeColor = theme.palette.accent.withAlphaComponent(0.42)
        body.lineWidth = 1
        helicopter.addChild(body)

        let rotor = SKShapeNode(rectOf: CGSize(width: 78, height: 4), cornerRadius: 2)
        rotor.fillColor = SKColor.white.withAlphaComponent(0.58)
        rotor.strokeColor = .clear
        helicopter.addChild(rotor)
        rotor.run(.repeatForever(.rotate(byAngle: CGFloat.pi * 2, duration: 0.16)))

        helicopter.run(.repeatForever(.sequence([
            .group([.moveBy(x: -26, y: 10, duration: 2.2), .rotate(toAngle: -0.06, duration: 2.2)]),
            .group([.moveBy(x: 26, y: -10, duration: 2.2), .rotate(toAngle: 0.06, duration: 2.2)])
        ])))
    }

    private func buildHeader() {
        let save = SaveManager.shared.data
        let title = UIHelpers.label("TRAFFIC GETAWAY", size: UITheme.Font.titleSize, color: UITheme.Color.gold, width: size.width - 32)
        title.name = "menu.title"
        title.position = CGPoint(x: size.width / 2, y: size.height - 78)
        contentNode.addChild(title)
        title.run(.repeatForever(.sequence([
            .scale(to: 1.018, duration: 1.3),
            .scale(to: 1, duration: 1.3)
        ])))

        let cash = UIHelpers.bodyLabel("$0   BEST \(save.bestScore)", size: 16, color: UITheme.Color.text, width: size.width - 32)
        cash.position = CGPoint(x: size.width / 2, y: size.height - 114)
        contentNode.addChild(cash)
        cash.run(.customAction(withDuration: 0.7) { node, elapsed in
            guard let label = node as? SKLabelNode else { return }
            let progress = min(1, elapsed / 0.7)
            label.text = "$\(Int(CGFloat(save.totalCash) * progress))   BEST \(save.bestScore)"
        }) {
            cash.text = "$\(save.totalCash)   BEST \(save.bestScore)"
        }

        let level = UIHelpers.bodyLabel("LEVEL \(save.playerLevel)", size: 14, color: UITheme.Color.green)
        level.position = CGPoint(x: size.width / 2, y: size.height - 142)
        contentNode.addChild(level)

        let xp = SaveManager.xpProgress(totalXP: save.totalXP, level: save.playerLevel)
        let xpProgress = CGFloat(xp.current) / CGFloat(max(1, xp.required))
        let bar = UIHelpers.progressBar(width: min(size.width - 92, 260), height: 8, progress: xpProgress, fill: UITheme.Color.green)
        bar.position = CGPoint(x: size.width / 2, y: size.height - 164)
        bar.xScale = 0.05
        contentNode.addChild(bar)
        bar.run(.scaleX(to: 1, duration: 0.55))

        let xpText = UIHelpers.bodyLabel("\(xp.current) / \(xp.required) XP", size: 11, color: UITheme.Color.secondaryText)
        xpText.position = CGPoint(x: size.width / 2, y: size.height - 181)
        contentNode.addChild(xpText)
    }

    private func buildSelectedCarCard() {
        let save = SaveManager.shared.data
        let car = CarCatalog.car(id: save.selectedCarID)
        let paint = CarCatalog.paint(id: save.selectedPaintID)
        let panel = UIHelpers.panel(size: CGSize(width: min(size.width - 42, 340), height: 220), fill: UITheme.Color.panelDeep, stroke: car.rarity.color.withAlphaComponent(0.82))
        panel.position = CGPoint(x: size.width / 2, y: size.height * 0.58)
        contentNode.addChild(panel)
        UIHelpers.entrance(panel, delay: 0.08, offsetY: -16)

        let aura = SKShapeNode(ellipseOf: CGSize(width: 118, height: 168))
        aura.fillColor = car.rarity.color.withAlphaComponent(0.12)
        aura.strokeColor = car.rarity.color.withAlphaComponent(0.28)
        aura.glowWidth = car.rarity == .legendary ? 16 : 8
        aura.position = CGPoint(x: panel.position.x - 92, y: panel.position.y - 8)
        contentNode.addChild(aura)
        UIHelpers.pulse(aura, scale: car.rarity == .legendary ? 1.08 : 1.04, duration: 0.95)

        let preview = UIHelpers.carPreview(car: car, paint: paint, size: CGSize(width: 82, height: 132))
        preview.position = CGPoint(x: panel.position.x - 92, y: panel.position.y - 8)
        contentNode.addChild(preview)
        preview.run(.repeatForever(.sequence([
            .group([.rotate(toAngle: -0.035, duration: 1.0), .moveBy(x: -2, y: 3, duration: 1.0)]),
            .group([.rotate(toAngle: 0.035, duration: 1.0), .moveBy(x: 2, y: -3, duration: 1.0)])
        ])))

        let name = UIHelpers.label(car.displayName.uppercased(), size: 21, color: car.rarity.color, width: 182)
        name.horizontalAlignmentMode = .left
        name.position = CGPoint(x: panel.position.x - 22, y: panel.position.y + 48)
        contentNode.addChild(name)

        let rarity = UIHelpers.bodyLabel("\(car.rarity.displayName)  \(paint.displayName)", size: 13, color: UITheme.Color.secondaryText, width: 178)
        rarity.horizontalAlignmentMode = .left
        rarity.position = CGPoint(x: panel.position.x - 22, y: panel.position.y + 20)
        contentNode.addChild(rarity)

        let stats = UIHelpers.bodyLabel("Handling \(statText(car.handling))  Boost \(statText(car.dodgeBoost))", size: 12, color: .white, width: 178)
        stats.horizontalAlignmentMode = .left
        stats.position = CGPoint(x: panel.position.x - 22, y: panel.position.y - 12)
        contentNode.addChild(stats)

        let rewards = UIHelpers.bodyLabel("Cash \(statText(car.cashMultiplier))  Score \(statText(car.scoreMultiplier))", size: 12, color: UITheme.Color.gold, width: 178)
        rewards.horizontalAlignmentMode = .left
        rewards.position = CGPoint(x: panel.position.x - 22, y: panel.position.y - 40)
        contentNode.addChild(rewards)

        let nextLevel = LevelCatalog.nextPlayableLevel(completedIDs: save.completedLevelIDs)
        let chase = UIHelpers.bodyLabel("\(nextLevel.worldTheme.stageCode) \(nextLevel.worldTheme.shortName): \(nextLevel.name)", size: 11, color: UITheme.Color.green, width: 178)
        chase.horizontalAlignmentMode = .left
        chase.position = CGPoint(x: panel.position.x - 22, y: panel.position.y - 68)
        contentNode.addChild(chase)
    }

    private func buildDailyCard() {
        let card = DailyChallengeManager.shared.currentCard()
        let panel = UIHelpers.panel(size: CGSize(width: min(size.width - 42, 330), height: 86), fill: UITheme.Color.panel, stroke: UITheme.Color.cyan.withAlphaComponent(0.7))
        panel.position = CGPoint(x: size.width / 2, y: size.height * 0.36)
        contentNode.addChild(panel)
        panel.run(.repeatForever(.sequence([
            .scale(to: 1.012, duration: 1.2),
            .scale(to: 1, duration: 1.2)
        ])))

        let title = UIHelpers.label("DAILY: \(card.definition.title.uppercased())", size: 15, color: UITheme.Color.cyan, width: panel.frame.width - 26)
        title.position = CGPoint(x: panel.position.x, y: panel.position.y + 24)
        contentNode.addChild(title)

        let desc = UIHelpers.bodyLabel(card.definition.description, size: 12, color: UITheme.Color.secondaryText, width: panel.frame.width - 28)
        desc.position = CGPoint(x: panel.position.x, y: panel.position.y + 1)
        contentNode.addChild(desc)

        let progress = UIHelpers.progressBar(width: panel.frame.width - 58, height: 6, progress: CGFloat(card.progress) / CGFloat(max(1, card.definition.target)), fill: card.isCompleted ? UITheme.Color.green : UITheme.Color.cyan)
        progress.position = CGPoint(x: panel.position.x, y: panel.position.y - 24)
        progress.xScale = 0.05
        contentNode.addChild(progress)
        progress.run(.scaleX(to: 1, duration: 0.42))

        if card.isCompleted && !card.isClaimed {
            let claim = UIHelpers.button(text: "CLAIM", name: "daily.claim", size: CGSize(width: 86, height: 30), fill: SKColor.green.withAlphaComponent(0.25), stroke: .green)
            claim.position = CGPoint(x: panel.position.x + panel.frame.width / 2 - 58, y: panel.position.y - 24)
            contentNode.addChild(claim)
        }
    }

    private func buildButtons() {
        let y = size.height * 0.2
        let width = min(size.width - 82, 250)
        let play = UIHelpers.button(text: "STORY CHASE", name: "menu.play", size: CGSize(width: width, height: 48), fill: SKColor(red: 1, green: 0.18, blue: 0.2, alpha: 0.32), stroke: SKColor(red: 1, green: 0.18, blue: 0.2, alpha: 1))
        play.position = CGPoint(x: size.width / 2, y: y + 80)
        contentNode.addChild(play)

        let garage = UIHelpers.button(text: "GARAGE", name: "menu.garage", size: CGSize(width: width, height: 40), fill: SKColor.cyan.withAlphaComponent(0.18), stroke: .cyan)
        garage.position = CGPoint(x: size.width / 2, y: y + 28)
        contentNode.addChild(garage)

        let missions = UIHelpers.button(text: "MISSIONS", name: "menu.missions", size: CGSize(width: width * 0.48, height: 38), fill: SKColor.magenta.withAlphaComponent(0.18), stroke: .magenta)
        missions.position = CGPoint(x: size.width / 2 - width * 0.26, y: y - 22)
        contentNode.addChild(missions)

        let achievements = UIHelpers.button(text: "ACHIEVEMENTS", name: "menu.achievements", size: CGSize(width: width * 0.48, height: 38), fill: SKColor(red: 1, green: 0.78, blue: 0.1, alpha: 0.18), stroke: SKColor(red: 1, green: 0.78, blue: 0.1, alpha: 1))
        achievements.position = CGPoint(x: size.width / 2 + width * 0.26, y: y - 22)
        contentNode.addChild(achievements)

        let store = UIHelpers.button(text: "STORE", name: "menu.store", size: CGSize(width: width * 0.48, height: 38), fill: SKColor(red: 1, green: 0.45, blue: 0.16, alpha: 0.18), stroke: SKColor(red: 1, green: 0.45, blue: 0.16, alpha: 1))
        store.position = CGPoint(x: size.width / 2 - width * 0.26, y: y - 70)
        contentNode.addChild(store)

        let settings = UIHelpers.button(text: "SETTINGS", name: "menu.settings", size: CGSize(width: width * 0.48, height: 38), fill: SKColor.white.withAlphaComponent(0.1), stroke: SKColor.white.withAlphaComponent(0.72))
        settings.position = CGPoint(x: size.width / 2 + width * 0.26, y: y - 70)
        contentNode.addChild(settings)
    }

    private func showMissionsOverlay() {
        overlay = .missions
        overlayNode.removeAllChildren()
        addOverlayDimmer()
        let panelSize = CGSize(width: min(size.width - 34, 356), height: min(size.height - 118, 560))
        let panel = UIHelpers.panel(size: panelSize, stroke: .magenta)
        panel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlayNode.addChild(panel)

        let title = UIHelpers.label("MISSIONS", size: 28, color: .magenta)
        title.position = CGPoint(x: size.width / 2, y: panel.position.y + panelSize.height / 2 - 46)
        overlayNode.addChild(title)

        let cards = MissionManager.shared.activeMissionCards()
        for (index, card) in cards.enumerated() {
            addMissionCard(card, y: panel.position.y + 118 - CGFloat(index) * 118, width: panelSize.width - 34)
        }

        let back = UIHelpers.button(text: "BACK", name: "overlay.back", size: CGSize(width: 118, height: 36), fill: SKColor.white.withAlphaComponent(0.12), stroke: .white)
        back.position = CGPoint(x: size.width / 2, y: panel.position.y - panelSize.height / 2 + 38)
        overlayNode.addChild(back)
    }

    private func addMissionCard(_ card: MissionCard, y: CGFloat, width: CGFloat) {
        let panel = UIHelpers.panel(size: CGSize(width: width, height: 92), fill: SKColor.black.withAlphaComponent(0.28), stroke: card.isComplete ? .green : SKColor.white.withAlphaComponent(0.22))
        panel.position = CGPoint(x: size.width / 2, y: y)
        overlayNode.addChild(panel)

        let title = UIHelpers.label(card.definition.title.uppercased(), size: 15, color: card.isComplete ? .green : .white, width: width - 24)
        title.position = CGPoint(x: panel.position.x, y: y + 25)
        overlayNode.addChild(title)

        let desc = UIHelpers.bodyLabel(card.definition.description, size: 11, color: SKColor(white: 0.78, alpha: 1), width: width - 28)
        desc.position = CGPoint(x: panel.position.x, y: y + 5)
        overlayNode.addChild(desc)

        let progress = UIHelpers.progressBar(width: width - 108, height: 6, progress: CGFloat(card.progress) / CGFloat(card.definition.target), fill: card.isComplete ? .green : .magenta)
        progress.position = CGPoint(x: panel.position.x - 38, y: y - 25)
        overlayNode.addChild(progress)

        let reward = UIHelpers.bodyLabel("$\(card.definition.rewardCash)  \(card.definition.rewardXP)XP", size: 10, color: SKColor(red: 1, green: 0.84, blue: 0.2, alpha: 1))
        reward.position = CGPoint(x: panel.position.x - width / 2 + 58, y: y - 38)
        overlayNode.addChild(reward)

        if card.isComplete {
            let claim = UIHelpers.button(text: "CLAIM", name: "mission.claim.\(card.definition.id)", size: CGSize(width: 78, height: 28), fill: SKColor.green.withAlphaComponent(0.22), stroke: .green)
            claim.position = CGPoint(x: panel.position.x + width / 2 - 52, y: y - 25)
            overlayNode.addChild(claim)
        }
    }

    private func showAchievementsOverlay() {
        overlay = .achievements
        overlayNode.removeAllChildren()
        addOverlayDimmer()

        let panelSize = CGSize(width: min(size.width - 28, 368), height: min(size.height - 92, 620))
        let panel = UIHelpers.panel(size: panelSize, stroke: SKColor(red: 1, green: 0.78, blue: 0.1, alpha: 1))
        panel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlayNode.addChild(panel)

        let title = UIHelpers.label("ACHIEVEMENTS", size: 27, color: SKColor(red: 1, green: 0.78, blue: 0.1, alpha: 1))
        title.position = CGPoint(x: size.width / 2, y: panel.position.y + panelSize.height / 2 - 44)
        overlayNode.addChild(title)

        let cards = AchievementManager.shared.achievementCards()
        let maxPage = max(0, Int(ceil(Double(cards.count) / Double(achievementsPerPage))) - 1)
        achievementPage = max(0, min(achievementPage, maxPage))
        let start = achievementPage * achievementsPerPage
        let visible = Array(cards.dropFirst(start).prefix(achievementsPerPage))

        for (index, card) in visible.enumerated() {
            addAchievementCard(card, y: panel.position.y + 168 - CGFloat(index) * 78, width: panelSize.width - 28)
        }

        let pageText = UIHelpers.bodyLabel("PAGE \(achievementPage + 1) / \(maxPage + 1)", size: 12, color: SKColor(white: 0.75, alpha: 1))
        pageText.position = CGPoint(x: size.width / 2, y: panel.position.y - panelSize.height / 2 + 76)
        overlayNode.addChild(pageText)

        let prev = UIHelpers.button(text: "PREV", name: "ach.prev", size: CGSize(width: 74, height: 32), fill: SKColor.white.withAlphaComponent(0.1), stroke: .white)
        prev.position = CGPoint(x: size.width / 2 - 82, y: panel.position.y - panelSize.height / 2 + 38)
        overlayNode.addChild(prev)

        let next = UIHelpers.button(text: "NEXT", name: "ach.next", size: CGSize(width: 74, height: 32), fill: SKColor.white.withAlphaComponent(0.1), stroke: .white)
        next.position = CGPoint(x: size.width / 2 + 82, y: panel.position.y - panelSize.height / 2 + 38)
        overlayNode.addChild(next)

        let back = UIHelpers.button(text: "BACK", name: "overlay.back", size: CGSize(width: 92, height: 32), fill: SKColor.white.withAlphaComponent(0.1), stroke: .white)
        back.position = CGPoint(x: size.width / 2, y: panel.position.y - panelSize.height / 2 + 38)
        overlayNode.addChild(back)
    }

    private func addAchievementCard(_ card: AchievementCard, y: CGFloat, width: CGFloat) {
        let color = card.isClaimed ? SKColor(white: 0.5, alpha: 1) : (card.isUnlocked ? SKColor.green : SKColor.white.withAlphaComponent(0.25))
        let panel = UIHelpers.panel(size: CGSize(width: width, height: 66), fill: SKColor.black.withAlphaComponent(0.28), stroke: color)
        panel.position = CGPoint(x: size.width / 2, y: y)
        overlayNode.addChild(panel)

        let title = UIHelpers.label(card.definition.name.uppercased(), size: 13, color: card.isUnlocked ? .white : SKColor(white: 0.68, alpha: 1), width: width - 24)
        title.position = CGPoint(x: panel.position.x, y: y + 18)
        overlayNode.addChild(title)

        let desc = UIHelpers.bodyLabel(card.definition.description, size: 10, color: SKColor(white: 0.72, alpha: 1), width: width - 28)
        desc.position = CGPoint(x: panel.position.x, y: y + 1)
        overlayNode.addChild(desc)

        let progressText = "\(min(card.progress, card.definition.target)) / \(card.definition.target)"
        let progress = UIHelpers.bodyLabel(card.isClaimed ? "CLAIMED" : progressText, size: 10, color: color)
        progress.position = CGPoint(x: panel.position.x - width / 2 + 52, y: y - 20)
        overlayNode.addChild(progress)

        if card.isUnlocked && !card.isClaimed {
            let claim = UIHelpers.button(text: "CLAIM", name: "achievement.claim.\(card.definition.id)", size: CGSize(width: 72, height: 25), fill: SKColor.green.withAlphaComponent(0.22), stroke: .green)
            claim.position = CGPoint(x: panel.position.x + width / 2 - 48, y: y - 19)
            overlayNode.addChild(claim)
        }
    }

    private func addOverlayDimmer() {
        let dimmer = SKShapeNode(rect: CGRect(origin: .zero, size: size))
        dimmer.fillColor = SKColor.black.withAlphaComponent(0.74)
        dimmer.strokeColor = .clear
        overlayNode.addChild(dimmer)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        titleTouchStartTime = UIHelpers.nodeName(at: location, in: self) == "menu.title" ? touch.timestamp : nil
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isTransitioning,
              let touch = touches.first else { return }

        let location = touch.location(in: self)
        if AppConfig.showDebugMenu,
           UIHelpers.nodeName(at: location, in: self) == "menu.title",
           let start = titleTouchStartTime,
           touch.timestamp - start > 0.8 {
            isTransitioning = true
            titleTouchStartTime = nil
            UIHelpers.present(DebugBalanceScene(size: size), from: self)
            return
        }

        titleTouchStartTime = nil

        guard let name = UIHelpers.nodeName(at: location, in: self) else { return }
        UIHelpers.animatePress(nodes(at: location).first { $0.name == name }?.parent?.name == name ? nodes(at: location).first { $0.name == name }?.parent : nodes(at: location).first { $0.name == name })

        AudioManager.shared.play(.menuClick, volume: 0.72, cooldown: 0.04)

        if overlay != .none {
            handleOverlayTap(name)
            return
        }

        switch name {
        case "menu.play":
            isTransitioning = true
            UIHelpers.present(LevelSelectScene(size: size), from: self)
        case "menu.garage":
            isTransitioning = true
            UIHelpers.present(GarageScene(size: size), from: self)
        case "menu.missions":
            showMissionsOverlay()
        case "menu.achievements":
            showAchievementsOverlay()
        case "menu.store":
            isTransitioning = true
            UIHelpers.present(StoreScene(size: size), from: self)
        case "menu.settings":
            isTransitioning = true
            UIHelpers.present(SettingsScene(size: size), from: self)
        case "daily.claim":
            if let reward = DailyChallengeManager.shared.claimDailyChallenge(), AppConfig.debugMode {
                print("[Reward] daily cash=\(reward.cash) xp=\(reward.xp)")
            }
            buildMenu()
        default:
            break
        }
    }

    private func handleOverlayTap(_ name: String) {
        if name == "overlay.back" {
            overlay = .none
            overlayNode.removeAllChildren()
            buildMenu()
            return
        }

        if name == "ach.prev" {
            achievementPage = max(0, achievementPage - 1)
            showAchievementsOverlay()
            return
        }

        if name == "ach.next" {
            let count = AchievementManager.shared.achievementCards().count
            let maxPage = max(0, Int(ceil(Double(count) / Double(achievementsPerPage))) - 1)
            achievementPage = min(maxPage, achievementPage + 1)
            showAchievementsOverlay()
            return
        }

        if name.hasPrefix("mission.claim.") {
            let id = String(name.dropFirst("mission.claim.".count))
            _ = MissionManager.shared.claimMission(id: id)
            showMissionsOverlay()
            return
        }

        if name.hasPrefix("achievement.claim.") {
            let id = String(name.dropFirst("achievement.claim.".count))
            _ = AchievementManager.shared.claimAchievement(id: id)
            showAchievementsOverlay()
        }
    }

    private func statText(_ value: CGFloat) -> String {
        String(format: "%.2fx", Double(value))
    }
}
