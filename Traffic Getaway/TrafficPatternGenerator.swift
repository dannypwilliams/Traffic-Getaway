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
    let worldThemeID: WorldThemeID
    let protectedLanes: Set<Int>
    let protectedSlots: Set<Int>
    let recentBlockedLanes: Set<Int>
    let recentHazards: [TrafficHazardSnapshot]
    let exitActive: Bool
    let exitSide: ExitSide?
    let dodgeBoostActive: Bool
}

struct AppSeededRNG {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed == 0 ? 0x1234ABCD : seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }

    mutating func double(in range: ClosedRange<Double>) -> Double {
        let unit = Double(next() >> 11) / Double(UInt64.max >> 11)
        return range.lowerBound + unit * (range.upperBound - range.lowerBound)
    }

    mutating func cgFloat(in range: ClosedRange<CGFloat>) -> CGFloat {
        CGFloat(double(in: Double(range.lowerBound)...Double(range.upperBound)))
    }

    mutating func int(in range: ClosedRange<Int>) -> Int {
        guard range.lowerBound < range.upperBound else { return range.lowerBound }
        let width = UInt64(range.upperBound - range.lowerBound + 1)
        return range.lowerBound + Int(next() % width)
    }

    mutating func chance(_ probability: Double) -> Bool {
        double(in: 0...1) < max(0, min(1, probability))
    }

    mutating func element<T>(from values: [T]) -> T? {
        guard !values.isEmpty else { return nil }
        return values[int(in: 0...(values.count - 1))]
    }

    mutating func shuffled<T>(_ values: [T]) -> [T] {
        guard values.count > 1 else { return values }
        var result = values
        for index in stride(from: result.count - 1, through: 1, by: -1) {
            let swapIndex = int(in: 0...index)
            result.swapAt(index, swapIndex)
        }
        return result
    }

    func derivedStream(named name: String) -> AppSeededRNG {
        AppSeededRNG(seed: Self.stableSeed(for: name, runIndex: 0, baseSeed: state))
    }

    static func stableSeed(for key: String, runIndex: Int, baseSeed: UInt64 = 0) -> UInt64 {
        var hash: UInt64 = 1469598103934665603
        for byte in key.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 1099511628211
        }
        return hash &+ baseSeed &+ UInt64(runIndex * 7919 + 17)
    }
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
        case haulerWall
        case compactPack
        case fastLaneBurst
        case policePressure
    }

    static func generate(context: TrafficPatternContext, rng: inout AppSeededRNG) -> TrafficWavePlan? {
        var lastRejection = "unknown"
        for attempt in 0..<10 {
            let pattern = choosePattern(context: context, rng: &rng)
            let requests = makeRequests(pattern: pattern, context: context, rng: &rng)
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

        return recoveryWave(context: context, lastRejection: lastRejection, rng: &rng)
    }

    private static func choosePattern(context: TrafficPatternContext, rng: inout AppSeededRNG) -> Pattern {
        let easy: [Pattern] = [.sparseLanes, .staggeredCars, .denseClusters]
        let mid: [Pattern] = [.denseClusters, .staggeredCars, .compactPack, .fastLaneBurst, .haulerWall]
        let hard: [Pattern] = [.denseClusters, .haulerWall, .compactPack, .fastLaneBurst, .policePressure, .staggeredCars]

        if context.density < 0.46 {
            return rng.element(from: easy) ?? .sparseLanes
        } else if context.density < 0.72 {
            return rng.element(from: mid) ?? .denseClusters
        } else {
            return rng.element(from: hard) ?? .policePressure
        }
    }

    private static func makeRequests(pattern: Pattern, context: TrafficPatternContext, rng: inout AppSeededRNG) -> [TrafficSpawnRequest] {
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
                let offset = CGFloat((lane + requests.count) % 4) * 42
                requests.append(TrafficSpawnRequest(lane: lane, type: randomCivilian(context, rng: &rng), yOffset: offset, speedMultiplier: rng.cgFloat(in: 0.9...1.08)))
            }

        case .haulerWall:
            let gap = Set(openGap(width: context.density > 0.78 ? 2 : 3, context: context, rng: &rng))
            for lane in lanes where !gap.contains(lane) && occupiedCount(requests, context) < occupiedTarget {
                let type: VehicleType = requests.count.isMultiple(of: 2) ? .boxTruck : randomCivilian(context, rng: &rng)
                requests.append(request(lane: lane, type: type, index: requests.count, speed: 0.92, rng: &rng))
            }

        case .compactPack:
            let gap = Set(openGap(width: 2, context: context, rng: &rng))
            for lane in lanes where !gap.contains(lane) && occupiedCount(requests, context) < occupiedTarget {
                requests.append(request(lane: lane, type: .compact, index: requests.count, speed: 0.96, rng: &rng))
            }

        case .fastLaneBurst:
            for lane in lanes.prefix(min(context.laneCount - 2, occupiedTarget + 1)) where occupiedCount(requests, context) < occupiedTarget {
                requests.append(request(lane: lane, type: .sportCoupe, index: requests.count, speed: 1.12, rng: &rng))
            }

        case .policePressure:
            let gap = Set(openGap(width: 2, context: context, rng: &rng))
            for lane in lanes where !gap.contains(lane) && occupiedCount(requests, context) < occupiedTarget {
                let type: VehicleType = context.wantedLevel >= 4 && requests.count.isMultiple(of: 3) ? .policeMoto : (requests.count.isMultiple(of: 4) ? .van : randomCivilian(context, rng: &rng))
                requests.append(request(lane: lane, type: type, index: requests.count, speed: 1.02, rng: &rng))
            }
        }

        return requests
    }

    private static func occupiedLaneTarget(_ context: TrafficPatternContext, rng: inout AppSeededRNG) -> Int {
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

    private static func shuffledPlayableLanes(_ context: TrafficPatternContext, rng: inout AppSeededRNG) -> [Int] {
        return rng.shuffled(Array(0..<context.laneCount)
            .filter { !context.protectedLanes.contains($0) && !context.recentBlockedLanes.contains($0) }
        )
    }

    private static func openGap(width: Int, context: TrafficPatternContext, rng: inout AppSeededRNG) -> [Int] {
        let start = rng.int(in: 0...max(0, context.laneCount - width))
        return Array(start..<(start + width))
    }

    private static func recoveryWave(context: TrafficPatternContext, lastRejection: String, rng: inout AppSeededRNG) -> TrafficWavePlan? {
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

        let types: [VehicleType] = [.sedan, .compact, .sportCoupe]
        let requests = fallbackLanes.enumerated().map { index, lane in
            TrafficSpawnRequest(
                lane: lane,
                type: types[index % types.count],
                yOffset: CGFloat(index) * 68,
                speedMultiplier: rng.cgFloat(in: 0.88...0.98)
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

    private static func request(lane: Int, type: VehicleType, index: Int, speed: CGFloat = 1, rng: inout AppSeededRNG) -> TrafficSpawnRequest {
        TrafficSpawnRequest(
            lane: lane,
            type: type,
            yOffset: CGFloat(index % 4) * rng.cgFloat(in: 38...76),
            speedMultiplier: speed * rng.cgFloat(in: 0.92...1.08)
        )
    }

    private static func randomCivilian(_ context: TrafficPatternContext, rng: inout AppSeededRNG) -> VehicleType {
        rng.element(from: WorldThemeCatalog.theme(id: context.worldThemeID).trafficPool(wantedLevel: context.wantedLevel)) ?? .sedan
    }

    private static func occupiedCount(_ requests: [TrafficSpawnRequest], _ context: TrafficPatternContext) -> Int {
        var occupied: Set<Int> = []
        for request in requests {
            occupied.formUnion(occupiedLanes(for: request.lane, type: request.type, laneCount: context.laneCount))
        }
        return occupied.count
    }

    private static func occupiedLanes(for lane: Int, type: VehicleType, laneCount: Int) -> Set<Int> {
        guard type == .boxTruck else { return [max(0, min(laneCount - 1, lane))] }
        let sideLane = lane < laneCount - 1 ? lane + 1 : lane - 1
        return [max(0, min(laneCount - 1, lane)), max(0, min(laneCount - 1, sideLane))]
    }

}
