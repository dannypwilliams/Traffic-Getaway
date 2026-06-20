import Foundation

enum MissionKind: String, Codable {
    case score
    case distance
    case nearMisses
    case clutchSaves
    case wantedLevel
    case surviveSeconds
    case earnCash
    case dodgeBoosts
    case reachCity
    case completeRuns
    case laneSplits
    case completeMotorcycleLevel
    case wantedOnMotorcycle
    case exitOnMotorcycle
    case nearMissesOnMotorcycle
    case cleanMotorcycleChase
}

struct MissionDefinition {
    let id: String
    let title: String
    let description: String
    let kind: MissionKind
    let target: Int
    let rewardCash: Int
    let rewardXP: Int
}

struct MissionCard {
    let definition: MissionDefinition
    let progress: Int
    let isComplete: Bool
}

struct MissionUpdate {
    let title: String
    let progress: Int
    let target: Int
    let completed: Bool
}

struct ClaimReward {
    let cash: Int
    let xp: Int
    let levelChange: LevelChange?
}

final class MissionManager {
    static let shared = MissionManager()

    let definitions: [MissionDefinition] = [
        MissionDefinition(id: "score_500", title: "Warm Up", description: "Reach score 500.", kind: .score, target: 500, rewardCash: 120, rewardXP: 70),
        MissionDefinition(id: "score_1200", title: "Clean Escape", description: "Reach score 1,200.", kind: .score, target: 1_200, rewardCash: 180, rewardXP: 100),
        MissionDefinition(id: "score_2500", title: "Big Run", description: "Reach score 2,500.", kind: .score, target: 2_500, rewardCash: 320, rewardXP: 150),
        MissionDefinition(id: "score_5000", title: "Legend Run", description: "Reach score 5,000.", kind: .score, target: 5_000, rewardCash: 560, rewardXP: 260),
        MissionDefinition(id: "distance_800", title: "City Blocks", description: "Drive 800 distance.", kind: .distance, target: 800, rewardCash: 140, rewardXP: 80),
        MissionDefinition(id: "distance_1800", title: "Freeway Push", description: "Drive 1,800 distance.", kind: .distance, target: 1_800, rewardCash: 240, rewardXP: 130),
        MissionDefinition(id: "distance_3200", title: "Long Haul", description: "Drive 3,200 distance.", kind: .distance, target: 3_200, rewardCash: 420, rewardXP: 210),
        MissionDefinition(id: "near_5", title: "Risky Lines", description: "Get 5 near misses.", kind: .nearMisses, target: 5, rewardCash: 150, rewardXP: 90),
        MissionDefinition(id: "near_12", title: "Thread Traffic", description: "Get 12 near misses.", kind: .nearMisses, target: 12, rewardCash: 280, rewardXP: 150),
        MissionDefinition(id: "near_25", title: "Mirror Scraper", description: "Get 25 near misses.", kind: .nearMisses, target: 25, rewardCash: 520, rewardXP: 260),
        MissionDefinition(id: "clutch_1", title: "Saved It", description: "Get 1 clutch save.", kind: .clutchSaves, target: 1, rewardCash: 160, rewardXP: 100),
        MissionDefinition(id: "clutch_3", title: "Last Second", description: "Get 3 clutch saves.", kind: .clutchSaves, target: 3, rewardCash: 360, rewardXP: 190),
        MissionDefinition(id: "clutch_8", title: "Escape Artist", description: "Get 8 clutch saves.", kind: .clutchSaves, target: 8, rewardCash: 760, rewardXP: 360),
        MissionDefinition(id: "wanted_2", title: "Heat Check", description: "Reach wanted level 2.", kind: .wantedLevel, target: 2, rewardCash: 120, rewardXP: 80),
        MissionDefinition(id: "wanted_3", title: "Radio Chatter", description: "Reach wanted level 3.", kind: .wantedLevel, target: 3, rewardCash: 240, rewardXP: 140),
        MissionDefinition(id: "wanted_4", title: "Roadblock Runner", description: "Reach wanted level 4.", kind: .wantedLevel, target: 4, rewardCash: 420, rewardXP: 220),
        MissionDefinition(id: "wanted_5", title: "Air Support", description: "Reach wanted level 5.", kind: .wantedLevel, target: 5, rewardCash: 640, rewardXP: 320),
        MissionDefinition(id: "survive_45", title: "Stay Loose", description: "Survive 45 seconds.", kind: .surviveSeconds, target: 45, rewardCash: 160, rewardXP: 90),
        MissionDefinition(id: "survive_90", title: "Outrun Units", description: "Survive 90 seconds.", kind: .surviveSeconds, target: 90, rewardCash: 360, rewardXP: 190),
        MissionDefinition(id: "survive_150", title: "Gone Long", description: "Survive 150 seconds.", kind: .surviveSeconds, target: 150, rewardCash: 720, rewardXP: 350),
        MissionDefinition(id: "cash_250", title: "Pocket Money", description: "Earn 250 cash.", kind: .earnCash, target: 250, rewardCash: 160, rewardXP: 90),
        MissionDefinition(id: "cash_750", title: "Hot Cash", description: "Earn 750 cash.", kind: .earnCash, target: 750, rewardCash: 360, rewardXP: 180),
        MissionDefinition(id: "cash_1500", title: "Big Score", description: "Earn 1,500 cash.", kind: .earnCash, target: 1_500, rewardCash: 700, rewardXP: 330),
        MissionDefinition(id: "boost_5", title: "Quick Feet", description: "Use Dodge Boost 5 times.", kind: .dodgeBoosts, target: 5, rewardCash: 160, rewardXP: 100),
        MissionDefinition(id: "boost_15", title: "Boost Habit", description: "Use Dodge Boost 15 times.", kind: .dodgeBoosts, target: 15, rewardCash: 420, rewardXP: 220),
        MissionDefinition(id: "city_la", title: "Westbound", description: "Reach Los Angeles.", kind: .reachCity, target: 2, rewardCash: 260, rewardXP: 150),
        MissionDefinition(id: "city_miami", title: "Neon Coast", description: "Reach Miami.", kind: .reachCity, target: 3, rewardCash: 520, rewardXP: 280),
        MissionDefinition(id: "runs_2", title: "Back Again", description: "Complete 2 runs.", kind: .completeRuns, target: 2, rewardCash: 130, rewardXP: 80),
        MissionDefinition(id: "runs_5", title: "Routine Work", description: "Complete 5 runs.", kind: .completeRuns, target: 5, rewardCash: 320, rewardXP: 170),
        MissionDefinition(id: "runs_10", title: "Night Shift", description: "Complete 10 runs.", kind: .completeRuns, target: 10, rewardCash: 620, rewardXP: 300),
        MissionDefinition(id: "bike_split_5", title: "Split Decision", description: "Perform 5 lane splits.", kind: .laneSplits, target: 5, rewardCash: 220, rewardXP: 120),
        MissionDefinition(id: "bike_split_15", title: "Between Mirrors", description: "Perform 15 lane splits.", kind: .laneSplits, target: 15, rewardCash: 460, rewardXP: 230),
        MissionDefinition(id: "bike_escape_1", title: "Two-Wheel Exit", description: "Complete a level on a motorcycle.", kind: .completeMotorcycleLevel, target: 1, rewardCash: 300, rewardXP: 180),
        MissionDefinition(id: "bike_wanted_4", title: "Moto Heat", description: "Reach wanted level 4 on a motorcycle.", kind: .wantedOnMotorcycle, target: 4, rewardCash: 420, rewardXP: 230),
        MissionDefinition(id: "bike_exit", title: "Ramp Rider", description: "Escape through an exit on a motorcycle.", kind: .exitOnMotorcycle, target: 1, rewardCash: 360, rewardXP: 210),
        MissionDefinition(id: "bike_near_10", title: "Handlebar Close", description: "Get 10 near misses on a motorcycle.", kind: .nearMissesOnMotorcycle, target: 10, rewardCash: 380, rewardXP: 220),
        MissionDefinition(id: "bike_clean", title: "No Scrapes", description: "Complete a chase without crashing on a motorcycle.", kind: .cleanMotorcycleChase, target: 1, rewardCash: 520, rewardXP: 280)
    ]

