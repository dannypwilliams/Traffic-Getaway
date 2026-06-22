import SpriteKit

/// A short playable first-run lesson. It teaches the real fantasy quickly:
/// move across twelve lanes, skim traffic, trigger boost, and escape through a ramp.
final class TutorialScene: SKScene {
    private enum Stage: Int, CaseIterable {
        case move
        case traffic
        case nearMiss
        case boost
        case exit
        case complete
    }

    private let roadNode = SKNode()
    private let trafficNode = SKNode()
    private let effectsNode = SKNode()
    private let uiNode = SKNode()
    private var laneManager = LaneManager(roadLeft: 0, roadWidth: 1)
    private var laneCenters: [CGFloat] = []
    private var roadLeft: CGFloat = 0
    private var roadWidth: CGFloat = 0
    private var laneWidth: CGFloat = 0
    private var playerSlot = LaneManager.startSlot
    private var stage: Stage = .move
    private var stageTimer: TimeInterval = 0
    private var totalTime: TimeInterval = 0
    private var lastUpdate: TimeInterval = 0
    private var touchStart: CGPoint?
    private var firstInputLogged = false
    private weak var player: SKNode?
    private weak var prompt: SKLabelNode?
    private var isTransitioning = false

    override func didMove(to view: SKView) {
        anchorPoint = .zero
        backgroundColor = UITheme.Color.background
        addChild(roadNode)
        addChild(trafficNode)
        addChild(effectsNode)
        addChild(uiNode)
        AnalyticsManager.shared.tutorialStarted()
        AudioManager.shared.configure()
        buildScene()
        showStage(.move)
    }

    override func didChangeSize(_ oldSize: CGSize) {
        guard oldSize != .zero else { return }
        buildScene()
        showStage(stage)
    }

    private func buildScene() {
        roadNode.removeAllChildren()
        trafficNode.removeAllChildren()
        effectsNode.removeAllChildren()
        uiNode.removeAllChildren()

        roadWidth = min(size.width * 0.92, 390)
        roadLeft = (size.width - roadWidth) / 2
        laneWidth = roadWidth / CGFloat(LaneManager.laneCount)
        laneManager = LaneManager(roadLeft: roadLeft, roadWidth: roadWidth)
        laneCenters = (0..<LaneManager.laneCount).map { laneManager.centerX(for: $0) }

        let road = SKShapeNode(rectOf: CGSize(width: roadWidth, height: size.height + 80), cornerRadius: 16)
        road.position = CGPoint(x: size.width / 2, y: size.height / 2)
        road.fillColor = SKColor(red: 0.035, green: 0.038, blue: 0.06, alpha: 1)
        road.strokeColor = UITheme.Color.cyan.withAlphaComponent(0.45)
        road.lineWidth = 2
        road.glowWidth = 6
        roadNode.addChild(road)

        for lane in 1..<LaneManager.laneCount {
            let x = roadLeft + CGFloat(lane) * laneWidth
            for dash in stride(from: -40, through: size.height + 80, by: 78) {
                let marker = SKShapeNode(rectOf: CGSize(width: max(2, laneWidth * 0.12), height: 34), cornerRadius: 2)
                marker.position = CGPoint(x: x, y: dash)
                marker.fillColor = SKColor.white.withAlphaComponent(lane.isMultiple(of: 2) ? 0.5 : 0.25)
                marker.strokeColor = .clear
                roadNode.addChild(marker)
                marker.run(.repeatForever(.sequence([
                    .moveBy(x: 0, y: -78, duration: 0.62),
                    .moveBy(x: 0, y: 78, duration: 0)
                ])))
            }
        }

        let car = UIHelpers.carPreview(car: CarCatalog.defaultCar, paint: CarCatalog.defaultPaint, size: CGSize(width: max(28, laneWidth * 0.86), height: 74))
        car.position = CGPoint(x: laneManager.xPositionForSlot(playerSlot), y: size.height * 0.22)
        car.zPosition = 10
        player = car
        roadNode.addChild(car)

        let title = UIHelpers.label("QUICK CHASE SCHOOL", size: 28, color: UITheme.Color.gold, width: size.width - 28)
        title.position = CGPoint(x: size.width / 2, y: UIHelpers.topSafeY(in: self, padding: 92))
        uiNode.addChild(title)

        let skip = UIHelpers.button(text: "SKIP", name: "tutorial.skip", size: CGSize(width: 82, height: 32), style: .ghost)
        skip.position = CGPoint(x: size.width - 54, y: UIHelpers.topSafeY(in: self, padding: 76))
        uiNode.addChild(skip)
    }

