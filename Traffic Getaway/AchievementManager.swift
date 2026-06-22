import Foundation

enum AchievementKind: String, Codable {
    case totalRuns
    case totalNearMisses
    case totalLaneSplits
    case totalClutchSaves
    case highestWanted
    case lifetimeScore
    case lifetimeCash
    case bestCombo
    case bestDistance
    case reachCity
    case unlockedCars
    case unlockedMotorcycles
    case legendaryMotorcycles
    case motorcycleLevelsCompleted
    case unlockedPaints
    case cashSpent
    case totalCrashes
    case playerLevel
}

struct AchievementDefinition {
    let id: String
    let name: String
    let description: String
    let kind: AchievementKind
    let target: Int
    let rewardCash: Int
    let rewardXP: Int
}

struct AchievementCard {
    let definition: AchievementDefinition
    let progress: Int
    let isUnlocked: Bool
    let isClaimed: Bool
}

struct AchievementUpdate {
    let name: String
    let completed: Bool
}

final class AchievementManager {
    static let shared = AchievementManager()

    let definitions: [AchievementDefinition] = [
        AchievementDefinition(id: "first_escape", name: "First Escape", description: "Complete 1 run.", kind: .totalRuns, target: 1, rewardCash: 120, rewardXP: 80),
        AchievementDefinition(id: "repeat_offender", name: "Repeat Offender", description: "Complete 10 runs.", kind: .totalRuns, target: 10, rewardCash: 360, rewardXP: 200),
        AchievementDefinition(id: "career_criminal", name: "Career Criminal", description: "Complete 100 runs.", kind: .totalRuns, target: 100, rewardCash: 2_000, rewardXP: 1_000),
        AchievementDefinition(id: "close_call", name: "Close Call", description: "Get 1 clutch save.", kind: .totalClutchSaves, target: 1, rewardCash: 180, rewardXP: 100),
        AchievementDefinition(id: "last_second_legend", name: "Last Second Legend", description: "Get 25 clutch saves.", kind: .totalClutchSaves, target: 25, rewardCash: 900, rewardXP: 420),
        AchievementDefinition(id: "thread_master", name: "Thread Master", description: "Get 100 near misses.", kind: .totalNearMisses, target: 100, rewardCash: 1_200, rewardXP: 600),
        AchievementDefinition(id: "mirror_touch", name: "Mirror Touch", description: "Get 25 near misses.", kind: .totalNearMisses, target: 25, rewardCash: 420, rewardXP: 240),
        AchievementDefinition(id: "heat_level", name: "Heat Level", description: "Reach wanted level 3.", kind: .highestWanted, target: 3, rewardCash: 300, rewardXP: 180),
        AchievementDefinition(id: "air_support", name: "Air Support", description: "Reach wanted level 5.", kind: .highestWanted, target: 5, rewardCash: 720, rewardXP: 360),
        AchievementDefinition(id: "most_wanted", name: "Most Wanted", description: "Reach wanted level 6.", kind: .highestWanted, target: 6, rewardCash: 1_200, rewardXP: 650),
        AchievementDefinition(id: "million_chase", name: "Million Dollar Chase", description: "Earn 1,000,000 lifetime score.", kind: .lifetimeScore, target: 1_000_000, rewardCash: 3_000, rewardXP: 1_500),
        AchievementDefinition(id: "score_hunter", name: "Score Hunter", description: "Earn 100,000 lifetime score.", kind: .lifetimeScore, target: 100_000, rewardCash: 900, rewardXP: 420),
        AchievementDefinition(id: "miami_nights", name: "Miami Nights", description: "Reach Miami.", kind: .reachCity, target: 3, rewardCash: 520, rewardXP: 280),
        AchievementDefinition(id: "west_coast", name: "Empire Bound", description: "Reach New York.", kind: .reachCity, target: 2, rewardCash: 260, rewardXP: 140),
        AchievementDefinition(id: "collector", name: "Collector", description: "Unlock 10 cars.", kind: .unlockedCars, target: 10, rewardCash: 1_200, rewardXP: 650),
        AchievementDefinition(id: "full_garage", name: "Full Garage", description: "Unlock all cars.", kind: .unlockedCars, target: CarCatalog.carsOnly.count, rewardCash: 4_000, rewardXP: 2_000),
        AchievementDefinition(id: "paint_sampler", name: "Paint Sampler", description: "Unlock 5 paints.", kind: .unlockedPaints, target: 5, rewardCash: 500, rewardXP: 260),
        AchievementDefinition(id: "paint_master", name: "Paint Master", description: "Unlock all paints.", kind: .unlockedPaints, target: CarCatalog.paints.count, rewardCash: 1_500, rewardXP: 700),
        AchievementDefinition(id: "big_spender", name: "Big Spender", description: "Spend 10,000 cash.", kind: .cashSpent, target: 10_000, rewardCash: 1_000, rewardXP: 500),
        AchievementDefinition(id: "combo_king", name: "Combo King", description: "Reach combo x10.", kind: .bestCombo, target: 10, rewardCash: 700, rewardXP: 380),
        AchievementDefinition(id: "combo_royalty", name: "Combo Royalty", description: "Reach combo x20.", kind: .bestCombo, target: 20, rewardCash: 1_400, rewardXP: 760),
        AchievementDefinition(id: "distance_runner", name: "Distance Runner", description: "Drive 5,000 distance in one run.", kind: .bestDistance, target: 5_000, rewardCash: 900, rewardXP: 440),
        AchievementDefinition(id: "marathon_chase", name: "Marathon Chase", description: "Drive 10,000 distance in one run.", kind: .bestDistance, target: 10_000, rewardCash: 1_800, rewardXP: 900),
        AchievementDefinition(id: "cash_stack", name: "Cash Stack", description: "Earn 25,000 lifetime cash.", kind: .lifetimeCash, target: 25_000, rewardCash: 1_200, rewardXP: 620),
        AchievementDefinition(id: "level_10", name: "Made Driver", description: "Reach player level 10.", kind: .playerLevel, target: 10, rewardCash: 1_000, rewardXP: 0),
        AchievementDefinition(id: "crash_tested", name: "Crash Tested", description: "Crash 25 times.", kind: .totalCrashes, target: 25, rewardCash: 450, rewardXP: 220),
        AchievementDefinition(id: "first_ride", name: "First Ride", description: "Unlock a motorcycle.", kind: .unlockedMotorcycles, target: 1, rewardCash: 260, rewardXP: 160),
        AchievementDefinition(id: "lane_splitter", name: "Lane Splitter", description: "Perform 10 lane splits.", kind: .totalLaneSplits, target: 10, rewardCash: 420, rewardXP: 240),
        AchievementDefinition(id: "thread_master_bike", name: "Thread Master", description: "Perform 100 lane splits.", kind: .totalLaneSplits, target: 100, rewardCash: 1_600, rewardXP: 820),
        AchievementDefinition(id: "two_wheel_escape", name: "Two-Wheel Escape", description: "Complete 10 levels on motorcycles.", kind: .motorcycleLevelsCompleted, target: 10, rewardCash: 1_700, rewardXP: 900),
        AchievementDefinition(id: "neon_rider", name: "Neon Rider", description: "Unlock a legendary motorcycle.", kind: .legendaryMotorcycles, target: 1, rewardCash: 1_200, rewardXP: 700)
    ]

