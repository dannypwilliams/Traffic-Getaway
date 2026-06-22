import Foundation

public struct TrafficHazardSnapshot: Equatable {
    public let lane: Int
    public let laneSpan: Int
    public let type: TrafficVehicleType
    public let y: Double
    public let height: Double
    public let isRoadblock: Bool

    public init(lane: Int, laneSpan: Int, type: TrafficVehicleType, y: Double, height: Double, isRoadblock: Bool) {
        self.lane = lane
        self.laneSpan = laneSpan
        self.type = type
        self.y = y
        self.height = height
        self.isRoadblock = isRoadblock
    }
}

public struct TrafficSpawnRequest: Equatable {
    public let lane: Int
    public let type: TrafficVehicleType
    public let yOffset: Double
    public let speedMultiplier: Double

    public init(lane: Int, type: TrafficVehicleType, yOffset: Double, speedMultiplier: Double) {
        self.lane = lane
        self.type = type
        self.yOffset = yOffset
        self.speedMultiplier = speedMultiplier
    }
}

public struct TrafficPatternContext: Equatable {
    public let laneCount: Int
    public let playerLane: Int
    public let playerSlot: Int
    public let vehicleClass: VehicleClass
    public let density: Double
    public let wantedLevel: Int
    public let city: RunCity
    public let protectedLanes: Set<Int>
    public let protectedSlots: Set<Int>
    public let recentBlockedLanes: Set<Int>
    public let recentHazards: [TrafficHazardSnapshot]
    public let exitActive: Bool
    public let exitSide: ExitSide?
    public let dodgeBoostActive: Bool

    public init(
        laneCount: Int,
        playerLane: Int,
        playerSlot: Int,
        vehicleClass: VehicleClass,
        density: Double,
        wantedLevel: Int,
        city: RunCity,
        protectedLanes: Set<Int>,
        protectedSlots: Set<Int>,
        recentBlockedLanes: Set<Int>,
        recentHazards: [TrafficHazardSnapshot],
        exitActive: Bool,
        exitSide: ExitSide?,
        dodgeBoostActive: Bool
    ) {
        self.laneCount = laneCount
        self.playerLane = playerLane
        self.playerSlot = playerSlot
        self.vehicleClass = vehicleClass
        self.density = density
        self.wantedLevel = wantedLevel
        self.city = city
        self.protectedLanes = protectedLanes
        self.protectedSlots = protectedSlots
        self.recentBlockedLanes = recentBlockedLanes
        self.recentHazards = recentHazards
        self.exitActive = exitActive
        self.exitSide = exitSide
        self.dodgeBoostActive = dodgeBoostActive
    }
}

public struct TrafficSafetyResult: Equatable {
    public let isValid: Bool
    public let occupiedLanes: Set<Int>
    public let openLanes: Set<Int>
    public let safeCarSlots: Set<Int>
    public let safeMotorcycleSlots: Set<Int>
    public let rejectionReason: String
}

public struct TrafficWavePlan: Equatable {
    public let patternName: String
    public let spawns: [TrafficSpawnRequest]
    public let occupiedLanes: Set<Int>
    public let openLanes: Set<Int>
    public let safeCarSlots: Set<Int>
    public let safeMotorcycleSlots: Set<Int>
    public let rejectionReason: String
}

public enum TrafficSafetyAnalyzer {
    private static let slotCount = LaneModel.slotCount

