import SpriteKit
import UIKit

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
        let minimumReadTime: TimeInterval
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
    private var safeAreaInsets = UIEdgeInsets.zero
    private var didRenderVisibleFrame = false
    private var hasObservedFirstUpdate = false
    private var stepPresentedAt: TimeInterval?
    private var currentSceneTime: TimeInterval = 0
    private var lastCanAdvance = false

    private let steps: [Step] = [
        Step(
            title: "QUICK CHASE SCHOOL",
            subtitle: "Traffic is slower. Read the gaps.",
            bullets: [
                "Your getaway car is faster",
                "Choose an opening before you reach it"
            ],
            interaction: .none,
            minimumReadTime: 3.1
        ),
        Step(
            title: "CHANGE LANES",
            subtitle: "Swipe left or right to change lanes.",
            bullets: [
                "One swipe moves one lane",
                "Fast swipes cross wider gaps"
            ],
            interaction: .laneChange,
            minimumReadTime: 1.2
        ),
        Step(
            title: "KEEP MOVING",
            subtitle: "Do not sit still. Police close in when you hesitate.",
            bullets: [
                "Waiting in one lane raises pressure",
                "Clean lane changes keep the chase alive"
            ],
            interaction: .policePressure,
            minimumReadTime: 1.4
        ),
        Step(
            title: "COMMIT EARLY",
            subtitle: "Near misses build combo when you pick real gaps.",
            bullets: [
                "Close passes pay",
                "Mindless zigzags do not"
            ],
            interaction: .nearMiss,
            minimumReadTime: 1.4
        ),
        Step(
            title: "ONE REVIVE",
            subtitle: "Crash once and you may get one revive.",
            bullets: [
                "Use it to recover",
                "Then the next hit ends the run"
            ],
            interaction: .none,
            minimumReadTime: 1.5
        ),
        Step(
            title: "SURVIVE THE CHASE",
            subtitle: "Keep moving, read ahead, and hit the ramp.",
            bullets: [
                "Traffic crashes and police catches are different",
                "Changing lanes keeps the chase alive"
            ],
            interaction: .none,
            minimumReadTime: 1.5
        )
    ]

    override func didMove(to view: SKView) {
        anchorPoint = .zero
        safeAreaInsets = view.safeAreaInsets
        buildStep()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            AudioManager.shared.configure()
        }
    }

    override func didChangeSize(_ oldSize: CGSize) {
        guard oldSize != .zero else { return }
        safeAreaInsets = view?.safeAreaInsets ?? .zero
        buildStep()
    }

    override func update(_ currentTime: TimeInterval) {
        currentSceneTime = currentTime
        if !hasObservedFirstUpdate {
            hasObservedFirstUpdate = true
        } else if !didRenderVisibleFrame {
            didRenderVisibleFrame = true
            stepPresentedAt = currentTime
        }

        let canAdvanceNow = canAdvanceCurrentStep
        if canAdvanceNow != lastCanAdvance {
            lastCanAdvance = canAdvanceNow
            buildButtons()
        }
    }

    private func buildStep() {
        removeAllChildren()
        contentNode.removeAllChildren()
        actionComplete = steps[stepIndex].interaction == .none
        trainingLane = 5
        trainingCombo = 0
        hasObservedFirstUpdate = false
        didRenderVisibleFrame = false
        stepPresentedAt = nil
        lastCanAdvance = false
        addChild(contentNode)

        backgroundColor = UITheme.Color.background
        buildBackground()

        let step = steps[stepIndex]
        let compact = isCompactLayout
        let topY = size.height - topSafeInset
        let progress = UIHelpers.bodyLabel("\(stepIndex + 1) / \(steps.count)", size: 13, color: SKColor(white: 0.72, alpha: 1))
        progress.zPosition = 20
        progress.position = CGPoint(x: leadingSafeInset + 36, y: topY - 22)
        contentNode.addChild(progress)

        let titleSize: CGFloat = compact ? 25 : (step.title.count > 14 ? 31 : 35)
        let title = UIHelpers.label(step.title, size: titleSize, color: UITheme.Color.gold, width: size.width - 32)
        title.zPosition = 20
        title.position = CGPoint(x: size.width / 2, y: topY - (compact ? 68 : 74))
        contentNode.addChild(title)

        let subtitle = UIHelpers.bodyLabel(step.subtitle, size: compact ? 15 : 17, color: .white, width: size.width - 50)
        subtitle.zPosition = 20
        subtitle.position = CGPoint(x: size.width / 2, y: title.position.y - (compact ? 40 : 46))
        contentNode.addChild(subtitle)

        buildIllustration(for: stepIndex)
        buildInteractionPrompt(for: step.interaction)
        buildBullets(step.bullets)
        buildPagerDots()
        buildButtons()
    }

    private func buildBackground() {
        let wash = SKShapeNode(rect: CGRect(origin: .zero, size: size))
        wash.fillColor = UITheme.Color.panelDeep.withAlphaComponent(0.72)
        wash.strokeColor = .clear
        wash.zPosition = -20
        contentNode.addChild(wash)

        for index in 0..<22 {
            let line = SKShapeNode(rectOf: CGSize(width: CGFloat.random(in: 1.5...3.5), height: CGFloat.random(in: 80...190)), cornerRadius: 1)
            line.fillColor = (index.isMultiple(of: 2) ? UITheme.Color.cyan : UITheme.Color.magenta).withAlphaComponent(0.14)
            line.strokeColor = .clear
            line.glowWidth = 6
            line.zPosition = -10
            line.position = CGPoint(x: CGFloat.random(in: 0...max(size.width, 1)), y: CGFloat.random(in: 0...max(size.height, 1)))
            contentNode.addChild(line)
        }
    }

    private func buildIllustration(for index: Int) {
        let center = CGPoint(x: size.width / 2, y: illustrationCenterY)
        let roadWidth = trainingRoadWidth()
        let road = SKShapeNode(rectOf: CGSize(width: roadWidth, height: 174), cornerRadius: 12)
        road.fillColor = SKColor(red: 0.05, green: 0.055, blue: 0.11, alpha: 1)
        road.strokeColor = SKColor.cyan.withAlphaComponent(0.55)
        road.lineWidth = 2
        road.zPosition = 0
        road.position = center
        contentNode.addChild(road)

        let laneWidth = roadWidth / CGFloat(LaneManager.laneCount)
        for separator in 1..<LaneManager.laneCount {
            let x = center.x - roadWidth / 2 + CGFloat(separator) * laneWidth
            for dash in 0..<3 {
                let marker = SKShapeNode(rectOf: CGSize(width: 2.2, height: 26), cornerRadius: 1)
                marker.fillColor = SKColor.white.withAlphaComponent(separator.isMultiple(of: 2) ? 0.38 : 0.22)
                marker.strokeColor = .clear
                marker.zPosition = 1
                marker.position = CGPoint(x: x, y: center.y - 58 + CGFloat(dash) * 56)
                contentNode.addChild(marker)
            }
        }

        addTrainingTraffic(center: center, roadWidth: roadWidth, index: index)
        if index == 2 {
            addPolicePressureCue(center: center, roadWidth: roadWidth)
        }

        let playerCar = CarCatalog.defaultCar
        let playerSize = CGSize(width: 48, height: 82)
        let player = UIHelpers.carPreview(car: playerCar, paint: CarCatalog.defaultPaint, size: playerSize)
        player.position = CGPoint(x: xForTrainingLane(trainingLane), y: center.y - 38)
        player.zPosition = 4
        trainingCar = player
        contentNode.addChild(player)

        if index >= 1 {
            let leftArrow = UIHelpers.label("<", size: 36, color: SKColor.cyan)
            leftArrow.position = CGPoint(x: center.x - roadWidth * 0.42, y: center.y - 38)
            leftArrow.zPosition = 5
            contentNode.addChild(leftArrow)
            let rightArrow = UIHelpers.label(">", size: 36, color: SKColor.cyan)
            rightArrow.position = CGPoint(x: center.x + roadWidth * 0.42, y: center.y - 38)
            rightArrow.zPosition = 5
            contentNode.addChild(rightArrow)
        }

        if index >= 3 {
            let bonus = UIHelpers.label("+25", size: 22, color: SKColor.green)
            bonus.position = CGPoint(x: center.x - roadWidth * 0.31, y: center.y + 56)
            bonus.zPosition = 6
            contentNode.addChild(bonus)
        }

        if index >= 5 {
            let sign = UIHelpers.label("EXIT RIGHT", size: 18, color: UITheme.Color.green, width: roadWidth - 22)
            sign.position = CGPoint(x: center.x, y: center.y + 70)
            sign.zPosition = 6
            contentNode.addChild(sign)
            let arrow = UIHelpers.label(">>>", size: 28, color: UITheme.Color.gold)
            arrow.position = CGPoint(x: center.x + roadWidth * 0.31, y: center.y + 42)
            arrow.zPosition = 6
            contentNode.addChild(arrow)
        }
    }

    private func addTrainingTraffic(center: CGPoint, roadWidth: CGFloat, index: Int) {
        let traffic = UIHelpers.carPreview(car: CarCatalog.car(id: "yellow_cab"), paint: CarCatalog.defaultPaint, size: CGSize(width: 46, height: 76))
        traffic.position = CGPoint(x: xForTrainingLane(index == 0 ? 3 : 6), y: center.y + 48)
        traffic.zPosition = 3
        contentNode.addChild(traffic)

        let secondTraffic = UIHelpers.carPreview(car: CarCatalog.car(id: "boxy_retro"), paint: CarCatalog.defaultPaint, size: CGSize(width: 46, height: 76))
        secondTraffic.position = CGPoint(x: xForTrainingLane(index == 0 ? 7 : 4), y: center.y + 18)
        secondTraffic.zPosition = 3
        contentNode.addChild(secondTraffic)

        if index > 0 {
            traffic.run(.repeatForever(.sequence([
                .moveBy(x: 0, y: -92, duration: 1.2),
                .moveBy(x: 0, y: 92, duration: 0)
            ])))
        }

        let gap = SKShapeNode(rectOf: CGSize(width: max(30, roadWidth / CGFloat(LaneManager.laneCount) * 1.2), height: 142), cornerRadius: 6)
        gap.fillColor = SKColor.green.withAlphaComponent(index == 0 ? 0.12 : 0.07)
        gap.strokeColor = SKColor.green.withAlphaComponent(index == 0 ? 0.32 : 0.12)
        gap.lineWidth = 1.2
        gap.zPosition = 2
        gap.position = CGPoint(x: xForTrainingLane(5), y: center.y + 28)
        contentNode.addChild(gap)
    }

    private func addPolicePressureCue(center: CGPoint, roadWidth: CGFloat) {
        let siren = SKShapeNode(rectOf: CGSize(width: roadWidth * 0.72, height: 42), cornerRadius: 8)
        siren.fillColor = SKColor.red.withAlphaComponent(0.18)
        siren.strokeColor = SKColor.red.withAlphaComponent(0.42)
        siren.glowWidth = 5
        siren.zPosition = 2
        siren.position = CGPoint(x: center.x, y: center.y - 82)
        contentNode.addChild(siren)

        let label = UIHelpers.label("POLICE CLOSING", size: 15, color: SKColor.red, width: roadWidth - 28)
        label.zPosition = 6
        label.position = siren.position
        contentNode.addChild(label)
    }

    private func trainingRoadWidth() -> CGFloat {
        min(size.width * (isCompactLayout ? 0.8 : 0.78), 302)
    }

    private var isCompactLayout: Bool {
        size.width <= 340 || size.height <= 600
    }

    private var topSafeInset: CGFloat {
        max(safeAreaInsets.top, 18)
    }

    private var bottomSafeInset: CGFloat {
        max(safeAreaInsets.bottom, 12)
    }

    private var leadingSafeInset: CGFloat {
        max(safeAreaInsets.left, 12)
    }

    private var trailingSafeInset: CGFloat {
        max(safeAreaInsets.right, 12)
    }

    private var illustrationCenterY: CGFloat {
        if isCompactLayout {
            return max(bottomSafeInset + 226, min(size.height * 0.47, size.height - topSafeInset - 238))
        }
        return size.height * 0.45
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
            text = "Tap a gap to break the pressure"
        }

        let label = UIHelpers.label(text, size: isCompactLayout ? 14 : 16, color: UITheme.Color.cyan, width: size.width - 46)
        label.zPosition = 20
        label.position = CGPoint(x: size.width / 2, y: promptY)
        promptLabel = label
        contentNode.addChild(label)
        UIHelpers.pulse(label, scale: 1.04, duration: 0.6)
    }

    private func buildBullets(_ bullets: [String]) {
        guard !bullets.isEmpty else { return }
        let baseY = bulletBaseY
        for (index, bullet) in bullets.enumerated() {
            let label = UIHelpers.bodyLabel(bullet, size: isCompactLayout ? 12 : 14, color: SKColor(white: 0.86, alpha: 1), width: size.width - 54)
            label.zPosition = 20
            label.position = CGPoint(x: size.width / 2, y: baseY - CGFloat(index) * 26)
            contentNode.addChild(label)
        }
    }

    private var promptY: CGFloat {
        max(bottomSafeInset + 118, illustrationCenterY - (isCompactLayout ? 98 : 104))
    }

    private var bulletBaseY: CGFloat {
        min(promptY - 28, max(bottomSafeInset + 104, size.height * (isCompactLayout ? 0.27 : 0.28)))
    }

    private func buildPagerDots() {
        let y = bottomSafeInset + 86
        for index in steps.indices {
            let dot = SKShapeNode(circleOfRadius: index == stepIndex ? 5 : 3.5)
            dot.fillColor = index == stepIndex ? SKColor.cyan : SKColor.white.withAlphaComponent(0.35)
            dot.strokeColor = .clear
            dot.zPosition = 20
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

        let buttonY = bottomSafeInset + 38
        let isFinal = stepIndex == steps.count - 1
        let canAdvance = canAdvanceCurrentStep
        let title = isFinal ? (canAdvance ? "START RUN" : "READ") : (actionComplete ? (canAdvance ? "NEXT" : "READ") : "TRY IT")
        let nextStyle: UITheme.ButtonStyle = canAdvance ? .primary : .secondary
        let next = UIHelpers.button(text: title, name: isFinal ? "onboarding.start" : "onboarding.next", size: CGSize(width: isFinal ? 178 : 112, height: 44), style: actionComplete ? nextStyle : .secondary)
        next.alpha = actionComplete && !canAdvance ? 0.68 : 1
        next.zPosition = 24
        next.position = CGPoint(x: stepIndex > 0 ? size.width / 2 + 74 : size.width / 2, y: buttonY)
        contentNode.addChild(next)

        let skip = UIHelpers.button(text: "SKIP", name: "onboarding.skip", size: CGSize(width: 82, height: 32), style: .ghost)
        skip.zPosition = 24
        skip.position = CGPoint(x: size.width - trailingSafeInset - 41, y: size.height - topSafeInset - 22)
        contentNode.addChild(skip)

        if stepIndex > 0 {
            contentNode.childNode(withName: "onboarding.back")?.position = CGPoint(x: size.width / 2 - 74, y: buttonY)
            contentNode.childNode(withName: "onboarding.back")?.zPosition = 24
        }
    }

    private var canAdvanceCurrentStep: Bool {
        guard actionComplete, didRenderVisibleFrame, let stepPresentedAt else { return false }
        return currentSceneTime - stepPresentedAt >= steps[stepIndex].minimumReadTime
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
            guard actionComplete, canAdvanceCurrentStep else {
                promptLabel?.run(.sequence([.scale(to: 1.12, duration: 0.08), .scale(to: 1, duration: 0.12)]))
                return
            }
            stepIndex = min(steps.count - 1, stepIndex + 1)
            buildStep()
        case "onboarding.back":
            stepIndex = max(0, stepIndex - 1)
            buildStep()
        case "onboarding.start":
            guard canAdvanceCurrentStep else { return }
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
            showPop("PRESSURE DROPPED", color: UITheme.Color.gold)
            completeAction(text: "KEEP MOVING")
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
        label.zPosition = 26
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
