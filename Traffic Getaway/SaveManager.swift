import Foundation

struct SaveData: Codable {
    var totalCash: Int
    var totalXP: Int
    var playerLevel: Int
    var selectedCarID: String
    var selectedPaintID: String
    var unlockedCarIDs: [String]
    var unlockedPaintIDs: [String]
    var completedMissionIDs: [String]
    var activeMissionIDs: [String]
    var activeMissionProgress: [String: Int]
    var achievementProgress: [String: Int]
    var claimedAchievementRewards: [String]
    var dailyChallengeDate: String
    var dailyChallengeID: String
    var dailyChallengeProgress: Int
    var dailyChallengeCompleted: Bool
    var dailyChallengeClaimed: Bool
    var bestScore: Int
    var bestDistance: Int
    var bestCombo: Int
    var totalNearMisses: Int
    var totalLaneSplits: Int
    var bestLaneSplits: Int
    var motorcycleLevelsCompleted: Int
    var totalClutchSaves: Int
    var totalCrashes: Int
    var totalRuns: Int
    var highestWantedLevelReached: Int
    var totalTimePlayed: TimeInterval
    var lifetimeScore: Int
    var lifetimeCashEarned: Int
    var lifetimeCashSpent: Int
    var highestCityReached: Int
    var hasCompletedOnboarding: Bool
    var screenShakeEnabled: Bool
    var reducedFlashingEnabled: Bool
    var controlPreference: ControlPreference
    var largerHUDTextEnabled: Bool
    var highContrastHUDEnabled: Bool
    var removeAdsOwned: Bool
    var interstitialRunCounter: Int
    var completedLevelIDs: [String]
    var levelBestScores: [String: Int]
    var levelStarRatings: [String: Int]
    var levelBestCombos: [String: Int]
    var levelBestEscapeTimes: [String: TimeInterval]

    init(
        totalCash: Int,
        totalXP: Int,
        playerLevel: Int,
        selectedCarID: String,
        selectedPaintID: String,
        unlockedCarIDs: [String],
        unlockedPaintIDs: [String],
        completedMissionIDs: [String],
        activeMissionIDs: [String],
        activeMissionProgress: [String: Int],
        achievementProgress: [String: Int],
        claimedAchievementRewards: [String],
        dailyChallengeDate: String,
        dailyChallengeID: String,
        dailyChallengeProgress: Int,
        dailyChallengeCompleted: Bool,
        dailyChallengeClaimed: Bool,
        bestScore: Int,
        bestDistance: Int,
        bestCombo: Int,
        totalNearMisses: Int,
        totalLaneSplits: Int,
        bestLaneSplits: Int,
        motorcycleLevelsCompleted: Int,
        totalClutchSaves: Int,
        totalCrashes: Int,
        totalRuns: Int,
        highestWantedLevelReached: Int,
        totalTimePlayed: TimeInterval,
        lifetimeScore: Int,
        lifetimeCashEarned: Int,
        lifetimeCashSpent: Int,
        highestCityReached: Int,
        hasCompletedOnboarding: Bool,
        screenShakeEnabled: Bool,
        reducedFlashingEnabled: Bool,
        controlPreference: ControlPreference,
        largerHUDTextEnabled: Bool,
        highContrastHUDEnabled: Bool,
        removeAdsOwned: Bool,
        interstitialRunCounter: Int,
        completedLevelIDs: [String],
        levelBestScores: [String: Int],
        levelStarRatings: [String: Int],
        levelBestCombos: [String: Int],
        levelBestEscapeTimes: [String: TimeInterval]
    ) {
        self.totalCash = totalCash
        self.totalXP = totalXP
        self.playerLevel = playerLevel
        self.selectedCarID = selectedCarID
        self.selectedPaintID = selectedPaintID
        self.unlockedCarIDs = unlockedCarIDs
        self.unlockedPaintIDs = unlockedPaintIDs
        self.completedMissionIDs = completedMissionIDs
        self.activeMissionIDs = activeMissionIDs
        self.activeMissionProgress = activeMissionProgress
        self.achievementProgress = achievementProgress
        self.claimedAchievementRewards = claimedAchievementRewards
        self.dailyChallengeDate = dailyChallengeDate
        self.dailyChallengeID = dailyChallengeID
        self.dailyChallengeProgress = dailyChallengeProgress
        self.dailyChallengeCompleted = dailyChallengeCompleted
        self.dailyChallengeClaimed = dailyChallengeClaimed
        self.bestScore = bestScore
        self.bestDistance = bestDistance
        self.bestCombo = bestCombo
        self.totalNearMisses = totalNearMisses
        self.totalLaneSplits = totalLaneSplits
        self.bestLaneSplits = bestLaneSplits
        self.motorcycleLevelsCompleted = motorcycleLevelsCompleted
        self.totalClutchSaves = totalClutchSaves
        self.totalCrashes = totalCrashes
        self.totalRuns = totalRuns
        self.highestWantedLevelReached = highestWantedLevelReached
        self.totalTimePlayed = totalTimePlayed
        self.lifetimeScore = lifetimeScore
        self.lifetimeCashEarned = lifetimeCashEarned
        self.lifetimeCashSpent = lifetimeCashSpent
        self.highestCityReached = highestCityReached
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.screenShakeEnabled = screenShakeEnabled
        self.reducedFlashingEnabled = reducedFlashingEnabled
        self.controlPreference = controlPreference
        self.largerHUDTextEnabled = largerHUDTextEnabled
        self.highContrastHUDEnabled = highContrastHUDEnabled
        self.removeAdsOwned = removeAdsOwned
        self.interstitialRunCounter = interstitialRunCounter
        self.completedLevelIDs = completedLevelIDs
        self.levelBestScores = levelBestScores
        self.levelStarRatings = levelStarRatings
        self.levelBestCombos = levelBestCombos
        self.levelBestEscapeTimes = levelBestEscapeTimes
    }

