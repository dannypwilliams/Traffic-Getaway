import SpriteKit

final class LevelSelectScene: SKScene {
    private let contentNode = SKNode()
    private var selectedCity: RunCity = .newYork
    private var isTransitioning = false

    override func didMove(to view: SKView) {
        anchorPoint = .zero
        buildLevelSelect()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        guard oldSize != .zero else { return }
        buildLevelSelect()
    }

    private func buildLevelSelect() {
        removeAllChildren()
        contentNode.removeAllChildren()
        isTransitioning = false
        backgroundColor = UITheme.Color.background
        addChild(contentNode)

        buildBackground()

        let title = UIHelpers.label("STORY CHASE", size: 34, color: UITheme.Color.gold, width: size.width - 34)
        title.position = CGPoint(x: size.width / 2, y: size.height - 70)
        contentNode.addChild(title)

        buildCityTabs()
        buildLevelCards()

        let endless = UIHelpers.button(text: "ENDLESS PURSUIT", name: "level.endless", size: CGSize(width: min(size.width - 76, 260), height: 38), fill: SKColor.cyan.withAlphaComponent(0.18), stroke: .cyan)
        endless.position = CGPoint(x: size.width / 2, y: 92)
        contentNode.addChild(endless)

        let back = UIHelpers.button(text: "MAIN MENU", name: "level.back", size: CGSize(width: 150, height: 36), fill: SKColor.white.withAlphaComponent(0.1), stroke: .white)
        back.position = CGPoint(x: size.width / 2, y: 42)
        contentNode.addChild(back)
    }

    private func buildBackground() {
        for index in 0..<20 {
            let line = SKShapeNode(rectOf: CGSize(width: CGFloat.random(in: 1.4...3), height: CGFloat.random(in: 70...170)), cornerRadius: 1)
            line.fillColor = (index.isMultiple(of: 2) ? UITheme.Color.cyan : UITheme.Color.magenta).withAlphaComponent(0.12)
            line.strokeColor = .clear
            line.glowWidth = 5
            line.position = CGPoint(x: CGFloat.random(in: 0...max(size.width, 1)), y: CGFloat.random(in: 0...max(size.height, 1)))
            contentNode.addChild(line)
        }
    }

    private func buildCityTabs() {
        let cities: [(RunCity, String)] = [(.newYork, "NEW YORK"), (.losAngeles, "L.A."), (.miami, "MIAMI")]
        let width = min((size.width - 48) / 3, 112)
        for (index, item) in cities.enumerated() {
            let city = item.0
            let selected = city == selectedCity
            let fill = selected ? UITheme.Color.cyan.withAlphaComponent(0.26) : SKColor.white.withAlphaComponent(0.08)
            let button = UIHelpers.button(text: item.1, name: "level.city.\(city.rawValue)", size: CGSize(width: width, height: 34), fill: fill, stroke: selected ? .cyan : SKColor.white.withAlphaComponent(0.55))
            button.position = CGPoint(x: size.width / 2 - width - 8 + CGFloat(index) * (width + 8), y: size.height - 122)
            contentNode.addChild(button)
        }
    }

