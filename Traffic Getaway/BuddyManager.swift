import Foundation
import SpriteKit

enum BuddyLineCategory: String, CaseIterable {
    case levelStart
    case trafficWarning
    case policeWarning
    case exitWarningLeft
    case exitWarningRight
    case exitCountdown
    case nearMiss
    case clutchSave
    case roadblockWarning
    case missedExit
    case levelComplete
    case failure
    case tutorial
}

/// Lightweight arcade radio chatter. It owns one popup at a time, applies
/// category/global cooldowns, and avoids blocking the playfield.
final class BuddyManager {
    private weak var parentNode: SKNode?
    private var sceneSize: CGSize = .zero
    private var popup: SKNode?
    private var lastGlobalTime: TimeInterval = -100
    private var lastCategoryTime: [BuddyLineCategory: TimeInterval] = [:]

    private let globalCooldown: TimeInterval = 2.8
    private let categoryCooldowns: [BuddyLineCategory: TimeInterval] = [
        .levelStart: 8,
        .trafficWarning: 9,
        .policeWarning: 9,
        .exitWarningLeft: 1,
        .exitWarningRight: 1,
        .exitCountdown: 3,
        .nearMiss: 5,
        .clutchSave: 3,
        .roadblockWarning: 3,
        .missedExit: 1,
        .levelComplete: 1,
        .failure: 1,
        .tutorial: 8
    ]

    func attach(to parent: SKNode, sceneSize: CGSize) {
        parentNode = parent
        self.sceneSize = sceneSize
    }

    func updateLayout(sceneSize: CGSize) {
        self.sceneSize = sceneSize
    }

    func say(_ category: BuddyLineCategory, detail: String? = nil, force: Bool = false) {
        guard let parentNode else { return }
        let now = Date().timeIntervalSince1970
        let categoryCooldown = categoryCooldowns[category] ?? 4
        let lastCategory = lastCategoryTime[category] ?? -100

        guard force || (now - lastGlobalTime >= globalCooldown && now - lastCategory >= categoryCooldown) else { return }

        lastGlobalTime = now
        lastCategoryTime[category] = now

        popup?.removeFromParent()
        let node = makePopup(text: detail ?? line(for: category), category: category)
        popup = node
        parentNode.addChild(node)
        animatePopup(node)
    }

    func dismiss() {
        popup?.removeAllActions()
        popup?.run(.sequence([.fadeOut(withDuration: 0.12), .removeFromParent()]))
        popup = nil
    }

    private func line(for category: BuddyLineCategory) -> String {
        let lines: [String]
        switch category {
        case .levelStart:
            lines = ["Floor it!", "Chase is live. Stay sharp.", "Punch it and keep moving."]
        case .trafficWarning:
            lines = ["Traffic's getting thick!", "Read the gaps, then cut.", "Watch the clusters ahead."]
        case .policeWarning:
            lines = ["Cops are closing in!", "They're right on us!", "Lose them in traffic!"]
        case .exitWarningLeft:
            lines = ["Exit on the left!", "Move left! Move left!", "Left exit coming up!"]
        case .exitWarningRight:
            lines = ["Exit on the right!", "Move right! Move right!", "Right exit coming up!"]
        case .exitCountdown:
            lines = ["Commit to the ramp!", "Pick a side and go!", "Exit window is closing!"]
        case .nearMiss:
            lines = ["That was way too close!", "Nice thread!", "You shaved the paint!"]
        case .clutchSave:
            lines = ["Insane save!", "How did we fit through that?", "Keep that boost alive!"]
        case .roadblockWarning:
            lines = ["Roadblock ahead!", "Barricades! Find the gap!", "They are blocking lanes!"]
        case .missedExit:
            lines = ["You missed it!", "That was the ramp!", "Not good. Heat's spiking!"]
        case .levelComplete:
            lines = ["We made it!", "Clean escape!", "That's our exit!"]
        case .failure:
            lines = ["We're boxed in!", "They're on us!", "That chase is done!"]
        case .tutorial:
            lines = ["Fast swipes jump lanes.", "Hold a side to carve across.", "Close calls charge Dodge Boost."]
        }
        return lines.randomElement() ?? "Go!"
    }