    public static func validateWave(requests: [TrafficSpawnRequest], context: TrafficPatternContext) -> TrafficSafetyResult {
        guard !requests.isEmpty else {
            return rejected("empty wave", occupied: [], open: Set(0..<context.laneCount), carSlots: [], motorcycleSlots: [])
        }

        var occupiedLanes: Set<Int> = []
        var blockedCarSlots: Set<Int> = context.protectedSlots
        var blockedMotorcycleSlots: Set<Int> = context.protectedSlots
        var largeVehicleLanes: Set<Int> = []

        for request in requests {
            let lanes = lanesOccupied(by: request.lane, span: request.type.laneSpan, laneCount: context.laneCount)
            if !lanes.isDisjoint(with: occupiedLanes) {
                return rejected("overlap", occupied: occupiedLanes, open: openLanes(occupied: occupiedLanes, context: context), carSlots: [], motorcycleSlots: [])
            }
            if !lanes.isDisjoint(with: context.protectedLanes) {
                return rejected("protected exit lane", occupied: occupiedLanes, open: openLanes(occupied: occupiedLanes, context: context), carSlots: [], motorcycleSlots: [])
            }

            occupiedLanes.formUnion(lanes)
            blockedCarSlots.formUnion(lanes.map { $0 * 2 })
            if request.type.isLarge {
                largeVehicleLanes.formUnion(lanes)
                blockedMotorcycleSlots.formUnion(slotsBlockedByLargeVehicle(lanes: lanes))
            }
        }

        for hazard in context.recentHazards {
            let lanes = lanesOccupied(by: hazard.lane, span: hazard.laneSpan, laneCount: context.laneCount)
            occupiedLanes.formUnion(lanes)
            blockedCarSlots.formUnion(lanes.map { $0 * 2 })
            if hazard.isRoadblock || hazard.type.isLarge {
                largeVehicleLanes.formUnion(lanes)
                blockedMotorcycleSlots.formUnion(slotsBlockedByLargeVehicle(lanes: lanes))
            }
        }

        let open = openLanes(occupied: occupiedLanes, context: context)
        let safeCarSlots = carSlots().subtracting(blockedCarSlots)
        let safeMotorcycleSlots = motorcycleSlots(occupiedLanes: occupiedLanes, largeVehicleLanes: largeVehicleLanes)
            .subtracting(blockedMotorcycleSlots)

        let requirements = requiredSafeCounts(for: context.density)
        guard safeCarSlots.count >= requirements.carSlots else {
            return rejected("not enough safe car lanes", occupied: occupiedLanes, open: open, carSlots: safeCarSlots, motorcycleSlots: safeMotorcycleSlots)
        }
        guard safeMotorcycleSlots.count >= requirements.motorcycleSlots else {
            return rejected("not enough safe motorcycle slots", occupied: occupiedLanes, open: open, carSlots: safeCarSlots, motorcycleSlots: safeMotorcycleSlots)
        }

        let reach = reachableRange(for: context)
        let activeSafeSlots = context.vehicleClass == .motorcycle ? safeMotorcycleSlots : safeCarSlots
        let reachableSafeSlots = activeSafeSlots.filter { abs($0 - context.playerSlot) <= reach }
        guard !reachableSafeSlots.isEmpty else {
            return rejected("no reachable safe slot", occupied: occupiedLanes, open: open, carSlots: safeCarSlots, motorcycleSlots: safeMotorcycleSlots)
        }

        if context.exitActive, let side = context.exitSide {
            let exitRoute = reachableSafeSlots.contains { slot in
                switch side {
                case .left:
                    return slot <= context.playerSlot && slot <= 8
                case .right:
                    return slot >= context.playerSlot && slot >= slotCount - 9
                }
            }

            guard exitRoute else {
                return rejected("no reachable exit-side route", occupied: occupiedLanes, open: open, carSlots: safeCarSlots, motorcycleSlots: safeMotorcycleSlots)
            }
        }

        return TrafficSafetyResult(
            isValid: true,
            occupiedLanes: occupiedLanes,
            openLanes: open,
            safeCarSlots: safeCarSlots,
            safeMotorcycleSlots: safeMotorcycleSlots,
            rejectionReason: "ok"
        )
    }

    public static func lanesOccupied(by lane: Int, span: Int, laneCount: Int = LaneModel.laneCount) -> Set<Int> {
        let clamped = max(0, min(laneCount - 1, lane))
        guard span > 1 else { return [clamped] }
        let sideLane = clamped < laneCount - 1 ? clamped + 1 : clamped - 1
        return [clamped, max(0, min(laneCount - 1, sideLane))]
    }

    private static func rejected(_ reason: String, occupied: Set<Int>, open: Set<Int>, carSlots: Set<Int>, motorcycleSlots: Set<Int>) -> TrafficSafetyResult {
        TrafficSafetyResult(
            isValid: false,
            occupiedLanes: occupied,
            openLanes: open,
            safeCarSlots: carSlots,
            safeMotorcycleSlots: motorcycleSlots,
            rejectionReason: reason
        )
    }

    private static func requiredSafeCounts(for density: Double) -> (carSlots: Int, motorcycleSlots: Int) {
        if density < 0.46 {
            return (3, 5)
        }
        if density < 0.72 {
            return (3, 4)
        }
        return (2, 3)
    }

    private static func reachableRange(for context: TrafficPatternContext) -> Int {
        let base: Int
        if context.vehicleClass == .motorcycle {
            base = context.exitActive ? 8 : 7
        } else {
            base = context.exitActive ? 8 : 6
        }
        return context.dodgeBoostActive ? base + 2 : base
    }

    private static func carSlots() -> Set<Int> {
        Set(stride(from: 0, through: LaneModel.slotCount - 1, by: 2))
    }

    private static func motorcycleSlots(occupiedLanes: Set<Int>, largeVehicleLanes: Set<Int>) -> Set<Int> {
        var slots = Set(0..<LaneModel.slotCount)

        for lane in occupiedLanes {
            slots.remove(lane * 2)
        }

        for lane in largeVehicleLanes {
            slots.subtract(slotsBlockedByLargeVehicle(lanes: [lane]))
        }

        return slots
    }

    private static func openLanes(occupied: Set<Int>, context: TrafficPatternContext) -> Set<Int> {
        Set(0..<context.laneCount).subtracting(occupied).subtracting(context.protectedLanes)
    }

    private static func slotsBlockedByLargeVehicle(lanes: Set<Int>) -> Set<Int> {
        var slots: Set<Int> = []
        for lane in lanes {
            let center = lane * 2
            slots.insert(center)
            if center > 0 {
                slots.insert(center - 1)
            }
            if center < slotCount - 1 {
                slots.insert(center + 1)
            }
        }
        return slots
    }
}