    static func fresh() -> SaveData {
        SaveData(
            totalCash: AppConfig.startingCashForTesting,
            totalXP: 0,
            playerLevel: 1,
            selectedCarID: CarCatalog.starterCarID,
            selectedPaintID: CarCatalog.defaultPaintID,
            unlockedCarIDs: [CarCatalog.starterCarID],
            unlockedPaintIDs: [CarCatalog.defaultPaintID],
            completedMissionIDs: [],
            activeMissionIDs: [],
            activeMissionProgress: [:],
            achievementProgress: [:],
            claimedAchievementRewards: [],
            dailyChallengeDate: "",
            dailyChallengeID: "",
            dailyChallengeProgress: 0,
            dailyChallengeCompleted: false,
            dailyChallengeClaimed: false,
            bestScore: 0,
            bestDistance: 0,
            bestCombo: 0,
            totalNearMisses: 0,
            totalLaneSplits: 0,
            bestLaneSplits: 0,
            motorcycleLevelsCompleted: 0,
            totalClutchSaves: 0,
            totalCrashes: 0,
            totalRuns: 0,
            highestWantedLevelReached: 1,
            totalTimePlayed: 0,
            lifetimeScore: 0,
            lifetimeCashEarned: 0,
            lifetimeCashSpent: 0,
            highestCityReached: 1,
            hasCompletedOnboarding: false,
            screenShakeEnabled: true,
            reducedFlashingEnabled: false,
            controlPreference: .swipeAndTap,
            largerHUDTextEnabled: false,
            highContrastHUDEnabled: false,
            removeAdsOwned: false,
            interstitialRunCounter: 0,
            completedLevelIDs: [],
            levelBestScores: [:],
            levelStarRatings: [:],
            levelBestCombos: [:],
            levelBestEscapeTimes: [:]
        )
    }

    enum CodingKeys: String, CodingKey {
        case totalCash
        case totalXP
        case playerLevel
        case selectedCarID
        case selectedPaintID
        case unlockedCarIDs
        case unlockedPaintIDs
        case completedMissionIDs
        case activeMissionIDs
        case activeMissionProgress
        case achievementProgress
        case claimedAchievementRewards
        case dailyChallengeDate
        case dailyChallengeID
        case dailyChallengeProgress
        case dailyChallengeCompleted
        case dailyChallengeClaimed
        case bestScore
        case bestDistance
        case bestCombo
        case totalNearMisses
        case totalLaneSplits
        case bestLaneSplits
        case motorcycleLevelsCompleted
        case totalClutchSaves
        case totalCrashes
        case totalRuns
        case highestWantedLevelReached
        case totalTimePlayed
        case lifetimeScore
        case lifetimeCashEarned
        case lifetimeCashSpent
        case highestCityReached
        case hasCompletedOnboarding
        case screenShakeEnabled
        case reducedFlashingEnabled
        case controlPreference
        case largerHUDTextEnabled
        case highContrastHUDEnabled
        case removeAdsOwned
        case interstitialRunCounter
        case completedLevelIDs
        case levelBestScores
        case levelStarRatings
        case levelBestCombos
        case levelBestEscapeTimes
    }

