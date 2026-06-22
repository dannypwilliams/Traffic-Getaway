import Foundation

struct DailyChallengeDefinition {
    let id: String
    let title: String
    let description: String
    let kind: MissionKind
    let target: Int
    let rewardCash: Int
    let rewardXP: Int
    let paintRewardID: String?
}

struct DailyChallengeCard {
    let definition: DailyChallengeDefinition
    let date: String
    let progress: Int
    let isCompleted: Bool
    let isClaimed: Bool
}

struct DailyChallengeUpdate {
    let title: String
    let progress: Int
    let target: Int
    let completed: Bool
}

struct DailyClaimReward {
    let cash: Int
    let xp: Int
    let paintUnlocked: String?
    let levelChange: LevelChange?
}

final class DailyChallengeManager {
    static let shared = DailyChallengeManager()

    let definitions: [DailyChallengeDefinition] = [
        DailyChallengeDefinition(id: "daily_near_20", title: "Thread The Pack", description: "Get 20 near misses in one run.", kind: .nearMisses, target: 20, rewardCash: 500, rewardXP: 260, paintRewardID: nil),
        DailyChallengeDefinition(id: "daily_wanted_4", title: "Bring The Heat", description: "Reach wanted level 4.", kind: .wantedLevel, target: 4, rewardCash: 420, rewardXP: 220, paintRewardID: nil),
        DailyChallengeDefinition(id: "daily_survive_90", title: "Stay Gone", description: "Survive 90 seconds.", kind: .surviveSeconds, target: 90, rewardCash: 480, rewardXP: 240, paintRewardID: nil),
        DailyChallengeDefinition(id: "daily_reach_la", title: "Eastbound Run", description: "Reach New York without quitting.", kind: .reachCity, target: 2, rewardCash: 360, rewardXP: 190, paintRewardID: nil),
        DailyChallengeDefinition(id: "daily_cash_500", title: "Grab The Bag", description: "Earn 500 cash in one run.", kind: .earnCash, target: 500, rewardCash: 520, rewardXP: 230, paintRewardID: nil),
        DailyChallengeDefinition(id: "daily_clutch_3", title: "No Room Left", description: "Get 3 clutch saves.", kind: .clutchSaves, target: 3, rewardCash: 560, rewardXP: 280, paintRewardID: "matte_black"),
        DailyChallengeDefinition(id: "daily_distance_3000", title: "Long Road", description: "Drive 3,000 distance.", kind: .distance, target: 3_000, rewardCash: 620, rewardXP: 300, paintRewardID: "ocean_blue")
    ]

    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private init() {}

    func currentCard() -> DailyChallengeCard {
        ensureToday()
        let save = SaveManager.shared.data
        let definition = definition(id: save.dailyChallengeID) ?? definitionForToday()
        return DailyChallengeCard(
            definition: definition,
            date: save.dailyChallengeDate,
            progress: min(save.dailyChallengeProgress, definition.target),
            isCompleted: save.dailyChallengeCompleted,
            isClaimed: save.dailyChallengeClaimed
        )
    }

