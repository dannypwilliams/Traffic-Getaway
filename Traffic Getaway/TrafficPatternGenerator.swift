import CoreGraphics
import Foundation

struct TrafficSpawnRequest {
    let lane: Int
    let type: VehicleType
    let yOffset: CGFloat
    let speedMultiplier: CGFloat
}

struct TrafficPatternContext {
    let laneCount: Int
    let playerLane: Int
    let playerSlot: Int
    let vehicleClass: PlayableVehicleClass
    let density: CGFloat
    let wantedLevel: Int
    let city: CityTheme
    let protectedLanes: Set<Int>
    let protectedSlots: Set<Int>
    let recentBlockedLanes: Set<Int>
    let recentHazards: [TrafficHazardSnapshot]
    let exitActive: Bool
    let exitSide: ExitSide?
    let dodgeBoostActive: Bool
}

struct TrafficWavePlan {
    let patternName: String
    let spawns: [TrafficSpawnRequest]
    let occupiedLanes: Set<Int>
    let openLanes: Set<Int>
    let safeCarSlots: Set<Int>
    let safeMotorcycleSlots: Set<Int>
    let rejectionReason: String
}

enum TrafficPatternGenerator {
    private enum Pattern: CaseIterable {
        case sparseLanes
        case denseClusters
        case staggeredCars
        case truckWall
        case taxiSwarm
        case sportsBurst
        case policePressure
    }

    static func generate(context: TrafficPatternContext) -> TrafficWavePlan? {
        var lastRejection = "unknown"
        for attempt in 0..<10 {
            let pattern = choosePattern(context: context)
            let requests = makeRequests(pattern: pattern, context: context)
            let validation = TrafficSafetyAnalyzer.validateWave(requests: requests, context: context)

            if validation.isValid {
                return TrafficWavePlan(
                    patternName: String(describing: pattern),
                    spawns: requests,
                    occupiedLanes: validation.occupiedLanes,
                    openLanes: validation.openLanes,
                    safeCarSlots: validation.safeCarSlots,
                    safeMotorcycleSlots: validation.safeMotorcycleSlots,
                    rejectionReason: validation.rejectionReason
                )
            } else {
                lastRejection = validation.rejectionReason
                if AppConfig.printRejectedTrafficWaves {
                    print("[TrafficPattern] rejected \(pattern) attempt=\(attempt) reason=\(validation.rejectionReason)")
                }
            }
        }

        return recoveryWave(context: context, lastRejection: lastRejection)
    }

    private static func choosePattern(context: TrafficPatternContext) -> Pattern {
        let easy: [Pattern] = [.sparseLanes, .staggeredCars, .denseClusters]
        let mid: [Pattern] = [.denseClusters, .staggeredCars, .taxiSwarm, .sportsBurst, .truckWall]
        let hard: [Pattern] = [.denseClusters, .truckWall, .taxiSwarm, .sportsBurst, .policePressure, .staggeredCars]

        if context.density < 0.46 {
            return easy.randomElement() ?? .sparseLanes
        } else if context.density < 0.72 {
            return mid.randomElement() ?? .denseClusters
        } else {
            return hard.randomElement() ?? .policePressure
        }
    }

    private static func makeRequests(pattern: Pattern, context: TrafficPatternContext) -> [TrafficSpawnRequest] {
        let occupiedTarget = occupiedLaneTarget(context)
        let lanes = shuffledPlayableLanes(context)
        var requests: [TrafficSpawnRequest] = []

        switch pattern {
        case .sparseLanes:
            for lane in lanes.prefix(min(5, occupiedTarget)) {
                requests.append(request(lane: lane, type: randomCivilian(context), index: requests.count))
            }

        case .denseClusters:
            let gapStart = Int.random(in: 0...(context.laneCount - 2))
            let gap = Set([gapStart, gapStart + 1]).union(context.protectedLanes)
            for lane in lanes where !gap.contains(lane) && occupiedCount(requests, context) < occupiedTarget {
                requests.append(request(lane: lane, type: randomCivilian(context), index: requests.count))
            }

        case .staggeredCars:
            for lane in lanes where occupiedCount(requests, context) < occupiedTarget {
                let offset = CGFloat((lane + requests.count) % 4) * 42
                requests.append(TrafficSpawnRequest(lane: lane, type: randomCivilian(context), yOffset: offset, speedMultiplier: CGFloat.random(in: 0.9...1.08)))
            }

        case .truckWall:
            let gap = Set(openGap(width: context.density > 0.78 ? 2 : 3, context: context))
            for lane in lanes where !gap.contains(lane) && occupiedCount(requests, context) < occupiedTarget {
                let type: VehicleType = requests.count.isMultiple(of: 2) ? .truck : randomCivilian(context)
                requests.append(request(lane: lane, type: type, index: requests.count, speed: 0.92))
            }

        case .taxiSwarm:
            let gap = Set(openGap(width: 2, context: context))
            for lane in lanes where !gap.contains(lane) && occupiedCount(requests, context) < occupiedTarget {
                requests.append(request(lane: lane, type: .taxi, index: requests.count, speed: 0.96))
            }

        case .sportsBurst:
            for lane in lanes.prefix(min(context.laneCount - 2, occupiedTarget + 1)) where occupiedCount(requests, context) < occupiedTarget {
                requests.append(request(lane: lane, type: .sports, index: requests.count, speed: 1.12))
            }

        case .policePressure:
            let gap = Set(openGap(width: 2, context: context))
            for lane in lanes where !gap.contains(lane) && occupiedCount(requests, context) < occupiedTarget {
                let type: VehicleType = context.wantedLevel >= 4 && requests.count.isMultiple(of: 3) ? .policeMoto : (requests.count.isMultiple(of: 4) ? .bus : randomCivilian(context))
                requests.append(request(lane: lane, type: type, index: requests.count, speed: 1.02))
            }
        }

        return requests
    }

