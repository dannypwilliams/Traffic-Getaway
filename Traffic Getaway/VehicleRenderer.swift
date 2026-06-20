import SpriteKit

enum VehicleRenderer {
    static func garagePreview(car: CarDefinition, paint: PaintDefinition, size: CGSize) -> SKNode {
        if car.vehicleClass == .motorcycle {
            return makeMotorcycleSprite(car: car, paint: paint, size: motorcyclePreviewSize(canvas: size), animated: true)
        }
        let sprite = makeCarSprite(car: car, paint: paint, size: previewBodySize(for: car.vehicleShapeStyle, canvas: size), animated: true)
        return sprite
    }

    static func gameplayCar(car: CarDefinition, paint: PaintDefinition, laneWidth: CGFloat) -> SKSpriteNode {
        if car.vehicleClass == .motorcycle {
            return makeMotorcycleSprite(car: car, paint: paint, size: motorcycleGameplaySize(laneWidth: laneWidth), animated: false)
        }
        return makeCarSprite(car: car, paint: paint, size: gameplaySize(for: car.vehicleShapeStyle, laneWidth: laneWidth), animated: false)
    }

    private static func motorcycleGameplaySize(laneWidth: CGFloat) -> CGSize {
        CGSize(width: min(18, max(13, laneWidth * 0.44)), height: min(74, max(54, laneWidth * 1.7)))
    }

    private static func motorcyclePreviewSize(canvas: CGSize) -> CGSize {
        CGSize(width: canvas.width * 0.46, height: canvas.height * 0.9)
    }

    private static func gameplaySize(for style: VehicleShapeStyle, laneWidth: CGFloat) -> CGSize {
        switch style {
        case .van:
            return CGSize(width: min(34, max(25, laneWidth * 0.92)), height: min(92, max(74, laneWidth * 2.45)))
        case .muscle, .luxury, .lowrider:
            return CGSize(width: min(34, max(25, laneWidth * 0.92)), height: min(92, max(74, laneWidth * 2.5)))
        case .speeder, .bullet, .crown:
            return CGSize(width: min(30, max(21, laneWidth * 0.76)), height: min(88, max(70, laneWidth * 2.38)))
        case .roadster:
            return CGSize(width: min(31, max(22, laneWidth * 0.82)), height: min(84, max(68, laneWidth * 2.2)))
        default:
            return CGSize(width: min(32, max(23, laneWidth * 0.84)), height: min(84, max(68, laneWidth * 2.18)))
        }
    }

    private static func previewBodySize(for style: VehicleShapeStyle, canvas: CGSize) -> CGSize {
        switch style {
        case .van:
            return CGSize(width: canvas.width * 0.8, height: canvas.height * 1.02)
        case .lowrider, .luxury, .muscle:
            return CGSize(width: canvas.width * 0.9, height: canvas.height * 0.96)
        case .speeder, .bullet, .crown:
            return CGSize(width: canvas.width * 0.66, height: canvas.height * 0.96)
        case .roadster:
            return CGSize(width: canvas.width * 0.76, height: canvas.height * 0.9)
        default:
            return CGSize(width: canvas.width * 0.78, height: canvas.height * 0.94)
        }
    }

    private static func makeCarSprite(car: CarDefinition, paint: PaintDefinition, size: CGSize, animated: Bool) -> SKSpriteNode {
        let colors = CarCatalog.resolvedColors(car: car, paint: paint)
        let node = SKSpriteNode(color: .clear, size: size)
        let style = car.vehicleShapeStyle
        let accent = colors.accent
        let bodyColor = colors.body

        let shadow = SKShapeNode(path: bodyPath(size: size, style: style))
        shadow.position = CGPoint(x: 2.5, y: -3.5)
        shadow.fillColor = SKColor.black.withAlphaComponent(0.36)
        shadow.strokeColor = .clear
        shadow.zPosition = -4
        node.addChild(shadow)

        let glow = SKShapeNode(path: bodyPath(size: CGSize(width: size.width * 1.08, height: size.height * 1.05), style: style))
        glow.fillColor = accent.withAlphaComponent(glowAlpha(for: style))
        glow.strokeColor = accent.withAlphaComponent(0.42)
        glow.lineWidth = 2
        glow.glowWidth = car.rarity == .legendary ? 12 : 6
        glow.zPosition = -3
        node.addChild(glow)

        addWheels(to: node, size: size, style: style)

        let body = SKShapeNode(path: bodyPath(size: size, style: style))
        body.fillColor = bodyColor
        body.strokeColor = accent.withAlphaComponent(0.88)
        body.lineWidth = 1.8
        body.zPosition = 0
        node.addChild(body)

        addCommonGlass(to: node, size: size, style: style)
        addLights(to: node, size: size, accent: accent)
        addStyleDetails(to: node, car: car, size: size, bodyColor: bodyColor, accent: accent)
        addPaintShine(to: node, size: size, style: style)

        if animated || car.rarity == .legendary {
            addRarityEffects(to: node, size: size, car: car, accent: accent)
        }

        return node
    }

