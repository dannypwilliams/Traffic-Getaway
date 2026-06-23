import Foundation
import GameCore

struct Options {
    var levelID = "la_01"
    var vehicleID = "starter_compact"
    var runs = 10_000
    var seed: UInt64 = 12_345
    var list = false
    var help = false
    var trafficStress = false
    var activeTrafficLifetime = false
}

func parseOptions(_ arguments: [String]) -> Options {
    var options = Options()
    var index = 0

    while index < arguments.count {
        let argument = arguments[index]
        switch argument {
        case "--help", "-h":
            options.help = true
        case "--list":
            options.list = true
        case "--traffic-stress":
            options.trafficStress = true
        case "--active-traffic-lifetime":
            options.activeTrafficLifetime = true
        case "--level":
            if index + 1 < arguments.count {
                options.levelID = arguments[index + 1]
                index += 1
            }
        case "--vehicle":
            if index + 1 < arguments.count {
                options.vehicleID = arguments[index + 1]
                index += 1
            }
        case "--runs":
            if index + 1 < arguments.count, let runs = Int(arguments[index + 1]) {
                options.runs = runs
                index += 1
            }
        case "--seed":
            if index + 1 < arguments.count, let seed = UInt64(arguments[index + 1]) {
                options.seed = seed
                index += 1
            }
        default:
            break
        }
        index += 1
    }

    options.runs = max(1, options.runs)
    return options
}

func printHelp() {
    print("""
    Traffic Getaway GameSim

    Usage:
      swift run GameSim --level la_01 --vehicle starter_compact --runs 10000 --seed 12345
      swift run GameSim --level sunset_merge --vehicle starter_compact --runs 10000 --seed 12345

    Options:
      --level <id|name|all>       Level to simulate. Default: la_01
      --vehicle <id|name|all>     Vehicle to simulate. Default: starter_compact
      --runs <count>         Runs per level/vehicle configuration. Default: 10000
      --seed <number>        Base deterministic seed. Default: 12345
      --traffic-stress       Run pure traffic wave reachability stress instead of chase simulation
      --active-traffic-lifetime
                             Run chase simulation with active on-screen traffic lifetime and transition checks
      --list                 List known levels and vehicles
      --help                 Show this help
    """)
}

func printCatalog() {
    print("Levels")
    for level in LevelCatalog.all {
        print("  \(level.levelID)  \(normalizedIdentifier(level.name))  \(level.name)  \(level.city.displayName)")
    }
    print("")
    print("Vehicles")
    for vehicle in VehicleCatalog.all {
        print("  \(vehicle.id)  \(normalizedIdentifier(vehicle.displayName))  \(vehicle.displayName)  \(vehicle.vehicleClass.rawValue)")
    }
}

func normalizedIdentifier(_ value: String) -> String {
    var result = ""
    let allowed = CharacterSet.alphanumerics
    for scalar in value.lowercased().unicodeScalars {
        if allowed.contains(scalar) {
            result += String(scalar)
        } else if result.last != "_" {
            result += "_"
        }
    }
    return result.trimmingCharacters(in: CharacterSet(charactersIn: "_"))
}

func selectedLevels(_ id: String) -> [LevelDefinition]? {
    if id == "all" {
        return LevelCatalog.all
    }
    let normalized = normalizedIdentifier(id)
    guard let level = LevelCatalog.all.first(where: { $0.levelID == id || normalizedIdentifier($0.name) == normalized }) else { return nil }
    return [level]
}

func selectedVehicles(_ id: String) -> [VehicleDefinition]? {
    if id == "all" {
        return VehicleCatalog.all
    }
    let normalized = normalizedIdentifier(id)
    guard let vehicle = VehicleCatalog.all.first(where: { $0.id == id || normalizedIdentifier($0.displayName) == normalized }) else { return nil }
    return [vehicle]
}

func percent(_ value: Double) -> String {
    String(format: "%.1f%%", value * 100)
}

func decimal(_ value: Double, places: Int = 1) -> String {
    String(format: "%.\(places)f", value)
}

func firstCrashDistribution(_ aggregate: ChaseSimulationAggregate) -> String {
    guard aggregate.firstCrashTime > 0 else { return "n/a" }
    let p10 = aggregate.firstCrashPercentile(0.10)
    let p50 = aggregate.firstCrashPercentile(0.50)
    let p90 = aggregate.firstCrashPercentile(0.90)
    return "p10 \(decimal(p10))s / p50 \(decimal(p50))s / p90 \(decimal(p90))s"
}

