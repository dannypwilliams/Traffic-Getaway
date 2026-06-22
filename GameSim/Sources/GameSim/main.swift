import Foundation
import GameCore

struct Options {
    var levelID = "ny_01"
    var vehicleID = "starter_compact"
    var runs = 10_000
    var seed: UInt64 = 12_345
    var list = false
    var help = false
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
      swift run GameSim --level ny_01 --vehicle starter_compact --runs 10000 --seed 12345
      swift run GameSim --level brooklyn_warmup --vehicle starter_compact --runs 10000 --seed 12345

    Options:
      --level <id|name|all>       Level to simulate. Default: ny_01
      --vehicle <id|name|all>     Vehicle to simulate. Default: starter_compact
      --runs <count>         Runs per level/vehicle configuration. Default: 10000
      --seed <number>        Base deterministic seed. Default: 12345
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

    if level.levelID == "ny_01" && vehicle.id == VehicleCatalog.starterCarID {
        if level.durationBeforeExit > 45 {
            return "Move Brooklyn Warmup exit earlier into the 35-45s target"
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
        baseSeed: options.seed
    )

    print("Traffic Getaway GameSim")
    print("Runs per configuration: \(options.runs)")
    print("Base seed: \(options.seed)")
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

let options = parseOptions(Array(CommandLine.arguments.dropFirst()))

if options.help {
    printHelp()
} else if options.list {
    printCatalog()
} else if let levels = selectedLevels(options.levelID), let vehicles = selectedVehicles(options.vehicleID) {
    printReport(levels: levels, vehicles: vehicles, options: options)
} else {
    print("Unknown level or vehicle.")
    print("")
    printCatalog()
}
