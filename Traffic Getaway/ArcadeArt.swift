import SpriteKit

enum ArcadeArt {
    static let systemName = "SunlitCaliforniaArcade"

    enum VehicleAsset: String, CaseIterable {
        case playerCruiser = "vehicle.player.sunset_cruiser"
        case trafficSedan = "vehicle.traffic.sedan"
        case trafficCompact = "vehicle.traffic.compact"
        case trafficSUV = "vehicle.traffic.suv"
        case trafficPickup = "vehicle.traffic.pickup"
        case trafficVan = "vehicle.traffic.van"
        case trafficBoxTruck = "vehicle.traffic.box_truck"
        case trafficSportCoupe = "vehicle.traffic.sport_coupe"
        case policeCruiser = "vehicle.police.cruiser"
        case policeSUV = "vehicle.police.suv"
        case policeMotorcycle = "vehicle.police.motorcycle"

        var displayName: String {
            switch self {
            case .playerCruiser: return "Player Cruiser"
            case .trafficSedan: return "Traffic Sedan"
            case .trafficCompact: return "Traffic Compact"
            case .trafficSUV: return "Traffic SUV"
            case .trafficPickup: return "Traffic Pickup"
            case .trafficVan: return "Traffic Van"
            case .trafficBoxTruck: return "Box Truck"
            case .trafficSportCoupe: return "Sport Coupe"
            case .policeCruiser: return "Police Cruiser"
            case .policeSUV: return "Police SUV"
            case .policeMotorcycle: return "Police Motorcycle"
            }
        }
    }

    enum RoadAsset: String, CaseIterable {
        case freewaySlab = "road.freeway.slab"
        case laneDash = "road.lane.dash"
        case shoulderStripe = "road.shoulder.stripe"
        case asphaltFleck = "road.asphalt.fleck"
        case palmProp = "environment.prop.palm"
        case freewaySign = "environment.prop.freeway_sign"

        var displayName: String {
            switch self {
            case .freewaySlab: return "Freeway Slab"
            case .laneDash: return "Lane Dash"
            case .shoulderStripe: return "Shoulder Stripe"
            case .asphaltFleck: return "Asphalt Fleck"
            case .palmProp: return "Palm Prop"
            case .freewaySign: return "Freeway Sign"
            }
        }
    }

    enum EffectAsset: String, CaseIterable {
        case tireSmoke = "effect.tire_smoke"
        case speedStreak = "effect.speed_streak"
        case crashSpark = "effect.crash_spark"
        case sirenGlow = "effect.siren_glow"
        case boostTrail = "effect.boost_trail"

        var displayName: String {
            switch self {
            case .tireSmoke: return "Tire Smoke"
            case .speedStreak: return "Speed Streak"
            case .crashSpark: return "Crash Spark"
            case .sirenGlow: return "Siren Glow"
            case .boostTrail: return "Boost Trail"
            }
        }
    }

    enum UIAsset: String, CaseIterable {
        case panel = "ui.panel.navy"
        case buttonPrimary = "ui.button.orange"
        case buttonSecondary = "ui.button.cream"
        case accentLine = "ui.accent.gold_line"
    }

    enum WheelStyle {
        case standard
        case sport
        case heavy
        case motorcycle
    }

    struct RoadPalette {
        let background: SKColor
        let road: SKColor
        let shoulder: SKColor
        let laneMarker: SKColor
        let accent: SKColor
        let secondAccent: SKColor
        let roadTexture: SKColor
        let edgeLine: SKColor
        let panel: SKColor
    }

    struct HitboxScale {
        let width: CGFloat
        let height: CGFloat
    }

    struct VehicleSpec {
        let asset: VehicleAsset
        let size: CGSize
        let bodyColor: SKColor
        let strokeColor: SKColor
        let glowColor: SKColor
        let frontInset: CGFloat
        let rearInset: CGFloat
        let wheelStyle: WheelStyle
        let laneSpan: Int
        let speedOffset: CGFloat
        let hitboxScale: HitboxScale
    }

    enum Palette {
        static let sky = SKColor(red: 0.58, green: 0.82, blue: 0.96, alpha: 1)
        static let horizon = SKColor(red: 0.98, green: 0.72, blue: 0.38, alpha: 1)
        static let asphalt = SKColor(red: 0.34, green: 0.35, blue: 0.37, alpha: 1)
        static let asphaltDark = SKColor(red: 0.24, green: 0.25, blue: 0.27, alpha: 1)
        static let asphaltLight = SKColor(red: 0.47, green: 0.48, blue: 0.49, alpha: 1)
        static let shoulder = SKColor(red: 0.69, green: 0.55, blue: 0.38, alpha: 1)
        static let sand = SKColor(red: 0.86, green: 0.72, blue: 0.48, alpha: 1)
        static let palm = SKColor(red: 0.06, green: 0.43, blue: 0.22, alpha: 1)
        static let cream = SKColor(red: 1.0, green: 0.94, blue: 0.78, alpha: 1)
        static let mutedCream = SKColor(red: 0.78, green: 0.72, blue: 0.58, alpha: 1)
        static let navy = SKColor(red: 0.025, green: 0.045, blue: 0.095, alpha: 1)
        static let navyPanel = SKColor(red: 0.035, green: 0.058, blue: 0.12, alpha: 0.96)
        static let navyPanelDeep = SKColor(red: 0.018, green: 0.032, blue: 0.07, alpha: 0.97)
        static let orange = SKColor(red: 1.0, green: 0.43, blue: 0.12, alpha: 1)
        static let gold = SKColor(red: 1.0, green: 0.76, blue: 0.22, alpha: 1)
        static let red = SKColor(red: 0.95, green: 0.12, blue: 0.09, alpha: 1)
        static let blue = SKColor(red: 0.12, green: 0.43, blue: 1.0, alpha: 1)
        static let green = SKColor(red: 0.2, green: 0.74, blue: 0.34, alpha: 1)
        static let glass = SKColor(red: 0.58, green: 0.88, blue: 0.95, alpha: 0.94)
        static let darkGlass = SKColor(red: 0.055, green: 0.09, blue: 0.13, alpha: 0.95)
        static let tire = SKColor(red: 0.035, green: 0.035, blue: 0.04, alpha: 1)
    }