    init(from decoder: Decoder) throws {
        let fresh = SaveData.fresh()
        let container = try decoder.container(keyedBy: CodingKeys.self)

        totalCash = try container.decodeIfPresent(Int.self, forKey: .totalCash) ?? fresh.totalCash
        totalXP = try container.decodeIfPresent(Int.self, forKey: .totalXP) ?? fresh.totalXP
        playerLevel = try container.decodeIfPresent(Int.self, forKey: .playerLevel) ?? fresh.playerLevel
        selectedCarID = try container.decodeIfPresent(String.self, forKey: .selectedCarID) ?? fresh.selectedCarID
        selectedPaintID = try container.decodeIfPresent(String.self, forKey: .selectedPaintID) ?? fresh.selectedPaintID
        unlockedCarIDs = try container.decodeIfPresent([String].self, forKey: .unlockedCarIDs) ?? fresh.unlockedCarIDs
        unlockedPaintIDs = try container.decodeIfPresent([String].self, forKey: .unlockedPaintIDs) ?? fresh.unlockedPaintIDs
        completedMissionIDs = try container.decodeIfPresent([String].self, forKey: .completedMissionIDs) ?? fresh.completedMissionIDs
        activeMissionIDs = try container.decodeIfPresent([String].self, forKey: .activeMissionIDs) ?? fresh.activeMissionIDs
        activeMissionProgress = try container.decodeIfPresent([String: Int].self, forKey: .activeMissionProgress) ?? fresh.activeMissionProgress
        achievementProgress = try container.decodeIfPresent([String: Int].self, forKey: .achievementProgress) ?? fresh.achievementProgress
        claimedAchievementRewards = try container.decodeIfPresent([String].self, forKey: .claimedAchievementRewards) ?? fresh.claimedAchievementRewards
        dailyChallengeDate = try container.decodeIfPresent(String.self, forKey: .dailyChallengeDate) ?? fresh.dailyChallengeDate
        dailyChallengeID = try container.decodeIfPresent(String.self, forKey: .dailyChallengeID) ?? fresh.dailyChallengeID
        dailyChallengeProgress = try container.decodeIfPresent(Int.self, forKey: .dailyChallengeProgress) ?? fresh.dailyChallengeProgress
        dailyChallengeCompleted = try container.decodeIfPresent(Bool.self, forKey: .dailyChallengeCompleted) ?? fresh.dailyChallengeCompleted
        dailyChallengeClaimed = try container.decodeIfPresent(Bool.self, forKey: .dailyChallengeClaimed) ?? fresh.dailyChallengeClaimed
        bestScore = try container.decodeIfPresent(Int.self, forKey: .bestScore) ?? fresh.bestScore
        bestDistance = try container.decodeIfPresent(Int.self, forKey: .bestDistance) ?? fresh.bestDistance
        bestCombo = try container.decodeIfPresent(Int.self, forKey: .bestCombo) ?? fresh.bestCombo
        totalNearMisses = try container.decodeIfPresent(Int.self, forKey: .totalNearMisses) ?? fresh.totalNearMisses
        totalLaneSplits = try container.decodeIfPresent(Int.self, forKey: .totalLaneSplits) ?? fresh.totalLaneSplits
        bestLaneSplits = try container.decodeIfPresent(Int.self, forKey: .bestLaneSplits) ?? fresh.bestLaneSplits
        motorcycleLevelsCompleted = try container.decodeIfPresent(Int.self, forKey: .motorcycleLevelsCompleted) ?? fresh.motorcycleLevelsCompleted
        totalClutchSaves = try container.decodeIfPresent(Int.self, forKey: .totalClutchSaves) ?? fresh.totalClutchSaves
        totalCrashes = try container.decodeIfPresent(Int.self, forKey: .totalCrashes) ?? fresh.totalCrashes
        totalRuns = try container.decodeIfPresent(Int.self, forKey: .totalRuns) ?? fresh.totalRuns
        highestWantedLevelReached = try container.decodeIfPresent(Int.self, forKey: .highestWantedLevelReached) ?? fresh.highestWantedLevelReached
        totalTimePlayed = try container.decodeIfPresent(TimeInterval.self, forKey: .totalTimePlayed) ?? fresh.totalTimePlayed
        lifetimeScore = try container.decodeIfPresent(Int.self, forKey: .lifetimeScore) ?? fresh.lifetimeScore
        lifetimeCashEarned = try container.decodeIfPresent(Int.self, forKey: .lifetimeCashEarned) ?? fresh.lifetimeCashEarned
        lifetimeCashSpent = try container.decodeIfPresent(Int.self, forKey: .lifetimeCashSpent) ?? fresh.lifetimeCashSpent
        highestCityReached = try container.decodeIfPresent(Int.self, forKey: .highestCityReached) ?? fresh.highestCityReached
        hasCompletedOnboarding = try container.decodeIfPresent(Bool.self, forKey: .hasCompletedOnboarding) ?? fresh.hasCompletedOnboarding
        screenShakeEnabled = try container.decodeIfPresent(Bool.self, forKey: .screenShakeEnabled) ?? fresh.screenShakeEnabled
        reducedFlashingEnabled = try container.decodeIfPresent(Bool.self, forKey: .reducedFlashingEnabled) ?? fresh.reducedFlashingEnabled
        controlPreference = try container.decodeIfPresent(ControlPreference.self, forKey: .controlPreference) ?? fresh.controlPreference
        largerHUDTextEnabled = try container.decodeIfPresent(Bool.self, forKey: .largerHUDTextEnabled) ?? fresh.largerHUDTextEnabled
        highContrastHUDEnabled = try container.decodeIfPresent(Bool.self, forKey: .highContrastHUDEnabled) ?? fresh.highContrastHUDEnabled
        removeAdsOwned = try container.decodeIfPresent(Bool.self, forKey: .removeAdsOwned) ?? fresh.removeAdsOwned
        interstitialRunCounter = try container.decodeIfPresent(Int.self, forKey: .interstitialRunCounter) ?? fresh.interstitialRunCounter
        completedLevelIDs = try container.decodeIfPresent([String].self, forKey: .completedLevelIDs) ?? fresh.completedLevelIDs
        levelBestScores = try container.decodeIfPresent([String: Int].self, forKey: .levelBestScores) ?? fresh.levelBestScores
        levelStarRatings = try container.decodeIfPresent([String: Int].self, forKey: .levelStarRatings) ?? fresh.levelStarRatings
        levelBestCombos = try container.decodeIfPresent([String: Int].self, forKey: .levelBestCombos) ?? fresh.levelBestCombos
        levelBestEscapeTimes = try container.decodeIfPresent([String: TimeInterval].self, forKey: .levelBestEscapeTimes) ?? fresh.levelBestEscapeTimes
    }
}

