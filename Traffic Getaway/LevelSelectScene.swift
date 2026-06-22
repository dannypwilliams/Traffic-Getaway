import SpriteKit

final class LevelSelectScene: SKScene {
    private let contentNode = SKNode()
    private var selectedWorld: WorldThemeID = WorldThemeCatalog.defaultTheme.id
    private var isTransitioning = false

    override func didMove(to view: SKView) {
        anchorPoint = .zero
        selectedWorld = LevelCatalog.nextPlayableLevel(completedIDs: SaveManager.shared.data.completedLevelIDs).worldTheme.id
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

        let title = UIHelpers.label("CITY SELECT", size: 34, color: UITheme.Color.gold, width: size.width - 34)
        title.position = CGPoint(x: size.width / 2, y: size.height - 70)
        contentNode.addChild(title)

        buildCityCards()
        buildLevelCards()

        let endless = UIHelpers.button(text: "ENDLESS PURSUIT", name: "level.endless", size: CGSize(width: min(size.width - 76, 260), height: 38), fill: SKColor.cyan.withAlphaComponent(0.18), stroke: .cyan)
        endless.position = CGPoint(x: size.width / 2, y: 92)
        contentNode.addChild(endless)

        let back = UIHelpers.button(text: "MAIN MENU", name: "level.back", size: CGSize(width: 150, height: 36), fill: SKColor.white.withAlphaComponent(0.1), stroke: .white)
        back.position = CGPoint(x: size.width / 2, y: 42)
        contentNode.addChild(back)
    }

    private func buildBackground() {
        let theme = WorldThemeCatalog.theme(id: selectedWorld)
        let road = ArcadeArt.makeRoadSample(size: CGSize(width: min(size.width * 0.66, 280), height: size.height * 0.7), theme: theme)
        road.alpha = 0.3
        road.position = CGPoint(x: size.width / 2, y: size.height * 0.42)
        contentNode.addChild(road)

        for index in 0..<14 {
            let line = SKShapeNode(rectOf: CGSize(width: CGFloat.random(in: 1.4...3), height: CGFloat.random(in: 70...170)), cornerRadius: 1)
            line.fillColor = (index.isMultiple(of: 2) ? theme.palette.accent : theme.palette.secondAccent).withAlphaComponent(0.12)
            line.strokeColor = .clear
            line.glowWidth = 5
            line.position = CGPoint(x: CGFloat.random(in: 0...max(size.width, 1)), y: CGFloat.random(in: 0...max(size.height, 1)))
            contentNode.addChild(line)
        }
    }

    private func buildCityCards() {
        let save = SaveManager.shared.data
        let themes = WorldThemeCatalog.all
        let spacing = min(8, max(6, size.width * 0.02))
        let width = min((size.width - 34 - spacing * CGFloat(max(0, themes.count - 1))) / CGFloat(themes.count), 116)
        let cardHeight = min(96, max(90, size.height * 0.12))
        let totalWidth = width * CGFloat(themes.count) + spacing * CGFloat(max(0, themes.count - 1))
        let centerY = size.height - 142

        for (index, theme) in themes.enumerated() {
            let selected = theme.id == selectedWorld
            let unlocked = isWorldUnlocked(theme.id, save: save)
            let cardName = "level.world.\(theme.id.rawValue)"
            let x = size.width / 2 - totalWidth / 2 + width / 2 + CGFloat(index) * (width + spacing)
            let card = SKNode()
            card.name = cardName
            card.position = CGPoint(x: x, y: centerY)
            contentNode.addChild(card)

            let fillAlpha: CGFloat = unlocked ? (selected ? 0.96 : 0.78) : 0.42
            let stroke = selected ? theme.palette.accent : (unlocked ? theme.palette.secondAccent : SKColor.white.withAlphaComponent(0.24))
            let panel = UIHelpers.panel(size: CGSize(width: width, height: cardHeight), fill: theme.palette.panel.withAlphaComponent(fillAlpha), stroke: stroke)
            panel.name = cardName
            card.addChild(panel)

            let titleColor = unlocked ? UITheme.Color.text : SKColor.white.withAlphaComponent(0.48)
            let title = UIHelpers.label(theme.displayName.uppercased(), size: 13, color: titleColor, width: width - 10)
            title.name = cardName
            title.position = CGPoint(x: 0, y: cardHeight * 0.34)
            card.addChild(title)

            let identity = UIHelpers.bodyLabel(cityCardIdentity(for: theme), size: 9, color: unlocked ? UITheme.Color.secondaryText : SKColor.white.withAlphaComponent(0.38), width: width - 12)
            identity.name = cardName
            identity.position = CGPoint(x: 0, y: cardHeight * 0.16)
            card.addChild(identity)

            let difficulty = UIHelpers.bodyLabel(cityCardDifficulty(for: theme), size: 9, color: unlocked ? theme.palette.accent : SKColor.white.withAlphaComponent(0.36), width: width - 12)
            difficulty.name = cardName
            difficulty.position = CGPoint(x: 0, y: cardHeight * 0.02)
            card.addChild(difficulty)

            let road = ArcadeArt.makeRoadSample(size: CGSize(width: width - 18, height: 17), theme: theme)
            road.name = cardName
            road.alpha = unlocked ? 0.92 : 0.42
            road.position = CGPoint(x: 0, y: -cardHeight * 0.15)
            card.addChild(road)

            addPaletteStrip(for: theme, width: width - 18, name: cardName, to: card, y: -cardHeight * 0.3, alpha: unlocked ? 1 : 0.38)

            let actionY = -cardHeight * 0.42
            let actionBack = SKShapeNode(rectOf: CGSize(width: width - 18, height: 13), cornerRadius: 2)
            actionBack.name = cardName
            actionBack.fillColor = unlocked ? theme.palette.accent.withAlphaComponent(selected ? 0.28 : 0.16) : SKColor.black.withAlphaComponent(0.22)
            actionBack.strokeColor = unlocked ? theme.palette.accent.withAlphaComponent(0.62) : SKColor.white.withAlphaComponent(0.16)
            actionBack.lineWidth = 1
            actionBack.position = CGPoint(x: 0, y: actionY)
            card.addChild(actionBack)

            let state = UIHelpers.bodyLabel(cityCardState(for: theme, save: save), size: 9, color: unlocked ? (selected ? UITheme.Color.gold : theme.palette.secondAccent) : SKColor.white.withAlphaComponent(0.42), width: width - 14)
            state.name = cardName
            state.position = CGPoint(x: 0, y: actionY)
            card.addChild(state)
        }
    }