    enum FallbackPolicy {
        static let summary = "Use code-drawn Sunlit California Arcade shapes for missing work-in-progress art. Never show magenta debug boxes or raw missing-image text in gameplay."

        static func node(assetID: String, size: CGSize) -> SKNode {
            let node = SKNode()
            node.name = assetID

            let base = SKShapeNode(rectOf: size, cornerRadius: min(6, min(size.width, size.height) * 0.12))
            base.fillColor = Palette.asphaltLight.withAlphaComponent(0.9)
            base.strokeColor = Palette.gold.withAlphaComponent(0.85)
            base.lineWidth = 2
            node.addChild(base)

            let inset = SKShapeNode(rectOf: CGSize(width: size.width * 0.72, height: size.height * 0.52), cornerRadius: 4)
            inset.fillColor = Palette.orange.withAlphaComponent(0.32)
            inset.strokeColor = Palette.cream.withAlphaComponent(0.45)
            inset.lineWidth = 1
            node.addChild(inset)

            let slash = SKShapeNode(rectOf: CGSize(width: size.width * 0.82, height: 5), cornerRadius: 2)
            slash.fillColor = Palette.cream.withAlphaComponent(0.82)
            slash.strokeColor = .clear
            slash.zRotation = -0.45
            node.addChild(slash)

            return node
        }
    }

    static func roadPalette(for city: CityTheme) -> RoadPalette {
        switch city {
        case .newYork:
            return RoadPalette(
                background: SKColor(red: 0.62, green: 0.82, blue: 0.94, alpha: 1),
                road: Palette.asphalt,
                shoulder: Palette.shoulder,
                laneMarker: Palette.cream,
                accent: Palette.gold,
                secondAccent: SKColor(red: 0.18, green: 0.57, blue: 0.82, alpha: 1),
                roadTexture: Palette.asphaltLight,
                edgeLine: SKColor(red: 1.0, green: 0.86, blue: 0.38, alpha: 1),
                panel: Palette.navyPanel
            )

        case .losAngeles:
            return RoadPalette(
                background: Palette.sky,
                road: SKColor(red: 0.35, green: 0.36, blue: 0.36, alpha: 1),
                shoulder: Palette.sand,
                laneMarker: Palette.cream,
                accent: Palette.orange,
                secondAccent: SKColor(red: 0.16, green: 0.62, blue: 0.56, alpha: 1),
                roadTexture: Palette.asphaltLight,
                edgeLine: Palette.gold,
                panel: Palette.navyPanel
            )

        case .miami:
            return RoadPalette(
                background: SKColor(red: 0.54, green: 0.88, blue: 0.94, alpha: 1),
                road: SKColor(red: 0.32, green: 0.35, blue: 0.38, alpha: 1),
                shoulder: SKColor(red: 0.75, green: 0.67, blue: 0.48, alpha: 1),
                laneMarker: Palette.cream,
                accent: SKColor(red: 0.98, green: 0.48, blue: 0.16, alpha: 1),
                secondAccent: SKColor(red: 0.08, green: 0.68, blue: 0.86, alpha: 1),
                roadTexture: Palette.asphaltLight,
                edgeLine: SKColor(red: 1.0, green: 0.82, blue: 0.3, alpha: 1),
                panel: Palette.navyPanel
            )
        }
    }

    static func roadPalette(for world: WorldThemeID) -> RoadPalette {
        WorldThemeCatalog.theme(id: world).palette
    }

    static func trafficSpec(for type: VehicleType, laneWidth: CGFloat, city: CityTheme) -> VehicleSpec {
        trafficSpec(for: type, laneWidth: laneWidth, world: WorldThemeCatalog.legacyTheme(for: city))
    }

