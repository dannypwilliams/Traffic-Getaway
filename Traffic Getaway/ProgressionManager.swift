import Foundation

struct ProgressionResult {
    let runStats: RunStats
    let finalCashEarned: Int
    let finalXPEarned: Int
    let baseCash: Int
    let levelBefore: Int
    let levelAfter: Int
    let xpBefore: Int
    let xpAfter: Int
    let levelCashBonus: Int
    let missionUpdates: [MissionUpdate]
    let achievementUpdates: [AchievementUpdate]
    let dailyUpdate: DailyChallengeUpdate?
    let completedLevel: LevelDefinition?
    let nextLevel: LevelDefinition?
    let levelCompletionRewarded: Bool
    let levelStarRating: Int
    let previousBestStarRating: Int
    let primaryUnlockVehicleID: String?
}

final class ProgressionManager {
    static let shared = ProgressionManager()

    private init() {}

    /// Economy balance: early rewards are intentionally generous. A decent run should move the player
    /// toward a second car within several attempts, while legendary cars remain long-term targets.
    func processRun(_ run: RunStats) -> ProgressionResult {
        MissionManager.shared.ensureActiveMissions()
        _ = DailyChallengeManager.shared.currentCard()
        _ = AchievementManager.shared.updateStoredProgress()

        let saveBefore = SaveManager.shared.data
        let car = CarCatalog.car(id: run.selectedCarID)
        let completedLevel = run.levelCompleted ? run.levelID.flatMap(LevelCatalog.level) : nil
        let alreadyCompletedLevel = completedLevel.map { saveBefore.completedLevelIDs.contains($0.levelID) } ?? false
        let levelRewardCash = alreadyCompletedLevel ? 0 : (completedLevel?.rewardCash ?? 0)
        let levelRewardXP = alreadyCompletedLevel ? 0 : (completedLevel?.rewardXP ?? 0)
        let levelStarRating = completedLevel.map { LevelDifficultyConfig.starRating(for: run, level: $0) } ?? 0
        let previousBestStars = completedLevel.map { saveBefore.levelStarRatings[$0.levelID] ?? 0 } ?? 0
        let primaryUnlockVehicleID = Self.firstEscapeVehicleUnlock(
            completedLevel: completedLevel,
            alreadyCompletedLevel: alreadyCompletedLevel,
            saveBefore: saveBefore
        )
        let baseCash = calculateBaseCash(run)
        let economyScale: CGFloat = run.selectedVehicleClass == .motorcycle ? 0.96 : 1.02
        let finalCash = max(20, Int(CGFloat(baseCash) * car.cashMultiplier * economyScale) + levelRewardCash)
        let finalXP = max(12, calculateXP(run: run) + levelRewardXP)
        let levelBefore = saveBefore.playerLevel
        let xpBefore = saveBefore.totalXP

        SaveManager.shared.mutate { save in
            save.totalRuns += 1
            save.totalCrashes += run.crashes
            save.totalNearMisses += run.nearMisses
            save.totalLaneSplits += run.laneSplits
            save.totalClutchSaves += run.clutchSaves
            save.totalTimePlayed += run.survivalTime
            save.lifetimeScore += run.score
            save.highestWantedLevelReached = max(save.highestWantedLevelReached, run.wantedLevelReached)
            save.bestScore = max(save.bestScore, run.score)
            save.bestDistance = max(save.bestDistance, run.distance)
            save.bestCombo = max(save.bestCombo, run.highestCombo)
            save.bestLaneSplits = max(save.bestLaneSplits, run.laneSplits)
            save.highestCityReached = max(save.highestCityReached, run.cityReached.rank)
            if run.completedOnMotorcycle {
                save.motorcycleLevelsCompleted += 1
            }
            if let completedLevel, !save.completedLevelIDs.contains(completedLevel.levelID) {
                save.completedLevelIDs.append(completedLevel.levelID)
            }
            if let primaryUnlockVehicleID, !save.unlockedCarIDs.contains(primaryUnlockVehicleID) {
                save.unlockedCarIDs.append(primaryUnlockVehicleID)
                save.selectedCarID = primaryUnlockVehicleID
            }
            if let completedLevel {
                save.levelBestScores[completedLevel.levelID] = max(save.levelBestScores[completedLevel.levelID] ?? 0, run.score)
                save.levelBestCombos[completedLevel.levelID] = max(save.levelBestCombos[completedLevel.levelID] ?? 0, run.highestCombo)
                save.levelStarRatings[completedLevel.levelID] = max(save.levelStarRatings[completedLevel.levelID] ?? 0, levelStarRating)
                if let bestTime = save.levelBestEscapeTimes[completedLevel.levelID] {
                    save.levelBestEscapeTimes[completedLevel.levelID] = min(bestTime, run.survivalTime)
                } else {
                    save.levelBestEscapeTimes[completedLevel.levelID] = run.survivalTime
                }
            }
        }

        SaveManager.shared.addCash(finalCash)
        let levelChange = SaveManager.shared.addXP(finalXP)
        let missionUpdates = MissionManager.shared.updateProgress(with: run, cashEarned: finalCash)
        let dailyUpdate = DailyChallengeManager.shared.updateProgress(with: run, cashEarned: finalCash)
        let achievementUpdates = AchievementManager.shared.updateStoredProgress()
        SaveManager.shared.incrementInterstitialCounter()
        AnalyticsManager.shared.runEnded(run, cashEarned: finalCash, xpEarned: finalXP)

        return ProgressionResult(
            runStats: run,
            finalCashEarned: finalCash,
            finalXPEarned: finalXP,
            baseCash: baseCash,
            levelBefore: levelBefore,
            levelAfter: SaveManager.shared.data.playerLevel,
            xpBefore: xpBefore,
            xpAfter: SaveManager.shared.data.totalXP,
            levelCashBonus: levelChange?.cashBonus ?? 0,
            missionUpdates: missionUpdates,
            achievementUpdates: achievementUpdates,
            dailyUpdate: dailyUpdate,
            completedLevel: completedLevel,
            nextLevel: completedLevel.flatMap { LevelCatalog.nextLevel(after: $0.levelID, completedIDs: SaveManager.shared.data.completedLevelIDs) },
            levelCompletionRewarded: completedLevel != nil && !alreadyCompletedLevel,
            levelStarRating: levelStarRating,
            previousBestStarRating: previousBestStars,
            primaryUnlockVehicleID: primaryUnlockVehicleID
        )
    }

