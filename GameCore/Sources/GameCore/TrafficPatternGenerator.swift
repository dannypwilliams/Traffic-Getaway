import Foundation

public enum TrafficPatternGenerator {
    private enum Pattern: String, CaseIterable {
        case sparseLanes
        case denseClusters
        case staggeredCars
        case truckWall
        case taxiSwarm
        case sportsBurst
        case policePressure
    }

    public static func generate(context: TrafficPatternContext, rng: inout SeededRNG) -> TrafficWavePlan? {
        for _ in 0..<10 {
            let pattern = choosePattern(context: context, rng: &rng)
            let requests = makeRequests(pattern: pattern, context: context, rng: &rng)
            let validation = TrafficSafetyAnalyzer.validateWave(requests: requests, context: context)

            if validation.isValid {
                return TrafficWavePlan(
                    patternName: pattern.rawValue,
                    spawns: requests,
                    occupiedLanes: validation.occupiedLanes,
                    openLanes: validation.openLanes,
                    safeCarSlots: validation.safeCarSlots,
                    safeMotorcycleSlots: validation.safeMotorcycleSlots,
                    rejectionReason: validation.rejectionReason
                )
            }
        }

        return recoveryWave(context: context, rng: &rng)
    }

    private static func choosePattern(context: TrafficPatternContext, rng: inout SeededRNG) -> Pattern {
        let easy: [Pattern] = [.sparseLanes, .staggeredCars, .denseClusters]
        let mid: [Pattern] = [.denseClusters, .staggeredCars, .taxiSwarm, .sportsBurst, .truckWall]
        let hard: [Pattern] = [.denseClusters, .truckWall, .taxiSwarm, .sportsBurst, .policePressure, .staggeredCars]

        if context.density < 0.46 {
            return rng.element(from: easy) ?? .sparseLanes
        } else if context.density < 0.72 {
            return rng.element(from: mid) ?? .denseClusters
        } else {
            return rng.element(from: hard) ?? .policePressure
        }
    }

    private static func makeRequests(pattern: Pattern, context: TrafficPatternContext, rng: inout SeededRNG) -> [TrafficSpawnRequest] {
        let occupiedTarget = occupiedLaneTarget(context, rng: &rng)
        let lanes = shuffledPlayableLanes(context, rng: &rng)
        var requests: [TrafficSpawnRequest] = []

        switch pattern {
        case .sparseLanes:
            for lane in lanes.prefix(min(5, occupiedTarget)) {
                requests.append(request(lane: lane, type: randomCivilian(context, rng: &rng), index: requests.count, rng: &rng))
            }

        case .denseClusters:
            let gapStart = rng.int(in: 0...(context.laneCount - 2))
            let gap = Set([gapStart, gapStart + 1]).union(context.protectedLanes)
            for lane in lanes where !gap.contains(lane) && occupiedCount(requests, context) < occupiedTarget {
                requests.append(request(lane: lane, type: randomCivilian(context, rng: &rng), index: requests.count, rng: &rng))
            }

        case .staggeredCars:
            for lane in lanes where occupiedCount(requests, context) < occupiedTarget {
                let offset = Double((lane + requests.count) % 4) * 42
                requests.append(TrafficSpawnRequest(lane: lane, type: randomCivilian(context, rng: &rng), yOffset: offset, speedMultiplier: rng.double(in: 0.9...1.08)))
            }

        case .truckWall:
            let gap = Set(openGap(width: context.density > 0.78 ? 2 : 3, context: context, rng: &rng))
            for lane in lanes where !gap.contains(lane) && occupiedCount(requests, context) < occupiedTarget {
                let type: TrafficVehicleType = requests.count.isMultiple(of: 2) ? .truck : randomCivilian(context, rng: &rng)
                requests.append(request(lane: lane, type: type, index: requests.count, speed: 0.92, rng: &rng))
            }

        case .taxiSwarm:
            let gap = Set(openGap(width: 2, context: context, rng: &rng))
            for lane in lanes where !gap.contains(lane) && occupiedCount(requests, context) < occupiedTarget {
                requests.append(request(lane: lane, type: .taxi, index: requests.count, speed: 0.96, rng: &rng))
            }

        case .sportsBurst:
            for lane in lanes.prefix(min(context.laneCount - 2, occupiedTarget + 1)) where occupiedCount(requests, context) < occupiedTarget {
                requests.append(request(lane: lane, type: .sports, index: requests.count, speed: 1.12, rng: &rng))
            }

        case .policePressure:
            let gap = Set(openGap(width: 2, context: context, rng: &rng))
            for lane in lanes where !gap.contains(lane) && occupiedCount(requests, context) < occupiedTarget {
                let type: TrafficVehicleType = context.wantedLevel >= 4 && requests.count.isMultiple(of: 3) ? .policeMoto : (requests.count.isMultiple(of: 4) ? .bus : randomCivilian(context, rng: &rng))
                requests.append(request(lane: lane, type: type, index: requests.count, speed: 1.02, rng: &rng))
            }
        }

        return requests
    }

