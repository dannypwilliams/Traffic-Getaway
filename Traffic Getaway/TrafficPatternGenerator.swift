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
    let recentBlockedLanes: Set<Int>
}

struct TrafficWavePlan {
    let patternName: String
    let spawns: [TrafficSpawnRequest]
    let occupiedLanes: Set<Int>
    let openLanes: Set<Int>
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
        for attempt in 0..<10 {
            let pattern = choosePattern(context: context)
            let requests = makeRequests(pattern: pattern, context: context)
            let validation = validate(requests: requests, context: context)

            if validation.isValid {
                return TrafficWavePlan(
                    patternName: String(describing: pattern),
                    spawns: requests,
                    occupiedLanes: validation.occupied,
                    openLanes: validation.open
                )
            } else if AppConfig.printRejectedTrafficWaves {
                print("[TrafficPattern] rejected \(pattern) attempt=\(attempt) reason=\(validation.reason)")
            }
        }
        return nil
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
            for lane in lanes.prefix(max(3, min(5, occupiedTarget))) {
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

    private static func validate(requests: [TrafficSpawnRequest], context: TrafficPatternContext) -> (isValid: Bool, occupied: Set<Int>, open: Set<Int>, reason: String) {
        guard !requests.isEmpty else { return (false, [], [], "empty wave") }

        var occupied: Set<Int> = []
        for request in requests {
            let lanes = occupiedLanes(for: request.lane, type: request.type, laneCount: context.laneCount)
            if !lanes.isDisjoint(with: occupied) {
                return (false, occupied, [], "overlap")
            }
            if !lanes.isDisjoint(with: context.protectedLanes) {
                return (false, occupied, [], "protected exit lane")
            }
            occupied.formUnion(lanes)
        }

        let danger = occupied.union(context.recentBlockedLanes)
        let allLanes = Set(0..<context.laneCount)
        let open = allLanes.subtracting(danger)
        let minOpen = context.vehicleClass == .motorcycle ? 1 : (context.density < 0.82 ? 2 : 1)
        guard open.count >= minOpen else { return (false, occupied, open, "not enough open lanes") }

        let reachableOpen: Bool
        if context.vehicleClass == .motorcycle {
            let openSlots = openSlots(fromOpenLanes: open, occupiedLanes: danger, laneCount: context.laneCount)
            reachableOpen = openSlots.contains { abs($0 - context.playerSlot) <= 6 }
        } else {
            reachableOpen = open.contains { abs($0 - context.playerLane) <= 3 }
        }
        guard reachableOpen else { return (false, occupied, open, "no reachable gap") }

        return (true, occupied, open, "ok")
    }

    private static func occupiedLaneTarget(_ context: TrafficPatternContext) -> Int {
        let bikeBonus = context.vehicleClass == .motorcycle ? 1 : 0
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

    private static func openSlots(fromOpenLanes openLanes: Set<Int>, occupiedLanes: Set<Int>, laneCount: Int) -> Set<Int> {
        var slots = Set(openLanes.map { $0 * 2 })
        for lane in 0..<(laneCount - 1) where !occupiedLanes.contains(lane) || !occupiedLanes.contains(lane + 1) {
            slots.insert(lane * 2 + 1)
        }
        return slots
    }
}