    private func buildLevelCards() {
        let save = SaveManager.shared.data
        let levels = WorldThemeCatalog.levels(in: selectedWorld)
        let cardSpacing: CGFloat = 8
        let compactGrid = size.height < 650
        let columns = compactGrid ? 2 : 1
        let rows = (levels.count + columns - 1) / columns
        let topEdge = size.height - 218
        let bottomEdge: CGFloat = 142
        let availableHeight = max(120, topEdge - bottomEdge)
        let maxCardHeight: CGFloat = compactGrid ? 58 : 84
        let minCardHeight: CGFloat = compactGrid ? 50 : 56
        let cardHeight = min(maxCardHeight, max(minCardHeight, (availableHeight - cardSpacing * CGFloat(max(0, rows - 1))) / CGFloat(max(1, rows))))
        let topY = topEdge - cardHeight / 2
        let fullWidth = min(size.width - 34, 358)
        let width = compactGrid ? (fullWidth - cardSpacing) / 2 : fullWidth
        let totalWidth = width * CGFloat(columns) + cardSpacing * CGFloat(max(0, columns - 1))

        for (index, level) in levels.enumerated() {
            let unlocked = LevelCatalog.isUnlocked(level, completedIDs: save.completedLevelIDs)
            let completed = save.completedLevelIDs.contains(level.levelID)
            let stars = save.levelStarRatings[level.levelID] ?? 0
            let column = index % columns
            let row = index / columns
            let x = size.width / 2 - totalWidth / 2 + width / 2 + CGFloat(column) * (width + cardSpacing)
            let y = topY - CGFloat(row) * (cardHeight + cardSpacing)
            let theme = level.worldTheme
            let stroke = completed ? UITheme.Color.green : (unlocked ? theme.palette.accent : SKColor.white.withAlphaComponent(0.24))
            let panel = UIHelpers.panel(size: CGSize(width: width, height: cardHeight), fill: UITheme.Color.panelDeep.withAlphaComponent(unlocked ? 0.96 : 0.5), stroke: stroke)
            panel.position = CGPoint(x: x, y: y)
            panel.name = unlocked ? "level.play.\(level.levelID)" : "level.locked"
            contentNode.addChild(panel)

            let number = LevelCatalog.displayNumber(for: level.levelID)
            let titleWidth = compactGrid ? width - 54 : width - 24
            let title = UIHelpers.label("\(number). \(level.name.uppercased())", size: compactGrid ? 12 : 15, color: unlocked ? .white : SKColor(white: 0.5, alpha: 1), width: titleWidth)
            title.horizontalAlignmentMode = .left
            title.position = CGPoint(x: panel.position.x - width / 2 + 16, y: y + cardHeight * 0.28)
            title.name = panel.name
            contentNode.addChild(title)

            let rewardText = compactGrid ? "$\(level.rewardCash)" : "$\(level.rewardCash)  \(level.rewardXP)XP"
            let reward = UIHelpers.bodyLabel(rewardText, size: compactGrid ? 9 : 11, color: UITheme.Color.gold)
            reward.horizontalAlignmentMode = .right
            reward.position = CGPoint(x: panel.position.x + width / 2 - 16, y: y + cardHeight * 0.28)
            reward.name = panel.name
            contentNode.addChild(reward)

            let score = save.levelBestScores[level.levelID] ?? 0
            let combo = save.levelBestCombos[level.levelID] ?? 0
            let time = save.levelBestEscapeTimes[level.levelID].map { "\(Int($0))s" } ?? "--"
            let detailText = compactGrid
                ? (unlocked ? "Best \(score)  x\(combo)  \(time)" : lockedDetailText(for: level, compact: true))
                : (unlocked ? "\(theme.displayName)  Best \(score)  Combo x\(combo)  Time \(time)" : lockedDetailText(for: level))
            let detail = UIHelpers.bodyLabel(detailText, size: compactGrid ? 9 : 11, color: UITheme.Color.secondaryText, width: width - 32)
            detail.horizontalAlignmentMode = .left
            detail.position = CGPoint(x: panel.position.x - width / 2 + 16, y: y - cardHeight * 0.02)
            detail.name = panel.name
            contentNode.addChild(detail)

            let starText = String(repeating: "*", count: stars) + String(repeating: "-", count: max(0, 3 - stars))
            let starsLabel = UIHelpers.label(starText, size: compactGrid ? 13 : 17, color: stars > 0 ? UITheme.Color.gold : SKColor.white.withAlphaComponent(0.25))
            starsLabel.horizontalAlignmentMode = .left
            starsLabel.position = CGPoint(x: panel.position.x - width / 2 + 16, y: y - cardHeight * 0.31)
            starsLabel.name = panel.name
            contentNode.addChild(starsLabel)

            let state = UIHelpers.bodyLabel(completed ? "ESCAPED" : (unlocked ? "READY" : "LOCKED"), size: compactGrid ? 9 : 11, color: stroke)
            state.horizontalAlignmentMode = .right
            state.position = CGPoint(x: panel.position.x + width / 2 - 16, y: y - cardHeight * 0.31)
            state.name = panel.name
            contentNode.addChild(state)
        }
    }