    static func trafficSpec(for type: VehicleType, laneWidth: CGFloat, world: WorldTheme) -> VehicleSpec {
        let paint = civilianPaint(for: type, world: world)

        switch type {
        case .sedan:
            return VehicleSpec(asset: .trafficSedan, size: CGSize(width: min(28, max(20, laneWidth * 0.72)), height: min(76, max(58, laneWidth * 1.86))), bodyColor: paint.body, strokeColor: paint.stroke, glowColor: paint.glow, frontInset: 0.18, rearInset: 0.08, wheelStyle: .standard, laneSpan: 1, speedOffset: 0, hitboxScale: HitboxScale(width: 0.9, height: 0.9))
        case .compact:
            return VehicleSpec(asset: .trafficCompact, size: CGSize(width: min(25, max(18, laneWidth * 0.64)), height: min(66, max(50, laneWidth * 1.62))), bodyColor: paint.body, strokeColor: paint.stroke, glowColor: paint.glow, frontInset: 0.2, rearInset: 0.12, wheelStyle: .standard, laneSpan: 1, speedOffset: 8, hitboxScale: HitboxScale(width: 0.86, height: 0.88))
        case .suv:
            return VehicleSpec(asset: .trafficSUV, size: CGSize(width: min(33, max(24, laneWidth * 0.88)), height: min(86, max(66, laneWidth * 2.14))), bodyColor: paint.body, strokeColor: paint.stroke, glowColor: paint.glow, frontInset: 0.1, rearInset: 0.05, wheelStyle: .heavy, laneSpan: 1, speedOffset: -8, hitboxScale: HitboxScale(width: 0.96, height: 0.92))
        case .pickup:
            return VehicleSpec(asset: .trafficPickup, size: CGSize(width: min(32, max(23, laneWidth * 0.84)), height: min(84, max(64, laneWidth * 2.04))), bodyColor: paint.body, strokeColor: paint.stroke, glowColor: paint.glow, frontInset: 0.12, rearInset: 0.04, wheelStyle: .heavy, laneSpan: 1, speedOffset: -4, hitboxScale: HitboxScale(width: 0.94, height: 0.9))
        case .van:
            return VehicleSpec(asset: .trafficVan, size: CGSize(width: min(34, max(25, laneWidth * 0.9)), height: min(94, max(72, laneWidth * 2.38))), bodyColor: paint.body, strokeColor: paint.stroke, glowColor: paint.glow, frontInset: 0.07, rearInset: 0.04, wheelStyle: .heavy, laneSpan: 1, speedOffset: -15, hitboxScale: HitboxScale(width: 0.96, height: 0.93))
        case .boxTruck:
            return VehicleSpec(asset: .trafficBoxTruck, size: CGSize(width: min(54, max(42, laneWidth * 1.55)), height: min(118, max(88, laneWidth * 2.95))), bodyColor: paint.body, strokeColor: paint.stroke, glowColor: paint.glow, frontInset: 0.08, rearInset: 0.04, wheelStyle: .heavy, laneSpan: 2, speedOffset: -22, hitboxScale: HitboxScale(width: 1.05, height: 0.94))
        case .sportCoupe:
            return VehicleSpec(asset: .trafficSportCoupe, size: CGSize(width: min(26, max(19, laneWidth * 0.66)), height: min(70, max(54, laneWidth * 1.72))), bodyColor: paint.body, strokeColor: paint.stroke, glowColor: paint.glow, frontInset: 0.24, rearInset: 0.16, wheelStyle: .sport, laneSpan: 1, speedOffset: 34, hitboxScale: HitboxScale(width: 0.82, height: 0.88))
        case .policeMoto:
            return VehicleSpec(asset: .policeMotorcycle, size: CGSize(width: min(18, max(13, laneWidth * 0.42)), height: min(66, max(48, laneWidth * 1.55))), bodyColor: SKColor(white: 0.06, alpha: 1), strokeColor: Palette.cream.withAlphaComponent(0.9), glowColor: Palette.blue, frontInset: 0.34, rearInset: 0.26, wheelStyle: .motorcycle, laneSpan: 1, speedOffset: 54, hitboxScale: HitboxScale(width: 0.5, height: 0.82))
        }
    }

    static func policeCruiserSpec(laneWidth: CGFloat) -> VehicleSpec {
        VehicleSpec(asset: .policeCruiser, size: CGSize(width: min(34, max(24, laneWidth * 0.9)), height: min(84, max(70, laneWidth * 2.05))), bodyColor: SKColor(red: 0.035, green: 0.04, blue: 0.05, alpha: 1), strokeColor: Palette.cream.withAlphaComponent(0.78), glowColor: Palette.blue, frontInset: 0.12, rearInset: 0.06, wheelStyle: .heavy, laneSpan: 1, speedOffset: 0, hitboxScale: HitboxScale(width: 0.92, height: 0.9))
    }

    static func policeSUVSpec(laneWidth: CGFloat) -> VehicleSpec {
        VehicleSpec(asset: .policeSUV, size: CGSize(width: min(35, max(26, laneWidth * 0.94)), height: min(94, max(74, laneWidth * 2.24))), bodyColor: SKColor(red: 0.025, green: 0.03, blue: 0.04, alpha: 1), strokeColor: Palette.cream.withAlphaComponent(0.86), glowColor: Palette.red, frontInset: 0.08, rearInset: 0.04, wheelStyle: .heavy, laneSpan: 1, speedOffset: -4, hitboxScale: HitboxScale(width: 0.98, height: 0.92))
    }

    static func assetID(for type: VehicleType) -> VehicleAsset {
        switch type {
        case .sedan: return .trafficSedan
        case .compact: return .trafficCompact
        case .suv: return .trafficSUV
        case .pickup: return .trafficPickup
        case .van: return .trafficVan
        case .boxTruck: return .trafficBoxTruck
        case .sportCoupe: return .trafficSportCoupe
        case .policeMoto: return .policeMotorcycle
        }
    }

    static func laneSpan(for type: VehicleType) -> Int {
        trafficSpec(for: type, laneWidth: 32, city: .losAngeles).laneSpan
    }

    static func speedOffset(for type: VehicleType) -> CGFloat {
        trafficSpec(for: type, laneWidth: 32, city: .losAngeles).speedOffset
    }

    static func hitboxScale(for type: VehicleType) -> HitboxScale {
        trafficSpec(for: type, laneWidth: 32, city: .losAngeles).hitboxScale
    }