    private init() {}

    func ensureActiveMissions() {
        var save = SaveManager.shared.data
        let validIDs = Set(definitions.map(\.id))
        save.activeMissionIDs = save.activeMissionIDs.filter { validIDs.contains($0) }

        while save.activeMissionIDs.count < 3 {
            guard let next = nextMission(excluding: save.activeMissionIDs + save.completedMissionIDs) else { break }
            save.activeMissionIDs.append(next.id)
            save.activeMissionProgress[next.id] = 0
        }

        SaveManager.shared.mutate { stored in
            stored.activeMissionIDs = save.activeMissionIDs
            stored.activeMissionProgress = save.activeMissionProgress
        }
    }

    func activeMissionCards() -> [MissionCard] {
        ensureActiveMissions()
        let save = SaveManager.shared.data
        return save.activeMissionIDs.compactMap { id in
            guard let definition = definition(id: id) else { return nil }
            let progress = min(save.activeMissionProgress[id] ?? 0, definition.target)
            return MissionCard(definition: definition, progress: progress, isComplete: progress >= definition.target)
        }
    }

    func updateProgress(with run: RunStats, cashEarned: Int) -> [MissionUpdate] {
        ensureActiveMissions()
        var updates: [MissionUpdate] = []
        var save = SaveManager.shared.data

        for id in save.activeMissionIDs {
            guard let mission = definition(id: id) else { continue }
            let oldProgress = save.activeMissionProgress[id] ?? 0
            let value = valueForMission(mission, run: run, cashEarned: cashEarned)
            let newProgress: Int

            switch mission.kind {
            case .score, .distance, .wantedLevel, .surviveSeconds, .reachCity, .wantedOnMotorcycle:
                newProgress = max(oldProgress, value)
            case .nearMisses, .clutchSaves, .earnCash, .dodgeBoosts, .completeRuns, .laneSplits, .completeMotorcycleLevel, .exitOnMotorcycle, .nearMissesOnMotorcycle, .cleanMotorcycleChase:
                newProgress = oldProgress + value
            }

            let clamped = min(newProgress, mission.target)
            if clamped != oldProgress {
                save.activeMissionProgress[id] = clamped
                updates.append(MissionUpdate(title: mission.title, progress: clamped, target: mission.target, completed: clamped >= mission.target))
                if oldProgress < mission.target && clamped >= mission.target {
                    AnalyticsManager.shared.missionCompleted(id: mission.id)
                }
            }
        }

        SaveManager.shared.mutate { stored in
            stored.activeMissionProgress = save.activeMissionProgress
        }
        return updates
    }