func balanceRecommendation(level: LevelDefinition, vehicle: VehicleDefinition, aggregate: ChaseSimulationAggregate) -> String {
    if aggregate.unfairCollisionRate > 0.05 {
        return "Inspect traffic wave safety before tuning difficulty"
    }

    if level.levelID == "la_01" && vehicle.id == VehicleCatalog.starterCarID {
        if level.durationBeforeExit > 45 {
            return "Move Sunset Merge exit earlier into the 35-45s target"
        }
        if aggregate.firstCrashTime > 0 && aggregate.firstCrashTime < 30 {
            return "Level 1 is too punishing; lower early density or spawn pressure"
        }
        if aggregate.exitAppearedRate < 0.80 {
            return "Level 1 hides the exit too often; reduce early police pressure"
        }
        if aggregate.completionRate < 0.40 {
            return "Level 1 may be too hard; widen safe exit paths or final window"
        }
        if aggregate.completionRate > 0.70 {
            return "Level 1 may be too easy; increase traffic only after 25s"
        }
        return "Level 1 is within starter targets; validate feel on Mac"
    }

    if aggregate.completionRate < 0.30 {
        return "Likely too hard; check density and exit reachability"
    }
    if aggregate.completionRate > 0.80 {
        return "Likely too easy; consider later-run pressure only"
    }
    return "No balance change indicated by this simulation"
}

func csvSafe(_ value: String) -> String {
    value.replacingOccurrences(of: ",", with: ";")
}

func printReport(levels: [LevelDefinition], vehicles: [VehicleDefinition], options: Options) {
    let aggregates = ChaseSimulator.runBatch(
        levels: levels,
        vehicles: vehicles,
        runsPerConfiguration: options.runs,
        baseSeed: options.seed,
        options: ChaseSimulationOptions(modelsActiveTrafficLifetime: options.activeTrafficLifetime)
    )

    print("Traffic Getaway GameSim")
    print("Runs per configuration: \(options.runs)")
    print("Base seed: \(options.seed)")
    if options.activeTrafficLifetime {
        print("Active traffic lifetime: enabled")
    }
    print("")
    print("levelID,levelName,vehicleID,vehicleName,class,runs,seed,avgSurvival,medianSurvival,firstCrashDistribution,exitAppeared,exitReached,completed,nearMisses,laneSplits,avgMaxCombo,maxCombo,avgCash,avgXP,unfairCollision,topFailure,recommendation")

    var classAggregates: [VehicleClass: ChaseSimulationAggregate] = [:]

    for level in levels {
        for vehicle in vehicles {
            let key = "\(level.levelID)|\(vehicle.id)"
            guard let aggregate = aggregates[key] else { continue }
            var classAggregate = classAggregates[vehicle.vehicleClass] ?? ChaseSimulationAggregate()
            classAggregate.merge(aggregate)
            classAggregates[vehicle.vehicleClass] = classAggregate
            let topFailure = aggregate.mostCommonFailure().map { "\($0.cause):\($0.count)" } ?? "none"
            let recommendation = balanceRecommendation(level: level, vehicle: vehicle, aggregate: aggregate)
            let line = [
                level.levelID,
                level.name,
                vehicle.id,
                vehicle.displayName,
                vehicle.vehicleClass.rawValue,
                "\(aggregate.runs)",
                "\(options.seed)",
                decimal(aggregate.averageDuration),
                decimal(aggregate.medianDuration),
                firstCrashDistribution(aggregate),
                percent(aggregate.exitAppearedRate),
                percent(aggregate.exitReachedRate),
                percent(aggregate.completionRate),
                decimal(aggregate.nearMissesPerRun),
                decimal(aggregate.laneSplitsPerRun),
                decimal(aggregate.averageMaxCombo),
                "\(aggregate.maxCombo)",
                decimal(aggregate.averageCash, places: 0),
                decimal(aggregate.averageXP, places: 0),
                percent(aggregate.unfairCollisionRate),
                topFailure,
                csvSafe(recommendation)
            ].joined(separator: ",")
            print(line)
        }
    }

    if vehicles.contains(where: { $0.vehicleClass == .motorcycle }) && vehicles.contains(where: { $0.vehicleClass == .car }) {
        print("")
        print("Class comparison")
        for vehicleClass in VehicleClass.allCases {
            guard let aggregate = classAggregates[vehicleClass] else { continue }
            print("\(vehicleClass.displayName): completed \(percent(aggregate.completionRate)), exit reached \(percent(aggregate.exitReachedRate)), avg cash \(decimal(aggregate.averageCash, places: 0)), avg XP \(decimal(aggregate.averageXP, places: 0))")
        }
    }
}

struct TrafficStressAggregate {
    var runs = 0
    var wavesGenerated = 0
    var fallbackWaves = 0
    var impossibleCommittedWaves = 0
    var exitReachabilityFailures = 0
    var missingPlans = 0
    var rejectionReasons: [String: Int] = [:]
    var patternCounts: [String: Int] = [:]