    func updateProgress(with run: RunStats, cashEarned: Int) -> DailyChallengeUpdate? {
        ensureToday()
        var save = SaveManager.shared.data
        guard let challenge = definition(id: save.dailyChallengeID), !save.dailyChallengeClaimed else { return nil }

        let value = valueForChallenge(challenge, run: run, cashEarned: cashEarned)
        let newProgress: Int

        switch challenge.kind {
        case .nearMisses, .clutchSaves, .dodgeBoosts, .completeRuns, .laneSplits, .completeMotorcycleLevel, .exitOnMotorcycle, .nearMissesOnMotorcycle, .cleanMotorcycleChase:
            newProgress = save.dailyChallengeProgress + value
        case .score, .distance, .wantedLevel, .surviveSeconds, .earnCash, .reachCity, .wantedOnMotorcycle:
            newProgress = max(save.dailyChallengeProgress, value)
        }

        let clamped = min(newProgress, challenge.target)
        guard clamped != save.dailyChallengeProgress else { return nil }
        let wasCompleted = save.dailyChallengeCompleted
        save.dailyChallengeProgress = clamped
        save.dailyChallengeCompleted = clamped >= challenge.target

        SaveManager.shared.mutate { stored in
            stored.dailyChallengeProgress = save.dailyChallengeProgress
            stored.dailyChallengeCompleted = save.dailyChallengeCompleted
        }

        if !wasCompleted && save.dailyChallengeCompleted {
            AnalyticsManager.shared.dailyCompleted(id: challenge.id)
        }

        return DailyChallengeUpdate(title: challenge.title, progress: clamped, target: challenge.target, completed: save.dailyChallengeCompleted)
    }

    func claimDailyChallenge() -> DailyClaimReward? {
        ensureToday()
        let save = SaveManager.shared.data
        guard let challenge = definition(id: save.dailyChallengeID),
              save.dailyChallengeCompleted,
              !save.dailyChallengeClaimed else {
            return nil
        }

        SaveManager.shared.addCash(challenge.rewardCash)
        let levelChange = SaveManager.shared.addXP(challenge.rewardXP)
        var paintUnlocked: String?

        if let paintID = challenge.paintRewardID,
           !SaveManager.shared.data.unlockedPaintIDs.contains(paintID) {
            SaveManager.shared.unlockPaint(paintID)
            paintUnlocked = CarCatalog.paint(id: paintID).displayName
        }

        SaveManager.shared.mutate { save in
            save.dailyChallengeClaimed = true
        }

        return DailyClaimReward(cash: challenge.rewardCash, xp: challenge.rewardXP, paintUnlocked: paintUnlocked, levelChange: levelChange)
    }

    private func ensureToday() {
        let today = formatter.string(from: Date())
        let save = SaveManager.shared.data
        guard save.dailyChallengeDate != today || save.dailyChallengeID.isEmpty else { return }

        let challenge = definitionForToday()
        SaveManager.shared.mutate { save in
            save.dailyChallengeDate = today
            save.dailyChallengeID = challenge.id
            save.dailyChallengeProgress = 0
            save.dailyChallengeCompleted = false
            save.dailyChallengeClaimed = false
        }
    }

    private func definitionForToday() -> DailyChallengeDefinition {
        let today = formatter.string(from: Date())
        let seed = today.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return definitions[seed % definitions.count]
    }

    private func definition(id: String) -> DailyChallengeDefinition? {
        definitions.first { $0.id == id }
    }

    private func valueForChallenge(_ challenge: DailyChallengeDefinition, run: RunStats, cashEarned: Int) -> Int {
        switch challenge.kind {
        case .score:
            return run.score
        case .distance:
            return run.distance
        case .nearMisses:
            return run.nearMisses
        case .clutchSaves:
            return run.clutchSaves
        case .wantedLevel:
            return run.wantedLevelReached
        case .surviveSeconds:
            return Int(run.survivalTime)
        case .earnCash:
            return cashEarned
        case .dodgeBoosts:
            return run.dodgeBoostsUsed
        case .reachCity:
            return run.cityReached.rank
        case .completeRuns:
            return 1
        case .laneSplits:
            return run.laneSplits
        case .completeMotorcycleLevel, .exitOnMotorcycle:
            return run.completedOnMotorcycle ? 1 : 0
        case .wantedOnMotorcycle:
            return run.selectedVehicleClass == .motorcycle ? run.wantedLevelReached : 0
        case .nearMissesOnMotorcycle:
            return run.selectedVehicleClass == .motorcycle ? run.nearMisses : 0
        case .cleanMotorcycleChase:
            return run.completedOnMotorcycle && run.crashesOnMotorcycle == 0 ? 1 : 0
        }
    }
}