    func claimMission(id: String) -> ClaimReward? {
        ensureActiveMissions()
        guard let mission = definition(id: id) else { return nil }
        let save = SaveManager.shared.data
        let progress = save.activeMissionProgress[id] ?? 0
        guard save.activeMissionIDs.contains(id), progress >= mission.target else { return nil }

        SaveManager.shared.addCash(mission.rewardCash)
        let levelChange = SaveManager.shared.addXP(mission.rewardXP)

        SaveManager.shared.mutate { save in
            save.completedMissionIDs.append(id)
            save.activeMissionIDs.removeAll { $0 == id }
            save.activeMissionProgress[id] = nil
        }
        ensureActiveMissions()

        return ClaimReward(cash: mission.rewardCash, xp: mission.rewardXP, levelChange: levelChange)
    }

    private func definition(id: String) -> MissionDefinition? {
        definitions.first { $0.id == id }
    }

    private func nextMission(excluding excludedIDs: [String]) -> MissionDefinition? {
        let excluded = Set(excludedIDs)
        if let mission = definitions.first(where: { !excluded.contains($0.id) }) {
            return mission
        }
        return definitions.first(where: { !excludedIDs.contains($0.id) })
    }

    private func valueForMission(_ mission: MissionDefinition, run: RunStats, cashEarned: Int) -> Int {
        switch mission.kind {
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
        case .completeMotorcycleLevel:
            return run.completedOnMotorcycle ? 1 : 0
        case .wantedOnMotorcycle:
            return run.selectedVehicleClass == .motorcycle ? run.wantedLevelReached : 0
        case .exitOnMotorcycle:
            return run.completedOnMotorcycle ? 1 : 0
        case .nearMissesOnMotorcycle:
            return run.selectedVehicleClass == .motorcycle ? run.nearMisses : 0
        case .cleanMotorcycleChase:
            return run.completedOnMotorcycle && run.crashesOnMotorcycle == 0 ? 1 : 0
        }
    }
}
