import SpriteKit

private enum GarageTab {
    case cars
    case motorcycles
    case all
    case paints
}

final class GarageScene: SKScene {
    private let contentNode = SKNode()
    private var tab: GarageTab = .all
    private var carIndex = 0
    private var paintIndex = 0
    private var isTransitioning = false

    override func didMove(to view: SKView) {
        anchorPoint = .zero
        syncIndicesToSave()
        buildGarage()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        guard oldSize != .zero else { return }
        buildGarage()
    }

    private func syncIndicesToSave() {
        let save = SaveManager.shared.data
        carIndex = displayedVehicles.firstIndex { $0.id == save.selectedCarID } ?? 0
        paintIndex = CarCatalog.paints.firstIndex { $0.id == save.selectedPaintID } ?? 0
    }

    private var displayedVehicles: [CarDefinition] {
        switch tab {
        case .cars:
            return CarCatalog.carsOnly
        case .motorcycles:
            return CarCatalog.motorcycles
        case .all, .paints:
            return CarCatalog.cars
        }
    }

    private func buildGarage() {
        removeAllChildren()
        contentNode.removeAllChildren()
        isTransitioning = false
        backgroundColor = UITheme.Color.background
        addChild(contentNode)

        buildBackground()
        buildHeader()
        buildTabs()

        switch tab {
        case .cars, .motorcycles, .all:
            buildCarPanel()
        case .paints:
            buildPaintPanel()
        }

        let back = UIHelpers.button(text: "BACK", name: "garage.back", size: CGSize(width: 120, height: 38), fill: SKColor.white.withAlphaComponent(0.12), stroke: .white)
        back.position = CGPoint(x: size.width / 2, y: 48)
        contentNode.addChild(back)
    }