struct LevelChange {
    let oldLevel: Int
    let newLevel: Int
    let cashBonus: Int
}

final class SaveManager {
    static let shared = SaveManager()

    private let saveKey = "TrafficGetaway.SaveData.v2"
    private let legacyCashKey = "TrafficGetawayTotalCash"
    private let legacyHighScoreKey = "TrafficGetawayHighScore"

    private(set) var data: SaveData

    private init() {
        if let storedData = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode(SaveData.self, from: storedData) {
            data = decoded
        } else {
            data = SaveData.fresh()
            migrateLegacyValues()
            save()
        }

        sanitize()
    }

    func save() {
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }

    func resetSaveData() {
        data = SaveData.fresh()
        save()
    }

    func mutate(_ block: (inout SaveData) -> Void) {
        block(&data)
        sanitize()
        save()
    }

    func addCash(_ amount: Int) {
        guard amount > 0 else { return }
        mutate { save in
            save.totalCash += amount
            save.lifetimeCashEarned += amount
        }
    }

    func spendCash(_ amount: Int) -> Bool {
        guard amount >= 0, data.totalCash >= amount else { return false }
        mutate { save in
            save.totalCash -= amount
            save.lifetimeCashSpent += amount
        }
        return true
    }

    @discardableResult
    func addXP(_ amount: Int) -> LevelChange? {
        guard amount > 0 else { return nil }
        let oldLevel = data.playerLevel

        mutate { save in
            save.totalXP += amount
            save.playerLevel = SaveManager.level(forTotalXP: save.totalXP)
        }

        guard data.playerLevel > oldLevel else { return nil }
        let bonus = (oldLevel + 1...data.playerLevel).reduce(0) { total, level in
            total + 40 + level * 20
        }
        addCash(bonus)
        return LevelChange(oldLevel: oldLevel, newLevel: data.playerLevel, cashBonus: bonus)
    }