    mutating func record(plan: TrafficWavePlan?, context: TrafficPatternContext) {
        wavesGenerated += 1
        guard let plan else {
            missingPlans += 1
            impossibleCommittedWaves += 1
            rejectionReasons["missing plan", default: 0] += 1
            return
        }

        patternCounts[plan.patternName, default: 0] += 1
        if plan.patternName == "recoveryWave" {
            fallbackWaves += 1
            rejectionReasons[plan.rejectionReason, default: 0] += 1
        }

        let validation = TrafficSafetyAnalyzer.validateWave(requests: plan.spawns, context: context)
        if !validation.isValid {
            impossibleCommittedWaves += 1
            rejectionReasons[validation.rejectionReason, default: 0] += 1
            if context.exitActive && validation.rejectionReason == "no reachable exit-side route" {
                exitReachabilityFailures += 1
            }
        }
    }
}

func printTrafficStressReport(levels: [LevelDefinition], vehicles: [VehicleDefinition], options: Options) {
    print("Traffic Getaway Traffic Stress")
    print("Runs per configuration: \(options.runs)")
    print("Base seed: \(options.seed)")
    print("")
    print("levelID,vehicleID,runs,waves,fallbackWaves,impossibleCommittedWaves,exitReachabilityFailures,missingPlans,topRejection,topPattern")

    for level in levels {
        for vehicle in vehicles {
            var aggregate = TrafficStressAggregate()
            aggregate.runs = options.runs

            for runIndex in 0..<options.runs {
                var rng = SeededRNG(seed: SeededRNG.stableSeed(for: "\(level.levelID)|\(vehicle.id)|traffic_stress", runIndex: runIndex, baseSeed: options.seed))
                var playerSlot = LaneModel.startSlot
                let waveCount = max(8, Int((level.durationBeforeExit + level.exitWindowSeconds) / 3.5))

                for waveIndex in 0..<waveCount {
                    let progress = Double(waveIndex) / Double(max(1, waveCount - 1))
                    let density = min(level.maxTrafficDensity, level.startingTrafficDensity + (level.maxTrafficDensity - level.startingTrafficDensity) * progress)
                    let exitActive = progress >= 0.72
                    let protectedLanes: Set<Int> = exitActive ? LaneModel.exitGuardLanes(for: level.exitSide) : []
                    let protectedSlots: Set<Int> = exitActive ? LaneModel.exitSlots(for: level.exitSide, vehicleClass: vehicle.vehicleClass) : []
                    let context = TrafficPatternContext(
                        laneCount: LaneModel.laneCount,
                        playerLane: LaneModel.nearestLaneForSlot(playerSlot),
                        playerSlot: playerSlot,
                        vehicleClass: vehicle.vehicleClass,
                        density: density,
                        wantedLevel: min(6, 1 + Int(progress * 5)),
                        city: level.city,
                        protectedLanes: protectedLanes,
                        protectedSlots: protectedSlots,
                        recentBlockedLanes: [],
                        recentHazards: [],
                        exitActive: exitActive,
                        exitSide: exitActive ? level.exitSide : nil,
                        dodgeBoostActive: false
                    )

                    let plan = TrafficPatternGenerator.generate(context: context, rng: &rng)
                    aggregate.record(plan: plan, context: context)

                    if let plan {
                        let safeSlots = vehicle.vehicleClass == .motorcycle ? plan.safeMotorcycleSlots : plan.safeCarSlots
                        if let nextSlot = safeSlots.min(by: { abs($0 - playerSlot) < abs($1 - playerSlot) }) {
                            playerSlot = LaneModel.clampSlot(nextSlot, for: vehicle.vehicleClass)
                        }
                    }
                }
            }

            let topRejection = aggregate.rejectionReasons.max(by: { $0.value < $1.value }).map { "\($0.key):\($0.value)" } ?? "none"
            let topPattern = aggregate.patternCounts.max(by: { $0.value < $1.value }).map { "\($0.key):\($0.value)" } ?? "none"
            print([
                level.levelID,
                vehicle.id,
                "\(aggregate.runs)",
                "\(aggregate.wavesGenerated)",
                "\(aggregate.fallbackWaves)",
                "\(aggregate.impossibleCommittedWaves)",
                "\(aggregate.exitReachabilityFailures)",
                "\(aggregate.missingPlans)",
                csvSafe(topRejection),
                csvSafe(topPattern)
            ].joined(separator: ","))
        }
    }
}

let options = parseOptions(Array(CommandLine.arguments.dropFirst()))

if options.help {
    printHelp()
} else if options.list {
    printCatalog()
} else if let levels = selectedLevels(options.levelID), let vehicles = selectedVehicles(options.vehicleID) {
    if options.trafficStress {
        printTrafficStressReport(levels: levels, vehicles: vehicles, options: options)
    } else {
        printReport(levels: levels, vehicles: vehicles, options: options)
    }
} else {
    print("Unknown level or vehicle.")
    print("")
    printCatalog()
}
