import CoreGraphics

/// Centralizes the freeway layout so gameplay, traffic, police, exits, and debug showcases
/// all use the same 12-lane geometry.
struct LaneManager {
    static let laneCount = 12
    static let slotCount = laneCount * 2 - 1
    static let startLane = 5
    static let startSlot = startLane * 2

    let roadLeft: CGFloat
    let roadWidth: CGFloat

    var laneWidth: CGFloat {
        roadWidth / CGFloat(Self.laneCount)
    }

    var laneCenters: [CGFloat] {
        (0..<Self.laneCount).map { centerX(for: $0) }
    }

    var slotCenters: [CGFloat] {
        (0..<Self.slotCount).map { xPositionForSlot($0) }
    }

    func centerX(for lane: Int) -> CGFloat {
        roadLeft + laneWidth * (CGFloat(clampedLane(lane)) + 0.5)
    }

    func xPositionForSlot(_ slot: Int) -> CGFloat {
        roadLeft + laneWidth * (CGFloat(clampRawSlot(slot)) * 0.5 + 0.5)
    }

    func nearestSlotForX(_ x: CGFloat) -> Int {
        let raw = Int(round(((x - roadLeft) / max(1, laneWidth) - 0.5) * 2))
        return clampRawSlot(raw)
    }

    func clampedLane(_ lane: Int) -> Int {
        max(0, min(Self.laneCount - 1, lane))
    }

    func targetLane(from currentLane: Int, delta: Int) -> Int {
        clampedLane(currentLane + delta)
    }

    func laneIndexForEvenSlot(_ slot: Int) -> Int? {
        let clamped = clampRawSlot(slot)
        guard isLaneCenterSlot(clamped) else { return nil }
        return clamped / 2
    }

    func nearestLaneForSlot(_ slot: Int) -> Int {
        clampedLane(Int(round(CGFloat(clampRawSlot(slot)) / 2)))
    }

    func isLaneCenterSlot(_ slot: Int) -> Bool {
        clampRawSlot(slot).isMultiple(of: 2)
    }

    func isSplitSlot(_ slot: Int) -> Bool {
        !isLaneCenterSlot(slot)
    }

    func validSlots(for vehicleClass: PlayableVehicleClass) -> [Int] {
        switch vehicleClass {
        case .car:
            return stride(from: 0, through: Self.slotCount - 1, by: 2).map { $0 }
        case .motorcycle:
            return Array(0..<Self.slotCount)
        }
    }

    func targetSlot(from currentSlot: Int, delta: Int, vehicleClass: PlayableVehicleClass) -> Int {
        clampSlot(currentSlot + delta, for: vehicleClass)
    }

    func clampSlot(_ slot: Int, for vehicleClass: PlayableVehicleClass) -> Int {
        let clamped = clampRawSlot(slot)
        guard vehicleClass == .car else { return clamped }
        if clamped.isMultiple(of: 2) { return clamped }
        let lower = clamped - 1
        let upper = clamped + 1
        if upper >= Self.slotCount { return lower }
        if lower < 0 { return upper }
        return abs(upper - slot) < abs(slot - lower) ? upper : lower
    }

    private func clampRawSlot(_ slot: Int) -> Int {
        max(0, min(Self.slotCount - 1, slot))
    }

    func exitLanes(for side: ExitSide) -> [Int] {
        switch side {
        case .left:
            return [0, 1]
        case .right:
            return [Self.laneCount - 2, Self.laneCount - 1]
        }
    }

    func exitGuardLanes(for side: ExitSide) -> Set<Int> {
        switch side {
        case .left:
            return Set(0...2)
        case .right:
            return Set((Self.laneCount - 3)..<Self.laneCount)
        }
    }

    func exitSlots(for side: ExitSide, vehicleClass: PlayableVehicleClass) -> Set<Int> {
        switch vehicleClass {
        case .car:
            return Set(exitLanes(for: side).map { $0 * 2 })
        case .motorcycle:
            switch side {
            case .left:
                return Set(0...3)
            case .right:
                return Set((Self.slotCount - 4)..<Self.slotCount)
            }
        }
    }
}
