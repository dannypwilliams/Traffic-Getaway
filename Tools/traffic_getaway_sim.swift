import Foundation

// Lightweight deterministic simulator for RAM-safe balancing passes.
// It intentionally stores only aggregate run metrics and avoids SpriteKit/runtime objects.

enum SimVehicleClass: String, CaseIterable {
    case car
    case motorcycle
}

enum SimExitSide: String {
    case left
    case right
}

struct SimLevel {
    let id: String
    let name: String
    let durationBeforeExit: Double
    let exitSide: SimExitSide
    let exitWindow: Double
    let startDensity: Double
    let maxDensity: Double
    let policeAggression: Double
    let allowsEmergencyExit: Bool
}

struct SimVehicle {
    let id: String
    let vehicleClass: SimVehicleClass
    let handling: Double
    let dodgeBoost: Double
    let policeResistance: Double
    let nearMissMultiplier: Double
}

struct SimRunResult {
    let levelID: String
    let vehicleID: String
    let vehicleClass: SimVehicleClass
    let seed: UInt64
    let duration: Double
    let completedExit: Bool
    let failureCause: String
    let laneChanges: Int
    let nearMisses: Int
    let laneSplits: Int
    let maxCombo: Int
    let averageDensity: Double
    let minimumPoliceGap: Double
    let exitAttempts: Int
}

struct SimAggregate {
    var runs = 0
    var totalDuration = 0.0
    var durations: [Double] = []
    var exitCompletions = 0
    var crashCauses: [String: Int] = [:]
    var laneChanges = 0
    var nearMisses = 0
    var laneSplits = 0
    var maxCombo = 0
    var totalDensity = 0.0
    var minimumPoliceGap = Double.greatestFiniteMagnitude
    var exitAttempts = 0

    mutating func add(_ result: SimRunResult) {
        runs += 1
        totalDuration += result.duration
        durations.append(result.duration)
        if result.completedExit { exitCompletions += 1 }
        crashCauses[result.failureCause, default: 0] += 1
        laneChanges += result.laneChanges
        nearMisses += result.nearMisses
        laneSplits += result.laneSplits
        maxCombo = max(maxCombo, result.maxCombo)
        totalDensity += result.averageDensity
        minimumPoliceGap = min(minimumPoliceGap, result.minimumPoliceGap)
        exitAttempts += result.exitAttempts
    }

    var averageDuration: Double { runs == 0 ? 0 : totalDuration / Double(runs) }
    var medianDuration: Double {
        guard !durations.isEmpty else { return 0 }
        let sorted = durations.sorted()
        return sorted[sorted.count / 2]
    }
    var exitRate: Double { runs == 0 ? 0 : Double(exitCompletions) / Double(runs) }
    var averageDensity: Double { runs == 0 ? 0 : totalDensity / Double(runs) }
}

struct SeededRNG {
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

    mutating func int(in range: ClosedRange<Int>) -> Int {
        let width = UInt64(range.upperBound - range.lowerBound + 1)
        return range.lowerBound + Int(next() % width)
    }

    mutating func chance(_ probability: Double) -> Bool {
        double(in: 0...1) < probability
    }
}

enum TrafficGetawaySim {
    static let laneCount = 12
    static let slotCount = laneCount * 2 - 1
    static let dt = 0.25
    static let maxPoliceGap = 180.0
    static let minPoliceGap = 34.0
    static let warningPoliceGap = 86.0

    static let levels: [SimLevel] = [
        SimLevel(id: "ny_01", name: "Brooklyn Warmup", durationBeforeExit: 52, exitSide: .right, exitWindow: 13, startDensity: 0.26, maxDensity: 0.48, policeAggression: 0.85, allowsEmergencyExit: true),
        SimLevel(id: "ny_03", name: "Midtown Split", durationBeforeExit: 68, exitSide: .right, exitWindow: 11, startDensity: 0.34, maxDensity: 0.60, policeAggression: 1.00, allowsEmergencyExit: true),
        SimLevel(id: "la_03", name: "Valley Cut", durationBeforeExit: 88, exitSide: .right, exitWindow: 9, startDensity: 0.44, maxDensity: 0.72, policeAggression: 1.20, allowsEmergencyExit: false),
        SimLevel(id: "mia_05", name: "Crown Escape", durationBeforeExit: 118, exitSide: .left, exitWindow: 8, startDensity: 0.60, maxDensity: 0.88, policeAggression: 1.58, allowsEmergencyExit: false)
    ]

