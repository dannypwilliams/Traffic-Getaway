import SpriteKit

enum CarRarity: String, Codable, CaseIterable {
    case common
    case rare
    case epic
    case legendary

    var displayName: String {
        rawValue.capitalized
    }

    var color: SKColor {
        switch self {
        case .common:
            return SKColor(white: 0.86, alpha: 1)
        case .rare:
            return SKColor(red: 0.28, green: 0.72, blue: 1, alpha: 1)
        case .epic:
            return SKColor(red: 0.78, green: 0.34, blue: 1, alpha: 1)
        case .legendary:
            return SKColor(red: 1, green: 0.78, blue: 0.18, alpha: 1)
        }
    }
}

enum VehicleShapeStyle: String, Codable {
    case compact
    case cab
    case coupe
    case speeder
    case retro
    case racer
    case muscle
    case van
    case interceptor
    case lowrider
    case cyber
    case rally
    case luxury
    case desert
    case bullet
    case roadster
    case runner
    case golden
    case ghost
    case crown
    case starterBike
    case courierBike
    case streetHawk
    case miamiPhantom
    case highwayGhost
    case policeMoto
    case neonKatana
    case crownSerpent
}

enum PlayableVehicleClass: String, Codable {
    case car
    case motorcycle

    var displayName: String {
        switch self {
        case .car:
            return "Car"
        case .motorcycle:
            return "Motorcycle"
        }
    }
}

struct CarDefinition {
    let id: String
    let displayName: String
    let description: String
    let rarity: CarRarity
    let unlockCost: Int
    let bodyColor: SKColor
    let accentColor: SKColor
    let handling: CGFloat
    let dodgeBoost: CGFloat
    let cashMultiplier: CGFloat
    let scoreMultiplier: CGFloat
    let policeResistance: CGFloat
    let vehicleShapeStyle: VehicleShapeStyle
    let vehicleClass: PlayableVehicleClass
    let collisionWidthMultiplier: CGFloat
    let nearMissMultiplier: CGFloat
    let canLaneSplit: Bool

    init(
        id: String,
        displayName: String,
        description: String,
        rarity: CarRarity,
        unlockCost: Int,
        bodyColor: SKColor,
        accentColor: SKColor,
        handling: CGFloat,
        dodgeBoost: CGFloat,
        cashMultiplier: CGFloat,
        scoreMultiplier: CGFloat,
        policeResistance: CGFloat,
        vehicleShapeStyle: VehicleShapeStyle,
        vehicleClass: PlayableVehicleClass = .car,
        collisionWidthMultiplier: CGFloat = 1.0,
        nearMissMultiplier: CGFloat = 1.0,
        canLaneSplit: Bool = false
    ) {
        self.id = id
        self.displayName = displayName
        self.description = description
        self.rarity = rarity
        self.unlockCost = unlockCost
        self.bodyColor = bodyColor
        self.accentColor = accentColor
        self.handling = handling
        self.dodgeBoost = dodgeBoost
        self.cashMultiplier = cashMultiplier
        self.scoreMultiplier = scoreMultiplier
        self.policeResistance = policeResistance
        self.vehicleShapeStyle = vehicleShapeStyle
        self.vehicleClass = vehicleClass
        self.collisionWidthMultiplier = collisionWidthMultiplier
        self.nearMissMultiplier = nearMissMultiplier
        self.canLaneSplit = canLaneSplit
    }
}

struct PaintDefinition {
    let id: String
    let displayName: String
    let unlockCost: Int
    let primaryColor: SKColor
    let accentColor: SKColor
    let rarity: CarRarity
}

enum RunCity: String, Codable {
    case newYork
    case losAngeles
    case miami

    var rank: Int {
        switch self {
        case .newYork:
            return 1
        case .losAngeles:
            return 2
        case .miami:
            return 3
        }
    }

    var displayName: String {
        switch self {
        case .newYork:
            return "New York"
        case .losAngeles:
            return "Los Angeles"
        case .miami:
            return "Miami"
        }
    }
}

