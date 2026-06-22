import Foundation

public struct ProgressionState: Codable, Equatable {
    public var totalCash: Int
    public var totalXP: Int
    public var completedLevelIDs: [String]
    public var unlockedVehicleIDs: [String]

    public init(
        totalCash: Int = 0,
        totalXP: Int = 0,
        completedLevelIDs: [String] = [],
        unlockedVehicleIDs: [String] = [VehicleCatalog.starterCarID]
    ) {
        self.totalCash = totalCash
        self.totalXP = totalXP
        self.completedLevelIDs = completedLevelIDs
        self.unlockedVehicleIDs = unlockedVehicleIDs
    }
}

public struct VehicleUnlockResult: Codable, Equatable {
    public let state: ProgressionState
    public let didUnlock: Bool
    public let reason: String
}

public enum ProgressionModel {
    public static func isLevelUnlocked(_ level: LevelDefinition, state: ProgressionState) -> Bool {
        LevelCatalog.isUnlocked(level, completedIDs: state.completedLevelIDs)
    }

    public static func nextPlayableLevel(state: ProgressionState) -> LevelDefinition {
        LevelCatalog.nextPlayableLevel(completedIDs: state.completedLevelIDs)
    }

    public static func isVehicleUnlocked(_ vehicle: VehicleDefinition, state: ProgressionState) -> Bool {
        vehicle.unlockCost == 0 || state.unlockedVehicleIDs.contains(vehicle.id)
    }

    public static func canUnlockVehicle(_ vehicle: VehicleDefinition, state: ProgressionState) -> Bool {
        !isVehicleUnlocked(vehicle, state: state) && state.totalCash >= vehicle.unlockCost
    }

    public static func unlockVehicle(_ vehicle: VehicleDefinition, state: ProgressionState) -> VehicleUnlockResult {
        if isVehicleUnlocked(vehicle, state: state) {
            return VehicleUnlockResult(state: state, didUnlock: false, reason: "already_unlocked")
        }

        guard state.totalCash >= vehicle.unlockCost else {
            return VehicleUnlockResult(state: state, didUnlock: false, reason: "not_enough_cash")
        }

        var next = state
        next.totalCash -= vehicle.unlockCost
        next.unlockedVehicleIDs.append(vehicle.id)
        return VehicleUnlockResult(state: next, didUnlock: true, reason: "unlocked")
    }

    public static func applyRunReward(_ reward: FinalRunReward, completedLevelID: String?, state: ProgressionState) -> ProgressionState {
        var next = state
        let firstCompletion = completedLevelID.map { !next.completedLevelIDs.contains($0) } ?? false
        next.totalCash += reward.cash
        next.totalXP += reward.xp
        if let completedLevelID, !next.completedLevelIDs.contains(completedLevelID) {
            next.completedLevelIDs.append(completedLevelID)
        }
        if completedLevelID == "la_01",
           firstCompletion,
           !next.unlockedVehicleIDs.contains(VehicleCatalog.starterBikeID) {
            next.unlockedVehicleIDs.append(VehicleCatalog.starterBikeID)
        }
        return next
    }
}