    private static func firstEscapeVehicleUnlock(completedLevel: LevelDefinition?, alreadyCompletedLevel: Bool, saveBefore: SaveData) -> String? {
        guard completedLevel?.levelID == "la_01",
              !alreadyCompletedLevel,
              !saveBefore.unlockedCarIDs.contains(CarCatalog.starterBikeID) else {
            return nil
        }

        return CarCatalog.starterBikeID
    }

    private func calculateBaseCash(_ run: RunStats) -> Int {
        let scoreCash = run.score / 120
        let distanceCash = run.distance / 180
        let wantedCash = run.wantedLevelReached * 18
        let nearMissCash = run.nearMisses * 5
        let laneSplitCash = run.laneSplits * 7
        let clutchCash = run.clutchSaves * 22
        let comboCash = run.highestCombo * 6
        let survivalCash = Int(run.survivalTime / 6)
        return run.cashEarned + scoreCash + distanceCash + wantedCash + nearMissCash + laneSplitCash + clutchCash + comboCash + survivalCash
    }

    private func calculateXP(run: RunStats) -> Int {
        let scoreXP = run.score / 170
        let survivalXP = Int(run.survivalTime / 3)
        let distanceXP = run.distance / 240
        let riskXP = run.nearMisses * 2 + run.laneSplits * 4 + run.clutchSaves * 10
        let heatXP = run.wantedLevelReached * 18
        let comboXP = run.highestCombo * 3
        return scoreXP + survivalXP + distanceXP + riskXP + heatXP + comboXP + run.xpEarned
    }
}