struct RunStats {
    let score: Int
    let distance: Int
    let survivalTime: TimeInterval
    let cashEarned: Int
    let xpEarned: Int
    let nearMisses: Int
    let clutchSaves: Int
    let highestCombo: Int
    let wantedLevelReached: Int
    let cityReached: RunCity
    let dodgeBoostsUsed: Int
    let crashes: Int
    let selectedCarID: String
    let selectedVehicleClass: PlayableVehicleClass
    let laneSplits: Int
    let motorcycleRunCompleted: Bool
    let completedOnMotorcycle: Bool
    let crashesOnMotorcycle: Int
    let gameMode: GameMode
    let levelID: String?
    let levelCompleted: Bool
    let failureReason: String?
    let usedRevive: Bool
}

enum CarCatalog {
    static let starterCarID = "starter_compact"
    static let starterBikeID = "starter_bike"
    static let defaultPaintID = "default"

    static let cars: [CarDefinition] = [
        CarDefinition(
            id: "starter_compact",
            displayName: "Sunset Cruiser",
            description: "Chunky freeway muscle with bright first-run readability.",
            rarity: .common,
            unlockCost: 0,
            bodyColor: SKColor(red: 1.0, green: 0.36, blue: 0.12, alpha: 1),
            accentColor: SKColor(red: 1.0, green: 0.82, blue: 0.22, alpha: 1),
            handling: 1.00,
            dodgeBoost: 1.00,
            cashMultiplier: 1.00,
            scoreMultiplier: 1.00,
            policeResistance: 1.00,
            vehicleShapeStyle: .muscle
        ),
        CarDefinition(id: "yellow_cab", displayName: "Yellow Cab", description: "Knows every shortcut and every dirty merge.", rarity: .common, unlockCost: 450, bodyColor: SKColor(red: 1, green: 0.82, blue: 0.02, alpha: 1), accentColor: SKColor.black, handling: 1.02, dodgeBoost: 0.98, cashMultiplier: 1.08, scoreMultiplier: 1.00, policeResistance: 1.00, vehicleShapeStyle: .cab),
        CarDefinition(id: "sunset_coupe", displayName: "Sunset Coupe", description: "Smooth freeway lines with a warm LA glow.", rarity: .common, unlockCost: 700, bodyColor: SKColor(red: 1, green: 0.42, blue: 0.14, alpha: 1), accentColor: SKColor(red: 0.62, green: 0.18, blue: 0.95, alpha: 1), handling: 1.04, dodgeBoost: 1.03, cashMultiplier: 1.02, scoreMultiplier: 1.03, policeResistance: 1.00, vehicleShapeStyle: .coupe),
        CarDefinition(id: "miami_speeder", displayName: "Miami Speeder", description: "Neon-night agility built for narrow escapes.", rarity: .rare, unlockCost: 1_150, bodyColor: SKColor(red: 1, green: 0.12, blue: 0.66, alpha: 1), accentColor: SKColor(red: 0, green: 0.82, blue: 1, alpha: 1), handling: 1.08, dodgeBoost: 1.08, cashMultiplier: 1.04, scoreMultiplier: 1.04, policeResistance: 1.01, vehicleShapeStyle: .speeder),
        CarDefinition(id: "boxy_retro", displayName: "Boxy Retro", description: "A square old-school ride with surprising nerve.", rarity: .common, unlockCost: 1_450, bodyColor: SKColor(red: 0.25, green: 0.48, blue: 0.72, alpha: 1), accentColor: SKColor(red: 0.92, green: 0.9, blue: 0.72, alpha: 1), handling: 0.98, dodgeBoost: 1.02, cashMultiplier: 1.06, scoreMultiplier: 1.02, policeResistance: 1.04, vehicleShapeStyle: .retro),
        CarDefinition(id: "street_racer", displayName: "Street Racer", description: "Lightweight tuner that snaps between lanes.", rarity: .rare, unlockCost: 1_900, bodyColor: SKColor(red: 0.02, green: 0.54, blue: 0.95, alpha: 1), accentColor: SKColor.white, handling: 1.11, dodgeBoost: 1.08, cashMultiplier: 1.02, scoreMultiplier: 1.07, policeResistance: 0.98, vehicleShapeStyle: .racer),
        CarDefinition(id: "muscle_v8", displayName: "Muscle V8", description: "Heavy roar, strong presence, stubborn under pressure.", rarity: .rare, unlockCost: 2_400, bodyColor: SKColor(red: 0.12, green: 0.13, blue: 0.16, alpha: 1), accentColor: SKColor(red: 1, green: 0.2, blue: 0.05, alpha: 1), handling: 0.97, dodgeBoost: 0.98, cashMultiplier: 1.04, scoreMultiplier: 1.06, policeResistance: 1.09, vehicleShapeStyle: .muscle),
        CarDefinition(id: "delivery_van", displayName: "Delivery Van", description: "Not graceful, but it earns extra cash on every run.", rarity: .rare, unlockCost: 2_850, bodyColor: SKColor(red: 0.78, green: 0.82, blue: 0.86, alpha: 1), accentColor: SKColor(red: 1, green: 0.58, blue: 0.05, alpha: 1), handling: 0.93, dodgeBoost: 0.95, cashMultiplier: 1.14, scoreMultiplier: 1.00, policeResistance: 1.08, vehicleShapeStyle: .van),
        CarDefinition(id: "police_interceptor", displayName: "Police Interceptor", description: "A turned pursuit car with radio-scanner confidence.", rarity: .epic, unlockCost: 3_600, bodyColor: SKColor(white: 0.05, alpha: 1), accentColor: SKColor(red: 0.25, green: 0.55, blue: 1, alpha: 1), handling: 1.05, dodgeBoost: 1.02, cashMultiplier: 1.04, scoreMultiplier: 1.08, policeResistance: 1.12, vehicleShapeStyle: .interceptor),
        CarDefinition(id: "lowrider", displayName: "Lowrider", description: "Stylish and stable, made for confident close calls.", rarity: .rare, unlockCost: 4_100, bodyColor: SKColor(red: 0.38, green: 0.1, blue: 0.62, alpha: 1), accentColor: SKColor(red: 1, green: 0.78, blue: 0.18, alpha: 1), handling: 1.01, dodgeBoost: 1.04, cashMultiplier: 1.08, scoreMultiplier: 1.04, policeResistance: 1.04, vehicleShapeStyle: .lowrider),
        CarDefinition(id: "cyber_hatch", displayName: "Cyber Hatch", description: "Angular, electric, and wired for fast reactions.", rarity: .epic, unlockCost: 5_100, bodyColor: SKColor(red: 0.05, green: 0.08, blue: 0.11, alpha: 1), accentColor: SKColor(red: 0, green: 1, blue: 0.78, alpha: 1), handling: 1.12, dodgeBoost: 1.12, cashMultiplier: 1.04, scoreMultiplier: 1.07, policeResistance: 1.02, vehicleShapeStyle: .cyber),
        CarDefinition(id: "rally_beater", displayName: "Rally Beater", description: "Scrappy grip and tough suspension for messy escapes.", rarity: .rare, unlockCost: 5_800, bodyColor: SKColor(red: 0.86, green: 0.22, blue: 0.08, alpha: 1), accentColor: SKColor(red: 0.08, green: 0.2, blue: 0.95, alpha: 1), handling: 1.08, dodgeBoost: 1.00, cashMultiplier: 1.05, scoreMultiplier: 1.05, policeResistance: 1.1, vehicleShapeStyle: .rally),
        CarDefinition(id: "luxury_sedan", displayName: "Luxury Sedan", description: "Quiet, composed, and profitable when the heat rises.", rarity: .epic, unlockCost: 6_900, bodyColor: SKColor(red: 0.08, green: 0.08, blue: 0.11, alpha: 1), accentColor: SKColor(red: 0.72, green: 0.86, blue: 1, alpha: 1), handling: 1.00, dodgeBoost: 1.02, cashMultiplier: 1.14, scoreMultiplier: 1.05, policeResistance: 1.11, vehicleShapeStyle: .luxury),
        CarDefinition(id: "desert_racer", displayName: "Desert Racer", description: "Wide stance, hot engine, calm under pressure.", rarity: .epic, unlockCost: 8_000, bodyColor: SKColor(red: 0.86, green: 0.52, blue: 0.22, alpha: 1), accentColor: SKColor(red: 0.08, green: 0.25, blue: 0.32, alpha: 1), handling: 1.04, dodgeBoost: 1.08, cashMultiplier: 1.08, scoreMultiplier: 1.08, policeResistance: 1.09, vehicleShapeStyle: .desert),
        CarDefinition(id: "neon_bullet", displayName: "Neon Bullet", description: "A bright dart for players who live on the edge.", rarity: .epic, unlockCost: 9_400, bodyColor: SKColor(red: 0.04, green: 0.9, blue: 1, alpha: 1), accentColor: SKColor(red: 1, green: 0.1, blue: 0.82, alpha: 1), handling: 1.15, dodgeBoost: 1.16, cashMultiplier: 1.05, scoreMultiplier: 1.11, policeResistance: 0.98, vehicleShapeStyle: .bullet),
        CarDefinition(id: "classic_roadster", displayName: "Classic Roadster", description: "Vintage curves with a clean getaway rhythm.", rarity: .epic, unlockCost: 10_800, bodyColor: SKColor(red: 0.74, green: 0.08, blue: 0.1, alpha: 1), accentColor: SKColor(red: 0.92, green: 0.82, blue: 0.62, alpha: 1), handling: 1.09, dodgeBoost: 1.09, cashMultiplier: 1.08, scoreMultiplier: 1.09, policeResistance: 1.05, vehicleShapeStyle: .roadster),
        CarDefinition(id: "midnight_runner", displayName: "Midnight Runner", description: "Blacktop stealth with a calm hand at high heat.", rarity: .legendary, unlockCost: 14_000, bodyColor: SKColor(red: 0.01, green: 0.015, blue: 0.035, alpha: 1), accentColor: SKColor(red: 0.25, green: 0.55, blue: 1, alpha: 1), handling: 1.11, dodgeBoost: 1.12, cashMultiplier: 1.1, scoreMultiplier: 1.12, policeResistance: 1.14, vehicleShapeStyle: .runner),
        CarDefinition(id: "golden_getaway", displayName: "Golden Getaway", description: "Flashy, lucrative, and impossible to ignore.", rarity: .legendary, unlockCost: 18_000, bodyColor: SKColor(red: 1, green: 0.76, blue: 0.08, alpha: 1), accentColor: SKColor.white, handling: 1.05, dodgeBoost: 1.08, cashMultiplier: 1.22, scoreMultiplier: 1.08, policeResistance: 1.06, vehicleShapeStyle: .golden),
        CarDefinition(id: "ghost_pursuit", displayName: "Ghost Pursuit", description: "A pale blur that makes impossible gaps look planned.", rarity: .legendary, unlockCost: 23_000, bodyColor: SKColor(white: 0.88, alpha: 1), accentColor: SKColor(red: 0.62, green: 0.94, blue: 1, alpha: 1), handling: 1.16, dodgeBoost: 1.18, cashMultiplier: 1.08, scoreMultiplier: 1.16, policeResistance: 1.12, vehicleShapeStyle: .ghost),
        CarDefinition(id: "crown_jewel", displayName: "Crown Jewel", description: "The trophy car: balanced, bright, and built for legends.",
                      rarity: .legendary, unlockCost: 30_000, bodyColor: SKColor(red: 0.72, green: 0.04, blue: 0.92, alpha: 1), accentColor: SKColor(red: 1, green: 0.86, blue: 0.22, alpha: 1), handling: 1.14, dodgeBoost: 1.15, cashMultiplier: 1.16, scoreMultiplier: 1.16, policeResistance: 1.16, vehicleShapeStyle: .crown),
        CarDefinition(id: "starter_bike", displayName: "Starter Bike", description: "A balanced first motorcycle built for clean lane splits.", rarity: .common, unlockCost: 550, bodyColor: SKColor(red: 0.86, green: 0.08, blue: 0.1, alpha: 1), accentColor: SKColor(red: 1, green: 0.78, blue: 0.22, alpha: 1), handling: 1.12, dodgeBoost: 1.06, cashMultiplier: 1.03, scoreMultiplier: 1.04, policeResistance: 0.94, vehicleShapeStyle: .starterBike, vehicleClass: .motorcycle, collisionWidthMultiplier: 0.56, nearMissMultiplier: 1.22, canLaneSplit: true),
        CarDefinition(id: "courier_250", displayName: "Courier 250", description: "Nimble delivery bike with quick hands and modest payouts.", rarity: .common, unlockCost: 850, bodyColor: SKColor(red: 0.95, green: 0.78, blue: 0.08, alpha: 1), accentColor: SKColor(red: 0.12, green: 0.2, blue: 0.26, alpha: 1), handling: 1.18, dodgeBoost: 1.02, cashMultiplier: 0.98, scoreMultiplier: 1.05, policeResistance: 0.92, vehicleShapeStyle: .courierBike, vehicleClass: .motorcycle, collisionWidthMultiplier: 0.54, nearMissMultiplier: 1.24, canLaneSplit: true),
        CarDefinition(id: "street_hawk", displayName: "Street Hawk", description: "A sharp sport bike that turns close calls into big combos.", rarity: .rare, unlockCost: 2_200, bodyColor: SKColor(red: 0.05, green: 0.45, blue: 0.95, alpha: 1), accentColor: SKColor.white, handling: 1.22, dodgeBoost: 1.1, cashMultiplier: 1.04, scoreMultiplier: 1.1, policeResistance: 0.91, vehicleShapeStyle: .streetHawk, vehicleClass: .motorcycle, collisionWidthMultiplier: 0.52, nearMissMultiplier: 1.32, canLaneSplit: true),
        CarDefinition(id: "miami_phantom", displayName: "Miami Phantom", description: "Neon sport bike with a slippery dodge boost feel.", rarity: .rare, unlockCost: 3_200, bodyColor: SKColor(red: 1, green: 0.12, blue: 0.68, alpha: 1), accentColor: SKColor(red: 0, green: 0.9, blue: 1, alpha: 1), handling: 1.2, dodgeBoost: 1.2, cashMultiplier: 1.06, scoreMultiplier: 1.08, policeResistance: 0.92, vehicleShapeStyle: .miamiPhantom, vehicleClass: .motorcycle, collisionWidthMultiplier: 0.52, nearMissMultiplier: 1.34, canLaneSplit: true),
        CarDefinition(id: "highway_ghost", displayName: "Highway Ghost", description: "Black stealth bike for score hunters who live in gaps.", rarity: .epic, unlockCost: 6_400, bodyColor: SKColor(red: 0.015, green: 0.02, blue: 0.035, alpha: 1), accentColor: SKColor(red: 0.48, green: 0.86, blue: 1, alpha: 1), handling: 1.21, dodgeBoost: 1.12, cashMultiplier: 1.06, scoreMultiplier: 1.17, policeResistance: 0.93, vehicleShapeStyle: .highwayGhost, vehicleClass: .motorcycle, collisionWidthMultiplier: 0.5, nearMissMultiplier: 1.4, canLaneSplit: true),
        CarDefinition(id: "police_moto", displayName: "Police Moto", description: "Pursuit hardware with strong resistance under heavy heat.", rarity: .epic, unlockCost: 7_800, bodyColor: SKColor(white: 0.05, alpha: 1), accentColor: SKColor(red: 0.25, green: 0.55, blue: 1, alpha: 1), handling: 1.16, dodgeBoost: 1.08, cashMultiplier: 1.06, scoreMultiplier: 1.1, policeResistance: 1.05, vehicleShapeStyle: .policeMoto, vehicleClass: .motorcycle, collisionWidthMultiplier: 0.55, nearMissMultiplier: 1.3, canLaneSplit: true),
        CarDefinition(id: "neon_katana", displayName: "Neon Katana", description: "Future-bike built for elite lane splitting and combo flow.", rarity: .legendary, unlockCost: 16_500, bodyColor: SKColor(red: 0.06, green: 0.95, blue: 1, alpha: 1), accentColor: SKColor(red: 1, green: 0.1, blue: 0.84, alpha: 1), handling: 1.26, dodgeBoost: 1.22, cashMultiplier: 1.1, scoreMultiplier: 1.18, policeResistance: 0.96, vehicleShapeStyle: .neonKatana, vehicleClass: .motorcycle, collisionWidthMultiplier: 0.49, nearMissMultiplier: 1.46, canLaneSplit: true),
        CarDefinition(id: "crown_serpent", displayName: "Crown Serpent", description: "Legendary superbike, precise and profitable without forgiveness.", rarity: .legendary, unlockCost: 26_000, bodyColor: SKColor(red: 0.48, green: 0.04, blue: 0.82, alpha: 1), accentColor: SKColor(red: 1, green: 0.86, blue: 0.24, alpha: 1), handling: 1.24, dodgeBoost: 1.2, cashMultiplier: 1.14, scoreMultiplier: 1.18, policeResistance: 0.98, vehicleShapeStyle: .crownSerpent, vehicleClass: .motorcycle, collisionWidthMultiplier: 0.5, nearMissMultiplier: 1.48, canLaneSplit: true)
    ]

