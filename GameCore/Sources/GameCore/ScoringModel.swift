import Foundation

public struct PassiveRewardResult: Codable, Equatable {
    public let distance: Double
    public let scoreGained: Int
    public let scoreRemainder: Double
    public let cashGained: Int
    public let cashRemainder: Double
}

public struct EventReward: Codable, Equatable {
    public let score: Int
    public let cash: Int
}

public struct FinalRunReward: Codable, Equatable {
    public let baseCash: Int
    public let cash: Int
    public let xp: Int
}

public enum ScoringModel {
    public static func scoreMultiplier(vehicle: VehicleDefinition, wantedLevel: Int, combo: Int) -> Double {
        let comboBonus = Double(min(combo, 8)) * 0.15
        let wantedBonus = Double(max(0, wantedLevel - 1)) * 0.1
        return (1 + comboBonus + wantedBonus) * vehicle.scoreMultiplier
    }

    public static func passiveRewardScale(vehicle: VehicleDefinition) -> Double {
        vehicle.vehicleClass == .motorcycle ? 0.92 : 1.03
    }

    public static func passiveReward(
        snapshot: DifficultySnapshot,
        vehicle: VehicleDefinition,
        wantedLevel: Int,
        combo: Int,
        deltaTime: Double,
        scoreRemainder: Double,
        cashRemainder: Double
    ) -> PassiveRewardResult {
        let passiveScale = passiveRewardScale(vehicle: vehicle)
        let distance = snapshot.roadSpeed * deltaTime * 0.1
        let scoreTotal = scoreRemainder + snapshot.roadSpeed * deltaTime * 0.1 * scoreMultiplier(vehicle: vehicle, wantedLevel: wantedLevel, combo: combo) * passiveScale
        let cashTotal = cashRemainder + snapshot.roadSpeed * deltaTime * 0.0035 * (1 + Double(wantedLevel - 1) * 0.08) * passiveScale
        let scoreGained = Int(scoreTotal)
        let cashGained = Int(cashTotal)

        return PassiveRewardResult(
            distance: distance,
            scoreGained: scoreGained,
            scoreRemainder: scoreTotal - Double(scoreGained),
            cashGained: cashGained,
            cashRemainder: cashTotal - Double(cashGained)
        )
    }

    public static func nearMissReward(vehicle: VehicleDefinition, wantedLevel: Int, combo: Int) -> EventReward {
        EventReward(
            score: Int(Double(25 + min(combo, 10) * 5) * scoreMultiplier(vehicle: vehicle, wantedLevel: wantedLevel, combo: combo) * vehicle.nearMissMultiplier),
            cash: 1 + min(combo, 8) / 2 + wantedLevel / 2
        )
    }

    public static func laneSplitReward(vehicle: VehicleDefinition, wantedLevel: Int, combo: Int) -> EventReward {
        EventReward(
            score: Int(Double(42 + min(combo, 12) * 5) * scoreMultiplier(vehicle: vehicle, wantedLevel: wantedLevel, combo: combo) * vehicle.nearMissMultiplier),
            cash: 2 + min(combo, 10) / 3 + wantedLevel
        )
    }

    public static func finalReward(
        score: Int,
        distance: Double,
        survivalTime: Double,
        runCash: Int,
        nearMisses: Int,
        laneSplits: Int,
        clutchSaves: Int = 0,
        highestWantedLevel: Int,
        highestCombo: Int,
        vehicle: VehicleDefinition,
        level: LevelDefinition?,
        completed: Bool
    ) -> FinalRunReward {
        let scoreCash = score / 120
        let distanceCash = Int(distance) / 180
        let wantedCash = highestWantedLevel * 18
        let nearMissCash = nearMisses * 5
        let laneSplitCash = laneSplits * 7
        let clutchCash = clutchSaves * 22
        let comboCash = highestCombo * 6
        let survivalCash = Int(survivalTime / 6)
        let baseCash = runCash + scoreCash + distanceCash + wantedCash + nearMissCash + laneSplitCash + clutchCash + comboCash + survivalCash
        let economyScale = vehicle.vehicleClass == .motorcycle ? 0.96 : 1.02
        let levelRewardCash = completed ? level?.rewardCash ?? 0 : 0
        let finalCash = max(20, Int(Double(baseCash) * vehicle.cashMultiplier * economyScale) + levelRewardCash)

        let scoreXP = score / 170
        let survivalXP = Int(survivalTime / 3)
        let distanceXP = Int(distance) / 240
        let riskXP = nearMisses * 2 + laneSplits * 4 + clutchSaves * 10
        let heatXP = highestWantedLevel * 18
        let comboXP = highestCombo * 3
        let levelRewardXP = completed ? level?.rewardXP ?? 0 : 0
        let finalXP = max(12, scoreXP + survivalXP + distanceXP + riskXP + heatXP + comboXP + levelRewardXP)

        return FinalRunReward(baseCash: baseCash, cash: finalCash, xp: finalXP)
    }
}
