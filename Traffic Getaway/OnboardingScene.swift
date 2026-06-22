import SpriteKit

final class OnboardingScene: SKScene {
    private enum Interaction {
        case none
        case laneChange
        case laneSplit
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
            subtitle: "Weave across twelve freeway lanes. Hit the exit before the cops close in.",
            bullets: [],
            interaction: .none
        ),
        Step(
            title: "FREEWAY CONTROLS",
            subtitle: "Move fast. Do not crawl across the road.",
            bullets: [
                "Swipe left or right to move one lane",
                "Fast swipes jump farther across traffic",
                "Hold a side to carve lane after lane"
            ],
            interaction: .laneChange
        ),
        Step(
            title: "MOTORCYCLES",
            subtitle: "Bikes can use the gaps cars cannot.",
            bullets: [
                "Cars snap to lane centers",
                "Motorcycles can split between lanes",
                "Smaller hitboxes mean higher risk"
            ],
            interaction: .laneSplit
        ),
        Step(
            title: "RISK DRIVING",
            subtitle: "Close passes fuel the chase.",
            bullets: [
                "Drive close to traffic for bonus points",
                "Lane splits and near misses build combo",
                "Close calls trigger Dodge Boost"
            ],
            interaction: .nearMiss
        ),
        Step(
            title: "EXIT RAMPS",
            subtitle: "A chase is won by reaching the ramp.",
            bullets: [
                "Your buddy calls out left or right",
                "Cross the freeway before time runs out",
                "Missing the exit spikes police pressure"
            ],
            interaction: .policePressure
        ),
        Step(
            title: "COMBO",
            subtitle: "Aggressive driving pays.",
            bullets: [
                "Chain risky passes back to back",
                "Higher combo means bigger rewards",
                "Stay calm when traffic gets dense"
            ],
            interaction: .combo
        ),
        Step(
            title: "READY?",
            subtitle: "Escape levels, earn rewards, and build the garage.",
            bullets: [
                "Earn cash, XP, and stars",
                "Complete missions",
                "Unlock cars, motorcycles, and paints"
            ],
            interaction: .none
        )
    ]

    override func didMove(to view: SKView) {
        anchorPoint = .zero
        buildStep()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            AudioManager.shared.configure()
        }
    }

    override func didChangeSize(_ oldSize: CGSize) {
        guard oldSize != .zero else { return }
        buildStep()
    }

    private func buildStep() {
        removeAllChildren()
        contentNode.removeAllChildren()
        actionComplete = steps[stepIndex].interaction == .none
        trainingLane = 5
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
        let roadWidth = trainingRoadWidth()
        let road = SKShapeNode(rectOf: CGSize(width: roadWidth, height: 174), cornerRadius: 12)
        road.fillColor = SKColor(red: 0.05, green: 0.055, blue: 0.11, alpha: 1)
        road.strokeColor = SKColor.cyan.withAlphaComponent(0.55)
        road.lineWidth = 2
        road.position = center
        contentNode.addChild(road)

        let laneWidth = roadWidth / CGFloat(LaneManager.laneCount)
        for separator in 1..<LaneManager.laneCount {
            let x = center.x - roadWidth / 2 + CGFloat(separator) * laneWidth
            for dash in 0..<3 {
                let marker = SKShapeNode(rectOf: CGSize(width: 2.2, height: 26), cornerRadius: 1)
                marker.fillColor = SKColor.white.withAlphaComponent(separator.isMultiple(of: 2) ? 0.38 : 0.22)
                marker.strokeColor = .clear
                marker.position = CGPoint(x: x, y: center.y - 58 + CGFloat(dash) * 56)
                contentNode.addChild(marker)
            }
        }

        let playerCar = index == 2 ? CarCatalog.car(id: CarCatalog.starterBikeID) : CarCatalog.defaultCar
        let playerSize = index == 2 ? CGSize(width: 48, height: 88) : CGSize(width: 48, height: 82)
        let player = UIHelpers.carPreview(car: playerCar, paint: CarCatalog.defaultPaint, size: playerSize)
        player.position = CGPoint(x: xForTrainingLane(trainingLane), y: center.y - 38)
        trainingCar = player
        contentNode.addChild(player)

        if index >= 1 {
            let leftArrow = UIHelpers.label("<", size: 36, color: SKColor.cyan)
            leftArrow.position = CGPoint(x: center.x - roadWidth * 0.42, y: center.y - 38)
            contentNode.addChild(leftArrow)
            let rightArrow = UIHelpers.label(">", size: 36, color: SKColor.cyan)
            rightArrow.position = CGPoint(x: center.x + roadWidth * 0.42, y: center.y - 38)
            contentNode.addChild(rightArrow)
        }

        if index >= 2 {
            let traffic = UIHelpers.carPreview(car: CarCatalog.car(id: "yellow_cab"), paint: CarCatalog.defaultPaint, size: CGSize(width: 46, height: 76))
            traffic.position = CGPoint(x: xForTrainingLane(6), y: center.y + 48)
            contentNode.addChild(traffic)
            traffic.run(.repeatForever(.sequence([
                .moveBy(x: 0, y: -92, duration: 1.2),
                .moveBy(x: 0, y: 92, duration: 0)
            ])))
            let secondTraffic = UIHelpers.carPreview(car: CarCatalog.car(id: "boxy_retro"), paint: CarCatalog.defaultPaint, size: CGSize(width: 46, height: 76))
            secondTraffic.position = CGPoint(x: xForTrainingLane(4), y: center.y + 18)
            contentNode.addChild(secondTraffic)
            let bonus = UIHelpers.label("+25", size: 22, color: SKColor.green)
            bonus.position = CGPoint(x: center.x - roadWidth * 0.31, y: center.y + 56)
            contentNode.addChild(bonus)
        }

        if index >= 3 {
            let sign = UIHelpers.label(index == 4 ? "EXIT RIGHT" : "x3", size: index == 4 ? 18 : 28, color: index == 4 ? UITheme.Color.green : UITheme.Color.magenta, width: roadWidth - 22)
            sign.position = CGPoint(x: center.x, y: center.y + 70)
            contentNode.addChild(sign)
            let arrow = UIHelpers.label(index == 4 ? ">>>" : "+50", size: 28, color: UITheme.Color.gold)
            arrow.position = CGPoint(x: index == 4 ? center.x + roadWidth * 0.31 : center.x - roadWidth * 0.31, y: center.y + 42)
            contentNode.addChild(arrow)
        }
    }

    private func trainingRoadWidth() -> CGFloat {
        min(size.width * 0.78, 302)
    }

    private func xForTrainingLane(_ lane: Int) -> CGFloat {
        let roadWidth = trainingRoadWidth()
        let laneWidth = roadWidth / CGFloat(LaneManager.laneCount)
        let clamped = max(0, min(LaneManager.laneCount - 1, lane))
        return size.width / 2 - roadWidth / 2 + laneWidth * (CGFloat(clamped) + 0.5)
    }

    private func buildInteractionPrompt(for interaction: Interaction) {
        let text: String
        switch interaction {
        case .none:
            return
        case .laneChange:
            text = "Try it: swipe, fast swipe, or tap a side"
        case .laneSplit:
            text = "Try it: tap to split the gap"
        case .nearMiss:
            text = "Tap to skim past traffic"
        case .combo:
            text = "Tap twice to chain a combo"
        case .policePressure:
            text = "Tap to commit to the exit"
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
            let direction = abs(dx) > 24 ? (dx > 0 ? 1 : -1) : (location.x > size.width / 2 ? 1 : -1)
            let lanesMoved = abs(dx) > 86 ? 2 : 1
            trainingLane = max(0, min(LaneManager.laneCount - 1, trainingLane + direction * lanesMoved))
            let targetX = xForTrainingLane(trainingLane)
            trainingCar?.run(.moveTo(x: targetX, duration: 0.16))
            completeAction(text: lanesMoved > 1 ? "FAST SWIPE" : "LANE CHANGE")
            return true
        case .laneSplit:
            trainingCar?.run(.sequence([
                .moveTo(x: (xForTrainingLane(5) + xForTrainingLane(6)) / 2, duration: 0.13),
                .rotate(toAngle: 0.12, duration: 0.08),
                .rotate(toAngle: 0, duration: 0.12)
            ]))
            showPop("LANE SPLIT +50", color: UITheme.Color.cyan)
            completeAction(text: "THREAD THE GAP")
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
            trainingLane = LaneManager.laneCount - 2
            trainingCar?.run(.moveTo(x: xForTrainingLane(trainingLane), duration: 0.18))
            showPop("EXIT COMMITTED", color: UITheme.Color.gold)
            completeAction(text: "RAMP READY")
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