    static var carsOnly: [CarDefinition] {
        cars.filter { $0.vehicleClass == .car }
    }

    static var motorcycles: [CarDefinition] {
        cars.filter { $0.vehicleClass == .motorcycle }
    }

    static let paints: [PaintDefinition] = [
        PaintDefinition(id: "default", displayName: "Default", unlockCost: 0, primaryColor: .clear, accentColor: .clear, rarity: .common),
        PaintDefinition(id: "matte_black", displayName: "Matte Black", unlockCost: 350, primaryColor: SKColor(white: 0.025, alpha: 1), accentColor: SKColor(white: 0.7, alpha: 1), rarity: .common),
        PaintDefinition(id: "candy_red", displayName: "Candy Red", unlockCost: 450, primaryColor: SKColor(red: 1, green: 0.02, blue: 0.08, alpha: 1), accentColor: SKColor(red: 1, green: 0.55, blue: 0.48, alpha: 1), rarity: .common),
        PaintDefinition(id: "ocean_blue", displayName: "Ocean Blue", unlockCost: 550, primaryColor: SKColor(red: 0.02, green: 0.34, blue: 0.95, alpha: 1), accentColor: SKColor(red: 0.42, green: 0.92, blue: 1, alpha: 1), rarity: .common),
        PaintDefinition(id: "taxi_yellow", displayName: "Taxi Yellow", unlockCost: 700, primaryColor: SKColor(red: 1, green: 0.82, blue: 0.02, alpha: 1), accentColor: SKColor.black, rarity: .common),
        PaintDefinition(id: "sunset_orange", displayName: "Sunset Orange", unlockCost: 900, primaryColor: SKColor(red: 1, green: 0.38, blue: 0.08, alpha: 1), accentColor: SKColor(red: 0.65, green: 0.18, blue: 0.9, alpha: 1), rarity: .rare),
        PaintDefinition(id: "miami_pink", displayName: "Miami Pink", unlockCost: 1_150, primaryColor: SKColor(red: 1, green: 0.12, blue: 0.66, alpha: 1), accentColor: SKColor(red: 0, green: 0.82, blue: 1, alpha: 1), rarity: .rare),
        PaintDefinition(id: "neon_green", displayName: "Neon Green", unlockCost: 1_400, primaryColor: SKColor(red: 0.08, green: 1, blue: 0.28, alpha: 1), accentColor: SKColor.white, rarity: .rare),
        PaintDefinition(id: "chrome_silver", displayName: "Chrome Silver", unlockCost: 2_200, primaryColor: SKColor(red: 0.72, green: 0.78, blue: 0.84, alpha: 1), accentColor: SKColor(red: 0.28, green: 0.75, blue: 1, alpha: 1), rarity: .epic),
        PaintDefinition(id: "gold", displayName: "Gold", unlockCost: 3_200, primaryColor: SKColor(red: 1, green: 0.74, blue: 0.12, alpha: 1), accentColor: SKColor.white, rarity: .legendary)
    ]

    static var defaultCar: CarDefinition {
        cars[0]
    }

    static var defaultPaint: PaintDefinition {
        paints[0]
    }

    static func car(id: String) -> CarDefinition {
        cars.first { $0.id == id } ?? defaultCar
    }

    static func paint(id: String) -> PaintDefinition {
        paints.first { $0.id == id } ?? defaultPaint
    }

    static func resolvedColors(car: CarDefinition, paint: PaintDefinition) -> (body: SKColor, accent: SKColor) {
        if paint.id == defaultPaintID {
            return (car.bodyColor, car.accentColor)
        }
        return (paint.primaryColor, paint.accentColor)
    }
}
