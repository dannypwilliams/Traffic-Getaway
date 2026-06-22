import Foundation

public struct Hitbox: Codable, Equatable {
    public let centerX: Double
    public let centerY: Double
    public let width: Double
    public let height: Double

    public init(centerX: Double, centerY: Double, width: Double, height: Double) {
        self.centerX = centerX
        self.centerY = centerY
        self.width = max(0, width)
        self.height = max(0, height)
    }

    public var minX: Double { centerX - width / 2 }
    public var maxX: Double { centerX + width / 2 }
    public var minY: Double { centerY - height / 2 }
    public var maxY: Double { centerY + height / 2 }
}

public struct NearMissCheck: Codable, Equatable {
    public let playerSlot: Int
    public let hazardLane: Int
    public let hazardLaneSpan: Int
    public let vehicleClass: VehicleClass
    public let longitudinalGap: Double
    public let nearMissWindow: Double

    public init(
        playerSlot: Int,
        hazardLane: Int,
        hazardLaneSpan: Int,
        vehicleClass: VehicleClass,
        longitudinalGap: Double,
        nearMissWindow: Double
    ) {
        self.playerSlot = playerSlot
        self.hazardLane = hazardLane
        self.hazardLaneSpan = hazardLaneSpan
        self.vehicleClass = vehicleClass
        self.longitudinalGap = longitudinalGap
        self.nearMissWindow = nearMissWindow
    }
}

public enum VehicleHitboxModel {
    public static func playerWidth(laneWidth: Double, vehicle: VehicleDefinition) -> Double {
        laneWidth * 0.9 * vehicle.collisionWidthMultiplier
    }

    public static func playerHeight(laneWidth: Double, vehicle: VehicleDefinition) -> Double {
        switch vehicle.vehicleClass {
        case .car:
            return laneWidth * 2.05
        case .motorcycle:
            return laneWidth * 1.72
        }
    }

    public static func trafficWidth(laneWidth: Double, type: TrafficVehicleType) -> Double {
        switch type {
        case .sedan, .taxi, .sports:
            return laneWidth * 0.9
        case .policeMoto:
            return laneWidth * 0.42
        case .truck:
            return laneWidth * 1.55
        case .bus:
            return laneWidth * 1.46
        }
    }

    public static func trafficHeight(laneWidth: Double, type: TrafficVehicleType) -> Double {
        switch type {
        case .sedan, .taxi, .sports:
            return laneWidth * 2.05
        case .policeMoto:
            return laneWidth * 1.55
        case .truck:
            return laneWidth * 2.95
        case .bus:
            return laneWidth * 3.25
        }
    }
}

public enum CollisionModel {
    public static func overlaps(_ lhs: Hitbox, _ rhs: Hitbox) -> Bool {
        lhs.minX < rhs.maxX
            && lhs.maxX > rhs.minX
            && lhs.minY < rhs.maxY
            && lhs.maxY > rhs.minY
    }

    public static func occupiedLanes(centerLane: Int, type: TrafficVehicleType, laneCount: Int = LaneModel.laneCount) -> Set<Int> {
        TrafficSafetyAnalyzer.lanesOccupied(by: centerLane, span: type.laneSpan, laneCount: laneCount)
    }

    public static func isNearMiss(_ check: NearMissCheck) -> Bool {
        guard check.longitudinalGap <= check.nearMissWindow else { return false }
        let occupiedLanes = TrafficSafetyAnalyzer.lanesOccupied(by: check.hazardLane, span: check.hazardLaneSpan)
        let playerLane = LaneModel.nearestLaneForSlot(check.playerSlot)

        if occupiedLanes.contains(playerLane) {
            return false
        }

        if check.vehicleClass == .motorcycle && LaneModel.isSplitSlot(check.playerSlot) {
            let leftLane = max(0, playerLane - 1)
            let rightLane = min(LaneModel.laneCount - 1, playerLane)
            return occupiedLanes.contains(leftLane) || occupiedLanes.contains(rightLane)
        }

        return occupiedLanes.contains(playerLane - 1) || occupiedLanes.contains(playerLane + 1)
    }
}
