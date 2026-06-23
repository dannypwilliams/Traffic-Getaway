import Foundation

public struct ChaseRunResult: Equatable {
    public let levelID: String
    public let levelName: String
    public let vehicleID: String
    public let vehicleName: String
    public let vehicleClass: VehicleClass
    public let seed: UInt64
    public let duration: Double
    public let firstCrashTime: Double?
    public let exitAppeared: Bool
    public let exitReached: Bool
    public let completedExit: Bool
    public let failureCause: String
    public let laneChanges: Int
    public let nearMisses: Int
    public let laneSplits: Int
    public let maxCombo: Int
    public let score: Int
    public let cashEarned: Int
    public let xpEarned: Int
    public let averageDensity: Double
    public let minimumPoliceGap: Double
    public let highestWantedLevel: Int
    public let unfairCollisionEstimate: Bool
}

public struct ChaseSimulationOptions: Equatable {
    public let modelsActiveTrafficLifetime: Bool

    public init(modelsActiveTrafficLifetime: Bool = false) {
        self.modelsActiveTrafficLifetime = modelsActiveTrafficLifetime
    }

    public static let `default` = ChaseSimulationOptions()
}

public struct ChaseSimulationAggregate {
    public private(set) var runs = 0
    public private(set) var totalDuration = 0.0
    public private(set) var durations: [Double] = []
    public private(set) var firstCrashTimes: [Double] = []
    public private(set) var exitAppeared = 0
    public private(set) var exitReached = 0
    public private(set) var exitCompletions = 0
    public private(set) var failureCounts: [String: Int] = [:]
    public private(set) var laneChanges = 0
    public private(set) var nearMisses = 0
    public private(set) var laneSplits = 0
    public private(set) var maxCombo = 0
    public private(set) var totalMaxCombo = 0
    public private(set) var totalScore = 0
    public private(set) var totalCash = 0
    public private(set) var totalXP = 0
    public private(set) var totalDensity = 0.0
    public private(set) var minimumPoliceGap = Double.greatestFiniteMagnitude
    public private(set) var highestWantedLevel = 1
    public private(set) var unfairCollisionEstimates = 0

    public init() {}

    public mutating func add(_ result: ChaseRunResult) {
        runs += 1
        totalDuration += result.duration
        durations.append(result.duration)
        if let firstCrashTime = result.firstCrashTime {
            firstCrashTimes.append(firstCrashTime)
        }
        if result.exitAppeared { exitAppeared += 1 }
        if result.exitReached { exitReached += 1 }
        if result.completedExit { exitCompletions += 1 }
        failureCounts[result.failureCause, default: 0] += 1
        laneChanges += result.laneChanges
        nearMisses += result.nearMisses
        laneSplits += result.laneSplits
        maxCombo = max(maxCombo, result.maxCombo)
        totalMaxCombo += result.maxCombo
        totalScore += result.score
        totalCash += result.cashEarned
        totalXP += result.xpEarned
        totalDensity += result.averageDensity
        minimumPoliceGap = min(minimumPoliceGap, result.minimumPoliceGap)
        highestWantedLevel = max(highestWantedLevel, result.highestWantedLevel)
        if result.unfairCollisionEstimate { unfairCollisionEstimates += 1 }
    }

    public mutating func merge(_ other: ChaseSimulationAggregate) {
        runs += other.runs
        totalDuration += other.totalDuration
        durations.append(contentsOf: other.durations)
        firstCrashTimes.append(contentsOf: other.firstCrashTimes)
        exitAppeared += other.exitAppeared
        exitReached += other.exitReached
        exitCompletions += other.exitCompletions
        for (cause, count) in other.failureCounts {
            failureCounts[cause, default: 0] += count
        }
        laneChanges += other.laneChanges
        nearMisses += other.nearMisses
        laneSplits += other.laneSplits
        maxCombo = max(maxCombo, other.maxCombo)
        totalMaxCombo += other.totalMaxCombo
        totalScore += other.totalScore
        totalCash += other.totalCash
        totalXP += other.totalXP
        totalDensity += other.totalDensity
        minimumPoliceGap = min(minimumPoliceGap, other.minimumPoliceGap)
        highestWantedLevel = max(highestWantedLevel, other.highestWantedLevel)
        unfairCollisionEstimates += other.unfairCollisionEstimates
    }