    private static func occupiedLaneTarget(_ context: TrafficPatternContext) -> Int {
        let bikeBonus = context.vehicleClass == .motorcycle ? 1 : 0
        if context.density < 0.28 {
            return Int.random(in: (2 + bikeBonus)...(4 + bikeBonus))
        }
        if context.density < 0.46 {
            return Int.random(in: (3 + bikeBonus)...(5 + bikeBonus))
        }
        if context.density < 0.72 {
            return Int.random(in: (5 + bikeBonus)...min(context.laneCount - 2, 8 + bikeBonus))
        }
        return Int.random(in: (7 + bikeBonus)...min(context.laneCount - 1, 10 + bikeBonus))
    }

    private static func shuffledPlayableLanes(_ context: TrafficPatternContext) -> [Int] {
        Array(0..<context.laneCount)
            .filter { !context.protectedLanes.contains($0) && !context.recentBlockedLanes.contains($0) }
            .shuffled()
    }

    private static func openGap(width: Int, context: TrafficPatternContext) -> [Int] {
        let start = Int.random(in: 0...max(0, context.laneCount - width))
        return Array(start..<(start + width))
    }

    private static func recoveryWave(context: TrafficPatternContext, lastRejection: String) -> TrafficWavePlan? {
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

        let types: [VehicleType] = [.sedan, .taxi, .sports]
        let requests = fallbackLanes.enumerated().map { index, lane in
            TrafficSpawnRequest(
                lane: lane,
                type: types[index % types.count],
                yOffset: CGFloat(index) * 68,
                speedMultiplier: CGFloat.random(in: 0.88...0.98)
            )
        }
        let validation = TrafficSafetyAnalyzer.validateWave(requests: requests, context: context)

        if AppConfig.printRejectedTrafficWaves {
            print("[TrafficPattern] recovery wave after rejection=\(lastRejection) validation=\(validation.rejectionReason)")
        }

        return TrafficWavePlan(
            patternName: "recoveryWave",
            spawns: requests,
            occupiedLanes: validation.occupiedLanes,
            openLanes: validation.openLanes,
            safeCarSlots: validation.safeCarSlots,
            safeMotorcycleSlots: validation.safeMotorcycleSlots,
            rejectionReason: validation.isValid ? lastRejection : validation.rejectionReason
        )
    }

    private static func request(lane: Int, type: VehicleType, index: Int, speed: CGFloat = 1) -> TrafficSpawnRequest {
        TrafficSpawnRequest(
            lane: lane,
            type: type,
            yOffset: CGFloat(index % 4) * CGFloat.random(in: 38...76),
            speedMultiplier: speed * CGFloat.random(in: 0.92...1.08)
        )
    }

    private static func randomCivilian(_ context: TrafficPatternContext) -> VehicleType {
        switch context.city {
        case .newYork:
            return [.taxi, .taxi, .sedan, .sedan, .truck, .bus].randomElement() ?? .sedan
        case .losAngeles:
            return [.sports, .sports, .sedan, .sedan, .taxi, .truck].randomElement() ?? .sedan
        case .miami:
            return [.sports, .sports, .sports, .sedan, .taxi, .bus].randomElement() ?? .sports
        }
    }

    private static func occupiedCount(_ requests: [TrafficSpawnRequest], _ context: TrafficPatternContext) -> Int {
        var occupied: Set<Int> = []
        for request in requests {
            occupied.formUnion(occupiedLanes(for: request.lane, type: request.type, laneCount: context.laneCount))
        }
        return occupied.count
    }

    private static func occupiedLanes(for lane: Int, type: VehicleType, laneCount: Int) -> Set<Int> {
        guard type == .truck || type == .bus else { return [max(0, min(laneCount - 1, lane))] }
        let sideLane = lane < laneCount - 1 ? lane + 1 : lane - 1
        return [max(0, min(laneCount - 1, lane)), max(0, min(laneCount - 1, sideLane))]
    }

}