    func unlockCar(_ id: String) {
        mutate { save in
            if !save.unlockedCarIDs.contains(id) {
                save.unlockedCarIDs.append(id)
            }
        }
    }

    func unlockPaint(_ id: String) {
        mutate { save in
            if !save.unlockedPaintIDs.contains(id) {
                save.unlockedPaintIDs.append(id)
            }
        }
    }

    func selectCar(_ id: String) {
        guard data.unlockedCarIDs.contains(id) else { return }
        mutate { save in
            save.selectedCarID = id
        }
    }

    func selectPaint(_ id: String) {
        guard data.unlockedPaintIDs.contains(id) else { return }
        mutate { save in
            save.selectedPaintID = id
        }
    }

    func setOnboardingCompleted(_ completed: Bool) {
        mutate { save in
            save.hasCompletedOnboarding = completed
        }
    }

    func setScreenShakeEnabled(_ enabled: Bool) {
        mutate { save in
            save.screenShakeEnabled = enabled
        }
    }

    func setReducedFlashingEnabled(_ enabled: Bool) {
        mutate { save in
            save.reducedFlashingEnabled = enabled
        }
    }

    func setControlPreference(_ preference: ControlPreference) {
        mutate { save in
            save.controlPreference = preference
        }
    }

    func setLargerHUDTextEnabled(_ enabled: Bool) {
        mutate { save in
            save.largerHUDTextEnabled = enabled
        }
    }

    func setHighContrastHUDEnabled(_ enabled: Bool) {
        mutate { save in
            save.highContrastHUDEnabled = enabled
        }
    }

    func setRemoveAdsOwned(_ owned: Bool) {
        mutate { save in
            save.removeAdsOwned = owned
        }
    }

    func applyDoubleCashBonus(_ amount: Int) {
        addCash(amount)
    }

    func resetMissionProgress() {
        mutate { save in
            save.completedMissionIDs = []
            save.activeMissionIDs = []
            save.activeMissionProgress = [:]
        }
    }

    func resetAchievementProgress() {
        mutate { save in
            save.achievementProgress = [:]
            save.claimedAchievementRewards = []
        }
    }

    func resetDailyChallenge() {
        mutate { save in
            save.dailyChallengeDate = ""
            save.dailyChallengeID = ""
            save.dailyChallengeProgress = 0
            save.dailyChallengeCompleted = false
            save.dailyChallengeClaimed = false
        }
    }

    func unlockAllCarsAndPaints() {
        mutate { save in
            save.unlockedCarIDs = CarCatalog.cars.map(\.id)
            save.unlockedPaintIDs = CarCatalog.paints.map(\.id)
        }
    }

    func lockAllNonStarterCars() {
        mutate { save in
            save.unlockedCarIDs = [CarCatalog.starterCarID]
            save.selectedCarID = CarCatalog.starterCarID
        }
    }

    func incrementInterstitialCounter() {
        mutate { save in
            save.interstitialRunCounter += 1
        }
    }

    func markLevelCompleted(_ levelID: String) {
        mutate { save in
            if !save.completedLevelIDs.contains(levelID) {
                save.completedLevelIDs.append(levelID)
            }
        }
    }

    func isLevelCompleted(_ levelID: String) -> Bool {
        data.completedLevelIDs.contains(levelID)
    }

    func recordLevelResult(levelID: String, score: Int, combo: Int, escapeTime: TimeInterval, stars: Int) {
        mutate { save in
            save.levelBestScores[levelID] = max(save.levelBestScores[levelID] ?? 0, score)
            save.levelBestCombos[levelID] = max(save.levelBestCombos[levelID] ?? 0, combo)
            save.levelStarRatings[levelID] = max(save.levelStarRatings[levelID] ?? 0, max(0, min(3, stars)))
            if let bestTime = save.levelBestEscapeTimes[levelID] {
                save.levelBestEscapeTimes[levelID] = min(bestTime, escapeTime)
            } else {
                save.levelBestEscapeTimes[levelID] = escapeTime
            }
        }
    }

    static func requiredXP(forLevel level: Int) -> Int {
        100 + level * 50
    }