    private static func occupiedLaneTarget(_ context: TrafficPatternContext, rng: inout SeededRNG) -> Int {
        let bikeBonus = context.vehicleClass == .motorcycle ? 1 : 0
        if context.density < 0.28 {
            return rng.int(in: (2 + bikeBonus)...(4 + bikeBonus))
        }
        if context.density < 0.46 {
            return rng.int(in: (3 + bikeBonus)...(5 + bikeBonus))
        }
        if context.density < 0.72 {
            return rng.int(in: (5 + bikeBonus)...min(context.laneCount - 2, 8 + bikeBonus))
        }
        return rng.int(in: (7 + bikeBonus)...min(context.laneCount - 1, 10 + bikeBonus))
    }

    private static func shuffledPlayableLanes(_ context: TrafficPatternContext, rng: inout SeededRNG) -> [Int] {
        rng.shuffled(
            Array(0..<context.laneCount)
                .filter { !context.protectedLanes.contains($0) && !context.recentBlockedLanes.contains($0) }
        )
    }

    private static func openGap(width: Int, context: TrafficPatternContext, rng: inout SeededRNG) -> [Int] {
        let start = rng.int(in: 0...max(0, context.laneCount - width))
        return Array(start..<(start + width))
    }

    private static func recoveryWave(context: TrafficPatternContext, rng: inout SeededRNG) -> TrafficWavePlan? {
        let laneOrder = Array(0..<context.laneCount)
            .filter { lane in
                !context.protectedLanes.contains(lane)
                    && !context.recentBlockedLanes.contains(lane)
                    && !context.protectedSlots.contains(lane * 2)
                    && abs((lane * 2) - context.playerSlot) > 4
            }
            .sorted { abs(($0 * 2) - context.playerSlot) > abs(($1 * 2) - context.playerSlot) }

        let fallbackLanes = Array(laneOrder.prefix(3))
        guard !fallbackLanes.isEmpty else { return nil }

        let types: [TrafficVehicleType] = [.sedan, .taxi, .sports]
        var requests: [TrafficSpawnRequest] = []
        for (index, lane) in fallbackLanes.enumerated() {
            requests.append(TrafficSpawnRequest(
                lane: lane,
                type: types[index % types.count],
                yOffset: Double(index) * 68,
                speedMultiplier: rng.double(in: 0.88...0.98)
            ))
        }
        let validation = TrafficSafetyAnalyzer.validateWave(requests: requests, context: context)
        guard validation.isValid else { return nil }

        return TrafficWavePlan(
            patternName: "recoveryWave",
            spawns: requests,
            occupiedLanes: validation.occupiedLanes,
            openLanes: validation.openLanes,
            safeCarSlots: validation.safeCarSlots,
            safeMotorcycleSlots: validation.safeMotorcycleSlots,
            rejectionReason: validation.rejectionReason
        )
    }

    private static func request(lane: Int, type: TrafficVehicleType, index: Int, speed: Double = 1, rng: inout SeededRNG) -> TrafficSpawnRequest {
        TrafficSpawnRequest(
            lane: lane,
            type: type,
            yOffset: Double(index % 4) * rng.double(in: 38...76),
            speedMultiplier: speed * rng.double(in: 0.92...1.08)
        )
    }

    private static func randomCivilian(_ context: TrafficPatternContext, rng: inout SeededRNG) -> TrafficVehicleType {
        switch context.city {
        case .newYork:
            return rng.element(from: [.taxi, .taxi, .sedan, .sedan, .truck, .bus]) ?? .sedan
        case .losAngeles:
            return rng.element(from: [.sports, .sports, .sedan, .sedan, .taxi, .truck]) ?? .sedan
        case .miami:
            return rng.element(from: [.sports, .sports, .sports, .sedan, .taxi, .bus]) ?? .sports
        }
    }

    private static func occupiedCount(_ requests: [TrafficSpawnRequest], _ context: TrafficPatternContext) -> Int {
        var occupied: Set<Int> = []
        for request in requests {
            occupied.formUnion(TrafficSafetyAnalyzer.lanesOccupied(by: request.lane, span: request.type.laneSpan, laneCount: context.laneCount))
        }
        return occupied.count
    }
}
