import Foundation

public struct TrafficHazardSnapshot: Equatable {
    public let lane: Int
    public let laneSpan: Int
    public let type: TrafficVehicleType
    public let y: Double
    public let height: Double
    public let speed: Double
    public let isRoadblock: Bool

    public init(lane: Int, laneSpan: Int, type: TrafficVehicleType, y: Double, height: Double, speed: Double = 0, isRoadblock: Bool) {
        self.lane = lane
        self.laneSpan = laneSpan
        self.type = type
        self.y = y
        self.height = height
        self.speed = speed
        self.isRoadblock = isRoadblock
    }
}

public struct TrafficTransitionSafetyConfiguration: Equatable {
    public let laneChangeDuration: Double
    public let predictionHorizon: Double
    public let playerHeight: Double
    public let verticalPadding: Double

    public init(laneChangeDuration: Double = 0.3, predictionHorizon: Double = 0.3, playerHeight: Double = 72, verticalPadding: Double = 10) {
        self.laneChangeDuration = laneChangeDuration
        self.predictionHorizon = predictionHorizon
        self.playerHeight = playerHeight
        self.verticalPadding = verticalPadding
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
            guard preservesExitRoute(from: context.playerSlot, reachableSafeSlots: reachableSafeSlots, side: side) else {
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

    public static func transitionSafeSlots(
        from currentSlot: Int,
        candidateSlots: Set<Int>,
        vehicleClass: VehicleClass,
        hazards: [TrafficHazardSnapshot],
        configuration: TrafficTransitionSafetyConfiguration = TrafficTransitionSafetyConfiguration()
    ) -> Set<Int> {
        guard !candidateSlots.isEmpty, !hazards.isEmpty else { return candidateSlots }

        return candidateSlots.filter { targetSlot in
            let duration = targetSlot == currentSlot ? 0 : configuration.laneChangeDuration

            if targetSlot != currentSlot,
               movingPathIntersectsHazard(from: currentSlot, to: targetSlot, vehicleClass: vehicleClass, hazards: hazards, duration: duration, configuration: configuration) {
                return false
            }

            if slotIntersectsHazard(slot: targetSlot, vehicleClass: vehicleClass, hazards: hazards, after: configuration.predictionHorizon, configuration: configuration) {
                return false
            }

            return true
        }
    }

    public static func transitionRiskScore(
        from currentSlot: Int,
        to targetSlot: Int,
        vehicleClass: VehicleClass,
        hazards: [TrafficHazardSnapshot],
        configuration: TrafficTransitionSafetyConfiguration = TrafficTransitionSafetyConfiguration()
    ) -> Double {
        guard !hazards.isEmpty else { return 0 }

        let start = LaneModel.clampSlot(currentSlot, for: vehicleClass)
        let target = LaneModel.clampSlot(targetSlot, for: vehicleClass)
        let duration = start == target ? 0 : configuration.laneChangeDuration
        let totalTime = max(duration + configuration.predictionHorizon, 0.016)
        let samples = max(4, Int(ceil(totalTime / 0.025)))
        var risk = 0.0

        for step in 0...samples {
            let elapsed = totalTime * Double(step) / Double(samples)
            let progress = duration > 0 ? min(1, max(0, elapsed / duration)) : 1
            let easedProgress = 1 - pow(1 - progress, 2)
            let interpolated = Double(start) + Double(target - start) * easedProgress
            let sampledSlot = LaneModel.clampRawSlot(Int(interpolated.rounded()))
            risk += slotRiskScore(slot: sampledSlot, vehicleClass: vehicleClass, hazards: hazards, after: elapsed, totalTime: totalTime, configuration: configuration)
            if risk > 1_000 {
                return risk
            }
        }

        return risk
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

    private static func preservesExitRoute(from playerSlot: Int, reachableSafeSlots: Set<Int>, side: ExitSide) -> Bool {
        let exitThreshold: Int
        let isExitSideSlot: (Int) -> Bool
        let movesTowardExit: (Int) -> Bool

        switch side {
        case .left:
            exitThreshold = 8
            isExitSideSlot = { $0 <= exitThreshold }
            movesTowardExit = { $0 < playerSlot }
        case .right:
            exitThreshold = slotCount - 9
            isExitSideSlot = { $0 >= exitThreshold }
            movesTowardExit = { $0 > playerSlot }
        }

        if isExitSideSlot(playerSlot) {
            return reachableSafeSlots.contains(where: isExitSideSlot)
        }

        return reachableSafeSlots.contains(where: movesTowardExit)
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

    private static func movingPathIntersectsHazard(
        from currentSlot: Int,
        to targetSlot: Int,
        vehicleClass: VehicleClass,
        hazards: [TrafficHazardSnapshot],
        duration: Double,
        configuration: TrafficTransitionSafetyConfiguration
    ) -> Bool {
        let start = LaneModel.clampSlot(currentSlot, for: vehicleClass)
        let target = LaneModel.clampSlot(targetSlot, for: vehicleClass)
        let samples = 6

        for step in 0...samples {
            let progress = Double(step) / Double(samples)
            let elapsed = duration * progress
            let interpolated = Double(start) + (Double(target - start) * progress)
            let sampledSlot = LaneModel.clampRawSlot(Int(interpolated.rounded()))
            if slotIntersectsHazard(slot: sampledSlot, vehicleClass: .motorcycle, hazards: hazards, after: elapsed, configuration: configuration) {
                return true
            }
        }
        return false
    }

    private static func slotIntersectsHazard(
        slot: Int,
        vehicleClass: VehicleClass,
        hazards: [TrafficHazardSnapshot],
        after elapsed: Double,
        configuration: TrafficTransitionSafetyConfiguration
    ) -> Bool {
        let lanes = lanesCovered(bySlot: slot, vehicleClass: vehicleClass)
        for hazard in hazards {
            let occupied = lanesOccupied(by: hazard.lane, span: hazard.laneSpan)
            guard !occupied.isDisjoint(with: lanes) else { continue }

            let predictedY = hazard.y - hazard.speed * elapsed
            let clearance = (hazard.height + configuration.playerHeight) / 2 + configuration.verticalPadding
            if abs(predictedY) <= clearance {
                return true
            }
        }
        return false
    }

    private static func slotRiskScore(
        slot: Int,
        vehicleClass: VehicleClass,
        hazards: [TrafficHazardSnapshot],
        after elapsed: Double,
        totalTime: Double,
        configuration: TrafficTransitionSafetyConfiguration
    ) -> Double {
        let lanes = lanesCovered(bySlot: slot, vehicleClass: vehicleClass)
        var risk = 0.0

        for hazard in hazards {
            let occupied = lanesOccupied(by: hazard.lane, span: hazard.laneSpan)
            guard !occupied.isDisjoint(with: lanes) else { continue }

            let predictedY = hazard.y - hazard.speed * elapsed
            let clearance = (hazard.height + configuration.playerHeight) / 2 + configuration.verticalPadding
            let overlap = max(0, clearance - abs(predictedY))
            guard overlap > 0 else { continue }

            let overlapRatio = min(1, overlap / max(clearance, 1))
            let urgency = 1 + (1 - min(1, elapsed / totalTime))
            risk += urgency * (1 + overlapRatio * 4)
        }

        return risk
    }

    private static func lanesCovered(bySlot slot: Int, vehicleClass: VehicleClass) -> Set<Int> {
        let clamped = LaneModel.clampSlot(slot, for: vehicleClass)
        if vehicleClass == .motorcycle, LaneModel.isSplitSlot(clamped) {
            let leftLane = LaneModel.clampedLane(clamped / 2)
            return [leftLane, LaneModel.clampedLane(leftLane + 1)]
        }
        return [LaneModel.nearestLaneForSlot(clamped)]
    }
}