    static func level(forTotalXP totalXP: Int) -> Int {
        var level = 1
        var remaining = max(0, totalXP)

        while remaining >= requiredXP(forLevel: level) {
            remaining -= requiredXP(forLevel: level)
            level += 1
        }

        return level
    }

    static func xpProgress(totalXP: Int, level: Int) -> (current: Int, required: Int) {
        var remaining = max(0, totalXP)
        if level > 1 {
            for completedLevel in 1..<level {
                remaining -= requiredXP(forLevel: completedLevel)
            }
        }
        return (max(0, remaining), requiredXP(forLevel: level))
    }

    private func migrateLegacyValues() {
        let defaults = UserDefaults.standard
        let oldCash = defaults.integer(forKey: legacyCashKey)
        let oldHighScore = defaults.integer(forKey: legacyHighScoreKey)
        data.totalCash = max(data.totalCash, oldCash)
        data.bestScore = max(data.bestScore, oldHighScore)
    }

    private func sanitize() {
        var changed = false

        if !data.unlockedCarIDs.contains(CarCatalog.starterCarID) {
            data.unlockedCarIDs.append(CarCatalog.starterCarID)
            changed = true
        }

        if !data.unlockedPaintIDs.contains(CarCatalog.defaultPaintID) {
            data.unlockedPaintIDs.append(CarCatalog.defaultPaintID)
            changed = true
        }

        if !data.unlockedCarIDs.contains(data.selectedCarID) {
            data.selectedCarID = CarCatalog.starterCarID
            changed = true
        }

        if !data.unlockedPaintIDs.contains(data.selectedPaintID) {
            data.selectedPaintID = CarCatalog.defaultPaintID
            changed = true
        }

        if data.totalCash < 0 {
            data.totalCash = 0
            changed = true
        }

        if data.totalXP < 0 {
            data.totalXP = 0
            changed = true
        }

        if data.totalLaneSplits < 0 {
            data.totalLaneSplits = 0
            changed = true
        }

        if data.bestLaneSplits < 0 {
            data.bestLaneSplits = 0
            changed = true
        }

        if data.motorcycleLevelsCompleted < 0 {
            data.motorcycleLevelsCompleted = 0
            changed = true
        }

        if data.interstitialRunCounter < 0 {
            data.interstitialRunCounter = 0
            changed = true
        }

        let validLevelIDs = Set(LevelCatalog.all.map(\.levelID))
        let filteredLevels = data.completedLevelIDs.filter { validLevelIDs.contains($0) }
        if filteredLevels.count != data.completedLevelIDs.count {
            data.completedLevelIDs = filteredLevels
            changed = true
        }

        let filteredBestScores = data.levelBestScores.filter { validLevelIDs.contains($0.key) }
        let filteredBestCombos = data.levelBestCombos.filter { validLevelIDs.contains($0.key) }
        let filteredStarRatings = data.levelStarRatings
            .filter { validLevelIDs.contains($0.key) }
            .mapValues { max(0, min(3, $0)) }
        let filteredEscapeTimes = data.levelBestEscapeTimes.filter { validLevelIDs.contains($0.key) && $0.value > 0 }
        if filteredBestScores != data.levelBestScores {
            data.levelBestScores = filteredBestScores
            changed = true
        }
        if filteredBestCombos != data.levelBestCombos {
            data.levelBestCombos = filteredBestCombos
            changed = true
        }
        if filteredStarRatings != data.levelStarRatings {
            data.levelStarRatings = filteredStarRatings
            changed = true
        }
        if filteredEscapeTimes != data.levelBestEscapeTimes {
            data.levelBestEscapeTimes = filteredEscapeTimes
            changed = true
        }

        let validCarIDs = Set(CarCatalog.cars.map(\.id))
        let validPaintIDs = Set(CarCatalog.paints.map(\.id))
        let filteredCars = data.unlockedCarIDs.filter { validCarIDs.contains($0) }
        let filteredPaints = data.unlockedPaintIDs.filter { validPaintIDs.contains($0) }
        if filteredCars.count != data.unlockedCarIDs.count {
            data.unlockedCarIDs = filteredCars
            changed = true
        }
        if filteredPaints.count != data.unlockedPaintIDs.count {
            data.unlockedPaintIDs = filteredPaints
            changed = true
        }

        data.playerLevel = SaveManager.level(forTotalXP: data.totalXP)

        if changed {
            save()
        }
    }
}