    private func showStage(_ newStage: Stage) {
        stage = newStage
        stageTimer = 0
        prompt?.removeFromParent()

        let text: String
        switch newStage {
        case .move:
            text = "Swipe or tap to cut across lanes."
        case .traffic:
            spawnEasyTraffic()
            text = "Traffic is slower. Read the gaps."
        case .nearMiss:
            spawnNearMissSetup()
            text = "Skim close for a near-miss bonus."
        case .boost:
            triggerBoostDemo()
            text = "Dodge Boost makes lane changes sharper."
        case .exit:
            spawnExitRamp()
            text = "Exit right! Take the ramp!"
        case .complete:
            completeTutorial()
            return
        }

        let label = UIHelpers.label(text, size: 18, color: .white, width: size.width - 52)
        label.position = CGPoint(x: size.width / 2, y: UIHelpers.topSafeY(in: self, padding: 132))
        prompt = label
        uiNode.addChild(label)
        UIHelpers.pulse(label, scale: 1.04, duration: 0.55)
    }

    override func update(_ currentTime: TimeInterval) {
        let delta = lastUpdate > 0 ? min(1 / 20, currentTime - lastUpdate) : 0
        lastUpdate = currentTime
        totalTime += delta
        stageTimer += delta

        for node in trafficNode.children {
            node.position.y -= CGFloat(delta) * 210
            if node.position.y < -120 {
                node.removeFromParent()
            }
        }

        switch stage {
        case .move where stageTimer > 6:
            showStage(.traffic)
        case .traffic where stageTimer > 7:
            showStage(.nearMiss)
        case .nearMiss where stageTimer > 7:
            showStage(.boost)
        case .boost where stageTimer > 5:
            showStage(.exit)
        case .exit where stageTimer > 10:
            showStage(.complete)
        default:
            break
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchStart = touches.first?.location(in: self)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isTransitioning, let location = touches.first?.location(in: self) else { return }
        if UIHelpers.nodeName(at: location, in: self) == "tutorial.skip" {
            completeTutorial(skipped: true)
            return
        }

        if !firstInputLogged {
            firstInputLogged = true
            AnalyticsManager.shared.firstInput(time: totalTime)
        }

        let start = touchStart ?? location
        let dx = location.x - start.x
        let direction = abs(dx) > 18 ? (dx > 0 ? 1 : -1) : (location.x > size.width / 2 ? 1 : -1)
        let fast = abs(dx) > 92
        movePlayer(delta: direction * (fast ? 4 : 2))

        if stage == .move {
            showStage(.traffic)
        }
    }

    private func movePlayer(delta: Int) {
        playerSlot = laneManager.clampSlot(playerSlot + delta, for: .car)
        guard let player else { return }
        let target = CGPoint(x: laneManager.xPositionForSlot(playerSlot), y: player.position.y)
        let move = SKAction.move(to: target, duration: 0.12)
        move.timingMode = .easeOut
        let tilt = SKAction.sequence([
            .rotate(toAngle: delta > 0 ? -0.14 : 0.14, duration: 0.04),
            .rotate(toAngle: 0, duration: 0.12)
        ])
        player.run(.group([move, tilt]))
        AudioManager.shared.play(.laneChange, volume: 0.55, cooldown: 0.06)
    }

    private func spawnEasyTraffic() {
        for lane in [1, 4, 8, 10] {
            addTraffic(lane: lane, y: size.height + CGFloat(lane % 3) * 76, color: lane.isMultiple(of: 2) ? UITheme.Color.cyan : UITheme.Color.gold)
        }
    }

    private func spawnNearMissSetup() {
        addTraffic(lane: laneManager.nearestLaneForSlot(playerSlot) + 1, y: size.height * 0.58, color: UITheme.Color.gold)
        showPop("+25 NEAR MISS", color: UITheme.Color.green)
        AudioManager.shared.play(.nearMiss, volume: 0.72, cooldown: 0.1)
    }

    private func triggerBoostDemo() {
        guard let player else { return }
        showPop("DODGE BOOST READY", color: UITheme.Color.cyan)
        let aura = SKShapeNode(ellipseOf: CGSize(width: 70, height: 104))
        aura.position = player.position
        aura.fillColor = UITheme.Color.cyan.withAlphaComponent(0.15)
        aura.strokeColor = UITheme.Color.cyan.withAlphaComponent(0.65)
        aura.glowWidth = 14
        aura.zPosition = 4
        effectsNode.addChild(aura)
        aura.run(.sequence([.fadeOut(withDuration: 1.1), .removeFromParent()]))
        AudioManager.shared.play(.powerUp, volume: 0.8, cooldown: 0.1)
    }

    private func spawnExitRamp() {
        let color = UITheme.Color.green
        let glow = SKShapeNode(rectOf: CGSize(width: laneWidth * 2.4, height: size.height), cornerRadius: 8)
        glow.position = CGPoint(x: laneCenters[LaneManager.laneCount - 1] - laneWidth * 0.5, y: size.height / 2)
        glow.fillColor = color.withAlphaComponent(0.16)
        glow.strokeColor = color
        glow.glowWidth = 12
        roadNode.addChild(glow)

        let sign = UIHelpers.label("EXIT RIGHT >>>", size: 26, color: color, width: size.width - 34)
        sign.position = CGPoint(x: size.width / 2, y: size.height * 0.68)
        uiNode.addChild(sign)
        UIHelpers.pulse(sign, scale: 1.08, duration: 0.28)
        AudioManager.shared.play(.cityTransition, volume: 0.84, cooldown: 0.1)
    }

    private func addTraffic(lane: Int, y: CGFloat, color: SKColor) {
        let clampedLane = max(0, min(LaneManager.laneCount - 1, lane))
        let car = SKShapeNode(rectOf: CGSize(width: max(24, laneWidth * 0.76), height: 62), cornerRadius: 6)
        car.fillColor = color.withAlphaComponent(0.9)
        car.strokeColor = SKColor.white.withAlphaComponent(0.45)
        car.glowWidth = 3
        car.position = CGPoint(x: laneCenters[clampedLane], y: y)
        trafficNode.addChild(car)
    }

    private func showPop(_ text: String, color: SKColor) {
        let label = UIHelpers.label(text, size: 22, color: color, width: size.width - 36)
        label.position = CGPoint(x: size.width / 2, y: size.height * 0.48)
        effectsNode.addChild(label)
        label.run(.sequence([
            .group([.moveBy(x: 0, y: 42, duration: 0.5), .fadeOut(withDuration: 0.5)]),
            .removeFromParent()
        ]))
    }

    private func completeTutorial(skipped: Bool = false) {
        guard !isTransitioning else { return }
        isTransitioning = true
        SaveManager.shared.setOnboardingCompleted(true)
        AnalyticsManager.shared.tutorialCompleted(skipped: skipped)
        if !skipped {
            showPop("TRAINING COMPLETE", color: UITheme.Color.gold)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + (skipped ? 0.05 : 0.65)) { [weak self] in
            guard let self else { return }
            UIHelpers.present(LevelSelectScene(size: self.size), from: self, transition: .doorsOpenVertical(withDuration: 0.26))
        }
    }
}