    private func buildLevelCards() {
        let save = SaveManager.shared.data
        let levels = LevelCatalog.all.filter { $0.city == selectedCity }
        let topY = size.height - 178
        let cardHeight: CGFloat = 84
        let width = min(size.width - 34, 358)

        for (index, level) in levels.enumerated() {
            let unlocked = LevelCatalog.isUnlocked(level, completedIDs: save.completedLevelIDs)
            let completed = save.completedLevelIDs.contains(level.levelID)
            let stars = save.levelStarRatings[level.levelID] ?? 0
            let y = topY - CGFloat(index) * (cardHeight + 10)
            let stroke = completed ? UITheme.Color.green : (unlocked ? UITheme.Color.cyan : SKColor.white.withAlphaComponent(0.24))
            let panel = UIHelpers.panel(size: CGSize(width: width, height: cardHeight), fill: UITheme.Color.panelDeep.withAlphaComponent(unlocked ? 0.96 : 0.5), stroke: stroke)
            panel.position = CGPoint(x: size.width / 2, y: y)
            panel.name = unlocked ? "level.play.\(level.levelID)" : "level.locked"
            contentNode.addChild(panel)

            let number = LevelCatalog.displayNumber(for: level.levelID)
            let title = UIHelpers.label("\(number). \(level.name.uppercased())", size: 15, color: unlocked ? .white : SKColor(white: 0.5, alpha: 1), width: width - 24)
            title.horizontalAlignmentMode = .left
            title.position = CGPoint(x: panel.position.x - width / 2 + 16, y: y + 24)
            title.name = panel.name
            contentNode.addChild(title)

            let reward = UIHelpers.bodyLabel("$\(level.rewardCash)  \(level.rewardXP)XP", size: 11, color: UITheme.Color.gold)
            reward.horizontalAlignmentMode = .right
            reward.position = CGPoint(x: panel.position.x + width / 2 - 16, y: y + 24)
            reward.name = panel.name
            contentNode.addChild(reward)

            let score = save.levelBestScores[level.levelID] ?? 0
            let combo = save.levelBestCombos[level.levelID] ?? 0
            let time = save.levelBestEscapeTimes[level.levelID].map { "\(Int($0))s" } ?? "--"
            let detailText = unlocked ? "Best \(score)  Combo x\(combo)  Time \(time)" : lockedDetailText(for: level)
            let detail = UIHelpers.bodyLabel(detailText, size: 11, color: UITheme.Color.secondaryText, width: width - 32)
            detail.horizontalAlignmentMode = .left
            detail.position = CGPoint(x: panel.position.x - width / 2 + 16, y: y - 2)
            detail.name = panel.name
            contentNode.addChild(detail)

            let starText = String(repeating: "*", count: stars) + String(repeating: "-", count: max(0, 3 - stars))
            let starsLabel = UIHelpers.label(starText, size: 17, color: stars > 0 ? UITheme.Color.gold : SKColor.white.withAlphaComponent(0.25))
            starsLabel.horizontalAlignmentMode = .left
            starsLabel.position = CGPoint(x: panel.position.x - width / 2 + 16, y: y - 28)
            starsLabel.name = panel.name
            contentNode.addChild(starsLabel)

            let state = UIHelpers.bodyLabel(completed ? "ESCAPED" : (unlocked ? "READY" : "LOCKED"), size: 11, color: stroke)
            state.horizontalAlignmentMode = .right
            state.position = CGPoint(x: panel.position.x + width / 2 - 16, y: y - 28)
            state.name = panel.name
            contentNode.addChild(state)
        }
    }

    private func lockedDetailText(for level: LevelDefinition) -> String {
        guard let index = LevelCatalog.all.firstIndex(where: { $0.levelID == level.levelID }),
              index > 0 else {
            return "Locked"
        }

        return "Clear \(LevelCatalog.all[index - 1].name) to unlock"
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isTransitioning,
              let location = touches.first?.location(in: self),
              let name = UIHelpers.nodeName(at: location, in: self) else { return }

        UIHelpers.animatePress(nodes(at: location).first { $0.name == name }?.parent?.name == name ? nodes(at: location).first { $0.name == name }?.parent : nodes(at: location).first { $0.name == name })
        AudioManager.shared.play(.menuClick, volume: 0.72, cooldown: 0.04)

        if name == "level.back" {
            isTransitioning = true
            UIHelpers.present(MainMenuScene(size: size), from: self)
            return
        }

        if name == "level.endless" {
            isTransitioning = true
            UIHelpers.present(GameScene(size: size, mode: .endlessPursuit, level: nil), from: self, transition: .doorsOpenVertical(withDuration: 0.28))
            return
        }

        if name.hasPrefix("level.city.") {
            let raw = String(name.dropFirst("level.city.".count))
            selectedCity = RunCity(rawValue: raw) ?? selectedCity
            buildLevelSelect()
            return
        }

        if name.hasPrefix("level.play.") {
            let id = String(name.dropFirst("level.play.".count))
            guard let level = LevelCatalog.level(id: id),
                  LevelCatalog.isUnlocked(level, completedIDs: SaveManager.shared.data.completedLevelIDs) else { return }
            isTransitioning = true
            UIHelpers.present(GameScene(size: size, mode: .storyChase, level: level), from: self, transition: .doorsOpenVertical(withDuration: 0.28))
        }
    }
}