    private func buildBackground() {
        for index in 0..<18 {
            let dot = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...5))
            dot.fillColor = (index.isMultiple(of: 2) ? SKColor.cyan : SKColor.magenta).withAlphaComponent(0.3)
            dot.strokeColor = .clear
            dot.glowWidth = 8
            dot.position = CGPoint(x: CGFloat.random(in: 0...max(size.width, 1)), y: CGFloat.random(in: 0...max(size.height, 1)))
            contentNode.addChild(dot)
        }
    }

    private func buildHeader() {
        let title = UIHelpers.label("GARAGE", size: UITheme.Font.titleSize, color: UITheme.Color.gold, width: size.width - 32)
        title.position = CGPoint(x: size.width / 2, y: size.height - 76)
        contentNode.addChild(title)

        let cash = UIHelpers.bodyLabel("$\(SaveManager.shared.data.totalCash)", size: 18, color: UITheme.Color.gold)
        cash.position = CGPoint(x: size.width / 2, y: size.height - 112)
        contentNode.addChild(cash)
    }

    private func buildTabs() {
        let allFill = tab == .all ? UITheme.Color.gold.withAlphaComponent(0.26) : SKColor.white.withAlphaComponent(0.08)
        let carsFill = tab == .cars ? SKColor.cyan.withAlphaComponent(0.3) : SKColor.white.withAlphaComponent(0.08)
        let bikesFill = tab == .motorcycles ? UITheme.Color.green.withAlphaComponent(0.26) : SKColor.white.withAlphaComponent(0.08)
        let paintsFill = tab == .paints ? SKColor.magenta.withAlphaComponent(0.3) : SKColor.white.withAlphaComponent(0.08)

        let buttonWidth = min((size.width - 44) / 4, 86)
        let all = UIHelpers.button(text: "ALL", name: "garage.tab.all", size: CGSize(width: buttonWidth, height: 34), fill: allFill, stroke: UITheme.Color.gold)
        all.position = CGPoint(x: size.width / 2 - buttonWidth * 1.5 - 6, y: size.height - 154)
        contentNode.addChild(all)

        let cars = UIHelpers.button(text: "CARS", name: "garage.tab.cars", size: CGSize(width: buttonWidth, height: 34), fill: carsFill, stroke: .cyan)
        cars.position = CGPoint(x: size.width / 2 - buttonWidth * 0.5 - 2, y: size.height - 154)
        contentNode.addChild(cars)

        let bikes = UIHelpers.button(text: "BIKES", name: "garage.tab.bikes", size: CGSize(width: buttonWidth, height: 34), fill: bikesFill, stroke: UITheme.Color.green)
        bikes.position = CGPoint(x: size.width / 2 + buttonWidth * 0.5 + 2, y: size.height - 154)
        contentNode.addChild(bikes)

        let paints = UIHelpers.button(text: "PAINT", name: "garage.tab.paints", size: CGSize(width: buttonWidth, height: 34), fill: paintsFill, stroke: .magenta)
        paints.position = CGPoint(x: size.width / 2 + buttonWidth * 1.5 + 6, y: size.height - 154)
        contentNode.addChild(paints)
    }

    private func buildCarPanel() {
        let vehicles = displayedVehicles
        guard !vehicles.isEmpty else { return }
        carIndex = max(0, min(carIndex, vehicles.count - 1))
        let car = vehicles[carIndex]
        let paint = CarCatalog.paint(id: SaveManager.shared.data.selectedPaintID)
        let save = SaveManager.shared.data
        let unlocked = save.unlockedCarIDs.contains(car.id)
        let selected = save.selectedCarID == car.id

        addCarouselButtons()

        addRarityStage(color: car.rarity.color, y: size.height * 0.61, legendary: car.rarity == .legendary)

        let preview = UIHelpers.carPreview(car: car, paint: paint, size: CGSize(width: 118, height: 188))
        preview.position = CGPoint(x: size.width / 2, y: size.height * 0.61)
        preview.setScale(0.92)
        contentNode.addChild(preview)
        preview.run(.sequence([
            .scale(to: 1.04, duration: UITheme.Animation.standard),
            .scale(to: 1, duration: UITheme.Animation.quick)
        ]))
        preview.run(.repeatForever(.sequence([
            .rotate(toAngle: -0.035, duration: 1.25),
            .rotate(toAngle: 0.035, duration: 1.25)
        ])), withKey: "garageRotate")

        let name = UIHelpers.label(car.displayName.uppercased(), size: 27, color: car.rarity.color, width: size.width - 46)
        name.position = CGPoint(x: size.width / 2, y: size.height * 0.43)
        contentNode.addChild(name)

        let rarity = UIHelpers.bodyLabel("\(car.rarity.displayName)  \(car.vehicleClass.displayName.uppercased())  \(carIndex + 1)/\(vehicles.count)", size: 15, color: car.rarity.color)
        rarity.position = CGPoint(x: size.width / 2, y: size.height * 0.39)
        contentNode.addChild(rarity)
        rarity.run(.sequence([.scale(to: 1.1, duration: 0.12), .scale(to: 1, duration: 0.16)]))

        let splitText = car.canLaneSplit ? "Lane Split Enabled" : "Lane Centers Only"
        let desc = UIHelpers.bodyLabel("\(car.description)  \(splitText).", size: 13, color: UITheme.Color.secondaryText, width: min(size.width - 52, 330))
        desc.position = CGPoint(x: size.width / 2, y: size.height * 0.35)
        contentNode.addChild(desc)

        addStats(car: car, y: size.height * 0.28)

        let actionText: String
        let actionName: String
        let fill: SKColor
        let stroke: SKColor
        if selected {
            actionText = "SELECTED"
            actionName = "garage.noop"
            fill = SKColor.green.withAlphaComponent(0.18)
            stroke = .green
        } else if unlocked {
            actionText = "SELECT"
            actionName = "garage.select.car"
            fill = SKColor.cyan.withAlphaComponent(0.2)
            stroke = .cyan
        } else if save.totalCash >= car.unlockCost {
            actionText = "UNLOCK $\(car.unlockCost)"
            actionName = "garage.unlock.car"
            fill = SKColor(red: 1, green: 0.78, blue: 0.12, alpha: 0.22)
            stroke = SKColor(red: 1, green: 0.78, blue: 0.12, alpha: 1)
        } else {
            actionText = "NEED $\(car.unlockCost - save.totalCash) MORE"
            actionName = "garage.noop"
            fill = SKColor.red.withAlphaComponent(0.12)
            stroke = SKColor.red.withAlphaComponent(0.6)
        }

        let action = UIHelpers.button(text: actionText, name: actionName, size: CGSize(width: min(size.width - 84, 260), height: 44), fill: fill, stroke: stroke)
        action.position = CGPoint(x: size.width / 2, y: 104)
        contentNode.addChild(action)
    }

    private func buildPaintPanel() {
        let car = CarCatalog.car(id: SaveManager.shared.data.selectedCarID)
        let paint = CarCatalog.paints[paintIndex]
        let save = SaveManager.shared.data
        let unlocked = save.unlockedPaintIDs.contains(paint.id)
        let selected = save.selectedPaintID == paint.id

        addCarouselButtons()

        addRarityStage(color: paint.rarity.color, y: size.height * 0.61, legendary: paint.rarity == .legendary)

        let preview = UIHelpers.carPreview(car: car, paint: paint, size: CGSize(width: 118, height: 188))
        preview.position = CGPoint(x: size.width / 2, y: size.height * 0.61)
        contentNode.addChild(preview)
        preview.run(.repeatForever(.sequence([
            .rotate(toAngle: -0.03, duration: 1.2),
            .rotate(toAngle: 0.03, duration: 1.2)
        ])))

        let name = UIHelpers.label(paint.displayName.uppercased(), size: 27, color: paint.rarity.color, width: size.width - 46)
        name.position = CGPoint(x: size.width / 2, y: size.height * 0.43)
        contentNode.addChild(name)

        let rarity = UIHelpers.bodyLabel("\(paint.rarity.displayName)  \(paintIndex + 1)/\(CarCatalog.paints.count)", size: 15, color: paint.rarity.color)
        rarity.position = CGPoint(x: size.width / 2, y: size.height * 0.39)
        contentNode.addChild(rarity)

        let swatch = SKShapeNode(rectOf: CGSize(width: 112, height: 32), cornerRadius: 8)
        swatch.fillColor = paint.id == CarCatalog.defaultPaintID ? car.bodyColor : paint.primaryColor
        swatch.strokeColor = paint.id == CarCatalog.defaultPaintID ? car.accentColor : paint.accentColor
        swatch.lineWidth = 3
        swatch.glowWidth = 5
        swatch.position = CGPoint(x: size.width / 2, y: size.height * 0.33)
        contentNode.addChild(swatch)

        let actionText: String
        let actionName: String
        let fill: SKColor
        let stroke: SKColor
        if selected {
            actionText = "SELECTED"
            actionName = "garage.noop"
            fill = SKColor.green.withAlphaComponent(0.18)
            stroke = .green
        } else if unlocked {
            actionText = "SELECT"
            actionName = "garage.select.paint"
            fill = SKColor.magenta.withAlphaComponent(0.2)
            stroke = .magenta
        } else if save.totalCash >= paint.unlockCost {
            actionText = "UNLOCK $\(paint.unlockCost)"
            actionName = "garage.unlock.paint"
            fill = SKColor(red: 1, green: 0.78, blue: 0.12, alpha: 0.22)
            stroke = SKColor(red: 1, green: 0.78, blue: 0.12, alpha: 1)
        } else {
            actionText = "NEED $\(paint.unlockCost - save.totalCash) MORE"
            actionName = "garage.noop"
            fill = SKColor.red.withAlphaComponent(0.12)
            stroke = SKColor.red.withAlphaComponent(0.6)
        }

        let action = UIHelpers.button(text: actionText, name: actionName, size: CGSize(width: min(size.width - 84, 260), height: 44), fill: fill, stroke: stroke)
        action.position = CGPoint(x: size.width / 2, y: 104)
        contentNode.addChild(action)
    }

    private func addCarouselButtons() {
        let left = UIHelpers.button(text: "<", name: "garage.prev", size: CGSize(width: 46, height: 54), fill: SKColor.white.withAlphaComponent(0.08), stroke: .white)
        left.position = CGPoint(x: 44, y: size.height * 0.6)
        contentNode.addChild(left)

        let right = UIHelpers.button(text: ">", name: "garage.next", size: CGSize(width: 46, height: 54), fill: SKColor.white.withAlphaComponent(0.08), stroke: .white)
        right.position = CGPoint(x: size.width - 44, y: size.height * 0.6)
        contentNode.addChild(right)
    }

    private func addRarityStage(color: SKColor, y: CGFloat, legendary: Bool) {
        let ring = SKShapeNode(ellipseOf: CGSize(width: legendary ? 184 : 156, height: legendary ? 218 : 196))
        ring.fillColor = color.withAlphaComponent(legendary ? 0.14 : 0.09)
        ring.strokeColor = color.withAlphaComponent(legendary ? 0.7 : 0.38)
        ring.lineWidth = legendary ? 3 : 2
        ring.glowWidth = legendary ? 18 : 9
        ring.position = CGPoint(x: size.width / 2, y: y)
        contentNode.addChild(ring)
        ring.run(.repeatForever(.sequence([
            .scale(to: legendary ? 1.08 : 1.04, duration: 1.0),
            .scale(to: 1, duration: 1.0)
        ])))

        if legendary {
            for index in 0..<10 {
                let spark = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...4))
                spark.fillColor = color.withAlphaComponent(0.72)
                spark.strokeColor = .clear
                spark.glowWidth = 6
                let angle = CGFloat(index) / 10 * CGFloat.pi * 2
                spark.position = CGPoint(x: size.width / 2 + cos(angle) * 92, y: y + sin(angle) * 108)
                contentNode.addChild(spark)
                spark.run(.repeatForever(.sequence([
                    .fadeAlpha(to: 0.18, duration: TimeInterval.random(in: 0.5...0.9)),
                    .fadeAlpha(to: 0.8, duration: TimeInterval.random(in: 0.5...0.9))
                ])))
            }
        }
    }

    private func addStats(car: CarDefinition, y: CGFloat) {
        let stats: [(String, CGFloat)]
        if car.vehicleClass == .motorcycle {
            stats = [
                ("Lane Split", car.nearMissMultiplier),
                ("Handling", car.handling),
                ("Fragility", 1.35 - car.collisionWidthMultiplier),
                ("Combo", car.scoreMultiplier),
                ("Police", car.policeResistance)
            ]
        } else {
            stats = [
                ("Handling", car.handling),
                ("Dodge", car.dodgeBoost),
                ("Cash", car.cashMultiplier),
                ("Score", car.scoreMultiplier),
                ("Police", car.policeResistance)
            ]
        }

        let barWidth = min(size.width - 96, 280)
        for (index, stat) in stats.enumerated() {
            let rowY = y + 42 - CGFloat(index) * 22
            let label = UIHelpers.bodyLabel(stat.0.uppercased(), size: 9, color: UITheme.Color.secondaryText)
            label.horizontalAlignmentMode = .left
            label.position = CGPoint(x: size.width / 2 - barWidth / 2, y: rowY)
            contentNode.addChild(label)

            let value = UIHelpers.bodyLabel(String(format: "%.2fx", Double(stat.1)), size: 10, color: .white)
            value.horizontalAlignmentMode = .right
            value.position = CGPoint(x: size.width / 2 + barWidth / 2, y: rowY)
            contentNode.addChild(value)

            let normalized = max(0.08, min(1, (stat.1 - 0.86) / 0.34))
            let bar = UIHelpers.progressBar(width: barWidth * 0.54, height: 5, progress: normalized, fill: stat.1 >= 1 ? UITheme.Color.green : UITheme.Color.cyan)
            bar.position = CGPoint(x: size.width / 2 + 14, y: rowY)
            bar.xScale = 0.05
            contentNode.addChild(bar)
            bar.run(.sequence([
                .wait(forDuration: 0.05 * Double(index)),
                .scaleX(to: 1, duration: 0.36)
            ]))
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isTransitioning,
              let location = touches.first?.location(in: self),
              let name = UIHelpers.nodeName(at: location, in: self) else { return }

        UIHelpers.animatePress(nodes(at: location).first { $0.name == name }?.parent?.name == name ? nodes(at: location).first { $0.name == name }?.parent : nodes(at: location).first { $0.name == name })
        AudioManager.shared.play(.menuClick, volume: 0.72, cooldown: 0.04)

        switch name {
        case "garage.back":
            isTransitioning = true
            UIHelpers.present(MainMenuScene(size: size), from: self)
        case "garage.tab.all":
            tab = .all
            syncIndicesToSave()
            buildGarage()
        case "garage.tab.cars":
            tab = .cars
            syncIndicesToSave()
            buildGarage()
        case "garage.tab.bikes":
            tab = .motorcycles
            syncIndicesToSave()
            buildGarage()
        case "garage.tab.paints":
            tab = .paints
            buildGarage()
        case "garage.prev":
            moveSelection(by: -1)
        case "garage.next":
            moveSelection(by: 1)
        case "garage.unlock.car":
            unlockCurrentCar()
        case "garage.select.car":
            let vehicles = displayedVehicles
            let id = vehicles[max(0, min(carIndex, vehicles.count - 1))].id
            SaveManager.shared.selectCar(id)
            AnalyticsManager.shared.carSelected(id: id)
            showSelectionPulse(text: "SELECTED")
            run(.wait(forDuration: 0.18)) { [weak self] in self?.buildGarage() }
        case "garage.unlock.paint":
            unlockCurrentPaint()
        case "garage.select.paint":
            SaveManager.shared.selectPaint(CarCatalog.paints[paintIndex].id)
            showSelectionPulse(text: "PAINT APPLIED")
            run(.wait(forDuration: 0.18)) { [weak self] in self?.buildGarage() }
        default:
            break
        }
    }

    private func moveSelection(by delta: Int) {
        switch tab {
        case .cars:
            carIndex = wrapped(carIndex + delta, count: displayedVehicles.count)
        case .motorcycles:
            carIndex = wrapped(carIndex + delta, count: displayedVehicles.count)
        case .all:
            carIndex = wrapped(carIndex + delta, count: displayedVehicles.count)
        case .paints:
            paintIndex = wrapped(paintIndex + delta, count: CarCatalog.paints.count)
        }
        buildGarage()
    }

    private func unlockCurrentCar() {
        let vehicles = displayedVehicles
        guard !vehicles.isEmpty else { return }
        let car = vehicles[max(0, min(carIndex, vehicles.count - 1))]
        guard !SaveManager.shared.data.unlockedCarIDs.contains(car.id),
              SaveManager.shared.spendCash(car.unlockCost) else {
            return
        }
        SaveManager.shared.unlockCar(car.id)
        SaveManager.shared.selectCar(car.id)
        AnalyticsManager.shared.carUnlocked(id: car.id)
        AnalyticsManager.shared.carSelected(id: car.id)
        _ = AchievementManager.shared.updateStoredProgress()
        showUnlockAnimation(title: "UNLOCKED", color: car.rarity.color)
        run(.wait(forDuration: 0.5)) { [weak self] in self?.buildGarage() }
    }

    private func unlockCurrentPaint() {
        let paint = CarCatalog.paints[paintIndex]
        guard !SaveManager.shared.data.unlockedPaintIDs.contains(paint.id),
              SaveManager.shared.spendCash(paint.unlockCost) else {
            return
        }
        SaveManager.shared.unlockPaint(paint.id)
        SaveManager.shared.selectPaint(paint.id)
        _ = AchievementManager.shared.updateStoredProgress()
        showUnlockAnimation(title: "PAINT UNLOCKED", color: paint.rarity.color)
        run(.wait(forDuration: 0.5)) { [weak self] in self?.buildGarage() }
    }

    private func showSelectionPulse(text: String) {
        let label = UIHelpers.label(text, size: 24, color: UITheme.Color.green)
        label.position = CGPoint(x: size.width / 2, y: size.height * 0.5)
        label.zPosition = 40
        contentNode.addChild(label)
        label.setScale(0.75)
        label.run(.sequence([
            .group([.scale(to: 1.12, duration: 0.12), .fadeIn(withDuration: 0.08)]),
            .scale(to: 1, duration: 0.1),
            .wait(forDuration: 0.22),
            .group([.moveBy(x: 0, y: 24, duration: 0.22), .fadeOut(withDuration: 0.22)]),
            .removeFromParent()
        ]))
    }

    private func showUnlockAnimation(title: String, color: SKColor) {
        AudioManager.shared.play(.powerUp, volume: 0.9, cooldown: 0.1)
        let label = UIHelpers.label(title, size: 30, color: color, width: size.width - 40)
        label.position = CGPoint(x: size.width / 2, y: size.height * 0.52)
        label.zPosition = 50
        contentNode.addChild(label)
        label.setScale(0.72)
        label.run(.sequence([
            .group([.scale(to: 1.14, duration: 0.16), .fadeIn(withDuration: 0.08)]),
            .scale(to: 1, duration: 0.12),
            .wait(forDuration: 0.26),
            .group([.scale(to: 1.2, duration: 0.2), .fadeOut(withDuration: 0.2)]),
            .removeFromParent()
        ]))

        for index in 0..<22 {
            let spark = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...5))
            spark.fillColor = color.withAlphaComponent(0.82)
            spark.strokeColor = .clear
            spark.glowWidth = 7
            spark.position = CGPoint(x: size.width / 2, y: size.height * 0.61)
            spark.zPosition = 45
            contentNode.addChild(spark)
            let angle = CGFloat(index) / 22 * CGFloat.pi * 2
            spark.run(.sequence([
                .group([
                    .moveBy(x: cos(angle) * CGFloat.random(in: 60...128), y: sin(angle) * CGFloat.random(in: 60...128), duration: 0.48),
                    .fadeOut(withDuration: 0.48),
                    .scale(to: 0.2, duration: 0.48)
                ]),
                .removeFromParent()
            ]))
        }
    }

    private func wrapped(_ index: Int, count: Int) -> Int {
        guard count > 0 else { return 0 }
        if index < 0 { return count - 1 }
        if index >= count { return 0 }
        return index
    }
}