    static let vehicles: [SimVehicle] = [
        SimVehicle(id: "starter_compact", vehicleClass: .car, handling: 1.00, dodgeBoost: 1.00, policeResistance: 1.00, nearMissMultiplier: 1.00),
        SimVehicle(id: "crown_jewel", vehicleClass: .car, handling: 1.14, dodgeBoost: 1.15, policeResistance: 1.16, nearMissMultiplier: 1.00),
        SimVehicle(id: "starter_bike", vehicleClass: .motorcycle, handling: 1.12, dodgeBoost: 1.06, policeResistance: 0.94, nearMissMultiplier: 1.22),
        SimVehicle(id: "neon_katana", vehicleClass: .motorcycle, handling: 1.26, dodgeBoost: 1.22, policeResistance: 0.96, nearMissMultiplier: 1.46)
    ]

    static func density(level: SimLevel, time: Double, exitActive: Bool) -> Double {
        let trafficProgress = min(1, max(0, (time - 15) / 30))
        let policeProgress = min(1, max(0, (time - 45) / 45))
        let finalStart = max(0, level.durationBeforeExit - 18)
        let finalProgress = min(1, max(0, (time - finalStart) / 18))
        let value = level.startDensity + (level.maxDensity - level.startDensity) * (trafficProgress * 0.62 + policeProgress * 0.22 + finalProgress * 0.16)
        return min(level.maxDensity, value + (exitActive ? 0.03 : 0))
    }

    static func policeClosing(level: SimLevel, time: Double, exitActive: Bool) -> Double {
        let policeProgress = min(1, max(0, (time - 45) / 45))
        let finalStart = max(0, level.durationBeforeExit - 18)
        let finalProgress = min(1, max(0, (time - finalStart) / 18))
        let base = (2.6 + policeProgress * 3.2 + finalProgress * 1.2) * level.policeAggression
        return exitActive ? base * 1.08 : base
    }

    static func spawnInterval(density: Double, exitActive: Bool) -> Double {
        max(0.38, 1.08 - density * 0.62 - (exitActive ? 0.08 : 0))
    }

    static func simulate(level: SimLevel, vehicle: SimVehicle, seed: UInt64) -> SimRunResult {
        var rng = SeededRNG(seed: seed)
        var time = 0.0
        var spawnTimer = 0.0
        var policeGap = maxPoliceGap
        var minGap = maxPoliceGap
        var playerSlot = vehicle.vehicleClass == .car ? 10 : 10
        var combo = 0
        var comboTimer = 0.0
        var maxCombo = 0
        var dodgeBoost = 0.0
        var laneChanges = 0
        var nearMisses = 0
        var laneSplits = 0
        var exitAttempts = 0
        var densityTotal = 0.0
        var densitySamples = 0
        var failure = "completed"
        var completed = false
        var emergencyUsed = false

        while time <= level.durationBeforeExit + level.exitWindow + (level.allowsEmergencyExit && !emergencyUsed ? 8 : 0) {
            let exitActive = time >= level.durationBeforeExit
            let currentDensity = density(level: level, time: time, exitActive: exitActive)
            densityTotal += currentDensity
            densitySamples += 1

            policeGap -= policeClosing(level: level, time: time, exitActive: exitActive) / max(0.86, vehicle.policeResistance) * dt
            minGap = min(minGap, policeGap)
            if policeGap <= minPoliceGap {
                failure = "police_caught"
                break
            }

            spawnTimer += dt
            if spawnTimer >= spawnInterval(density: currentDensity, exitActive: exitActive) {
                spawnTimer = 0
                let wave = makeWave(density: currentDensity, vehicle: vehicle, exitActive: exitActive, exitSide: level.exitSide, playerSlot: playerSlot, rng: &rng)
                let decision = chooseSlot(from: playerSlot, safeSlots: wave.safeSlots, vehicle: vehicle, exitActive: exitActive, exitSide: level.exitSide, dodgeBoost: dodgeBoost)

                guard let target = decision.target else {
                    failure = wave.failureCause
                    break
                }

                if target != playerSlot {
                    laneChanges += 1
                    playerSlot = target
                }

                if decision.risky || rng.chance(0.12 + currentDensity * 0.14) {
                    nearMisses += 1
                    combo += 1
                    comboTimer = 3.0
                    maxCombo = max(maxCombo, combo)
                    dodgeBoost = max(dodgeBoost, 1.5 * vehicle.dodgeBoost)
                    policeGap = min(maxPoliceGap, policeGap + 12 * vehicle.nearMissMultiplier)
                }

                if vehicle.vehicleClass == .motorcycle && playerSlot % 2 == 1 && rng.chance(0.34 + currentDensity * 0.22) {
                    laneSplits += 1
                    combo += 1
                    comboTimer = 3.0
                    maxCombo = max(maxCombo, combo)
                    policeGap = min(maxPoliceGap, policeGap + 8)
                }
            }

            if exitActive {
                exitAttempts += 1
                let exitSlots = slotsForExit(level.exitSide, vehicle: vehicle)
                if exitSlots.contains(playerSlot) {
                    completed = true
                    failure = "completed"
                    break
                }
                if time > level.durationBeforeExit + level.exitWindow {
                    if level.allowsEmergencyExit && !emergencyUsed {
                        emergencyUsed = true
                        policeGap -= 32
                    } else {
                        failure = "missed_exit"
                        break
                    }
                }
            }

            if comboTimer > 0 {
                comboTimer -= dt
                if comboTimer <= 0 { combo = 0 }
            }
            dodgeBoost = max(0, dodgeBoost - dt)
            time += dt
        }

        let averageDensity = densitySamples == 0 ? 0 : densityTotal / Double(densitySamples)
        return SimRunResult(
            levelID: level.id,
            vehicleID: vehicle.id,
            vehicleClass: vehicle.vehicleClass,
            seed: seed,
            duration: time,
            completedExit: completed,
            failureCause: failure,
            laneChanges: laneChanges,
            nearMisses: nearMisses,
            laneSplits: laneSplits,
            maxCombo: maxCombo,
            averageDensity: averageDensity,
            minimumPoliceGap: minGap,
            exitAttempts: exitAttempts
        )
    }