    private func makePopup(text: String, category: BuddyLineCategory) -> SKNode {
        let root = SKNode()
        root.zPosition = 132
        let importantExit = category == .exitWarningLeft || category == .exitWarningRight || category == .exitCountdown
        root.position = CGPoint(x: 12, y: importantExit ? max(104, min(136, sceneSize.height * 0.16)) : 82)
        root.alpha = 0

        let accent = color(for: category)
        let portraitSide: CGFloat = importantExit ? 42 : 34
        let bubbleHeight: CGFloat = importantExit ? 40 : 32
        let bubbleWidth = min(sceneSize.width - 86, importantExit ? 232 : 182)

        let portraitPanel = SKShapeNode(rectOf: CGSize(width: portraitSide, height: portraitSide), cornerRadius: 8)
        portraitPanel.position = CGPoint(x: portraitSide / 2, y: 0)
        portraitPanel.fillColor = SKColor(red: 0.035, green: 0.04, blue: 0.09, alpha: 0.94)
        portraitPanel.strokeColor = accent.withAlphaComponent(0.9)
        portraitPanel.lineWidth = 2
        portraitPanel.glowWidth = importantExit ? 5 : 3
        root.addChild(portraitPanel)

        let face = SKShapeNode(circleOfRadius: portraitSide * 0.29)
        face.fillColor = SKColor(red: 0.96, green: 0.72, blue: 0.52, alpha: 1)
        face.strokeColor = SKColor.black.withAlphaComponent(0.35)
        face.position = CGPoint(x: portraitSide / 2, y: 1)
        root.addChild(face)

        let visor = SKShapeNode(rectOf: CGSize(width: portraitSide * 0.58, height: 6), cornerRadius: 3)
        visor.fillColor = accent
        visor.strokeColor = .clear
        visor.position = CGPoint(x: portraitSide / 2, y: portraitSide * 0.17)
        root.addChild(visor)

        let mic = SKShapeNode(rectOf: CGSize(width: portraitSide * 0.3, height: 3), cornerRadius: 1.5)
        mic.fillColor = SKColor.black.withAlphaComponent(0.75)
        mic.strokeColor = .clear
        mic.position = CGPoint(x: portraitSide * 0.68, y: -portraitSide * 0.17)
        root.addChild(mic)

        let bubbleX = portraitSide + 10
        let bubble = SKShapeNode(rectOf: CGSize(width: bubbleWidth, height: bubbleHeight), cornerRadius: 8)
        bubble.position = CGPoint(x: bubbleX + bubbleWidth / 2, y: 0)
        bubble.fillColor = SKColor.black.withAlphaComponent(0.62)
        bubble.strokeColor = accent.withAlphaComponent(0.75)
        bubble.lineWidth = importantExit ? 1.6 : 1.25
        bubble.glowWidth = importantExit ? 4 : 2
        root.addChild(bubble)

        let label = SKLabelNode(fontNamed: UITheme.Font.body)
        label.text = text
        label.fontSize = importantExit ? 13 : 12
        label.fontColor = .white
        label.horizontalAlignmentMode = .left
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: bubbleX + 10, y: 0)
        fit(label, maxWidth: bubbleWidth - 18)
        root.addChild(label)

        return root
    }

    private func animatePopup(_ node: SKNode) {
        node.position.x -= 28
        node.setScale(0.96)
        let enter = SKAction.group([
            .fadeIn(withDuration: 0.1),
            .moveBy(x: 28, y: 0, duration: 0.16),
            .scale(to: 1, duration: 0.16)
        ])
        enter.timingMode = .easeOut
        let hold = SKAction.wait(forDuration: 1.35)
        let exit = SKAction.group([
            .fadeOut(withDuration: 0.18),
            .moveBy(x: -18, y: 0, duration: 0.18)
        ])
        node.run(.sequence([enter, hold, exit, .removeFromParent()]))
    }

    private func color(for category: BuddyLineCategory) -> SKColor {
        switch category {
        case .policeWarning, .missedExit, .failure, .roadblockWarning:
            return SKColor(red: 1, green: 0.16, blue: 0.16, alpha: 1)
        case .exitWarningLeft, .exitWarningRight, .exitCountdown, .levelComplete:
            return UITheme.Color.green
        case .nearMiss, .clutchSave:
            return UITheme.Color.gold
        case .trafficWarning:
            return UITheme.Color.orange
        case .levelStart, .tutorial:
            return UITheme.Color.cyan
        }
    }

    private func fit(_ label: SKLabelNode, maxWidth: CGFloat) {
        while label.frame.width > maxWidth && label.fontSize > 10 {
            label.fontSize -= 1
        }
    }
}