    static func makeVehicleSprite(spec: VehicleSpec, reducedFlashing: Bool = false) -> SKSpriteNode {
        if spec.wheelStyle == .motorcycle {
            return makeMotorcycleSprite(spec: spec, reducedFlashing: reducedFlashing)
        }

        let vehicle = makeVehicleShell(spec: spec)

        switch spec.asset {
        case .trafficSedan:
            addWindow(to: vehicle, size: spec.size, y: spec.size.height * 0.18, widthScale: 0.52, heightScale: 0.17, color: Palette.glass)
            addWindow(to: vehicle, size: spec.size, y: -spec.size.height * 0.19, widthScale: 0.42, heightScale: 0.13, color: Palette.darkGlass)
        case .trafficCompact:
            addWindow(to: vehicle, size: spec.size, y: spec.size.height * 0.12, widthScale: 0.54, heightScale: 0.18, color: Palette.glass)
            addShape(to: vehicle, rect: CGSize(width: spec.size.width * 0.44, height: 5), pos: CGPoint(x: 0, y: -spec.size.height * 0.3), radius: 2, fill: Palette.cream.withAlphaComponent(0.34), stroke: .clear)
        case .trafficSUV:
            addWindow(to: vehicle, size: spec.size, y: spec.size.height * 0.22, widthScale: 0.56, heightScale: 0.15, color: Palette.glass)
            addShape(to: vehicle, rect: CGSize(width: spec.size.width * 0.62, height: spec.size.height * 0.22), pos: CGPoint(x: 0, y: -spec.size.height * 0.14), radius: 3, fill: SKColor.black.withAlphaComponent(0.12), stroke: Palette.cream.withAlphaComponent(0.18))
            addShape(to: vehicle, rect: CGSize(width: spec.size.width * 0.72, height: 4), pos: CGPoint(x: 0, y: spec.size.height * 0.39), radius: 1, fill: Palette.cream.withAlphaComponent(0.5), stroke: .clear)
        case .trafficPickup:
            addWindow(to: vehicle, size: spec.size, y: spec.size.height * 0.26, widthScale: 0.5, heightScale: 0.14, color: Palette.glass)
            addShape(to: vehicle, rect: CGSize(width: spec.size.width * 0.68, height: spec.size.height * 0.32), pos: CGPoint(x: 0, y: -spec.size.height * 0.2), radius: 3, fill: SKColor.black.withAlphaComponent(0.16), stroke: Palette.cream.withAlphaComponent(0.18))
            addShape(to: vehicle, rect: CGSize(width: spec.size.width * 0.52, height: 3), pos: CGPoint(x: 0, y: -spec.size.height * 0.2), radius: 1, fill: Palette.cream.withAlphaComponent(0.34), stroke: .clear)
        case .trafficVan:
            addWindow(to: vehicle, size: spec.size, y: spec.size.height * 0.3, widthScale: 0.58, heightScale: 0.12, color: Palette.glass)
            for row in 0..<2 {
                addShape(to: vehicle, rect: CGSize(width: spec.size.width * 0.48, height: 8), pos: CGPoint(x: 0, y: -spec.size.height * 0.14 + CGFloat(row) * 16), radius: 2, fill: Palette.glass.withAlphaComponent(0.72), stroke: Palette.cream.withAlphaComponent(0.18))
            }
        case .trafficBoxTruck:
            let trailer = SKShapeNode(rectOf: CGSize(width: spec.size.width * 0.82, height: spec.size.height * 0.48), cornerRadius: 4)
            trailer.fillColor = Palette.cream.withAlphaComponent(0.72)
            trailer.strokeColor = Palette.navy.withAlphaComponent(0.34)
            trailer.lineWidth = 1
            trailer.position = CGPoint(x: 0, y: -spec.size.height * 0.18)
            trailer.zPosition = 4
            vehicle.addChild(trailer)

            addWindow(to: vehicle, size: spec.size, y: spec.size.height * 0.29, widthScale: 0.48, heightScale: 0.12, color: Palette.glass)
            for row in 0..<3 {
                addShape(to: vehicle, rect: CGSize(width: spec.size.width * 0.68, height: 2), pos: CGPoint(x: 0, y: -spec.size.height * 0.36 + CGFloat(row) * spec.size.height * 0.16), radius: 1, fill: SKColor.black.withAlphaComponent(0.16), stroke: .clear)
            }
        case .trafficSportCoupe:
            addWindow(to: vehicle, size: spec.size, y: spec.size.height * 0.12, widthScale: 0.46, heightScale: 0.16, color: Palette.glass)
            addVehicleHighlight(to: vehicle, size: spec.size, color: Palette.cream.withAlphaComponent(0.3))
            addShape(to: vehicle, rect: CGSize(width: spec.size.width * 0.78, height: 5), pos: CGPoint(x: 0, y: -spec.size.height * 0.46), radius: 2, fill: SKColor.black.withAlphaComponent(0.72), stroke: spec.glowColor.withAlphaComponent(0.35))
        case .policeCruiser:
            addPolicePanels(to: vehicle, size: spec.size)
            addWindow(to: vehicle, size: spec.size, y: spec.size.height * 0.2, widthScale: 0.54, heightScale: 0.17, color: Palette.glass)
            addWindow(to: vehicle, size: spec.size, y: -spec.size.height * 0.23, widthScale: 0.46, heightScale: 0.13, color: Palette.darkGlass)
            addPushBar(to: vehicle, size: spec.size)
            addPoliceLightBar(to: vehicle, size: spec.size, reducedFlashing: reducedFlashing)
        case .policeSUV:
            addPolicePanels(to: vehicle, size: spec.size)
            addWindow(to: vehicle, size: spec.size, y: spec.size.height * 0.22, widthScale: 0.52, heightScale: 0.15, color: Palette.glass)
            addShape(to: vehicle, rect: CGSize(width: spec.size.width * 0.72, height: spec.size.height * 0.44), pos: CGPoint(x: 0, y: -spec.size.height * 0.04), radius: 4, fill: Palette.cream.withAlphaComponent(0.88), stroke: SKColor.black.withAlphaComponent(0.3))
            addPushBar(to: vehicle, size: spec.size)
            addPoliceLightBar(to: vehicle, size: spec.size, reducedFlashing: reducedFlashing)
        case .playerCruiser, .policeMotorcycle:
            break
        }

        addVehicleLights(to: vehicle, size: spec.size)
        addWheelSet(to: vehicle, size: spec.size, style: spec.wheelStyle)
        return vehicle
    }

    static func makeRoadSample(size: CGSize) -> SKNode {
        makeRoadSample(size: size, theme: WorldThemeCatalog.defaultTheme)
    }