    private init() {}

    func achievementCards() -> [AchievementCard] {
        _ = updateStoredProgress()
        let save = SaveManager.shared.data
        return definitions.map { definition in
            let progress = min(save.achievementProgress[definition.id] ?? 0, definition.target)
            return AchievementCard(
                definition: definition,
                progress: progress,
                isUnlocked: progress >= definition.target,
                isClaimed: save.claimedAchievementRewards.contains(definition.id)
            )
        }
    }

    func updateStoredProgress() -> [AchievementUpdate] {
        let oldProgress = SaveManager.shared.data.achievementProgress
        var newProgress = oldProgress
        var updates: [AchievementUpdate] = []
        let save = SaveManager.shared.data

        for achievement in definitions {
            let value = progressValue(for: achievement, save: save)
            let clamped = min(value, achievement.target)
            let previous = oldProgress[achievement.id] ?? 0
            newProgress[achievement.id] = clamped

            if previous < achievement.target && clamped >= achievement.target {
                updates.append(AchievementUpdate(name: achievement.name, completed: true))
                AnalyticsManager.shared.achievementUnlocked(id: achievement.id)
            }
        }

        SaveManager.shared.mutate { save in
            save.achievementProgress = newProgress
        }

        return updates
    }

    func claimAchievement(id: String) -> ClaimReward? {
        _ = updateStoredProgress()
        guard let achievement = definitions.first(where: { $0.id == id }) else { return nil }
        let save = SaveManager.shared.data
        let progress = save.achievementProgress[id] ?? 0
        guard progress >= achievement.target, !save.claimedAchievementRewards.contains(id) else { return nil }

        SaveManager.shared.addCash(achievement.rewardCash)
        let levelChange = SaveManager.shared.addXP(achievement.rewardXP)
        SaveManager.shared.mutate { save in
            save.claimedAchievementRewards.append(id)
        }

        return ClaimReward(cash: achievement.rewardCash, xp: achievement.rewardXP, levelChange: levelChange)
    }

    private func progressValue(for achievement: AchievementDefinition, save: SaveData) -> Int {
        switch achievement.kind {
        case .totalRuns:
            return save.totalRuns
        case .totalNearMisses:
            return save.totalNearMisses
        case .totalLaneSplits:
            return save.totalLaneSplits
        case .totalClutchSaves:
            return save.totalClutchSaves
        case .highestWanted:
            return save.highestWantedLevelReached
        case .lifetimeScore:
            return save.lifetimeScore
        case .lifetimeCash:
            return save.lifetimeCashEarned
        case .bestCombo:
            return save.bestCombo
        case .bestDistance:
            return save.bestDistance
        case .reachCity:
            return save.highestCityReached
        case .unlockedCars:
            return save.unlockedCarIDs.filter { CarCatalog.car(id: $0).vehicleClass == .car }.count
        case .unlockedMotorcycles:
            return save.unlockedCarIDs.filter { CarCatalog.car(id: $0).vehicleClass == .motorcycle }.count
        case .legendaryMotorcycles:
            return save.unlockedCarIDs.filter {
                let car = CarCatalog.car(id: $0)
                return car.vehicleClass == .motorcycle && car.rarity == .legendary
            }.count
        case .motorcycleLevelsCompleted:
            return save.motorcycleLevelsCompleted
        case .unlockedPaints:
            return save.unlockedPaintIDs.count
        case .cashSpent:
            return save.lifetimeCashSpent
        case .totalCrashes:
            return save.totalCrashes
        case .playerLevel:
            return save.playerLevel
        }
    }
}
