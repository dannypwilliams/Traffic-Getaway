import Foundation

struct ReleaseReadinessIssue {
    let title: String
    let detail: String
}

struct ReleaseReadinessReport {
    let issues: [ReleaseReadinessIssue]

    var isReady: Bool {
        issues.isEmpty
    }

    var summary: String {
        isReady ? "Release checks passed" : "\(issues.count) release issue\(issues.count == 1 ? "" : "s") found"
    }
}

final class ReleaseReadinessManager {
    static let shared = ReleaseReadinessManager()

    private init() {}

    func runChecks() -> ReleaseReadinessReport {
        var issues: [ReleaseReadinessIssue] = []
        let save = SaveManager.shared.data

        if !save.unlockedCarIDs.contains(CarCatalog.starterCarID) {
            issues.append(ReleaseReadinessIssue(title: "Starter car locked", detail: "Starter Compact must always be unlocked."))
        }

        if !save.unlockedPaintIDs.contains(CarCatalog.defaultPaintID) {
            issues.append(ReleaseReadinessIssue(title: "Default paint locked", detail: "Default paint must always be unlocked."))
        }

        if !save.unlockedCarIDs.contains(save.selectedCarID) {
            issues.append(ReleaseReadinessIssue(title: "Invalid selected car", detail: "\(save.selectedCarID) is selected but not unlocked."))
        }

        if !save.unlockedPaintIDs.contains(save.selectedPaintID) {
            issues.append(ReleaseReadinessIssue(title: "Invalid selected paint", detail: "\(save.selectedPaintID) is selected but not unlocked."))
        }

        if DailyChallengeManager.shared.currentCard().definition.id.isEmpty {
            issues.append(ReleaseReadinessIssue(title: "Missing daily challenge", detail: "Daily challenge definition could not be resolved."))
        }

        if MissionManager.shared.definitions.count < 3 {
            issues.append(ReleaseReadinessIssue(title: "Mission pool too small", detail: "At least three missions are required."))
        }

        if MissionManager.shared.activeMissionCards().isEmpty {
            issues.append(ReleaseReadinessIssue(title: "No active missions", detail: "MissionManager could not create active missions."))
        }

        if AchievementManager.shared.definitions.isEmpty {
            issues.append(ReleaseReadinessIssue(title: "Missing achievements", detail: "Achievement pool is empty."))
        }

        if save.totalCash < 0 || save.totalXP < 0 {
            issues.append(ReleaseReadinessIssue(title: "Negative save values", detail: "Cash and XP must never be negative."))
        }

        if AppConfig.adsEnabled || AppConfig.enableInterstitialAds {
            issues.append(ReleaseReadinessIssue(title: "Ads enabled", detail: "Ads should stay disabled until real ad placements and privacy disclosures are ready."))
        }

        return ReleaseReadinessReport(issues: issues)
    }

    func repairSafeIssues() {
        SaveManager.shared.mutate { save in
            if !save.unlockedCarIDs.contains(CarCatalog.starterCarID) {
                save.unlockedCarIDs.append(CarCatalog.starterCarID)
            }
            if !save.unlockedPaintIDs.contains(CarCatalog.defaultPaintID) {
                save.unlockedPaintIDs.append(CarCatalog.defaultPaintID)
            }
            if !save.unlockedCarIDs.contains(save.selectedCarID) {
                save.selectedCarID = CarCatalog.starterCarID
            }
            if !save.unlockedPaintIDs.contains(save.selectedPaintID) {
                save.selectedPaintID = CarCatalog.defaultPaintID
            }
            save.totalCash = max(0, save.totalCash)
            save.totalXP = max(0, save.totalXP)
        }
        MissionManager.shared.ensureActiveMissions()
        _ = DailyChallengeManager.shared.currentCard()
        _ = AchievementManager.shared.updateStoredProgress()
    }
}
