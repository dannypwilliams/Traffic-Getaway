import SpriteKit

final class OnboardingScene: SKScene {
    private enum Interaction {
        case none
        case laneChange
        case nearMiss
        case combo
        case policePressure
    }

    private struct Step {
        let title: String
        let subtitle: String
        let bullets: [String]
        let interaction: Interaction
    }

    private let contentNode = SKNode()
    private var stepIndex = 0
    private var isTransitioning = false
    private var actionComplete = false
    private var touchStart: CGPoint?
    private var trainingLane = 1
    private var trainingCombo = 0
    private weak var trainingCar: SKNode?
    private weak var promptLabel: SKLabelNode?

    private let steps: [Step] = [
        Step(
            title: "TRAFFIC GETAWAY",
            subtitle: "Swipe through traffic. Outrun the cops. Survive the city.",
            bullets: [],
            interaction: .none
        ),
        Step(
            title: "CONTROLS",
            subtitle: "Move one lane at a time.",
            bullets: [
                "Swipe left or right to change lanes",
                "Tap either side of the screen also works",
                "Quick lane changes can save a run"
            ],
            interaction: .laneChange
        ),
        Step(
            title: "NEAR MISSES",
            subtitle: "Risky driving is rewarded.",
            bullets: [
                "Drive close to traffic for bonus points",
                "Chain near misses to build combo",
                "Close calls trigger Dodge Boost"
            ],
            interaction: .nearMiss
        ),
        Step(
            title: "COMBO",
            subtitle: "Keep pressure on for bigger rewards.",
            bullets: [
                "Hit close calls back to back",
                "Combo boosts score",
                "Dodge Boost rewards aggressive driving"
            ],
            interaction: .combo
        ),
        Step(
            title: "POLICE PRESSURE",
            subtitle: "The chase gets tighter over time.",
            bullets: [
                "Keep moving",
                "Near misses push police back",
                "Survive longer to reach new cities"
            ],
            interaction: .policePressure
        ),
        Step(
            title: "READY?",
            subtitle: "Build your garage one escape at a time.",
            bullets: [
                "Earn cash and XP",
                "Complete missions",
                "Unlock cars and paints"
            ],
            interaction: .none
        )
    ]

    override func didMove(to view: SKView) {
        anchorPoint = .zero
        AudioManager.shared.configure()
        buildStep()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        guard oldSize != .zero else { return }
        buildStep()
    }

    private func buildStep() {
        removeAllChildren()
        contentNode.removeAllChildren()
        actionComplete = steps[stepIndex].interaction == .none
        trainingLane = 1
        trainingCombo = 0
        addChild(contentNode)

        backgroundColor = UITheme.Color.background
        buildBackground()

        let step = steps[stepIndex]
        let progress = UIHelpers.bodyLabel("\(stepIndex + 1) / \(steps.count)", size: 13, color: SKColor(white: 0.72, alpha: 1))
        progress.position = CGPoint(x: size.width / 2, y: size.height - 54)
        contentNode.addChild(progress)

        let title = UIHelpers.label(step.title, size: step.title.count > 12 ? 35 : 43, color: UITheme.Color.gold, width: size.width - 36)
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.72)
        contentNode.addChild(title)

        let subtitle = UIHelpers.bodyLabel(step.subtitle, size: 17, color: .white, width: size.width - 52)
        subtitle.position = CGPoint(x: size.width / 2, y: size.height * 0.63)
        contentNode.addChild(subtitle)

