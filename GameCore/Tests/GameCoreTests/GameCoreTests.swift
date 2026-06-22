import XCTest
@testable import GameCore

final class GameCoreTests: XCTestCase {
    func testLevelOneMatchesCurrentAppBalance() throws {
        let level = try XCTUnwrap(LevelCatalog.level(id: "la_01"))
        XCTAssertEqual(level.name, "Sunset Merge")
        XCTAssertEqual(LevelCatalog.all.first?.levelID, "la_01")
        XCTAssertEqual(level.city, .losAngeles)
        XCTAssertEqual(level.durationBeforeExit, 42)
        XCTAssertEqual(level.exitWindowSeconds, 14)
        XCTAssertEqual(level.startingTrafficDensity, 0.2)
        XCTAssertEqual(level.maxTrafficDensity, 0.42)
        XCTAssertEqual(level.policeAggression, 0.72)
        XCTAssertEqual(level.rewardCash, 210)
        XCTAssertEqual(level.rewardXP, 90)
    }

    func testLaneModelSeparatesCarsAndMotorcycles() {
        XCTAssertEqual(LaneModel.laneCount, 12)
        XCTAssertEqual(LaneModel.slotCount, 23)
        XCTAssertTrue(LaneModel.validSlots(for: .car).allSatisfy { $0.isMultiple(of: 2) })
        XCTAssertEqual(LaneModel.validSlots(for: .motorcycle).count, LaneModel.slotCount)
        XCTAssertEqual(LaneModel.exitSlots(for: .right, vehicleClass: .car), Set([20, 22]))
        XCTAssertEqual(LaneModel.exitSlots(for: .right, vehicleClass: .motorcycle), Set([19, 20, 21, 22]))
    }

    func testTrafficWaveProducesReachableSafety() throws {
        var rng = SeededRNG(seed: 12345)
        let context = TrafficPatternContext(
            laneCount: LaneModel.laneCount,
            playerLane: LaneModel.startLane,
            playerSlot: LaneModel.startSlot,
            vehicleClass: .car,
            density: 0.35,
            wantedLevel: 1,
            city: .losAngeles,
            protectedLanes: [],
            protectedSlots: [],
            recentBlockedLanes: [],
            recentHazards: [],
            exitActive: false,
            exitSide: nil,
            dodgeBoostActive: false
        )

        let plan = try XCTUnwrap(TrafficPatternGenerator.generate(context: context, rng: &rng))
        XCTAssertFalse(plan.spawns.isEmpty)
        XCTAssertFalse(plan.safeCarSlots.isEmpty)
        XCTAssertEqual(plan.rejectionReason, "ok")
    }

    func testSimulationIsDeterministic() throws {
        let level = try XCTUnwrap(LevelCatalog.level(id: "la_01"))
        let vehicle = VehicleCatalog.vehicle(id: VehicleCatalog.starterCarID)
        let first = ChaseSimulator.simulate(level: level, vehicle: vehicle, seed: 12345)
        let second = ChaseSimulator.simulate(level: level, vehicle: vehicle, seed: 12345)

        XCTAssertEqual(first, second)
    }

    func testBatchSimulationCollectsExpectedMetrics() throws {
        let level = try XCTUnwrap(LevelCatalog.level(id: "la_01"))
        let vehicle = VehicleCatalog.vehicle(id: VehicleCatalog.starterCarID)
        let aggregates = ChaseSimulator.runBatch(levels: [level], vehicles: [vehicle], runsPerConfiguration: 10, baseSeed: 12345)
        let aggregate = try XCTUnwrap(aggregates["la_01|starter_compact"])

        XCTAssertEqual(aggregate.runs, 10)
        XCTAssertGreaterThan(aggregate.averageDuration, 0)
        XCTAssertGreaterThanOrEqual(aggregate.exitAppearedRate, 0)
        XCTAssertLessThanOrEqual(aggregate.completionRate, 1)
        XCTAssertGreaterThanOrEqual(aggregate.averageMaxCombo, 0)
    }

    func testCollisionAndNearMissModelsArePureRules() {
        let player = Hitbox(centerX: 10, centerY: 10, width: 4, height: 8)
        let overlapping = Hitbox(centerX: 11, centerY: 12, width: 4, height: 8)
        let clear = Hitbox(centerX: 40, centerY: 40, width: 4, height: 8)

        XCTAssertTrue(CollisionModel.overlaps(player, overlapping))
        XCTAssertFalse(CollisionModel.overlaps(player, clear))

        let check = NearMissCheck(
            playerSlot: LaneModel.startSlot,
            hazardLane: LaneModel.startLane + 1,
            hazardLaneSpan: 1,
            vehicleClass: .car,
            longitudinalGap: 14,
            nearMissWindow: 18
        )
        XCTAssertTrue(CollisionModel.isNearMiss(check))
    }

    func testScoringModelRewardsNearMissesAndFinalRuns() throws {
        let vehicle = VehicleCatalog.vehicle(id: VehicleCatalog.starterCarID)
        let level = try XCTUnwrap(LevelCatalog.level(id: "la_01"))
        let nearMiss = ScoringModel.nearMissReward(vehicle: vehicle, wantedLevel: 2, combo: 3)
        XCTAssertGreaterThan(nearMiss.score, 0)
        XCTAssertGreaterThan(nearMiss.cash, 0)

        let reward = ScoringModel.finalReward(
            score: 1_200,
            distance: 900,
            survivalTime: 42,
            runCash: 30,
            nearMisses: 5,
            laneSplits: 0,
            highestWantedLevel: 2,
            highestCombo: 4,
            vehicle: vehicle,
            level: level,
            completed: true
        )

        XCTAssertGreaterThanOrEqual(reward.cash, level.rewardCash)
        XCTAssertGreaterThanOrEqual(reward.xp, level.rewardXP)
    }

