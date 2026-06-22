import Foundation

public enum LaneModel {
    public static let laneCount = 12
    public static let slotCount = laneCount * 2 - 1
    public static let startLane = 5
    public static let startSlot = startLane * 2

    public static func clampedLane(_ lane: Int) -> Int {
        max(0, min(laneCount - 1, lane))
    }

    public static func targetLane(from currentLane: Int, delta: Int) -> Int {
        clampedLane(currentLane + delta)
    }

    public static func isLaneCenterSlot(_ slot: Int) -> Bool {
        clampRawSlot(slot).isMultiple(of: 2)
    }

    public static func isSplitSlot(_ slot: Int) -> Bool {
        !isLaneCenterSlot(slot)
    }

    public static func laneIndexForEvenSlot(_ slot: Int) -> Int? {
        let clamped = clampRawSlot(slot)
        guard isLaneCenterSlot(clamped) else { return nil }
        return clamped / 2
    }

    public static func nearestLaneForSlot(_ slot: Int) -> Int {
        clampedLane(Int((Double(clampRawSlot(slot)) / 2.0).rounded()))
    }

    public static func validSlots(for vehicleClass: VehicleClass) -> [Int] {
        switch vehicleClass {
        case .car:
            return stride(from: 0, through: slotCount - 1, by: 2).map { $0 }
        case .motorcycle:
            return Array(0..<slotCount)
        }
    }

    public static func targetSlot(from currentSlot: Int, delta: Int, vehicleClass: VehicleClass) -> Int {
        clampSlot(currentSlot + delta, for: vehicleClass)
    }

    public static func clampSlot(_ slot: Int, for vehicleClass: VehicleClass) -> Int {
        let clamped = clampRawSlot(slot)
        guard vehicleClass == .car else { return clamped }
        if clamped.isMultiple(of: 2) { return clamped }
        let lower = clamped - 1
        let upper = clamped + 1
        if upper >= slotCount { return lower }
        if lower < 0 { return upper }
        return abs(upper - slot) < abs(slot - lower) ? upper : lower
    }

    public static func clampRawSlot(_ slot: Int) -> Int {
        max(0, min(slotCount - 1, slot))
    }

    public static func exitLanes(for side: ExitSide) -> [Int] {
        switch side {
        case .left:
            return [0, 1]
        case .right:
            return [laneCount - 2, laneCount - 1]
        }
    }

    public static func exitGuardLanes(for side: ExitSide) -> Set<Int> {
        switch side {
        case .left:
            return Set(0...2)
        case .right:
            return Set((laneCount - 3)..<laneCount)
        }
    }

    public static func exitSlots(for side: ExitSide, vehicleClass: VehicleClass) -> Set<Int> {
        switch vehicleClass {
        case .car:
            return Set(exitLanes(for: side).map { $0 * 2 })
        case .motorcycle:
            switch side {
            case .left:
                return Set(0...3)
            case .right:
                return Set((slotCount - 4)..<slotCount)
            }
        }
    }
}
