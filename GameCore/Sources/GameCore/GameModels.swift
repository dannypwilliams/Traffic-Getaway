import Foundation

public enum VehicleClass: String, Codable, CaseIterable {
    case car
    case motorcycle

    public var displayName: String {
        switch self {
        case .car:
            return "Car"
        case .motorcycle:
            return "Motorcycle"
        }
    }
}

public enum ExitSide: String, Codable, CaseIterable {
    case left
    case right

    public var displayName: String {
        switch self {
        case .left:
            return "LEFT"
        case .right:
            return "RIGHT"
        }
    }

    public var opposite: ExitSide {
        self == .left ? .right : .left
    }
}

public enum RunCity: String, Codable, CaseIterable {
    case newYork
    case losAngeles
    case miami

    public var rank: Int {
        switch self {
        case .newYork:
            return 1
        case .losAngeles:
            return 2
        case .miami:
            return 3
        }
    }

    public var displayName: String {
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

public enum TrafficVehicleType: String, Codable, CaseIterable {
    case sedan
    case taxi
    case sports
    case truck
    case bus
    case policeMoto

    public var laneSpan: Int {
        switch self {
        case .truck, .bus:
            return 2
        case .sedan, .taxi, .sports, .policeMoto:
            return 1
        }
    }

    public var isLarge: Bool {
        switch self {
        case .truck, .bus:
            return true
        case .sedan, .taxi, .sports, .policeMoto:
            return false
        }
    }
}

public struct LevelDefinition: Codable, Equatable {
    public let levelID: String
    public let name: String
    public let city: RunCity
    public let durationBeforeExit: Double
    public let exitSide: ExitSide
    public let exitWindowSeconds: Double
    public let startingTrafficDensity: Double
    public let maxTrafficDensity: Double
    public let policeAggression: Double
    public let rewardCash: Int
    public let rewardXP: Int
    public let allowsEmergencyExit: Bool

    public init(
        levelID: String,
        name: String,
        city: RunCity,
        durationBeforeExit: Double,
        exitSide: ExitSide,
        exitWindowSeconds: Double,
        startingTrafficDensity: Double,
        maxTrafficDensity: Double,
        policeAggression: Double,
        rewardCash: Int,
        rewardXP: Int,
        allowsEmergencyExit: Bool
    ) {
        self.levelID = levelID
        self.name = name
        self.city = city
        self.durationBeforeExit = durationBeforeExit
        self.exitSide = exitSide
        self.exitWindowSeconds = exitWindowSeconds
        self.startingTrafficDensity = startingTrafficDensity
        self.maxTrafficDensity = maxTrafficDensity
        self.policeAggression = policeAggression
        self.rewardCash = rewardCash
        self.rewardXP = rewardXP
        self.allowsEmergencyExit = allowsEmergencyExit
    }
}

public enum LevelCatalog {
    public static let all: [LevelDefinition] = [
        LevelDefinition(levelID: "ny_01", name: "Brooklyn Warmup", city: .newYork, durationBeforeExit: 42, exitSide: .right, exitWindowSeconds: 14, startingTrafficDensity: 0.2, maxTrafficDensity: 0.42, policeAggression: 0.72, rewardCash: 210, rewardXP: 90, allowsEmergencyExit: true),
        LevelDefinition(levelID: "ny_02", name: "FDR Squeeze", city: .newYork, durationBeforeExit: 58, exitSide: .left, exitWindowSeconds: 13, startingTrafficDensity: 0.26, maxTrafficDensity: 0.5, policeAggression: 0.86, rewardCash: 240, rewardXP: 105, allowsEmergencyExit: true),
        LevelDefinition(levelID: "ny_03", name: "Midtown Split", city: .newYork, durationBeforeExit: 68, exitSide: .right, exitWindowSeconds: 11, startingTrafficDensity: 0.34, maxTrafficDensity: 0.6, policeAggression: 1.0, rewardCash: 280, rewardXP: 115, allowsEmergencyExit: true),
        LevelDefinition(levelID: "ny_04", name: "Queensboro Heat", city: .newYork, durationBeforeExit: 76, exitSide: .left, exitWindowSeconds: 10, startingTrafficDensity: 0.38, maxTrafficDensity: 0.66, policeAggression: 1.08, rewardCash: 340, rewardXP: 135, allowsEmergencyExit: false),
        LevelDefinition(levelID: "ny_05", name: "Tunnel Break", city: .newYork, durationBeforeExit: 84, exitSide: .right, exitWindowSeconds: 10, startingTrafficDensity: 0.42, maxTrafficDensity: 0.7, policeAggression: 1.16, rewardCash: 430, rewardXP: 160, allowsEmergencyExit: false),
        LevelDefinition(levelID: "la_01", name: "Sunset Merge", city: .losAngeles, durationBeforeExit: 68, exitSide: .right, exitWindowSeconds: 10, startingTrafficDensity: 0.36, maxTrafficDensity: 0.62, policeAggression: 1.05, rewardCash: 520, rewardXP: 180, allowsEmergencyExit: true),
        LevelDefinition(levelID: "la_02", name: "405 Afterburn", city: .losAngeles, durationBeforeExit: 78, exitSide: .left, exitWindowSeconds: 9, startingTrafficDensity: 0.4, maxTrafficDensity: 0.68, policeAggression: 1.12, rewardCash: 620, rewardXP: 205, allowsEmergencyExit: true),
        LevelDefinition(levelID: "la_03", name: "Valley Cut", city: .losAngeles, durationBeforeExit: 88, exitSide: .right, exitWindowSeconds: 9, startingTrafficDensity: 0.44, maxTrafficDensity: 0.72, policeAggression: 1.2, rewardCash: 740, rewardXP: 235, allowsEmergencyExit: false),
        LevelDefinition(levelID: "la_04", name: "Freeway Riot", city: .losAngeles, durationBeforeExit: 96, exitSide: .left, exitWindowSeconds: 8, startingTrafficDensity: 0.48, maxTrafficDensity: 0.78, policeAggression: 1.28, rewardCash: 880, rewardXP: 270, allowsEmergencyExit: false),
        LevelDefinition(levelID: "la_05", name: "Last Exit West", city: .losAngeles, durationBeforeExit: 104, exitSide: .right, exitWindowSeconds: 8, startingTrafficDensity: 0.52, maxTrafficDensity: 0.82, policeAggression: 1.36, rewardCash: 1_050, rewardXP: 310, allowsEmergencyExit: false),
        LevelDefinition(levelID: "mia_01", name: "Ocean Drive Run", city: .miami, durationBeforeExit: 76, exitSide: .left, exitWindowSeconds: 8, startingTrafficDensity: 0.48, maxTrafficDensity: 0.76, policeAggression: 1.25, rewardCash: 1_220, rewardXP: 340, allowsEmergencyExit: true),
        LevelDefinition(levelID: "mia_02", name: "Neon Causeway", city: .miami, durationBeforeExit: 88, exitSide: .right, exitWindowSeconds: 8, startingTrafficDensity: 0.52, maxTrafficDensity: 0.8, policeAggression: 1.32, rewardCash: 1_420, rewardXP: 380, allowsEmergencyExit: false),
        LevelDefinition(levelID: "mia_03", name: "Thunder Strip", city: .miami, durationBeforeExit: 98, exitSide: .left, exitWindowSeconds: 8, startingTrafficDensity: 0.55, maxTrafficDensity: 0.84, policeAggression: 1.4, rewardCash: 1_650, rewardXP: 425, allowsEmergencyExit: false),
        LevelDefinition(levelID: "mia_04", name: "Vice Lockdown", city: .miami, durationBeforeExit: 108, exitSide: .right, exitWindowSeconds: 7, startingTrafficDensity: 0.58, maxTrafficDensity: 0.86, policeAggression: 1.5, rewardCash: 1_950, rewardXP: 475, allowsEmergencyExit: false),
        LevelDefinition(levelID: "mia_05", name: "Crown Escape", city: .miami, durationBeforeExit: 118, exitSide: .left, exitWindowSeconds: 8, startingTrafficDensity: 0.6, maxTrafficDensity: 0.88, policeAggression: 1.58, rewardCash: 2_400, rewardXP: 560, allowsEmergencyExit: false)
    ]

    public static func level(id: String) -> LevelDefinition? {
        all.first { $0.levelID == id }
    }

    public static func isUnlocked(_ level: LevelDefinition, completedIDs: [String]) -> Bool {
        guard let index = all.firstIndex(where: { $0.levelID == level.levelID }) else { return false }
        return index == 0 || completedIDs.contains(all[index - 1].levelID)
    }

    public static func nextPlayableLevel(completedIDs: [String]) -> LevelDefinition {
        all.first { isUnlocked($0, completedIDs: completedIDs) && !completedIDs.contains($0.levelID) } ?? all.last!
    }

    public static func nextLevel(after levelID: String, completedIDs: [String]) -> LevelDefinition? {
        guard let index = all.firstIndex(where: { $0.levelID == levelID }) else { return nil }
        let nextIndex = index + 1
        guard all.indices.contains(nextIndex), isUnlocked(all[nextIndex], completedIDs: completedIDs) else { return nil }
        return all[nextIndex]
    }

    public static func displayNumber(for levelID: String) -> Int {
        (all.firstIndex { $0.levelID == levelID } ?? 0) + 1
    }
}

public struct VehicleDefinition: Codable, Equatable {
    public let id: String
    public let displayName: String
    public let unlockCost: Int
    public let handling: Double
    public let dodgeBoost: Double
    public let cashMultiplier: Double
    public let scoreMultiplier: Double
    public let policeResistance: Double
    public let vehicleClass: VehicleClass
    public let collisionWidthMultiplier: Double
    public let nearMissMultiplier: Double
    public let canLaneSplit: Bool

    public init(
        id: String,
        displayName: String,
        unlockCost: Int,
        handling: Double,
        dodgeBoost: Double,
        cashMultiplier: Double,
        scoreMultiplier: Double,
        policeResistance: Double,
        vehicleClass: VehicleClass = .car,
        collisionWidthMultiplier: Double = 1.0,
        nearMissMultiplier: Double = 1.0,
        canLaneSplit: Bool = false
    ) {
        self.id = id
        self.displayName = displayName
        self.unlockCost = unlockCost
        self.handling = handling
        self.dodgeBoost = dodgeBoost
        self.cashMultiplier = cashMultiplier
        self.scoreMultiplier = scoreMultiplier
        self.policeResistance = policeResistance
        self.vehicleClass = vehicleClass
        self.collisionWidthMultiplier = collisionWidthMultiplier
        self.nearMissMultiplier = nearMissMultiplier
        self.canLaneSplit = canLaneSplit
    }
}

public enum VehicleCatalog {
    public static let starterCarID = "starter_compact"
    public static let starterBikeID = "starter_bike"

    public static let all: [VehicleDefinition] = [
        VehicleDefinition(id: "starter_compact", displayName: "Starter Compact", unlockCost: 0, handling: 1.00, dodgeBoost: 1.00, cashMultiplier: 1.00, scoreMultiplier: 1.00, policeResistance: 1.00),
        VehicleDefinition(id: "yellow_cab", displayName: "Yellow Cab", unlockCost: 450, handling: 1.02, dodgeBoost: 0.98, cashMultiplier: 1.08, scoreMultiplier: 1.00, policeResistance: 1.00),
        VehicleDefinition(id: "sunset_coupe", displayName: "Sunset Coupe", unlockCost: 700, handling: 1.04, dodgeBoost: 1.03, cashMultiplier: 1.02, scoreMultiplier: 1.03, policeResistance: 1.00),
        VehicleDefinition(id: "miami_speeder", displayName: "Miami Speeder", unlockCost: 1_150, handling: 1.08, dodgeBoost: 1.08, cashMultiplier: 1.04, scoreMultiplier: 1.04, policeResistance: 1.01),
        VehicleDefinition(id: "boxy_retro", displayName: "Boxy Retro", unlockCost: 1_450, handling: 0.98, dodgeBoost: 1.02, cashMultiplier: 1.06, scoreMultiplier: 1.02, policeResistance: 1.04),
        VehicleDefinition(id: "street_racer", displayName: "Street Racer", unlockCost: 1_900, handling: 1.11, dodgeBoost: 1.08, cashMultiplier: 1.02, scoreMultiplier: 1.07, policeResistance: 0.98),
        VehicleDefinition(id: "muscle_v8", displayName: "Muscle V8", unlockCost: 2_400, handling: 0.97, dodgeBoost: 0.98, cashMultiplier: 1.04, scoreMultiplier: 1.06, policeResistance: 1.09),
        VehicleDefinition(id: "delivery_van", displayName: "Delivery Van", unlockCost: 2_850, handling: 0.93, dodgeBoost: 0.95, cashMultiplier: 1.14, scoreMultiplier: 1.00, policeResistance: 1.08),
        VehicleDefinition(id: "police_interceptor", displayName: "Police Interceptor", unlockCost: 3_600, handling: 1.05, dodgeBoost: 1.02, cashMultiplier: 1.04, scoreMultiplier: 1.08, policeResistance: 1.12),
        VehicleDefinition(id: "lowrider", displayName: "Lowrider", unlockCost: 4_100, handling: 1.01, dodgeBoost: 1.04, cashMultiplier: 1.08, scoreMultiplier: 1.04, policeResistance: 1.04),
        VehicleDefinition(id: "cyber_hatch", displayName: "Cyber Hatch", unlockCost: 5_100, handling: 1.12, dodgeBoost: 1.12, cashMultiplier: 1.04, scoreMultiplier: 1.07, policeResistance: 1.02),
        VehicleDefinition(id: "rally_beater", displayName: "Rally Beater", unlockCost: 5_800, handling: 1.08, dodgeBoost: 1.00, cashMultiplier: 1.05, scoreMultiplier: 1.05, policeResistance: 1.10),
        VehicleDefinition(id: "luxury_sedan", displayName: "Luxury Sedan", unlockCost: 6_900, handling: 1.00, dodgeBoost: 1.02, cashMultiplier: 1.14, scoreMultiplier: 1.05, policeResistance: 1.11),
        VehicleDefinition(id: "desert_racer", displayName: "Desert Racer", unlockCost: 8_000, handling: 1.04, dodgeBoost: 1.08, cashMultiplier: 1.08, scoreMultiplier: 1.08, policeResistance: 1.09),
        VehicleDefinition(id: "neon_bullet", displayName: "Neon Bullet", unlockCost: 9_400, handling: 1.15, dodgeBoost: 1.16, cashMultiplier: 1.05, scoreMultiplier: 1.11, policeResistance: 0.98),
        VehicleDefinition(id: "classic_roadster", displayName: "Classic Roadster", unlockCost: 10_800, handling: 1.09, dodgeBoost: 1.09, cashMultiplier: 1.08, scoreMultiplier: 1.09, policeResistance: 1.05),
        VehicleDefinition(id: "midnight_runner", displayName: "Midnight Runner", unlockCost: 14_000, handling: 1.11, dodgeBoost: 1.12, cashMultiplier: 1.10, scoreMultiplier: 1.12, policeResistance: 1.14),
        VehicleDefinition(id: "golden_getaway", displayName: "Golden Getaway", unlockCost: 18_000, handling: 1.05, dodgeBoost: 1.08, cashMultiplier: 1.22, scoreMultiplier: 1.08, policeResistance: 1.06),
        VehicleDefinition(id: "ghost_pursuit", displayName: "Ghost Pursuit", unlockCost: 23_000, handling: 1.16, dodgeBoost: 1.18, cashMultiplier: 1.08, scoreMultiplier: 1.16, policeResistance: 1.12),
        VehicleDefinition(id: "crown_jewel", displayName: "Crown Jewel", unlockCost: 30_000, handling: 1.14, dodgeBoost: 1.15, cashMultiplier: 1.16, scoreMultiplier: 1.16, policeResistance: 1.16),
        VehicleDefinition(id: "starter_bike", displayName: "Starter Bike", unlockCost: 550, handling: 1.12, dodgeBoost: 1.06, cashMultiplier: 1.03, scoreMultiplier: 1.04, policeResistance: 0.94, vehicleClass: .motorcycle, collisionWidthMultiplier: 0.56, nearMissMultiplier: 1.22, canLaneSplit: true),
        VehicleDefinition(id: "courier_250", displayName: "Courier 250", unlockCost: 850, handling: 1.18, dodgeBoost: 1.02, cashMultiplier: 0.98, scoreMultiplier: 1.05, policeResistance: 0.92, vehicleClass: .motorcycle, collisionWidthMultiplier: 0.54, nearMissMultiplier: 1.24, canLaneSplit: true),
        VehicleDefinition(id: "street_hawk", displayName: "Street Hawk", unlockCost: 2_200, handling: 1.22, dodgeBoost: 1.10, cashMultiplier: 1.04, scoreMultiplier: 1.10, policeResistance: 0.91, vehicleClass: .motorcycle, collisionWidthMultiplier: 0.52, nearMissMultiplier: 1.32, canLaneSplit: true),
        VehicleDefinition(id: "miami_phantom", displayName: "Miami Phantom", unlockCost: 3_200, handling: 1.20, dodgeBoost: 1.20, cashMultiplier: 1.06, scoreMultiplier: 1.08, policeResistance: 0.92, vehicleClass: .motorcycle, collisionWidthMultiplier: 0.52, nearMissMultiplier: 1.34, canLaneSplit: true),
        VehicleDefinition(id: "highway_ghost", displayName: "Highway Ghost", unlockCost: 6_400, handling: 1.21, dodgeBoost: 1.12, cashMultiplier: 1.06, scoreMultiplier: 1.17, policeResistance: 0.93, vehicleClass: .motorcycle, collisionWidthMultiplier: 0.50, nearMissMultiplier: 1.40, canLaneSplit: true),
        VehicleDefinition(id: "police_moto", displayName: "Police Moto", unlockCost: 7_800, handling: 1.16, dodgeBoost: 1.08, cashMultiplier: 1.06, scoreMultiplier: 1.10, policeResistance: 1.05, vehicleClass: .motorcycle, collisionWidthMultiplier: 0.55, nearMissMultiplier: 1.30, canLaneSplit: true),
        VehicleDefinition(id: "neon_katana", displayName: "Neon Katana", unlockCost: 16_500, handling: 1.26, dodgeBoost: 1.22, cashMultiplier: 1.10, scoreMultiplier: 1.18, policeResistance: 0.96, vehicleClass: .motorcycle, collisionWidthMultiplier: 0.49, nearMissMultiplier: 1.46, canLaneSplit: true),
        VehicleDefinition(id: "crown_serpent", displayName: "Crown Serpent", unlockCost: 26_000, handling: 1.24, dodgeBoost: 1.20, cashMultiplier: 1.14, scoreMultiplier: 1.18, policeResistance: 0.98, vehicleClass: .motorcycle, collisionWidthMultiplier: 0.50, nearMissMultiplier: 1.48, canLaneSplit: true)
    ]

    public static var carsOnly: [VehicleDefinition] {
        all.filter { $0.vehicleClass == .car }
    }

    public static var motorcycles: [VehicleDefinition] {
        all.filter { $0.vehicleClass == .motorcycle }
    }

    public static var defaultVehicle: VehicleDefinition {
        all[0]
    }

    public static func vehicle(id: String) -> VehicleDefinition {
        all.first { $0.id == id } ?? defaultVehicle
    }
}