    static func makeWave(
        density: Double,
        vehicle: SimVehicle,
        exitActive: Bool,
        exitSide: SimExitSide,
        playerSlot: Int,
        rng: inout SeededRNG
    ) -> (safeSlots: Set<Int>, failureCause: String) {
        var fallback: (safeSlots: Set<Int>, failureCause: String) = ([], "unreachable_wave")

        for _ in 0..<8 {
            let occupiedTarget: Int
            if density < 0.46 {
                occupiedTarget = rng.int(in: 3...5)
            } else if density < 0.72 {
                occupiedTarget = rng.int(in: 5...8)
            } else {
                occupiedTarget = rng.int(in: 7...10)
            }

            var blockedLanes: Set<Int> = []
            let protected = exitActive ? lanesForExit(exitSide) : []
            var attempts = 0
            while blockedLanes.count < occupiedTarget && attempts < 30 {
                attempts += 1
                let lane = rng.int(in: 0...(laneCount - 1))
                if protected.contains(lane) { continue }
                blockedLanes.insert(lane)
                if rng.chance(density > 0.76 ? 0.18 : 0.08), lane < laneCount - 1, !protected.contains(lane + 1) {
                    blockedLanes.insert(lane + 1)
                }
            }

            var safeSlots = Set(0..<slotCount)
            for lane in blockedLanes {
                safeSlots.remove(lane * 2)
                if vehicle.vehicleClass == .car {
                    continue
                }
                if rng.chance(0.18 + density * 0.22) {
                    if lane * 2 > 0 { safeSlots.remove(lane * 2 - 1) }
                    if lane * 2 < slotCount - 1 { safeSlots.remove(lane * 2 + 1) }
                }
            }

            if vehicle.vehicleClass == .car {
                safeSlots = safeSlots.filter { $0 % 2 == 0 }
            }

            if exitActive {
                safeSlots.formUnion(slotsForExit(exitSide, vehicle: vehicle))
            }

            let minimumSafe = minimumSafeSlots(density: density, vehicle: vehicle)
            let reach = validationReach(vehicle: vehicle, exitActive: exitActive)
            let reachable = safeSlots.filter { abs($0 - playerSlot) <= reach }
            let hasExitRoute = !exitActive || reachable.contains { slot in
                switch exitSide {
                case .left:
                    return slot <= playerSlot && slot <= 8
                case .right:
                    return slot >= playerSlot && slot >= slotCount - 9
                }
            }

            fallback = (safeSlots, reachable.isEmpty ? "unreachable_wave" : "thin_safe_paths")
            if safeSlots.count >= minimumSafe, !reachable.isEmpty, hasExitRoute {
                return (safeSlots, "traffic_collision")
            }
        }

        return fallback
    }

