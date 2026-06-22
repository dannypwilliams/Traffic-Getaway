import Foundation

public struct DifficultySnapshot: Equatable {
    public let trafficDensity: Double
    public let roadSpeed: Double
    public let trafficSpeed: Double
    public let spawnInterval: Double
    public let policeClosingSpeed: Double
    public let roadblockCooldown: Double
    public let laneChangeDurationScale: Double
    public let exitSafetyGap: Double
    public let comboDuration: Double

    public init(
        trafficDensity: Double,
        roadSpeed: Double,
        trafficSpeed: Double,
        spawnInterval: Double,
        policeClosingSpeed: Double,
        roadblockCooldown: Double,
        laneChangeDurationScale: Double,
        exitSafetyGap: Double,
        comboDuration: Double
    ) {
        self.trafficDensity = trafficDensity
        self.roadSpeed = roadSpeed
        self.trafficSpeed = trafficSpeed
        self.spawnInterval = spawnInterval
        self.policeClosingSpeed = policeClosingSpeed
        self.roadblockCooldown = roadblockCooldown
        self.laneChangeDurationScale = laneChangeDurationScale
        self.exitSafetyGap = exitSafetyGap
        self.comboDuration = comboDuration
    }
}

public enum DifficultyModel {
    public static func snapshot(for level: LevelDefinition, elapsed: Double, exitActive: Bool) -> DifficultySnapshot {
        let warmupProgress = min(1, max(0, elapsed / 15))
        let trafficProgress = min(1, max(0, (elapsed - 15) / 30))
        let policeProgress = min(1, max(0, (elapsed - 45) / 45))
        let finalStart = max(0, level.durationBeforeExit - 18)
        let finalProgress = min(1, max(0, (elapsed - finalStart) / 18))

        let density = level.startingTrafficDensity
            + (level.maxTrafficDensity - level.startingTrafficDensity) * (trafficProgress * 0.62 + policeProgress * 0.22 + finalProgress * 0.16)
        let roadSpeed = 340 + warmupProgress * 30 + trafficProgress * 80 + policeProgress * 86 + finalProgress * 52
        let trafficSpeed = 232 + trafficProgress * 88 + policeProgress * 68 + finalProgress * 42
        let spawn = max(0.38, 1.08 - density * 0.62 - finalProgress * 0.12)
        let police = (2.6 + policeProgress * 3.2 + finalProgress * 1.2) * level.policeAggression

        return DifficultySnapshot(
            trafficDensity: min(level.maxTrafficDensity, density),
            roadSpeed: roadSpeed,
            trafficSpeed: trafficSpeed,
            spawnInterval: spawn,
            policeClosingSpeed: exitActive ? police * 1.08 : police,
            roadblockCooldown: max(4.8, 13.5 - level.policeAggression * 3.2 - finalProgress * 3.0),
            laneChangeDurationScale: max(0.86, 1.02 - (level.policeAggression - 1) * 0.08),
            exitSafetyGap: 300 + level.exitWindowSeconds * 16,
            comboDuration: max(2.65, 3.35 - (level.policeAggression - 0.8) * 0.28)
        )
    }

    public static func starRating(score: Int, highestCombo: Int, usedRevive: Bool, level: LevelDefinition) -> Int {
        let levelNumber = LevelCatalog.displayNumber(for: level.levelID)
        let goodScore = 850 + levelNumber * 170
        let comboTarget = 4 + levelNumber / 3
        var stars = 1
        if score >= goodScore {
            stars += 1
        }
        if highestCombo >= comboTarget || !usedRevive {
            stars += 1
        }
        return min(3, stars)
    }
}
