import XCTest
@testable import GameCore

final class GameCoreTests: XCTestCase {
    func testLevelOneMatchesCurrentAppBalance() throws {
        let level = try XCTUnwrap(LevelCatalog.level(id: "ny_01"))
        XCTAssertEqual(level.name, "Brooklyn Warmup")
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
            city: .newYork,
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
        let level = try XCTUnwrap(LevelCatalog.level(id: "ny_01"))
        let vehicle = VehicleCatalog.vehicle(id: VehicleCatalog.starterCarID)
        let first = ChaseSimulator.simulate(level: level, vehicle: vehicle, seed: 12345)
        let second = ChaseSimulator.simulate(level: level, vehicle: vehicle, seed: 12345)

        XCTAssertEqual(first, second)
    }

    func testBatchSimulationCollectsExpectedMetrics() throws {
        let level = try XCTUnwrap(LevelCatalog.level(id: "ny_01"))
        let vehicle = VehicleCatalog.vehicle(id: VehicleCatalog.starterCarID)
        let aggregates = ChaseSimulator.runBatch(levels: [level], vehicles: [vehicle], runsPerConfiguration: 10, baseSeed: 12345)
        let aggregate = try XCTUnwrap(aggregates["ny_01|starter_compact"])

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
        let level = try XCTUnwrap(LevelCatalog.level(id: "ny_01"))
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

        let levelTwo = try XCTUnwrap(LevelCatalog.level(id: "ny_02"))
        XCTAssertFalse(ProgressionModel.isLevelUnlocked(levelTwo, state: ProgressionState()))
        XCTAssertTrue(ProgressionModel.isLevelUnlocked(levelTwo, state: ProgressionState(completedLevelIDs: ["ny_01"])))
    }
}