    static func makeRoadSample(size: CGSize, theme: WorldTheme) -> SKNode {
        let palette = theme.palette
        let node = SKNode()
        let road = SKShapeNode(rectOf: size, cornerRadius: 8)
        road.fillColor = palette.road
        road.strokeColor = palette.edgeLine
        road.lineWidth = 2
        node.addChild(road)

        let shoulderWidth = max(6, size.width * 0.1)
        for x in [-size.width / 2 + shoulderWidth / 2, size.width / 2 - shoulderWidth / 2] {
            let shoulder = SKShapeNode(rectOf: CGSize(width: shoulderWidth, height: size.height), cornerRadius: 3)
            shoulder.fillColor = palette.shoulder
            shoulder.strokeColor = .clear
            shoulder.position = CGPoint(x: x, y: 0)
            node.addChild(shoulder)
        }

        for divider in [-1, 0, 1] {
            let x = CGFloat(divider) * size.width * 0.18
            for index in 0..<4 {
                let dash = SKShapeNode(rectOf: CGSize(width: 4, height: 22), cornerRadius: 2)
                dash.fillColor = palette.laneMarker
                dash.strokeColor = .clear
                dash.position = CGPoint(x: x, y: -size.height * 0.38 + CGFloat(index) * size.height * 0.25)
                node.addChild(dash)
            }
        }

        switch theme.roadStyle {
        case .tunnel:
            for x in [-size.width * 0.42, size.width * 0.42] {
                let rail = SKShapeNode(rectOf: CGSize(width: 6, height: size.height * 0.88), cornerRadius: 3)
                rail.fillColor = palette.accent.withAlphaComponent(0.36)
                rail.strokeColor = .clear
                rail.position = CGPoint(x: x, y: 0)
                node.addChild(rail)
            }
        case .boardwalk:
            let ocean = SKShapeNode(rectOf: CGSize(width: size.width * 0.22, height: size.height), cornerRadius: 4)
            ocean.fillColor = palette.secondAccent.withAlphaComponent(0.28)
            ocean.strokeColor = .clear
            ocean.position = CGPoint(x: -size.width * 0.49, y: 0)
            node.addChild(ocean)
        case .desertRun, .canyonPass:
            for x in [-size.width * 0.48, size.width * 0.48] {
                let dust = SKShapeNode(rectOf: CGSize(width: size.width * 0.12, height: size.height), cornerRadius: 4)
                dust.fillColor = palette.shoulder.withAlphaComponent(0.5)
                dust.strokeColor = .clear
                dust.position = CGPoint(x: x, y: 0)
                node.addChild(dust)
            }
        case .openFreeway, .downtownGrid:
            break
        }

        return node
    }

    static func makeEffectSample(_ effect: EffectAsset, size: CGSize) -> SKNode {
        let node = SKNode()
        switch effect {
        case .tireSmoke:
            for index in 0..<4 {
                let puff = SKShapeNode(circleOfRadius: CGFloat(7 + index * 2))
                puff.fillColor = SKColor.white.withAlphaComponent(0.16 + CGFloat(index) * 0.06)
                puff.strokeColor = Palette.asphaltLight.withAlphaComponent(0.22)
                puff.position = CGPoint(x: CGFloat(index - 2) * 10, y: CGFloat(index % 2) * 8)
                node.addChild(puff)
            }
        case .speedStreak:
            for index in 0..<5 {
                let streak = SKShapeNode(rectOf: CGSize(width: 3, height: size.height * CGFloat(0.42 + Double(index) * 0.08)), cornerRadius: 1.5)
                streak.fillColor = (index.isMultiple(of: 2) ? Palette.cream : Palette.gold).withAlphaComponent(0.8)
                streak.strokeColor = .clear
                streak.position = CGPoint(x: CGFloat(index - 2) * 9, y: 0)
                node.addChild(streak)
            }
        case .crashSpark:
            for index in 0..<10 {
                let spark = SKShapeNode(rectOf: CGSize(width: CGFloat.random(in: 3...8), height: 2), cornerRadius: 1)
                spark.fillColor = (index.isMultiple(of: 2) ? Palette.gold : Palette.orange)
                spark.strokeColor = .clear
                spark.zRotation = CGFloat(index) * 0.62
                spark.position = CGPoint(x: cos(CGFloat(index)) * 16, y: sin(CGFloat(index)) * 12)
                node.addChild(spark)
            }
        case .sirenGlow:
            for (index, color) in [Palette.red, Palette.blue].enumerated() {
                let glow = SKShapeNode(circleOfRadius: size.width * 0.18)
                glow.fillColor = color.withAlphaComponent(0.28)
                glow.strokeColor = color.withAlphaComponent(0.55)
                glow.glowWidth = 8
                glow.position = CGPoint(x: CGFloat(index == 0 ? -1 : 1) * size.width * 0.16, y: 0)
                node.addChild(glow)
            }
        case .boostTrail:
            for index in 0..<4 {
                let trail = SKShapeNode(rectOf: CGSize(width: 5, height: size.height * 0.34), cornerRadius: 2)
                trail.fillColor = (index.isMultiple(of: 2) ? Palette.orange : Palette.gold).withAlphaComponent(0.74)
                trail.strokeColor = .clear
                trail.position = CGPoint(x: CGFloat(index - 2) * 8, y: -size.height * 0.12)
                node.addChild(trail)
            }
        }
        return node
    }

    static func makePalmProp(height: CGFloat) -> SKNode {
        let node = SKNode()
        let trunk = SKShapeNode(rectOf: CGSize(width: 7, height: height), cornerRadius: 2)
        trunk.fillColor = SKColor(red: 0.48, green: 0.28, blue: 0.13, alpha: 1)
        trunk.strokeColor = SKColor.black.withAlphaComponent(0.25)
        trunk.position = CGPoint(x: 0, y: height * -0.12)
        node.addChild(trunk)

        for angle in stride(from: -70.0, through: 70.0, by: 23.0) {
            let frond = SKShapeNode(rectOf: CGSize(width: 32, height: 6), cornerRadius: 3)
            frond.fillColor = Palette.palm
            frond.strokeColor = Palette.cream.withAlphaComponent(0.16)
            frond.zRotation = CGFloat(angle * .pi / 180)
            frond.position = CGPoint(x: 0, y: height * 0.38)
            node.addChild(frond)
        }

        return node
    }