    func testProgressionModelUnlocksVehiclesAndLevels() throws {
        let starterBike = VehicleCatalog.vehicle(id: VehicleCatalog.starterBikeID)
        let state = ProgressionState(totalCash: starterBike.unlockCost)
        let result = ProgressionModel.unlockVehicle(starterBike, state: state)

        XCTAssertTrue(result.didUnlock)
        XCTAssertTrue(result.state.unlockedVehicleIDs.contains(starterBike.id))
        XCTAssertEqual(result.state.totalCash, 0)

        let levelTwo = try XCTUnwrap(LevelCatalog.level(id: "la_02"))
        XCTAssertFalse(ProgressionModel.isLevelUnlocked(levelTwo, state: ProgressionState()))
        XCTAssertTrue(ProgressionModel.isLevelUnlocked(levelTwo, state: ProgressionState(completedLevelIDs: ["la_01"])))
    }

    func testSeededRNGDerivedStreamsDoNotConsumeGameplayStream() {
        var gameplayA = SeededRNG(seed: 24680)
        let cosmetic = gameplayA.derivedStream(named: "cosmetic")
        var gameplayB = SeededRNG(seed: 24680)
        _ = cosmetic

        XCTAssertEqual(gameplayA.next(), gameplayB.next())
        XCTAssertEqual(gameplayA.next(), gameplayB.next())

        var traffic = gameplayA.derivedStream(named: "traffic")
        var audio = gameplayA.derivedStream(named: "audio")
        XCTAssertNotEqual(traffic.next(), audio.next())
    }

    func testLaneStaleFlowAndPursuitPressure() {
        let staleConfig = LaneStaleConfiguration(warningThreshold: 1, penaltyThreshold: 2, recoveryRate: 1, maximumEffect: 1, meaningfulMovementSlots: 2)
        var stale = LaneStaleState(currentSlot: LaneModel.startSlot)
        for _ in 0..<4 {
            stale.step(slot: LaneModel.startSlot, previousSlot: LaneModel.startSlot, deltaTime: 1, configuration: staleConfig)
        }
        XCTAssertGreaterThan(stale.effect, 0)

        let movedSlot = LaneModel.targetSlot(from: LaneModel.startSlot, delta: 2, vehicleClass: .car)
        stale.step(slot: movedSlot, previousSlot: LaneModel.startSlot, deltaTime: 1, configuration: staleConfig)
        XCTAssertLessThan(stale.effect, 1)

        var flow = FlowState()
        flow.recordCleanShift(fast: false)
        flow.recordNearMiss()
        XCTAssertGreaterThan(flow.value, 0.2)
        flow.step(deltaTime: 1, laneStaleEffect: stale.effect)
        XCTAssertGreaterThan(flow.value, 0)

        var pursuit = PursuitPressureState(value: 0.4)
        pursuit.step(flow: 0, laneStaleEffect: 1, deltaTime: 2)
        XCTAssertGreaterThan(pursuit.value, 0.4)
        let pressured = pursuit.value
        pursuit.recordNearMiss()
        XCTAssertLessThan(pursuit.value, pressured)
    }

    func testFixedStepReplayMatchesCleanExit() throws {
        let level = try XCTUnwrap(LevelCatalog.level(id: "la_01"))
        let vehicle = VehicleCatalog.vehicle(id: VehicleCatalog.starterCarID)
        let configuration = RunConfigurationRecord(
            levelID: level.levelID,
            cityID: level.city,
            vehicleID: vehicle.id,
            seed: 99,
            fixedStep: 1.0 / 60.0,
            exitSide: .right,
            exitWarningFrame: 10,
            exitDeadlineFrame: 40,
            capturePressureThreshold: 99
        )
        let commands = [
            RecordedCommand(frameIndex: 0, command: .fastMoveRight),
            RecordedCommand(frameIndex: 1, command: .fastMoveRight),
            RecordedCommand(frameIndex: 2, command: .fastMoveRight)
        ]

        let simulation = FixedStepRunSimulation(configuration: configuration, vehicle: vehicle)
        for command in commands {
            simulation.enqueue(command.command, forFrame: command.frameIndex)
        }

        var hashes: [RecordedStateHash] = []
        let hashFrames: Set<UInt64> = [0, 5, 11]
        while simulation.frameIndex <= 40 {
            if hashFrames.contains(simulation.frameIndex) {
                let snapshot = simulation.makeSnapshot()
                hashes.append(RecordedStateHash(frameIndex: snapshot.frameIndex, hash: snapshot.stableHash))
            }
            simulation.step()
            if simulation.outcome != .running, hashFrames.contains(simulation.frameIndex) {
                let snapshot = simulation.makeSnapshot()
                hashes.append(RecordedStateHash(frameIndex: snapshot.frameIndex, hash: snapshot.stableHash))
                break
            }
        }

        XCTAssertEqual(simulation.outcome, .escaped)
        let replay = RunReplay(
            simulationVersion: configuration.simulationVersion,
            configuration: configuration,
            seed: configuration.seed,
            commands: commands,
            expectedOutcome: simulation.outcome,
            expectedScore: simulation.score,
            stateHashes: hashes
        )

        let result = RunReplayVerifier.replay(replay, vehicle: vehicle)
        XCTAssertTrue(result.matches)
        XCTAssertEqual(result.snapshot.outcome, .escaped)
    }
}