    private static func makeMotorcycleSprite(car: CarDefinition, paint: PaintDefinition, size: CGSize, animated: Bool) -> SKSpriteNode {
        let colors = CarCatalog.resolvedColors(car: car, paint: paint)
        let node = SKSpriteNode(color: .clear, size: size)
        let bodyColor = colors.body
        let accent = colors.accent

        let shadow = SKShapeNode(ellipseOf: CGSize(width: size.width * 1.25, height: size.height * 1.02))
        shadow.fillColor = SKColor.black.withAlphaComponent(0.32)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 2.5, y: -3)
        shadow.zPosition = -5
        node.addChild(shadow)

        let glow = SKShapeNode(ellipseOf: CGSize(width: size.width * 1.18, height: size.height * 1.05))
        glow.fillColor = accent.withAlphaComponent(car.rarity == .legendary ? 0.2 : 0.11)
        glow.strokeColor = accent.withAlphaComponent(0.35)
        glow.glowWidth = car.rarity == .legendary ? 12 : 6
        glow.zPosition = -4
        node.addChild(glow)

        addBikeWheel(to: node, size: CGSize(width: size.width * 0.88, height: size.height * 0.19), y: size.height * 0.39, accent: accent)
        addBikeWheel(to: node, size: CGSize(width: size.width * 0.9, height: size.height * 0.21), y: -size.height * 0.39, accent: accent)

        let spine = SKShapeNode(rectOf: CGSize(width: size.width * 0.34, height: size.height * 0.68), cornerRadius: size.width * 0.17)
        spine.fillColor = bodyColor
        spine.strokeColor = accent.withAlphaComponent(0.82)
        spine.lineWidth = 1.4
        spine.zPosition = 0
        node.addChild(spine)

        let fairingWidth: CGFloat
        switch car.vehicleShapeStyle {
        case .courierBike:
            fairingWidth = 0.72
        case .streetHawk, .miamiPhantom, .neonKatana, .crownSerpent:
            fairingWidth = 0.96
        case .policeMoto:
            fairingWidth = 0.9
        default:
            fairingWidth = 0.82
        }

        addShape(to: node, rect: CGSize(width: size.width * fairingWidth, height: size.height * 0.28), pos: CGPoint(x: 0, y: size.height * 0.13), radius: size.width * 0.22, fill: bodyColor, stroke: accent)
        addShape(to: node, ellipse: CGSize(width: size.width * 0.72, height: size.height * 0.18), pos: CGPoint(x: 0, y: -size.height * 0.08), fill: SKColor.black.withAlphaComponent(0.82), stroke: .clear)
        addShape(to: node, rect: CGSize(width: size.width * 0.5, height: 4), pos: CGPoint(x: 0, y: size.height * 0.48), radius: 2, fill: SKColor(red: 0.95, green: 1, blue: 0.7, alpha: 1), stroke: .clear)
        addShape(to: node, rect: CGSize(width: size.width * 0.46, height: 4), pos: CGPoint(x: 0, y: -size.height * 0.48), radius: 2, fill: SKColor(red: 1, green: 0.04, blue: 0.08, alpha: 1), stroke: .clear)

        addBikeStyleDetails(to: node, car: car, size: size, bodyColor: bodyColor, accent: accent)

        if animated || car.rarity == .legendary {
            addRarityEffects(to: node, size: size, car: car, accent: accent)
        }