        buildIllustration(for: stepIndex)
        buildInteractionPrompt(for: step.interaction)
        buildBullets(step.bullets)
        buildPagerDots()
        buildButtons()
    }

    private func buildBackground() {
        for index in 0..<22 {
            let line = SKShapeNode(rectOf: CGSize(width: CGFloat.random(in: 1.5...3.5), height: CGFloat.random(in: 80...190)), cornerRadius: 1)
            line.fillColor = (index.isMultiple(of: 2) ? UITheme.Color.cyan : UITheme.Color.magenta).withAlphaComponent(0.14)
            line.strokeColor = .clear
            line.glowWidth = 6
            line.position = CGPoint(x: CGFloat.random(in: 0...max(size.width, 1)), y: CGFloat.random(in: 0...max(size.height, 1)))
            contentNode.addChild(line)
        }
    }

    private func buildIllustration(for index: Int) {
        let center = CGPoint(x: size.width / 2, y: size.height * 0.45)
        let road = SKShapeNode(rectOf: CGSize(width: min(size.width * 0.62, 230), height: 168), cornerRadius: 12)
        road.fillColor = SKColor(red: 0.05, green: 0.055, blue: 0.11, alpha: 1)
        road.strokeColor = SKColor.cyan.withAlphaComponent(0.55)
        road.lineWidth = 2
        road.position = center
        contentNode.addChild(road)

        for offset in [-46, 0, 46] {
            let marker = SKShapeNode(rectOf: CGSize(width: 5, height: 34), cornerRadius: 2)
            marker.fillColor = SKColor.white.withAlphaComponent(0.5)
            marker.strokeColor = .clear
            marker.position = CGPoint(x: center.x, y: center.y + CGFloat(offset))
            contentNode.addChild(marker)
        }

        let player = UIHelpers.carPreview(car: CarCatalog.defaultCar, paint: CarCatalog.defaultPaint, size: CGSize(width: 54, height: 88))
        player.position = CGPoint(x: center.x, y: center.y - 38)
        trainingCar = player
        contentNode.addChild(player)

        if index >= 1 {
            let leftArrow = UIHelpers.label("<", size: 36, color: SKColor.cyan)
            leftArrow.position = CGPoint(x: center.x - 88, y: center.y - 38)
            contentNode.addChild(leftArrow)
            let rightArrow = UIHelpers.label(">", size: 36, color: SKColor.cyan)
            rightArrow.position = CGPoint(x: center.x + 88, y: center.y - 38)
            contentNode.addChild(rightArrow)
        }

        if index >= 2 {
            let traffic = UIHelpers.carPreview(car: CarCatalog.car(id: "yellow_cab"), paint: CarCatalog.defaultPaint, size: CGSize(width: 46, height: 76))
            traffic.position = CGPoint(x: center.x + 48, y: center.y + 48)
            contentNode.addChild(traffic)
            traffic.run(.repeatForever(.sequence([
                .moveBy(x: 0, y: -92, duration: 1.2),
                .moveBy(x: 0, y: 92, duration: 0)
            ])))
            let bonus = UIHelpers.label("+25", size: 22, color: SKColor.green)
            bonus.position = CGPoint(x: center.x - 54, y: center.y + 48)
            contentNode.addChild(bonus)
        }

        if index >= 3 {
            let cash = UIHelpers.label("$", size: 34, color: SKColor(red: 1, green: 0.84, blue: 0.16, alpha: 1))
            cash.position = CGPoint(x: center.x - 78, y: center.y + 48)
            contentNode.addChild(cash)
            let star = UIHelpers.label("*", size: 34, color: SKColor.magenta)
            star.position = CGPoint(x: center.x + 78, y: center.y + 48)
            contentNode.addChild(star)
        }
    }

    private func buildInteractionPrompt(for interaction: Interaction) {
        let text: String
        switch interaction {
        case .none:
            return
        case .laneChange:
            text = "Try it: swipe or tap left/right"
        case .nearMiss:
            text = "Tap to slip past the taxi"
        case .combo:
            text = "Tap twice to chain a combo"
        case .policePressure:
            text = "Tap to dodge and push police back"
        }

        let label = UIHelpers.label(text, size: 16, color: UITheme.Color.cyan, width: size.width - 46)
        label.position = CGPoint(x: size.width / 2, y: size.height * 0.32)
        promptLabel = label
        contentNode.addChild(label)
        UIHelpers.pulse(label, scale: 1.04, duration: 0.6)
    }

    private func buildBullets(_ bullets: [String]) {
        guard !bullets.isEmpty else { return }
        let baseY = size.height * 0.27
        for (index, bullet) in bullets.enumerated() {
            let label = UIHelpers.bodyLabel(bullet, size: 14, color: SKColor(white: 0.86, alpha: 1), width: size.width - 54)
            label.position = CGPoint(x: size.width / 2, y: baseY - CGFloat(index) * 26)
            contentNode.addChild(label)
        }
    }

    private func buildPagerDots() {
        let y = 104.0
        for index in steps.indices {
            let dot = SKShapeNode(circleOfRadius: index == stepIndex ? 5 : 3.5)
            dot.fillColor = index == stepIndex ? SKColor.cyan : SKColor.white.withAlphaComponent(0.35)
            dot.strokeColor = .clear
            dot.position = CGPoint(x: size.width / 2 - 34 + CGFloat(index) * 17, y: CGFloat(y))
            contentNode.addChild(dot)
        }
    }

    private func buildButtons() {
        contentNode.children
            .filter { ($0.name ?? "").hasPrefix("onboarding.") }
            .forEach { $0.removeFromParent() }

        if stepIndex > 0 {
            let back = UIHelpers.button(text: "BACK", name: "onboarding.back", size: CGSize(width: 98, height: 38), style: .ghost)
            back.position = CGPoint(x: size.width / 2 - 74, y: 54)
            contentNode.addChild(back)
        }

        let isFinal = stepIndex == steps.count - 1
        let title = isFinal ? "START RUN" : (actionComplete ? "NEXT" : "TRY IT")
        let next = UIHelpers.button(text: title, name: isFinal ? "onboarding.start" : "onboarding.next", size: CGSize(width: isFinal ? 178 : 112, height: 44), style: actionComplete ? .primary : .secondary)
        next.position = CGPoint(x: stepIndex > 0 ? size.width / 2 + 74 : size.width / 2, y: 54)
        contentNode.addChild(next)

        let skip = UIHelpers.button(text: "SKIP", name: "onboarding.skip", size: CGSize(width: 82, height: 32), style: .ghost)
        skip.position = CGPoint(x: size.width - 54, y: size.height - 54)
        contentNode.addChild(skip)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchStart = touches.first?.location(in: self)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isTransitioning,
              let location = touches.first?.location(in: self) else { return }

        if handleTrainingTouch(at: location) {
            touchStart = nil
            return
        }

        guard let name = UIHelpers.nodeName(at: location, in: self) else { return }
        UIHelpers.animatePress(nodes(at: location).first { $0.name == name }?.parent?.name == name ? nodes(at: location).first { $0.name == name }?.parent : nodes(at: location).first { $0.name == name })
        AudioManager.shared.play(.menuClick, volume: 0.72, cooldown: 0.04)

        switch name {
        case "onboarding.next":
            guard actionComplete else {
                promptLabel?.run(.sequence([.scale(to: 1.12, duration: 0.08), .scale(to: 1, duration: 0.12)]))
                return
            }
            stepIndex = min(steps.count - 1, stepIndex + 1)
            buildStep()
        case "onboarding.back":
            stepIndex = max(0, stepIndex - 1)
            buildStep()
        case "onboarding.start":
            completeOnboarding()
        case "onboarding.skip":
            completeOnboarding()
        default:
            break
        }
        touchStart = nil
    }

    private func handleTrainingTouch(at location: CGPoint) -> Bool {
        let interaction = steps[stepIndex].interaction
        guard interaction != .none,
              UIHelpers.nodeName(at: location, in: self)?.hasPrefix("onboarding.") != true else {
            return false
        }

        switch interaction {
        case .laneChange:
            let start = touchStart ?? location
            let dx = location.x - start.x
            let direction: CGFloat = abs(dx) > 24 ? (dx > 0 ? 1 : -1) : (location.x > size.width / 2 ? 1 : -1)
            trainingLane = max(0, min(2, trainingLane + Int(direction)))
            let targetX = size.width / 2 + CGFloat(trainingLane - 1) * 48
            trainingCar?.run(.moveTo(x: targetX, duration: 0.16))
            completeAction(text: "LANE CHANGE")
            return true
        case .nearMiss:
            trainingCar?.run(.sequence([.moveBy(x: -48, y: 0, duration: 0.14), .moveBy(x: 48, y: 0, duration: 0.18)]))
            showPop("+25 NEAR MISS", color: UITheme.Color.green)
            completeAction(text: "DODGE BOOST READY")
            return true
        case .combo:
            trainingCombo += 1
            showPop("COMBO x\(trainingCombo)", color: trainingCombo >= 2 ? UITheme.Color.magenta : UITheme.Color.cyan)
            if trainingCombo >= 2 {
                completeAction(text: "COMBO ACTIVE")
            }
            return true
        case .policePressure:
            trainingCar?.run(.sequence([.scale(to: 1.1, duration: 0.08), .scale(to: 1, duration: 0.14)]))
            showPop("POLICE PUSHED BACK", color: UITheme.Color.gold)
            completeAction(text: "ESCAPE")
            return true
        case .none:
            return false
        }
    }

    private func completeAction(text: String) {
        guard !actionComplete else { return }
        actionComplete = true
        AudioManager.shared.play(.powerUp, volume: 0.75, cooldown: 0.1)
        promptLabel?.text = "\(text) - NEXT"
        promptLabel?.fontColor = UITheme.Color.green
        buildButtons()
    }

    private func showPop(_ text: String, color: SKColor) {
        let label = UIHelpers.label(text, size: 22, color: color, width: size.width - 44)
        label.position = CGPoint(x: size.width / 2, y: size.height * 0.45 + 92)
        contentNode.addChild(label)
        label.run(.sequence([
            .group([.moveBy(x: 0, y: 34, duration: 0.48), .fadeOut(withDuration: 0.48)]),
            .removeFromParent()
        ]))
    }

    private func completeOnboarding() {
        isTransitioning = true
        SaveManager.shared.setOnboardingCompleted(true)
        AnalyticsManager.shared.onboardingCompleted()
        UIHelpers.present(GameScene(size: size), from: self, transition: .doorsOpenVertical(withDuration: 0.28))
    }
}