    static func makeFreewaySign(size: CGSize) -> SKNode {
        let node = SKNode()
        let post = SKShapeNode(rectOf: CGSize(width: 4, height: size.height * 0.9), cornerRadius: 1)
        post.fillColor = Palette.asphaltDark
        post.strokeColor = .clear
        post.position = CGPoint(x: 0, y: -size.height * 0.18)
        node.addChild(post)

        let sign = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height * 0.42), cornerRadius: 4)
        sign.fillColor = Palette.green
        sign.strokeColor = Palette.cream.withAlphaComponent(0.7)
        sign.position = CGPoint(x: 0, y: size.height * 0.18)
        node.addChild(sign)

        let stripe = SKShapeNode(rectOf: CGSize(width: size.width * 0.72, height: 3), cornerRadius: 1)
        stripe.fillColor = Palette.cream
        stripe.strokeColor = .clear
        stripe.position = sign.position
        node.addChild(stripe)
        return node
    }

    static func makeRoadblock(size: CGSize) -> SKSpriteNode {
        let node = SKSpriteNode(color: .clear, size: size)
        node.userData = ["assetID": "obstacle.roadblock"]

        let base = SKShapeNode(rectOf: size, cornerRadius: 5)
        base.fillColor = Palette.navyPanelDeep
        base.strokeColor = Palette.red.withAlphaComponent(0.82)
        base.lineWidth = 2
        base.glowWidth = 4
        node.addChild(base)

        for stripeIndex in -1...1 {
            let stripe = SKShapeNode(rectOf: CGSize(width: size.width * 0.68, height: 7), cornerRadius: 2)
            stripe.fillColor = stripeIndex.isMultiple(of: 2) ? Palette.cream : Palette.red
            stripe.strokeColor = .clear
            stripe.zRotation = -0.38
            stripe.position = CGPoint(x: 0, y: CGFloat(stripeIndex) * 12)
            node.addChild(stripe)
        }

        let spikes = SKShapeNode(rectOf: CGSize(width: size.width * 0.86, height: 5), cornerRadius: 2)
        spikes.fillColor = Palette.asphaltLight
        spikes.strokeColor = .clear
        spikes.position = CGPoint(x: 0, y: -size.height * 0.42)
        node.addChild(spikes)
        return node
    }

    static func makeConstructionMarker(laneWidth: CGFloat) -> SKSpriteNode {
        let node = SKSpriteNode(color: .clear, size: CGSize(width: laneWidth * 0.72, height: 52))
        node.userData = ["assetID": "obstacle.construction_marker"]

        for x in [-laneWidth * 0.18, laneWidth * 0.18] {
            let cone = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: 22))
            path.addLine(to: CGPoint(x: -13, y: -22))
            path.addLine(to: CGPoint(x: 13, y: -22))
            path.closeSubpath()
            cone.path = path
            cone.fillColor = Palette.orange
            cone.strokeColor = Palette.cream.withAlphaComponent(0.7)
            cone.lineWidth = 1
            cone.position = CGPoint(x: x, y: 0)
            node.addChild(cone)
        }

        let bar = SKShapeNode(rectOf: CGSize(width: laneWidth * 0.62, height: 8), cornerRadius: 3)
        bar.fillColor = Palette.gold
        bar.strokeColor = SKColor.black.withAlphaComponent(0.35)
        bar.position = CGPoint(x: 0, y: 0)
        node.addChild(bar)
        return node
    }

    private static func civilianPaint(for type: VehicleType, city: CityTheme) -> (body: SKColor, stroke: SKColor, glow: SKColor) {
        civilianPaint(for: type, world: WorldThemeCatalog.legacyTheme(for: city))
    }

    private static func civilianPaint(for type: VehicleType, world: WorldTheme) -> (body: SKColor, stroke: SKColor, glow: SKColor) {
        let body = world.paintColor(for: type)
        return (body, body.withAlphaComponent(0.95), world.palette.accent)
    }

    private static func makeVehicleShell(spec: VehicleSpec) -> SKSpriteNode {
        let vehicle = SKSpriteNode(color: .clear, size: spec.size)
        vehicle.userData = ["assetID": spec.asset.rawValue]

        let shadow = SKShapeNode(path: vehicleBodyPath(size: spec.size, frontInset: spec.frontInset, rearInset: spec.rearInset))
        shadow.position = CGPoint(x: 2.5, y: -3.5)
        shadow.fillColor = SKColor.black.withAlphaComponent(0.34)
        shadow.strokeColor = .clear
        shadow.zPosition = -4
        vehicle.addChild(shadow)

        let glow = SKShapeNode(path: vehicleBodyPath(size: CGSize(width: spec.size.width * 1.06, height: spec.size.height * 1.04), frontInset: spec.frontInset, rearInset: spec.rearInset))
        glow.fillColor = spec.glowColor.withAlphaComponent(spec.asset == .policeCruiser || spec.asset == .policeSUV ? 0.17 : 0.08)
        glow.strokeColor = spec.glowColor.withAlphaComponent(0.26)
        glow.lineWidth = 2
        glow.zPosition = -3
        vehicle.addChild(glow)

        let body = SKShapeNode(path: vehicleBodyPath(size: spec.size, frontInset: spec.frontInset, rearInset: spec.rearInset))
        body.fillColor = spec.bodyColor
        body.strokeColor = spec.strokeColor.withAlphaComponent(0.8)
        body.lineWidth = 1.6
        body.zPosition = 0
        vehicle.addChild(body)

        let leftFacet = SKShapeNode(path: facetPath(size: spec.size, isLeft: true))
        leftFacet.fillColor = SKColor.black.withAlphaComponent(0.16)
        leftFacet.strokeColor = .clear
        leftFacet.zPosition = 1
        vehicle.addChild(leftFacet)

        let rightFacet = SKShapeNode(path: facetPath(size: spec.size, isLeft: false))
        rightFacet.fillColor = Palette.cream.withAlphaComponent(0.12)
        rightFacet.strokeColor = .clear
        rightFacet.zPosition = 1
        vehicle.addChild(rightFacet)

        return vehicle
    }

    private static func makeMotorcycleSprite(spec: VehicleSpec, reducedFlashing: Bool) -> SKSpriteNode {
        let node = SKSpriteNode(color: .clear, size: spec.size)
        node.userData = ["assetID": spec.asset.rawValue]

        let shadow = SKShapeNode(ellipseOf: CGSize(width: spec.size.width * 1.3, height: spec.size.height * 1.02))
        shadow.fillColor = SKColor.black.withAlphaComponent(0.32)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 2, y: -3)
        shadow.zPosition = -4
        node.addChild(shadow)

        addBikeWheel(to: node, size: CGSize(width: spec.size.width * 0.86, height: spec.size.height * 0.19), y: spec.size.height * 0.39, accent: spec.glowColor)
        addBikeWheel(to: node, size: CGSize(width: spec.size.width * 0.9, height: spec.size.height * 0.21), y: -spec.size.height * 0.39, accent: spec.glowColor)

        let spine = SKShapeNode(rectOf: CGSize(width: spec.size.width * 0.34, height: spec.size.height * 0.68), cornerRadius: spec.size.width * 0.17)
        spine.fillColor = spec.bodyColor
        spine.strokeColor = spec.glowColor.withAlphaComponent(0.82)
        spine.lineWidth = 1.4
        node.addChild(spine)

        addShape(to: node, rect: CGSize(width: spec.size.width * 0.92, height: spec.size.height * 0.28), pos: CGPoint(x: 0, y: spec.size.height * 0.13), radius: spec.size.width * 0.22, fill: Palette.cream.withAlphaComponent(0.94), stroke: spec.glowColor)
        addShape(to: node, ellipse: CGSize(width: spec.size.width * 0.72, height: spec.size.height * 0.18), pos: CGPoint(x: 0, y: -spec.size.height * 0.08), fill: SKColor.black.withAlphaComponent(0.82), stroke: .clear)
        addShape(to: node, rect: CGSize(width: spec.size.width * 0.5, height: 4), pos: CGPoint(x: 0, y: spec.size.height * 0.48), radius: 2, fill: Palette.cream, stroke: .clear)
        addShape(to: node, rect: CGSize(width: spec.size.width * 0.84, height: 5), pos: CGPoint(x: 0, y: spec.size.height * 0.08), radius: 2, fill: Palette.red, stroke: Palette.blue)

        if !reducedFlashing {
            node.children.last?.run(.repeatForever(.sequence([.fadeAlpha(to: 1, duration: 0.12), .fadeAlpha(to: 0.35, duration: 0.12)])))
        }

        return node
    }

    private static func vehicleBodyPath(size: CGSize, frontInset: CGFloat, rearInset: CGFloat) -> CGPath {
        let width = size.width
        let height = size.height
        let frontHalf = width * (0.5 - frontInset)
        let rearHalf = width * (0.5 - rearInset)
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -frontHalf, y: height / 2))
        path.addLine(to: CGPoint(x: frontHalf, y: height / 2))
        path.addLine(to: CGPoint(x: width * 0.5, y: height * 0.18))
        path.addLine(to: CGPoint(x: rearHalf, y: -height / 2))
        path.addLine(to: CGPoint(x: -rearHalf, y: -height / 2))
        path.addLine(to: CGPoint(x: -width * 0.5, y: height * 0.18))
        path.closeSubpath()
        return path
    }

    private static func facetPath(size: CGSize, isLeft: Bool) -> CGPath {
        let sign: CGFloat = isLeft ? -1 : 1
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: size.height * 0.42))
        path.addLine(to: CGPoint(x: sign * size.width * 0.44, y: size.height * 0.14))
        path.addLine(to: CGPoint(x: sign * size.width * 0.34, y: -size.height * 0.42))
        path.addLine(to: CGPoint(x: sign * size.width * 0.08, y: -size.height * 0.2))
        path.closeSubpath()
        return path
    }

    private static func addWindow(to vehicle: SKSpriteNode, size: CGSize, y: CGFloat, widthScale: CGFloat, heightScale: CGFloat, color: SKColor) {
        addShape(to: vehicle, rect: CGSize(width: size.width * widthScale, height: size.height * heightScale), pos: CGPoint(x: 0, y: y), radius: 4, fill: color, stroke: Palette.cream.withAlphaComponent(0.26))
    }

    private static func addVehicleLights(to vehicle: SKSpriteNode, size: CGSize) {
        for x in [-size.width * 0.2, size.width * 0.2] {
            addShape(to: vehicle, rect: CGSize(width: size.width * 0.16, height: 4), pos: CGPoint(x: x, y: size.height * 0.45), radius: 2, fill: Palette.cream, stroke: .clear)
            addShape(to: vehicle, rect: CGSize(width: size.width * 0.13, height: 4), pos: CGPoint(x: x, y: -size.height * 0.45), radius: 2, fill: Palette.red, stroke: .clear)
        }
    }

    private static func addVehicleHighlight(to vehicle: SKSpriteNode, size: CGSize, color: SKColor) {
        addShape(to: vehicle, rect: CGSize(width: size.width * 0.1, height: size.height * 0.72), pos: CGPoint(x: -size.width * 0.18, y: size.height * 0.02), radius: 2, fill: color, stroke: .clear)
    }

    private static func addPolicePanels(to vehicle: SKSpriteNode, size: CGSize) {
        addShape(to: vehicle, rect: CGSize(width: size.width * 0.72, height: size.height * 0.42), pos: CGPoint(x: 0, y: -size.height * 0.03), radius: 4, fill: Palette.cream.withAlphaComponent(0.92), stroke: SKColor.black.withAlphaComponent(0.35))
        addShape(to: vehicle, rect: CGSize(width: size.width * 0.92, height: 5), pos: CGPoint(x: 0, y: -size.height * 0.03), radius: 2, fill: SKColor.black.withAlphaComponent(0.85), stroke: .clear)
    }

    private static func addPushBar(to vehicle: SKSpriteNode, size: CGSize) {
        addShape(to: vehicle, rect: CGSize(width: size.width * 0.8, height: 5), pos: CGPoint(x: 0, y: size.height * 0.49), radius: 2, fill: SKColor.black.withAlphaComponent(0.92), stroke: Palette.cream.withAlphaComponent(0.22))
    }

    private static func addPoliceLightBar(to vehicle: SKSpriteNode, size: CGSize, reducedFlashing: Bool) {
        let bar = SKShapeNode(rectOf: CGSize(width: size.width * 0.5, height: 10), cornerRadius: 3)
        bar.fillColor = SKColor.black.withAlphaComponent(0.82)
        bar.strokeColor = Palette.cream.withAlphaComponent(0.35)
        bar.position = CGPoint(x: 0, y: size.height * 0.07)
        bar.zPosition = 8
        vehicle.addChild(bar)

        let redLight = policeLight(color: Palette.red, x: -size.width * 0.13, y: size.height * 0.07, size: size)
        let blueLight = policeLight(color: Palette.blue, x: size.width * 0.13, y: size.height * 0.07, size: size)
        vehicle.addChild(redLight.light)
        vehicle.addChild(blueLight.light)
        vehicle.addChild(redLight.glow)
        vehicle.addChild(blueLight.glow)

        let highAlpha: CGFloat = reducedFlashing ? 0.62 : 1
        let lowAlpha: CGFloat = reducedFlashing ? 0.32 : 0.16
        let flashDuration = reducedFlashing ? 0.28 : 0.11
        redLight.light.run(.repeatForever(.sequence([.fadeAlpha(to: highAlpha, duration: flashDuration), .fadeAlpha(to: lowAlpha, duration: flashDuration)])))
        blueLight.light.run(.repeatForever(.sequence([.fadeAlpha(to: lowAlpha, duration: flashDuration), .fadeAlpha(to: highAlpha, duration: flashDuration)])))
        redLight.glow.run(.repeatForever(.sequence([.fadeAlpha(to: reducedFlashing ? 0.18 : 0.46, duration: flashDuration), .fadeAlpha(to: 0.05, duration: flashDuration)])))
        blueLight.glow.run(.repeatForever(.sequence([.fadeAlpha(to: 0.05, duration: flashDuration), .fadeAlpha(to: reducedFlashing ? 0.18 : 0.46, duration: flashDuration)])))
    }

    private static func policeLight(color: SKColor, x: CGFloat, y: CGFloat, size: CGSize) -> (light: SKShapeNode, glow: SKShapeNode) {
        let light = SKShapeNode(rectOf: CGSize(width: size.width * 0.2, height: 8), cornerRadius: 3)
        light.fillColor = color
        light.strokeColor = .clear
        light.position = CGPoint(x: x, y: y)
        light.zPosition = 10

        let glow = SKShapeNode(circleOfRadius: size.width * 0.28)
        glow.fillColor = color.withAlphaComponent(0.22)
        glow.strokeColor = .clear
        glow.position = CGPoint(x: x, y: y)
        glow.zPosition = 7
        return (light, glow)
    }

    private static func addWheelSet(to vehicle: SKSpriteNode, size: CGSize, style: WheelStyle) {
        let wheelSize: CGSize
        let xOffset: CGFloat
        let yOffset: CGFloat

        switch style {
        case .standard:
            wheelSize = CGSize(width: 8, height: size.height * 0.22)
            xOffset = size.width * 0.5
            yOffset = size.height * 0.23
        case .sport:
            wheelSize = CGSize(width: 7, height: size.height * 0.2)
            xOffset = size.width * 0.51
            yOffset = size.height * 0.24
        case .heavy:
            wheelSize = CGSize(width: 9, height: size.height * 0.24)
            xOffset = size.width * 0.52
            yOffset = size.height * 0.26
        case .motorcycle:
            return
        }

        for x in [-xOffset, xOffset] {
            for y in [-yOffset, yOffset] {
                let wheel = SKShapeNode(rectOf: wheelSize, cornerRadius: 3)
                wheel.fillColor = Palette.tire
                wheel.strokeColor = Palette.cream.withAlphaComponent(0.12)
                wheel.position = CGPoint(x: x, y: y)
                wheel.zPosition = -1
                vehicle.addChild(wheel)

                let hub = SKShapeNode(rectOf: CGSize(width: wheelSize.width * 0.45, height: wheelSize.height * 0.42), cornerRadius: 2)
                hub.fillColor = SKColor(white: 0.32, alpha: 1)
                hub.strokeColor = .clear
                hub.position = CGPoint(x: x, y: y)
                hub.zPosition = 0
                vehicle.addChild(hub)
            }
        }
    }

    private static func addBikeWheel(to node: SKNode, size: CGSize, y: CGFloat, accent: SKColor) {
        let tire = SKShapeNode(ellipseOf: size)
        tire.fillColor = Palette.tire
        tire.strokeColor = Palette.cream.withAlphaComponent(0.18)
        tire.lineWidth = 1
        tire.position = CGPoint(x: 0, y: y)
        tire.zPosition = -1
        node.addChild(tire)

        let rim = SKShapeNode(ellipseOf: CGSize(width: size.width * 0.52, height: size.height * 0.52))
        rim.fillColor = Palette.cream.withAlphaComponent(0.18)
        rim.strokeColor = accent.withAlphaComponent(0.5)
        rim.position = CGPoint(x: 0, y: y)
        rim.zPosition = 1
        node.addChild(rim)
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
}