        return node
    }

    private static func bodyPath(size: CGSize, style: VehicleShapeStyle) -> CGPath {
        let w = size.width
        let h = size.height
        let path = CGMutablePath()

        switch style {
        case .cab, .retro, .van:
            path.move(to: CGPoint(x: -w * 0.43, y: h * 0.48))
            path.addLine(to: CGPoint(x: w * 0.43, y: h * 0.48))
            path.addLine(to: CGPoint(x: w * 0.48, y: -h * 0.42))
            path.addLine(to: CGPoint(x: w * 0.38, y: -h * 0.5))
            path.addLine(to: CGPoint(x: -w * 0.38, y: -h * 0.5))
            path.addLine(to: CGPoint(x: -w * 0.48, y: -h * 0.42))
        case .speeder, .bullet, .crown:
            path.move(to: CGPoint(x: -w * 0.21, y: h * 0.5))
            path.addLine(to: CGPoint(x: w * 0.21, y: h * 0.5))
            path.addLine(to: CGPoint(x: w * 0.5, y: h * 0.12))
            path.addLine(to: CGPoint(x: w * 0.32, y: -h * 0.48))
            path.addLine(to: CGPoint(x: -w * 0.32, y: -h * 0.48))
            path.addLine(to: CGPoint(x: -w * 0.5, y: h * 0.12))
        case .muscle:
            path.move(to: CGPoint(x: -w * 0.34, y: h * 0.5))
            path.addLine(to: CGPoint(x: w * 0.34, y: h * 0.5))
            path.addLine(to: CGPoint(x: w * 0.46, y: h * 0.08))
            path.addLine(to: CGPoint(x: w * 0.5, y: -h * 0.42))
            path.addLine(to: CGPoint(x: -w * 0.5, y: -h * 0.42))
            path.addLine(to: CGPoint(x: -w * 0.46, y: h * 0.08))
        case .roadster:
            path.move(to: CGPoint(x: -w * 0.28, y: h * 0.48))
            path.addLine(to: CGPoint(x: w * 0.28, y: h * 0.48))
            path.addLine(to: CGPoint(x: w * 0.48, y: h * 0.1))
            path.addLine(to: CGPoint(x: w * 0.36, y: -h * 0.46))
            path.addLine(to: CGPoint(x: -w * 0.36, y: -h * 0.46))
            path.addLine(to: CGPoint(x: -w * 0.48, y: h * 0.1))
        case .cyber:
            path.move(to: CGPoint(x: -w * 0.18, y: h * 0.5))
            path.addLine(to: CGPoint(x: w * 0.35, y: h * 0.42))
            path.addLine(to: CGPoint(x: w * 0.5, y: -h * 0.1))
            path.addLine(to: CGPoint(x: w * 0.22, y: -h * 0.5))
            path.addLine(to: CGPoint(x: -w * 0.48, y: -h * 0.35))
            path.addLine(to: CGPoint(x: -w * 0.44, y: h * 0.14))
        default:
            path.move(to: CGPoint(x: -w * 0.32, y: h * 0.5))
            path.addLine(to: CGPoint(x: w * 0.32, y: h * 0.5))
            path.addLine(to: CGPoint(x: w * 0.48, y: h * 0.16))
            path.addLine(to: CGPoint(x: w * 0.36, y: -h * 0.5))
            path.addLine(to: CGPoint(x: -w * 0.36, y: -h * 0.5))
            path.addLine(to: CGPoint(x: -w * 0.48, y: h * 0.16))
        }

        path.closeSubpath()
        return path
    }

    private static func addCommonGlass(to node: SKNode, size: CGSize, style: VehicleShapeStyle) {
        let glassColor = SKColor(red: 0.55, green: 0.9, blue: 1, alpha: 0.9)
        let darkGlass = SKColor(red: 0.04, green: 0.08, blue: 0.14, alpha: 0.92)

        switch style {
        case .roadster:
            addShape(to: node, rect: CGSize(width: size.width * 0.5, height: size.height * 0.12), pos: CGPoint(x: 0, y: size.height * 0.06), radius: 5, fill: darkGlass, stroke: .white)
            addShape(to: node, ellipse: CGSize(width: size.width * 0.46, height: size.height * 0.18), pos: CGPoint(x: 0, y: -size.height * 0.08), fill: SKColor.black.withAlphaComponent(0.5), stroke: .clear)
        case .van:
            addShape(to: node, rect: CGSize(width: size.width * 0.58, height: size.height * 0.12), pos: CGPoint(x: 0, y: size.height * 0.28), radius: 3, fill: glassColor, stroke: .white)
            addShape(to: node, rect: CGSize(width: size.width * 0.56, height: size.height * 0.32), pos: CGPoint(x: 0, y: -size.height * 0.12), radius: 3, fill: SKColor.white.withAlphaComponent(0.12), stroke: .clear)
        case .speeder, .bullet, .crown:
            addShape(to: node, ellipse: CGSize(width: size.width * 0.46, height: size.height * 0.28), pos: CGPoint(x: 0, y: size.height * 0.06), fill: glassColor, stroke: .white)
        default:
            addShape(to: node, rect: CGSize(width: size.width * 0.5, height: size.height * 0.17), pos: CGPoint(x: 0, y: size.height * 0.12), radius: 4, fill: glassColor, stroke: .white)
            addShape(to: node, rect: CGSize(width: size.width * 0.42, height: size.height * 0.12), pos: CGPoint(x: 0, y: -size.height * 0.22), radius: 3, fill: darkGlass, stroke: .white)
        }
    }

    private static func addStyleDetails(to node: SKNode, car: CarDefinition, size: CGSize, bodyColor: SKColor, accent: SKColor) {
        switch car.vehicleShapeStyle {
        case .compact:
            addShape(to: node, rect: CGSize(width: size.width * 0.44, height: size.height * 0.16), pos: CGPoint(x: 0, y: size.height * 0.33), radius: 5, fill: accent.withAlphaComponent(0.32), stroke: .clear)
        case .cab:
            addShape(to: node, rect: CGSize(width: size.width * 0.5, height: 6), pos: CGPoint(x: 0, y: -size.height * 0.03), radius: 1, fill: .black, stroke: .clear)
            addShape(to: node, rect: CGSize(width: size.width * 0.42, height: 8), pos: CGPoint(x: 0, y: size.height * 0.02), radius: 2, fill: .white, stroke: .black)
        case .coupe:
            addStripe(to: node, size: size, color: accent, x: -size.width * 0.18, width: size.width * 0.11)
        case .speeder:
            addNeonEdges(to: node, size: size, color: accent)
            addShape(to: node, rect: CGSize(width: size.width * 0.72, height: 4), pos: CGPoint(x: 0, y: -size.height * 0.42), radius: 2, fill: accent, stroke: .clear)
        case .retro:
            addShape(to: node, rect: CGSize(width: size.width * 0.7, height: size.height * 0.08), pos: CGPoint(x: 0, y: size.height * 0.33), radius: 1, fill: accent.withAlphaComponent(0.28), stroke: .clear)
        case .racer:
            addStripe(to: node, size: size, color: .white, x: 0, width: size.width * 0.16)
            addSpoiler(to: node, size: size, color: accent)
        case .muscle:
            addStripe(to: node, size: size, color: accent, x: -size.width * 0.12, width: size.width * 0.09)
            addStripe(to: node, size: size, color: accent, x: size.width * 0.12, width: size.width * 0.09)
        case .van:
            addShape(to: node, rect: CGSize(width: size.width * 0.62, height: size.height * 0.26), pos: CGPoint(x: 0, y: -size.height * 0.1), radius: 3, fill: SKColor.white.withAlphaComponent(0.18), stroke: accent)
            addShape(to: node, rect: CGSize(width: size.width * 0.38, height: 4), pos: CGPoint(x: 0, y: -size.height * 0.1), radius: 1, fill: accent, stroke: .clear)
        case .interceptor:
            addShape(to: node, rect: CGSize(width: size.width * 0.76, height: size.height * 0.32), pos: CGPoint(x: 0, y: -size.height * 0.02), radius: 4, fill: SKColor.white.withAlphaComponent(0.95), stroke: .black)
            addShape(to: node, rect: CGSize(width: size.width * 0.62, height: 7), pos: CGPoint(x: 0, y: size.height * 0.04), radius: 2, fill: SKColor.red, stroke: SKColor.blue)
            addShape(to: node, rect: CGSize(width: size.width * 0.78, height: 5), pos: CGPoint(x: 0, y: size.height * 0.49), radius: 2, fill: .black, stroke: .white)
        case .lowrider:
            addShape(to: node, rect: CGSize(width: size.width * 0.86, height: 3), pos: CGPoint(x: 0, y: -size.height * 0.34), radius: 1, fill: .white, stroke: .clear)
            addShape(to: node, rect: CGSize(width: size.width * 0.72, height: 3), pos: CGPoint(x: 0, y: size.height * 0.34), radius: 1, fill: accent, stroke: .clear)
        case .cyber:
            addNeonEdges(to: node, size: size, color: accent)
            addShape(to: node, rect: CGSize(width: size.width * 0.52, height: 5), pos: CGPoint(x: 0, y: size.height * 0.25), radius: 1, fill: accent, stroke: .clear)
        case .rally:
            addShape(to: node, rect: CGSize(width: size.width * 0.52, height: 7), pos: CGPoint(x: 0, y: size.height * 0.38), radius: 2, fill: SKColor.white.withAlphaComponent(0.92), stroke: accent)
            addMudFlaps(to: node, size: size)
        case .luxury:
            addShape(to: node, rect: CGSize(width: size.width * 0.62, height: 3), pos: CGPoint(x: 0, y: size.height * 0.37), radius: 1, fill: .white, stroke: .clear)
            addShape(to: node, rect: CGSize(width: size.width * 0.76, height: 3), pos: CGPoint(x: 0, y: -size.height * 0.39), radius: 1, fill: accent, stroke: .clear)
        case .desert:
            addShape(to: node, rect: CGSize(width: size.width * 0.58, height: size.height * 0.12), pos: CGPoint(x: 0, y: -size.height * 0.02), radius: 2, fill: SKColor.black.withAlphaComponent(0.34), stroke: accent)
            addMudFlaps(to: node, size: size)
        case .bullet:
            addNeonEdges(to: node, size: size, color: accent)
            addStripe(to: node, size: size, color: accent, x: 0, width: size.width * 0.12)
        case .roadster:
            addShape(to: node, ellipse: CGSize(width: size.width * 0.34, height: size.height * 0.2), pos: CGPoint(x: 0, y: -size.height * 0.1), fill: SKColor.black.withAlphaComponent(0.48), stroke: accent)
        case .runner:
            addShape(to: node, rect: CGSize(width: size.width * 0.7, height: 3), pos: CGPoint(x: 0, y: size.height * 0.36), radius: 1, fill: SKColor(red: 0.2, green: 0.62, blue: 1, alpha: 1), stroke: .clear)
        case .golden:
            addShape(to: node, rect: CGSize(width: size.width * 0.12, height: size.height * 0.74), pos: CGPoint(x: -size.width * 0.16, y: 0), radius: 2, fill: SKColor.white.withAlphaComponent(0.42), stroke: .clear)
            addShape(to: node, rect: CGSize(width: size.width * 0.54, height: 4), pos: CGPoint(x: 0, y: size.height * 0.38), radius: 2, fill: accent, stroke: .clear)
        case .ghost:
            addShape(to: node, ellipse: CGSize(width: size.width * 1.15, height: size.height * 1.08), pos: .zero, fill: accent.withAlphaComponent(0.09), stroke: accent.withAlphaComponent(0.25))
            addNeonEdges(to: node, size: size, color: accent.withAlphaComponent(0.78))
        case .crown:
            addNeonEdges(to: node, size: size, color: accent)
            addShape(to: node, rect: CGSize(width: size.width * 0.54, height: 5), pos: CGPoint(x: 0, y: size.height * 0.33), radius: 2, fill: UITheme.Color.gold, stroke: .clear)
            addShape(to: node, rect: CGSize(width: size.width * 0.74, height: 5), pos: CGPoint(x: 0, y: -size.height * 0.39), radius: 2, fill: accent, stroke: .clear)
        case .starterBike, .courierBike, .streetHawk, .miamiPhantom, .highwayGhost, .policeMoto, .neonKatana, .crownSerpent:
            break
        }
    }

    private static func addBikeWheel(to node: SKNode, size: CGSize, y: CGFloat, accent: SKColor) {
        let tire = SKShapeNode(ellipseOf: size)
        tire.fillColor = .black
        tire.strokeColor = SKColor.white.withAlphaComponent(0.18)
        tire.lineWidth = 1
        tire.position = CGPoint(x: 0, y: y)
        tire.zPosition = -1
        node.addChild(tire)

        let rim = SKShapeNode(ellipseOf: CGSize(width: size.width * 0.52, height: size.height * 0.52))
        rim.fillColor = SKColor.white.withAlphaComponent(0.18)
        rim.strokeColor = accent.withAlphaComponent(0.5)
        rim.position = CGPoint(x: 0, y: y)
        rim.zPosition = 1
        node.addChild(rim)
    }

    private static func addBikeStyleDetails(to node: SKNode, car: CarDefinition, size: CGSize, bodyColor: SKColor, accent: SKColor) {
        switch car.vehicleShapeStyle {
        case .courierBike:
            addShape(to: node, rect: CGSize(width: size.width * 0.72, height: size.height * 0.16), pos: CGPoint(x: 0, y: -size.height * 0.25), radius: 3, fill: SKColor.white.withAlphaComponent(0.86), stroke: accent)
        case .streetHawk:
            addShape(to: node, rect: CGSize(width: size.width * 0.18, height: size.height * 0.74), pos: CGPoint(x: -size.width * 0.18, y: 0), radius: 2, fill: .white, stroke: .clear)
        case .miamiPhantom:
            addNeonEdges(to: node, size: CGSize(width: size.width * 0.72, height: size.height), color: accent)
        case .highwayGhost:
            addShape(to: node, ellipse: CGSize(width: size.width * 1.35, height: size.height * 1.05), pos: .zero, fill: accent.withAlphaComponent(0.08), stroke: accent.withAlphaComponent(0.22))
        case .policeMoto:
            addShape(to: node, rect: CGSize(width: size.width * 0.84, height: 5), pos: CGPoint(x: 0, y: size.height * 0.08), radius: 2, fill: SKColor.red, stroke: SKColor.blue)
            addShape(to: node, rect: CGSize(width: size.width * 0.7, height: size.height * 0.18), pos: CGPoint(x: 0, y: -size.height * 0.06), radius: 3, fill: SKColor.white.withAlphaComponent(0.94), stroke: .black)
        case .neonKatana:
            addShape(to: node, rect: CGSize(width: size.width * 0.16, height: size.height * 0.88), pos: CGPoint(x: 0, y: 0), radius: 2, fill: accent, stroke: .clear)
            addNeonEdges(to: node, size: CGSize(width: size.width * 0.78, height: size.height), color: accent)
        case .crownSerpent:
            addShape(to: node, rect: CGSize(width: size.width * 0.78, height: 5), pos: CGPoint(x: 0, y: size.height * 0.25), radius: 2, fill: UITheme.Color.gold, stroke: .clear)
            addShape(to: node, rect: CGSize(width: size.width * 0.28, height: size.height * 0.82), pos: CGPoint(x: 0, y: 0), radius: 2, fill: accent.withAlphaComponent(0.72), stroke: .clear)
        default:
            addShape(to: node, rect: CGSize(width: size.width * 0.52, height: 4), pos: CGPoint(x: 0, y: size.height * 0.24), radius: 2, fill: accent, stroke: .clear)
        }
    }

    private static func addWheels(to node: SKNode, size: CGSize, style: VehicleShapeStyle) {
        let wheelWidth: CGFloat = [.van, .desert, .rally].contains(style) ? size.width * 0.2 : size.width * 0.16
        let wheelHeight: CGFloat = [.lowrider, .luxury, .muscle].contains(style) ? size.height * 0.22 : size.height * 0.18
        for x in [-size.width * 0.5, size.width * 0.5] {
            for y in [-size.height * 0.28, size.height * 0.26] {
                let wheel = SKShapeNode(rectOf: CGSize(width: wheelWidth, height: wheelHeight), cornerRadius: wheelWidth * 0.35)
                wheel.fillColor = .black
                wheel.strokeColor = style == .lowrider ? .white : SKColor.white.withAlphaComponent(0.14)
                wheel.lineWidth = style == .lowrider ? 1.5 : 1
                wheel.position = CGPoint(x: x, y: y)
                wheel.zPosition = -1
                node.addChild(wheel)
            }
        }
    }

    private static func addLights(to node: SKNode, size: CGSize, accent: SKColor) {
        for x in [-size.width * 0.18, size.width * 0.18] {
            addShape(to: node, rect: CGSize(width: size.width * 0.16, height: 4), pos: CGPoint(x: x, y: size.height * 0.45), radius: 2, fill: SKColor(red: 0.95, green: 1, blue: 0.72, alpha: 1), stroke: .clear)
            addShape(to: node, rect: CGSize(width: size.width * 0.13, height: 4), pos: CGPoint(x: x, y: -size.height * 0.45), radius: 2, fill: SKColor(red: 1, green: 0.04, blue: 0.08, alpha: 1), stroke: .clear)
        }
        addShape(to: node, rect: CGSize(width: size.width * 0.7, height: 2), pos: CGPoint(x: 0, y: -size.height * 0.49), radius: 1, fill: accent.withAlphaComponent(0.55), stroke: .clear)
    }

    private static func addPaintShine(to node: SKNode, size: CGSize, style: VehicleShapeStyle) {
        let shine = SKShapeNode(rectOf: CGSize(width: size.width * 0.08, height: size.height * 0.66), cornerRadius: 2)
        shine.fillColor = SKColor.white.withAlphaComponent(style == .golden ? 0.42 : 0.22)
        shine.strokeColor = .clear
        shine.position = CGPoint(x: -size.width * 0.18, y: 0)
        shine.zRotation = -0.18
        shine.zPosition = 5
        node.addChild(shine)
    }

    private static func addRarityEffects(to node: SKNode, size: CGSize, car: CarDefinition, accent: SKColor) {
        guard car.rarity == .legendary || car.vehicleShapeStyle == .ghost || car.vehicleShapeStyle == .crown else { return }
        for index in 0..<3 {
            let ring = SKShapeNode(ellipseOf: CGSize(width: size.width * (1.2 + CGFloat(index) * 0.16), height: size.height * (1.08 + CGFloat(index) * 0.12)))
            ring.fillColor = .clear
            ring.strokeColor = accent.withAlphaComponent(0.18)
            ring.lineWidth = 1.4
            ring.glowWidth = 5
            ring.zPosition = -5
            node.addChild(ring)
            ring.run(.repeatForever(.sequence([
                .fadeAlpha(to: 0.45, duration: 0.7 + Double(index) * 0.16),
                .fadeAlpha(to: 0.12, duration: 0.7 + Double(index) * 0.16)
            ])))
        }
    }

    private static func addStripe(to node: SKNode, size: CGSize, color: SKColor, x: CGFloat, width: CGFloat) {
        addShape(to: node, rect: CGSize(width: width, height: size.height * 0.82), pos: CGPoint(x: x, y: 0), radius: 2, fill: color.withAlphaComponent(0.75), stroke: .clear)
    }

    private static func addSpoiler(to node: SKNode, size: CGSize, color: SKColor) {
        addShape(to: node, rect: CGSize(width: size.width * 0.82, height: 6), pos: CGPoint(x: 0, y: -size.height * 0.49), radius: 2, fill: .black, stroke: color)
    }

    private static func addMudFlaps(to node: SKNode, size: CGSize) {
        for x in [-size.width * 0.32, size.width * 0.32] {
            addShape(to: node, rect: CGSize(width: size.width * 0.18, height: 6), pos: CGPoint(x: x, y: -size.height * 0.52), radius: 1, fill: SKColor.black.withAlphaComponent(0.8), stroke: .clear)
        }
    }

    private static func addNeonEdges(to node: SKNode, size: CGSize, color: SKColor) {
        for x in [-size.width * 0.42, size.width * 0.42] {
            addShape(to: node, rect: CGSize(width: 3, height: size.height * 0.68), pos: CGPoint(x: x, y: -size.height * 0.02), radius: 1.5, fill: color, stroke: .clear)
        }
    }

    private static func addShape(to node: SKNode, rect: CGSize, pos: CGPoint, radius: CGFloat, fill: SKColor, stroke: SKColor) {
        let shape = SKShapeNode(rectOf: rect, cornerRadius: radius)
        shape.fillColor = fill
        let hasStroke = stroke.cgColor.alpha > 0.01
        shape.strokeColor = hasStroke ? stroke.withAlphaComponent(0.6) : .clear
        shape.lineWidth = hasStroke ? 1 : 0
        shape.position = pos
        shape.zPosition = 4
        node.addChild(shape)
    }

    private static func addShape(to node: SKNode, ellipse: CGSize, pos: CGPoint, fill: SKColor, stroke: SKColor) {
        let shape = SKShapeNode(ellipseOf: ellipse)
        shape.fillColor = fill
        let hasStroke = stroke.cgColor.alpha > 0.01
        shape.strokeColor = hasStroke ? stroke.withAlphaComponent(0.6) : .clear
        shape.lineWidth = hasStroke ? 1 : 0
        shape.position = pos
        shape.zPosition = 4
        node.addChild(shape)
    }

    private static func glowAlpha(for style: VehicleShapeStyle) -> CGFloat {
        switch style {
        case .speeder, .bullet, .cyber, .ghost, .crown:
            return 0.22
        default:
            return 0.12
        }
    }
}
