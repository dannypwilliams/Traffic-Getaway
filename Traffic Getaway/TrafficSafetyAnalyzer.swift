import CoreGraphics
import Foundation

struct TrafficHazardSnapshot {
    let lane: Int
    let laneSpan: Int
    let type: VehicleType
    let y: CGFloat
    let height: CGFloat
    let isRoadblock: Bool
}

struct TrafficSafetyResult {
    let isValid: Bool
    let occupiedLanes: Set<Int>
    let openLanes: Set<Int>
    let safeCarSlots: Set<Int>
    let safeMotorcycleSlots: Set<Int>
    let rejectionReason: String
}

struct TrafficSlotSafety {
    let slot: Int
    let isSafeForCar: Bool
    let isSafeForMotorcycle: Bool
    let reason: String
}

enum TrafficSafetyAnalyzer {
    private static let slotCount = LaneManager.slotCount

    static func validateWave(requests: [TrafficSpawnRequest], context: TrafficPatternContext) -> TrafficSafetyResult {
        guard !requests.isEmpty else {
            return rejected("empty wave", occupied: [], open: Set(0..<context.laneCount), carSlots: [], motorcycleSlots: [])
        }

        var occupiedLanes: Set<Int> = []
        var blockedCarSlots: Set<Int> = context.protectedSlots
        var blockedMotorcycleSlots: Set<Int> = context.protectedSlots
        var largeVehicleLanes: Set<Int> = []

        for request in requests {
            let lanes = lanesOccupied(by: request.lane, span: laneSpan(for: request.type), laneCount: context.laneCount)
            if !lanes.isDisjoint(with: occupiedLanes) {
                return rejected("overlap", occupied: occupiedLanes, open: openLanes(occupied: occupiedLanes, context: context), carSlots: [], motorcycleSlots: [])
            }
            if !lanes.isDisjoint(with: context.protectedLanes) {
                return rejected("protected exit lane", occupied: occupiedLanes, open: openLanes(occupied: occupiedLanes, context: context), carSlots: [], motorcycleSlots: [])
            }

            occupiedLanes.formUnion(lanes)
            blockedCarSlots.formUnion(lanes.map { $0 * 2 })
            if isLarge(request.type) {
                largeVehicleLanes.formUnion(lanes)
                blockedMotorcycleSlots.formUnion(slotsBlockedByLargeVehicle(lanes: lanes))
            }
        }

        for hazard in context.recentHazards {
            let lanes = lanesOccupied(by: hazard.lane, span: hazard.laneSpan, laneCount: context.laneCount)
            occupiedLanes.formUnion(lanes)
            blockedCarSlots.formUnion(lanes.map { $0 * 2 })
            if hazard.isRoadblock || isLarge(hazard.type) {
                largeVehicleLanes.formUnion(lanes)
                blockedMotorcycleSlots.formUnion(slotsBlockedByLargeVehicle(lanes: lanes))
            }
        }

        let open = openLanes(occupied: occupiedLanes, context: context)
        let safeCarSlots = carSlots(context: context).subtracting(blockedCarSlots)
        let safeMotorcycleSlots = motorcycleSlots(context: context, occupiedLanes: occupiedLanes, largeVehicleLanes: largeVehicleLanes)
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

    private static func requiredSafeCounts(for density: CGFloat) -> (carSlots: Int, motorcycleSlots: Int) {
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

    private static func carSlots(context: TrafficPatternContext) -> Set<Int> {
        Set(stride(from: 0, through: LaneManager.slotCount - 1, by: 2))
    }

    private static func motorcycleSlots(context: TrafficPatternContext, occupiedLanes: Set<Int>, largeVehicleLanes: Set<Int>) -> Set<Int> {
        var slots = Set(0..<LaneManager.slotCount)

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

    private static func lanesOccupied(by lane: Int, span: Int, laneCount: Int) -> Set<Int> {
        let clamped = max(0, min(laneCount - 1, lane))
        guard span > 1 else { return [clamped] }
        let sideLane = clamped < laneCount - 1 ? clamped + 1 : clamped - 1
        return [clamped, max(0, min(laneCount - 1, sideLane))]
    }

    private static func laneSpan(for type: VehicleType) -> Int {
        ArcadeArt.laneSpan(for: type)
    }

    private static func isLarge(_ type: VehicleType) -> Bool {
        ArcadeArt.laneSpan(for: type) > 1
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