    private func cityCardIdentity(for theme: WorldTheme) -> String {
        switch theme.id {
        case .losAngeles:
            return "Sunlit freeway"
        case .newYork:
            return "Dense expressway"
        case .miami:
            return "Pastel coast"
        }
    }

    private func cityCardDifficulty(for theme: WorldTheme) -> String {
        switch theme.id {
        case .losAngeles:
            return "Starter readable"
        case .newYork:
            return "Urban pressure"
        case .miami:
            return "Fast coastal"
        }
    }

    private func isWorldUnlocked(_ themeID: WorldThemeID, save: SaveData) -> Bool {
        WorldThemeCatalog.levels(in: themeID).contains { LevelCatalog.isUnlocked($0, completedIDs: save.completedLevelIDs) }
    }

    private func cityCardState(for theme: WorldTheme, save: SaveData) -> String {
        guard isWorldUnlocked(theme.id, save: save) else {
            return "LOCKED"
        }

        if theme.id == selectedWorld {
            return "LEVELS READY"
        }

        let bestScore = WorldThemeCatalog.levels(in: theme.id)
            .compactMap { save.levelBestScores[$0.levelID] }
            .max() ?? 0
        return bestScore > 0 ? "BEST \(bestScore)" : "SELECT"
    }

    private func addPaletteStrip(for theme: WorldTheme, width: CGFloat, name: String, to parent: SKNode, y: CGFloat, alpha: CGFloat) {
        let colors = [
            theme.palette.background,
            theme.palette.road,
            theme.palette.shoulder,
            theme.palette.accent,
            theme.palette.secondAccent
        ]
        let spacing: CGFloat = 2
        let swatchWidth = (width - spacing * CGFloat(colors.count - 1)) / CGFloat(colors.count)
        let totalWidth = swatchWidth * CGFloat(colors.count) + spacing * CGFloat(colors.count - 1)

        for (index, color) in colors.enumerated() {
            let swatch = SKShapeNode(rectOf: CGSize(width: swatchWidth, height: 5), cornerRadius: 1)
            swatch.name = name
            swatch.fillColor = color.withAlphaComponent(alpha)
            swatch.strokeColor = .clear
            swatch.position = CGPoint(x: -totalWidth / 2 + swatchWidth / 2 + CGFloat(index) * (swatchWidth + spacing), y: y)
            parent.addChild(swatch)
        }
    }

    private func lockedDetailText(for level: LevelDefinition, compact: Bool = false) -> String {
        if compact {
            return "Clear previous route"
        }

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

        if name.hasPrefix("level.world.") {
            let raw = String(name.dropFirst("level.world.".count))
            selectedWorld = WorldThemeID(rawValue: raw) ?? selectedWorld
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