    public var averageDuration: Double { runs == 0 ? 0 : totalDuration / Double(runs) }
    public var medianDuration: Double { median(durations) }
    public var firstCrashTime: Double { median(firstCrashTimes) }
    public var exitAppearedRate: Double { rate(exitAppeared) }
    public var exitReachedRate: Double { rate(exitReached) }
    public var completionRate: Double { rate(exitCompletions) }
    public var nearMissesPerRun: Double { average(nearMisses) }
    public var laneSplitsPerRun: Double { average(laneSplits) }
    public var laneChangesPerRun: Double { average(laneChanges) }
    public var averageMaxCombo: Double { average(totalMaxCombo) }
    public var averageScore: Double { average(totalScore) }
    public var averageCash: Double { average(totalCash) }
    public var averageXP: Double { average(totalXP) }
    public var averageDensity: Double { runs == 0 ? 0 : totalDensity / Double(runs) }
    public var unfairCollisionRate: Double { rate(unfairCollisionEstimates) }

    public func mostCommonFailure(excludingCompleted: Bool = true) -> (cause: String, count: Int)? {
        failureCounts
            .filter { !excludingCompleted || $0.key != "completed" }
            .sorted { lhs, rhs in
                if lhs.value == rhs.value {
                    return lhs.key < rhs.key
                }
                return lhs.value > rhs.value
            }
            .first
            .map { (cause: $0.key, count: $0.value) }
    }

    public func firstCrashPercentile(_ percentile: Double) -> Double {
        value(at: percentile, in: firstCrashTimes)
    }

    private func rate(_ count: Int) -> Double {
        runs == 0 ? 0 : Double(count) / Double(runs)
    }

    private func average(_ total: Int) -> Double {
        runs == 0 ? 0 : Double(total) / Double(runs)
    }

    private func median(_ values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }
        let sorted = values.sorted()
        let middle = sorted.count / 2
        if sorted.count.isMultiple(of: 2) {
            return (sorted[middle - 1] + sorted[middle]) / 2
        }
        return sorted[middle]
    }

    private func value(at percentile: Double, in values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }
        let sorted = values.sorted()
        let clipped = max(0, min(1, percentile))
        let index = Int((Double(sorted.count - 1) * clipped).rounded())
        return sorted[index]
    }
}

public enum ChaseSimulator {
    private static let dt = 0.25
    private static let maxPoliceGap = 180.0
    private static let minPoliceGap = 34.0
    private static let trafficSpawnDistance = 860.0

    private struct SimulatedTrafficHazard {
        let lane: Int
        let type: TrafficVehicleType
        let y: Double
        let height: Double
        let speed: Double
        let isRoadblock: Bool

        var snapshot: TrafficHazardSnapshot {
            TrafficHazardSnapshot(
                lane: lane,
                laneSpan: type.laneSpan,
                type: type,
                y: y,
                height: height,
                speed: speed,
                isRoadblock: isRoadblock
            )
        }

        func advanced(by elapsed: Double) -> SimulatedTrafficHazard? {
            let nextY = y - speed * elapsed
            guard nextY > -180 else { return nil }
            return SimulatedTrafficHazard(
                lane: lane,
                type: type,
                y: nextY,
                height: height,
                speed: speed,
                isRoadblock: isRoadblock
            )
        }
    }

    public static func runBatch(levels: [LevelDefinition], vehicles: [VehicleDefinition], runsPerConfiguration: Int, baseSeed: UInt64, options: ChaseSimulationOptions = .default) -> [String: ChaseSimulationAggregate] {
        var aggregates: [String: ChaseSimulationAggregate] = [:]
        let cappedRuns = max(1, runsPerConfiguration)
        for level in levels {
            for vehicle in vehicles {
                let key = "\(level.levelID)|\(vehicle.id)"
                for runIndex in 0..<cappedRuns {
                    let seed = SeededRNG.stableSeed(for: key, runIndex: runIndex, baseSeed: baseSeed)
                    let result = simulate(level: level, vehicle: vehicle, seed: seed, options: options)
                    var aggregate = aggregates[key] ?? ChaseSimulationAggregate()
                    aggregate.add(result)
                    aggregates[key] = aggregate
                }
            }
        }
        return aggregates
    }

