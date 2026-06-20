import CoreGraphics
import Foundation

struct LevelDifficultySnapshot {
    let trafficDensity: CGFloat
    let roadSpeed: CGFloat
    let trafficSpeed: CGFloat
    let spawnInterval: TimeInterval
    let policeClosingSpeed: CGFloat
    let roadblockCooldown: TimeInterval
    let laneChangeDurationScale: TimeInterval
    let exitSafetyGap: CGFloat
    let comboDuration: TimeInterval
}

enum LevelDifficultyConfig {
    static func snapshot(for level: LevelDefinition, elapsed: TimeInterval, exitActive: Bool) -> LevelDifficultySnapshot {
        let warmupProgress = CGFloat(min(1, max(0, elapsed / 15)))
        let trafficProgress = CGFloat(min(1, max(0, (elapsed - 15) / 30)))
        let policeProgress = CGFloat(min(1, max(0, (elapsed - 45) / 45)))
        let finalStart = max(0, level.durationBeforeExit - 18)
        let finalProgress = CGFloat(min(1, max(0, (elapsed - finalStart) / 18)))

        let density = level.startingTrafficDensity
            + (level.maxTrafficDensity - level.startingTrafficDensity) * (trafficProgress * 0.62 + policeProgress * 0.22 + finalProgress * 0.16)
        let roadSpeed = 340 + warmupProgress * 30 + trafficProgress * 80 + policeProgress * 86 + finalProgress * 52
        let trafficSpeed = 232 + trafficProgress * 88 + policeProgress * 68 + finalProgress * 42
        let spawn = max(0.38, 1.08 - TimeInterval(density * 0.62) - TimeInterval(finalProgress * 0.12))
        let police = (2.6 + policeProgress * 3.2 + finalProgress * 1.2) * level.policeAggression

        return LevelDifficultySnapshot(
            trafficDensity: min(level.maxTrafficDensity, density),
            roadSpeed: roadSpeed,
            trafficSpeed: trafficSpeed,
            spawnInterval: spawn,
            policeClosingSpeed: exitActive ? police * 1.08 : police,
            roadblockCooldown: max(4.8, 13.5 - TimeInterval(level.policeAggression * 3.2) - TimeInterval(finalProgress * 3.0)),
            laneChangeDurationScale: max(0.86, 1.02 - TimeInterval(level.policeAggression - 1) * 0.08),
            exitSafetyGap: 300 + CGFloat(level.exitWindowSeconds) * 16,
            comboDuration: max(2.65, 3.35 - TimeInterval(level.policeAggression - 0.8) * 0.28)
        )
    }

    static func starRating(for run: RunStats, level: LevelDefinition) -> Int {
        guard run.levelCompleted else { return 0 }
        let levelNumber = LevelCatalog.displayNumber(for: level.levelID)
        let goodScore = 850 + levelNumber * 170
        let comboTarget = 4 + levelNumber / 3
        var stars = 1
        if run.score >= goodScore {
            stars += 1
        }
        if run.highestCombo >= comboTarget || !run.usedRevive {
            stars += 1
        }
        return min(3, stars)
    }
}