    static func chooseSlot(
        from current: Int,
        safeSlots: Set<Int>,
        vehicle: SimVehicle,
        exitActive: Bool,
        exitSide: SimExitSide,
        dodgeBoost: Double
    ) -> (target: Int?, risky: Bool) {
        let reach = reachableSlots(vehicle: vehicle, boosted: dodgeBoost > 0)
        let candidates = safeSlots.filter { abs($0 - current) <= reach }
        guard !candidates.isEmpty else { return (nil, false) }

        let targetSlots = exitActive ? slotsForExit(exitSide, vehicle: vehicle) : safeSlots
        let desired: Int
        if exitActive {
            desired = exitSide == .left ? targetSlots.min() ?? 0 : targetSlots.max() ?? (slotCount - 1)
        } else {
            desired = 10
        }

        let target = candidates.min { lhs, rhs in
            let lhsScore = abs(lhs - desired) + (lhs == current ? 2 : 0)
            let rhsScore = abs(rhs - desired) + (rhs == current ? 2 : 0)
            return lhsScore < rhsScore
        }
        let risky = target.map { abs($0 - current) <= 2 && $0 != current } ?? false
        return (target, risky)
    }

    static func reachableSlots(vehicle: SimVehicle, boosted: Bool) -> Int {
        let base = vehicle.vehicleClass == .motorcycle ? 2 : 4
        let handlingBonus = vehicle.handling > 1.1 ? 1 : 0
        return base + handlingBonus + (boosted ? 2 : 0)
    }

    static func validationReach(vehicle: SimVehicle, exitActive: Bool) -> Int {
        switch vehicle.vehicleClass {
        case .car:
            return exitActive ? 8 : 6
        case .motorcycle:
            return exitActive ? 8 : 7
        }
    }

    static func minimumSafeSlots(density: Double, vehicle: SimVehicle) -> Int {
        switch vehicle.vehicleClass {
        case .car:
            return density < 0.46 ? 3 : (density < 0.72 ? 3 : 2)
        case .motorcycle:
            return density < 0.46 ? 5 : (density < 0.72 ? 4 : 3)
        }
    }

    static func stableSeed(for key: String, runIndex: Int) -> UInt64 {
        var hash: UInt64 = 1469598103934665603
        for byte in key.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 1099511628211
        }
        return hash &+ UInt64(runIndex * 7919 + 17)
    }

    static func lanesForExit(_ side: SimExitSide) -> Set<Int> {
        side == .left ? [0, 1, 2] : [9, 10, 11]
    }

    static func slotsForExit(_ side: SimExitSide, vehicle: SimVehicle) -> Set<Int> {
        switch (side, vehicle.vehicleClass) {
        case (.left, .car):
            return [0, 2]
        case (.right, .car):
            return [20, 22]
        case (.left, .motorcycle):
            return [0, 1, 2, 3]
        case (.right, .motorcycle):
            return [19, 20, 21, 22]
        }
    }

    static func runBatch(runsPerConfiguration: Int) -> [String: SimAggregate] {
        var aggregates: [String: SimAggregate] = [:]
        for level in levels {
            for vehicle in vehicles {
                let key = "\(level.id)|\(vehicle.id)"
                for runIndex in 0..<runsPerConfiguration {
                    let seed = stableSeed(for: key, runIndex: runIndex)
                    let result = simulate(level: level, vehicle: vehicle, seed: seed)
                    aggregates[key, default: SimAggregate()].add(result)
                }
            }
        }
        return aggregates
    }
}

let runsPerConfiguration = CommandLine.arguments.dropFirst().first.flatMap(Int.init) ?? 25
let cappedRuns = max(1, min(50, runsPerConfiguration))
let aggregates = TrafficGetawaySim.runBatch(runsPerConfiguration: cappedRuns)

print("Traffic Getaway RAM-safe simulation")
print("Runs per configuration: \(cappedRuns)")
print("Stored data: aggregate metrics only")
print("")
print("level,vehicle,avgDuration,medianDuration,exitRate,avgDensity,nearMissesPerRun,laneSplitsPerRun,laneChangesPerRun,minPoliceGap,topFailure")

for key in aggregates.keys.sorted() {
    guard let aggregate = aggregates[key] else { continue }
    let parts = key.split(separator: "|")
    let topFailure = aggregate.crashCauses.sorted { lhs, rhs in lhs.value > rhs.value }.first.map { "\($0.key):\($0.value)" } ?? "none"
    let line = [
        String(parts[0]),
        String(parts[1]),
        String(format: "%.1f", aggregate.averageDuration),
        String(format: "%.1f", aggregate.medianDuration),
        String(format: "%.0f%%", aggregate.exitRate * 100),
        String(format: "%.2f", aggregate.averageDensity),
        String(format: "%.1f", Double(aggregate.nearMisses) / Double(max(1, aggregate.runs))),
        String(format: "%.1f", Double(aggregate.laneSplits) / Double(max(1, aggregate.runs))),
        String(format: "%.1f", Double(aggregate.laneChanges) / Double(max(1, aggregate.runs))),
        String(format: "%.0f", aggregate.minimumPoliceGap),
        topFailure
    ].joined(separator: ",")
    print(line)
}