    public static func simulate(level: LevelDefinition, vehicle: VehicleDefinition, seed: UInt64, options: ChaseSimulationOptions = .default) -> ChaseRunResult {
        var rng = SeededRNG(seed: seed)
        var time = 0.0
        var spawnTimer = 0.0
        var policeGap = maxPoliceGap
        var minGap = maxPoliceGap
        var playerSlot = LaneModel.clampSlot(LaneModel.startSlot, for: vehicle.vehicleClass)
        var recentBlockedLanes: Set<Int> = []
        var activeHazards: [SimulatedTrafficHazard] = []
        var latestPlannedSafeSlots = Set(LaneModel.validSlots(for: vehicle.vehicleClass))
        var activeExitSide = level.exitSide
        var exitDeadline = level.durationBeforeExit + level.exitWindowSeconds
        var emergencyUsed = false

        var combo = 0
        var comboTimer = 0.0
        var maxCombo = 0
        var dodgeBoost = 0.0
        var laneChanges = 0
        var nearMisses = 0
        var laneSplits = 0
        var score = 0
        var scoreRemainder = 0.0
        var runCash = 0
        var cashRemainder = 0.0
        var runDistance = 0.0
        var highestWantedLevel = 1
        var densityTotal = 0.0
        var densitySamples = 0
        var exitAppeared = false
        var exitReached = false
        var completed = false
        var failure = "completed"
        var firstCrashTime: Double?
        var unfairCollision = false

        let maxTime = level.durationBeforeExit + level.exitWindowSeconds + (level.allowsEmergencyExit ? 8 : 0)
        while time <= maxTime {
            let exitActive = time >= level.durationBeforeExit
            if exitActive {
                exitAppeared = true
            }

            let snapshot = DifficultyModel.snapshot(for: level, elapsed: time, exitActive: exitActive)
            let wantedLevel = wantedLevelFor(level: level, runTime: time)
            highestWantedLevel = max(highestWantedLevel, wantedLevel)
            densityTotal += snapshot.trafficDensity
            densitySamples += 1
            activeHazards = activeHazards.filter { $0.y > -180 }

            applyPassiveRewards(
                snapshot: snapshot,
                vehicle: vehicle,
                wantedLevel: wantedLevel,
                combo: combo,
                dt: dt,
                score: &score,
                scoreRemainder: &scoreRemainder,
                runCash: &runCash,
                cashRemainder: &cashRemainder,
                runDistance: &runDistance
            )

            policeGap -= snapshot.policeClosingSpeed / max(0.86, vehicle.policeResistance) * dt
            minGap = min(minGap, policeGap)
            if policeGap <= minPoliceGap {
                failure = "police_caught"
                break
            }

            var movedThisTick = false
            if options.modelsActiveTrafficLifetime && !activeHazards.isEmpty {
                var activeSafeSlots = hasImmediateHazard(activeHazards.map(\.snapshot))
                    ? Set(LaneModel.validSlots(for: vehicle.vehicleClass))
                    : latestPlannedSafeSlots
                if exitActive {
                    activeSafeSlots.formUnion(LaneModel.exitSlots(for: activeExitSide, vehicleClass: vehicle.vehicleClass))
                }
                let activeDecision = chooseSlot(
                    from: playerSlot,
                    safeSlots: activeSafeSlots,
                    vehicle: vehicle,
                    exitActive: exitActive,
                    exitSide: activeExitSide,
                    dodgeBoostActive: dodgeBoost > 0,
                    activeHazards: activeHazards.map(\.snapshot)
                )
                if let target = activeDecision.target, target != playerSlot {
                    laneChanges += 1
                    playerSlot = target
                    movedThisTick = true
                }
            }

            if options.modelsActiveTrafficLifetime && slotIntersectsActiveTraffic(playerSlot, vehicle: vehicle, activeHazards: activeHazards.map(\.snapshot)) {
                failure = "traffic_collision"
                firstCrashTime = time
                break
            }

            spawnTimer += dt
            if spawnTimer >= snapshot.spawnInterval {
                spawnTimer = 0
                let protectedLanes = exitActive ? LaneModel.exitGuardLanes(for: activeExitSide) : []
                let protectedSlots = exitActive ? LaneModel.exitSlots(for: activeExitSide, vehicleClass: vehicle.vehicleClass) : []
                let context = TrafficPatternContext(
                    laneCount: LaneModel.laneCount,
                    playerLane: LaneModel.nearestLaneForSlot(playerSlot),
                    playerSlot: playerSlot,
                    vehicleClass: vehicle.vehicleClass,
                    density: adjustedDensity(snapshot.trafficDensity, vehicle: vehicle),
                    wantedLevel: wantedLevel,
                    city: level.city,
                    protectedLanes: protectedLanes,
                    protectedSlots: protectedSlots,
                    recentBlockedLanes: recentBlockedLanes,
                    recentHazards: options.modelsActiveTrafficLifetime ? activeHazards
                        .filter { $0.y > 260 }
                        .map(\.snapshot) : [],
                    exitActive: exitActive,
                    exitSide: exitActive ? activeExitSide : nil,
                    dodgeBoostActive: dodgeBoost > 0
                )

                guard let plan = TrafficPatternGenerator.generate(context: context, rng: &rng) else {
                    failure = "no_valid_wave"
                    firstCrashTime = time
                    unfairCollision = true
                    break
                }

                recentBlockedLanes = plan.occupiedLanes
                var safeSlots = vehicle.vehicleClass == .motorcycle ? plan.safeMotorcycleSlots : plan.safeCarSlots
                if exitActive {
                    safeSlots.formUnion(LaneModel.exitSlots(for: activeExitSide, vehicleClass: vehicle.vehicleClass))
                }
                latestPlannedSafeSlots = safeSlots

                let decision = movedThisTick
                    ? (target: Optional(playerSlot), risky: false, rejectionReason: Optional<String>.none)
                    : chooseSlot(
                        from: playerSlot,
                        safeSlots: safeSlots,
                        vehicle: vehicle,
                        exitActive: exitActive,
                        exitSide: activeExitSide,
                        dodgeBoostActive: dodgeBoost > 0,
                        activeHazards: options.modelsActiveTrafficLifetime ? activeHazards.map(\.snapshot) : []
                    )

                guard let target = decision.target else {
                    failure = decision.rejectionReason ?? plan.rejectionReason
                    firstCrashTime = time
                    unfairCollision = isUnfairFailure(failure)
                    break
                }

                if target != playerSlot {
                    laneChanges += 1
                    playerSlot = target
                }

                if decision.risky || rng.chance(0.12 + snapshot.trafficDensity * 0.14) {
                    nearMisses += 1
                    combo += 1
                    comboTimer = snapshot.comboDuration
                    maxCombo = max(maxCombo, combo)
                    dodgeBoost = max(dodgeBoost, 1.5 * vehicle.dodgeBoost)
                    policeGap = min(maxPoliceGap, policeGap + 12 * vehicle.nearMissMultiplier)

                    let reward = ScoringModel.nearMissReward(vehicle: vehicle, wantedLevel: wantedLevel, combo: combo)
                    score += reward.score
                    runCash += reward.cash
                }

                if vehicle.canLaneSplit && LaneModel.isSplitSlot(playerSlot) && rng.chance(0.34 + snapshot.trafficDensity * 0.22) {
                    laneSplits += 1
                    combo += 1
                    comboTimer = snapshot.comboDuration
                    maxCombo = max(maxCombo, combo)
                    policeGap = min(maxPoliceGap, policeGap + 8)

                    let reward = ScoringModel.laneSplitReward(vehicle: vehicle, wantedLevel: wantedLevel, combo: combo)
                    score += reward.score
                    runCash += reward.cash
                }

                if options.modelsActiveTrafficLifetime {
                    activeHazards.append(contentsOf: plan.spawns.map {
                        makeHazard(from: $0, snapshot: snapshot)
                    })
                }
            }

            if exitActive {
                if isOnExitSide(slot: playerSlot, side: activeExitSide) {
                    exitReached = true
                }
                if LaneModel.exitSlots(for: activeExitSide, vehicleClass: vehicle.vehicleClass).contains(playerSlot) {
                    completed = true
                    failure = "completed"
                    break
                }
                if time > exitDeadline {
                    if level.allowsEmergencyExit && !emergencyUsed {
                        emergencyUsed = true
                        activeExitSide = activeExitSide.opposite
                        exitDeadline = time + 8
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
            if options.modelsActiveTrafficLifetime {
                activeHazards = activeHazards.compactMap { $0.advanced(by: dt) }
            }
            time += dt
        }

        let reward = finalRewards(
            score: score,
            distance: runDistance,
            survivalTime: time,
            runCash: runCash,
            nearMisses: nearMisses,
            laneSplits: laneSplits,
            highestWantedLevel: highestWantedLevel,
            highestCombo: maxCombo,
            vehicle: vehicle,
            level: level,
            completed: completed
        )

        return ChaseRunResult(
            levelID: level.levelID,
            levelName: level.name,
            vehicleID: vehicle.id,
            vehicleName: vehicle.displayName,
            vehicleClass: vehicle.vehicleClass,
            seed: seed,
            duration: time,
            firstCrashTime: firstCrashTime,
            exitAppeared: exitAppeared,
            exitReached: exitReached,
            completedExit: completed,
            failureCause: failure,
            laneChanges: laneChanges,
            nearMisses: nearMisses,
            laneSplits: laneSplits,
            maxCombo: maxCombo,
            score: score,
            cashEarned: reward.cash,
            xpEarned: reward.xp,
            averageDensity: densitySamples == 0 ? 0 : densityTotal / Double(densitySamples),
            minimumPoliceGap: minGap,
            highestWantedLevel: highestWantedLevel,
            unfairCollisionEstimate: unfairCollision
        )
    }

    private static func adjustedDensity(_ density: Double, vehicle: VehicleDefinition) -> Double {
        let bikeDensityBonus = vehicle.vehicleClass == .motorcycle ? 0.035 : 0
        return min(0.94, density + bikeDensityBonus)
    }

    private static func wantedLevelFor(level: LevelDefinition, runTime: Double) -> Int {
        let totalDuration = max(1, level.durationBeforeExit + level.exitWindowSeconds)
        let progress = max(0, min(1, runTime / totalDuration))
        return min(6, 1 + Int(progress * (4.4 * level.policeAggression)))
    }

    private static func chooseSlot(
        from current: Int,
        safeSlots: Set<Int>,
        vehicle: VehicleDefinition,
        exitActive: Bool,
        exitSide: ExitSide,
        dodgeBoostActive: Bool,
        activeHazards: [TrafficHazardSnapshot]
    ) -> (target: Int?, risky: Bool, rejectionReason: String?) {
        let reach = reachableSlots(vehicle: vehicle, boosted: dodgeBoostActive)
        let reachableCandidates = safeSlots
            .filter { abs($0 - current) <= reach }
            .sorted()
        guard !reachableCandidates.isEmpty else { return (nil, false, "no reachable safe slot") }

        let transitionSafeCandidates = TrafficSafetyAnalyzer.transitionSafeSlots(
            from: current,
            candidateSlots: Set(reachableCandidates),
            vehicleClass: vehicle.vehicleClass,
            hazards: activeHazards,
            configuration: transitionSafetyConfiguration(for: vehicle)
        ).sorted()
        guard !transitionSafeCandidates.isEmpty else {
            if reachableCandidates.contains(current) {
                return (current, false, "no transition-safe slot")
            }
            return (nil, false, "no transition-safe slot")
        }

        let desired: Int
        if exitActive {
            let targetSlots = LaneModel.exitSlots(for: exitSide, vehicleClass: vehicle.vehicleClass)
            desired = exitSide == .left ? targetSlots.min() ?? 0 : targetSlots.max() ?? (LaneModel.slotCount - 1)
        } else {
            desired = LaneModel.startSlot
        }

        let target = transitionSafeCandidates.min { lhs, rhs in
            let lhsScore = abs(lhs - desired) + (lhs == current ? 2 : 0)
            let rhsScore = abs(rhs - desired) + (rhs == current ? 2 : 0)
            if lhsScore == rhsScore {
                return lhs < rhs
            }
            return lhsScore < rhsScore
        }
        let risky = target.map { abs($0 - current) <= 2 && $0 != current } ?? false
        return (target, risky, nil)
    }

    private static func reachableSlots(vehicle: VehicleDefinition, boosted: Bool) -> Int {
        let base = vehicle.vehicleClass == .motorcycle ? 2 : 4
        let handlingBonus = vehicle.handling > 1.1 ? 1 : 0
        return base + handlingBonus + (boosted ? 2 : 0)
    }

    private static func isOnExitSide(slot: Int, side: ExitSide) -> Bool {
        switch side {
        case .left:
            return slot <= 8
        case .right:
            return slot >= LaneModel.slotCount - 9
        }
    }

    private static func applyPassiveRewards(
        snapshot: DifficultySnapshot,
        vehicle: VehicleDefinition,
        wantedLevel: Int,
        combo: Int,
        dt: Double,
        score: inout Int,
        scoreRemainder: inout Double,
        runCash: inout Int,
        cashRemainder: inout Double,
        runDistance: inout Double
    ) {
        let reward = ScoringModel.passiveReward(
            snapshot: snapshot,
            vehicle: vehicle,
            wantedLevel: wantedLevel,
            combo: combo,
            deltaTime: dt,
            scoreRemainder: scoreRemainder,
            cashRemainder: cashRemainder
        )
        runDistance += reward.distance
        score += reward.scoreGained
        scoreRemainder = reward.scoreRemainder
        runCash += reward.cashGained
        cashRemainder = reward.cashRemainder
    }

    private static func finalRewards(
        score: Int,
        distance: Double,
        survivalTime: Double,
        runCash: Int,
        nearMisses: Int,
        laneSplits: Int,
        highestWantedLevel: Int,
        highestCombo: Int,
        vehicle: VehicleDefinition,
        level: LevelDefinition,
        completed: Bool
    ) -> (cash: Int, xp: Int) {
        let reward = ScoringModel.finalReward(
            score: score,
            distance: distance,
            survivalTime: survivalTime,
            runCash: runCash,
            nearMisses: nearMisses,
            laneSplits: laneSplits,
            highestWantedLevel: highestWantedLevel,
            highestCombo: highestCombo,
            vehicle: vehicle,
            level: level,
            completed: completed
        )

        return (reward.cash, reward.xp)
    }

    private static func isUnfairFailure(_ cause: String) -> Bool {
        cause == "no_valid_wave"
            || cause == "no reachable safe slot"
            || cause == "no transition-safe slot"
            || cause == "no reachable exit-side route"
            || cause == "not enough safe car lanes"
            || cause == "not enough safe motorcycle slots"
    }

    private static func slotIntersectsActiveTraffic(_ slot: Int, vehicle: VehicleDefinition, activeHazards: [TrafficHazardSnapshot]) -> Bool {
        let safe = TrafficSafetyAnalyzer.transitionSafeSlots(
            from: slot,
            candidateSlots: [slot],
            vehicleClass: vehicle.vehicleClass,
            hazards: activeHazards,
            configuration: TrafficTransitionSafetyConfiguration(
                laneChangeDuration: 0,
                predictionHorizon: 0,
                playerHeight: vehicle.vehicleClass == .motorcycle ? 62 : 72,
                verticalPadding: 0
            )
        )
        return safe.isEmpty
    }

    private static func hasImmediateHazard(_ activeHazards: [TrafficHazardSnapshot]) -> Bool {
        activeHazards.contains { hazard in
            hazard.y > -40 && hazard.y < 190
        }
    }

    private static func makeHazard(from spawn: TrafficSpawnRequest, snapshot: DifficultySnapshot) -> SimulatedTrafficHazard {
        let height = hazardHeight(for: spawn.type)
        return SimulatedTrafficHazard(
            lane: spawn.lane,
            type: spawn.type,
            y: trafficSpawnDistance + spawn.yOffset + height / 2,
            height: height,
            speed: max(120, snapshot.trafficSpeed * spawn.speedMultiplier),
            isRoadblock: false
        )
    }

    private static func hazardHeight(for type: TrafficVehicleType) -> Double {
        switch type {
        case .sedan, .taxi, .sports:
            return 86
        case .policeMoto:
            return 76
        case .truck:
            return 118
        case .bus:
            return 136
        }
    }

    private static func transitionSafetyConfiguration(for vehicle: VehicleDefinition) -> TrafficTransitionSafetyConfiguration {
        TrafficTransitionSafetyConfiguration(
            laneChangeDuration: vehicle.vehicleClass == .motorcycle ? 0.24 : 0.3,
            predictionHorizon: 0.3,
            playerHeight: vehicle.vehicleClass == .motorcycle ? 62 : 72,
            verticalPadding: 10
        )
    }
}
