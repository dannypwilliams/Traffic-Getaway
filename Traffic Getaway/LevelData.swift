import CoreGraphics
import Foundation

enum GameMode: String, Codable {
    case storyChase
    case endlessPursuit
}

enum ExitSide: String, Codable {
    case left
    case right

    var displayName: String {
        switch self {
        case .left:
            return "LEFT"
        case .right:
            return "RIGHT"
        }
    }

    var opposite: ExitSide {
        self == .left ? .right : .left
    }
}

struct LevelDefinition {
    let levelID: String
    let name: String
    let city: RunCity
    let durationBeforeExit: TimeInterval
    let exitSide: ExitSide
    let exitWindowSeconds: TimeInterval
    let startingTrafficDensity: CGFloat
    let maxTrafficDensity: CGFloat
    let policeAggression: CGFloat
    let rewardCash: Int
    let rewardXP: Int
    let allowsEmergencyExit: Bool
}

enum LevelCatalog {
    static let all: [LevelDefinition] = [
        LevelDefinition(levelID: "la_01", name: "Sunset Merge", city: .losAngeles, durationBeforeExit: 42, exitSide: .right, exitWindowSeconds: 14, startingTrafficDensity: 0.2, maxTrafficDensity: 0.42, policeAggression: 0.72, rewardCash: 210, rewardXP: 90, allowsEmergencyExit: true),
        LevelDefinition(levelID: "la_02", name: "405 Afterburn", city: .losAngeles, durationBeforeExit: 58, exitSide: .left, exitWindowSeconds: 13, startingTrafficDensity: 0.26, maxTrafficDensity: 0.5, policeAggression: 0.86, rewardCash: 240, rewardXP: 105, allowsEmergencyExit: true),
        LevelDefinition(levelID: "la_03", name: "Valley Cut", city: .losAngeles, durationBeforeExit: 68, exitSide: .right, exitWindowSeconds: 11, startingTrafficDensity: 0.34, maxTrafficDensity: 0.6, policeAggression: 1.0, rewardCash: 280, rewardXP: 115, allowsEmergencyExit: true),
        LevelDefinition(levelID: "la_04", name: "Freeway Riot", city: .losAngeles, durationBeforeExit: 76, exitSide: .left, exitWindowSeconds: 10, startingTrafficDensity: 0.38, maxTrafficDensity: 0.66, policeAggression: 1.08, rewardCash: 340, rewardXP: 135, allowsEmergencyExit: false),
        LevelDefinition(levelID: "la_05", name: "Last Exit West", city: .losAngeles, durationBeforeExit: 84, exitSide: .right, exitWindowSeconds: 10, startingTrafficDensity: 0.42, maxTrafficDensity: 0.7, policeAggression: 1.16, rewardCash: 430, rewardXP: 160, allowsEmergencyExit: false),

        LevelDefinition(levelID: "ny_01", name: "Brooklyn Warmup", city: .newYork, durationBeforeExit: 68, exitSide: .right, exitWindowSeconds: 10, startingTrafficDensity: 0.36, maxTrafficDensity: 0.62, policeAggression: 1.05, rewardCash: 520, rewardXP: 180, allowsEmergencyExit: true),
        LevelDefinition(levelID: "ny_02", name: "FDR Squeeze", city: .newYork, durationBeforeExit: 78, exitSide: .left, exitWindowSeconds: 9, startingTrafficDensity: 0.4, maxTrafficDensity: 0.68, policeAggression: 1.12, rewardCash: 620, rewardXP: 205, allowsEmergencyExit: true),
        LevelDefinition(levelID: "ny_03", name: "Midtown Split", city: .newYork, durationBeforeExit: 88, exitSide: .right, exitWindowSeconds: 9, startingTrafficDensity: 0.44, maxTrafficDensity: 0.72, policeAggression: 1.2, rewardCash: 740, rewardXP: 235, allowsEmergencyExit: false),
        LevelDefinition(levelID: "ny_04", name: "Queensboro Heat", city: .newYork, durationBeforeExit: 96, exitSide: .left, exitWindowSeconds: 8, startingTrafficDensity: 0.48, maxTrafficDensity: 0.78, policeAggression: 1.28, rewardCash: 880, rewardXP: 270, allowsEmergencyExit: false),
        LevelDefinition(levelID: "ny_05", name: "Tunnel Break", city: .newYork, durationBeforeExit: 104, exitSide: .right, exitWindowSeconds: 8, startingTrafficDensity: 0.52, maxTrafficDensity: 0.82, policeAggression: 1.36, rewardCash: 1_050, rewardXP: 310, allowsEmergencyExit: false),

        LevelDefinition(levelID: "mia_01", name: "Ocean Drive Run", city: .miami, durationBeforeExit: 76, exitSide: .left, exitWindowSeconds: 8, startingTrafficDensity: 0.48, maxTrafficDensity: 0.76, policeAggression: 1.25, rewardCash: 1_220, rewardXP: 340, allowsEmergencyExit: true),
        LevelDefinition(levelID: "mia_02", name: "Neon Causeway", city: .miami, durationBeforeExit: 88, exitSide: .right, exitWindowSeconds: 8, startingTrafficDensity: 0.52, maxTrafficDensity: 0.8, policeAggression: 1.32, rewardCash: 1_420, rewardXP: 380, allowsEmergencyExit: false),
        LevelDefinition(levelID: "mia_03", name: "Thunder Strip", city: .miami, durationBeforeExit: 98, exitSide: .left, exitWindowSeconds: 8, startingTrafficDensity: 0.55, maxTrafficDensity: 0.84, policeAggression: 1.4, rewardCash: 1_650, rewardXP: 425, allowsEmergencyExit: false),
        LevelDefinition(levelID: "mia_04", name: "Vice Lockdown", city: .miami, durationBeforeExit: 108, exitSide: .right, exitWindowSeconds: 7, startingTrafficDensity: 0.58, maxTrafficDensity: 0.86, policeAggression: 1.5, rewardCash: 1_950, rewardXP: 475, allowsEmergencyExit: false),
        LevelDefinition(levelID: "mia_05", name: "Crown Escape", city: .miami, durationBeforeExit: 118, exitSide: .left, exitWindowSeconds: 8, startingTrafficDensity: 0.6, maxTrafficDensity: 0.88, policeAggression: 1.58, rewardCash: 2_400, rewardXP: 560, allowsEmergencyExit: false)
    ]

    static func level(id: String) -> LevelDefinition? {
        all.first { $0.levelID == id }
    }

    static func isUnlocked(_ level: LevelDefinition, completedIDs: [String]) -> Bool {
        guard let index = all.firstIndex(where: { $0.levelID == level.levelID }) else { return false }
        return index == 0 || completedIDs.contains(all[index - 1].levelID)
    }

    static func nextPlayableLevel(completedIDs: [String]) -> LevelDefinition {
        all.first { isUnlocked($0, completedIDs: completedIDs) && !completedIDs.contains($0.levelID) } ?? all.last!
    }

    static func nextLevel(after levelID: String, completedIDs: [String]) -> LevelDefinition? {
        guard let index = all.firstIndex(where: { $0.levelID == levelID }) else { return nil }
        let nextIndex = index + 1
        guard all.indices.contains(nextIndex), isUnlocked(all[nextIndex], completedIDs: completedIDs) else { return nil }
        return all[nextIndex]
    }

    static func displayNumber(for levelID: String) -> Int {
        (all.firstIndex { $0.levelID == levelID } ?? 0) + 1
    }
}
