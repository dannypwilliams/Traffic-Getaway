import Foundation

/// Local analytics facade. Debug builds print structured events; release builds do not send
/// anything off-device until a real provider is intentionally wired in.
final class AnalyticsManager {
    static let shared = AnalyticsManager()

    private init() {}

    func log(_ event: String, parameters: [String: Any] = [:]) {
        guard AppConfig.analyticsEnabled else { return }

        #if DEBUG
        let sortedParameters = parameters
            .sorted { $0.key < $1.key }
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: " ")
        if sortedParameters.isEmpty {
            print("[Analytics] event=\(event)")
        } else {
            print("[Analytics] event=\(event) \(sortedParameters)")
        }
        #endif
    }

    func appLaunched() {
        log("app_launched")
    }

    func onboardingCompleted() {
        log("onboarding_completed")
    }

    func tutorialStarted() {
        log("tutorial_started")
    }

    func tutorialCompleted(skipped: Bool) {
        log(skipped ? "tutorial_skipped" : "tutorial_completed")
    }

    func firstInput(time: TimeInterval) {
        log("first_input", parameters: ["time": String(format: "%.2f", time)])
    }

    func runStarted(carID: String, paintID: String) {
        log("run_started", parameters: [
            "car": carID,
            "paint": paintID
        ])
    }

    func runEnded(_ run: RunStats, cashEarned: Int, xpEarned: Int) {
        log("run_ended", parameters: [
            "score": run.score,
            "distance": run.distance,
            "cash": cashEarned,
            "xp": xpEarned,
            "city": run.cityReached.displayName,
            "wanted": run.wantedLevelReached,
            "near_misses": run.nearMisses,
            "lane_splits": run.laneSplits,
            "clutch_saves": run.clutchSaves,
            "vehicle_class": run.selectedVehicleClass.rawValue
        ])
    }

    func crash(reason: String, score: Int, distance: Int, timeSurvived: TimeInterval = 0) {
        log("crash", parameters: [
            "reason": reason,
            "score": score,
            "distance": distance,
            "time": String(format: "%.1f", timeSurvived)
        ])
    }

    func exitAppeared(levelID: String?, side: ExitSide, emergency: Bool) {
        log("exit_appeared", parameters: ["level": levelID ?? "endless", "side": side.rawValue, "emergency": emergency])
    }

    func exitReached(levelID: String?, time: TimeInterval) {
        log("exit_reached", parameters: ["level": levelID ?? "endless", "time": String(format: "%.1f", time)])
    }

    func exitMissed(levelID: String?, time: TimeInterval) {
        log("exit_missed", parameters: ["level": levelID ?? "endless", "time": String(format: "%.1f", time)])
    }

    func carSelected(id: String) {
        log("car_selected", parameters: ["car": id])
    }

    func carUnlocked(id: String) {
        log("car_unlocked", parameters: ["car": id])
    }

    func missionCompleted(id: String) {
        log("mission_completed", parameters: ["mission": id])
    }

    func achievementUnlocked(id: String) {
        log("achievement_unlocked", parameters: ["achievement": id])
    }

    func dailyCompleted(id: String) {
        log("daily_completed", parameters: ["daily": id])
    }

    func rewardedAdRequested(type: MonetizationManager.RewardedAdType) {
        log("rewarded_ad_requested", parameters: ["type": type.rawValue])
    }

    func rewardedAdCompleted(type: MonetizationManager.RewardedAdType) {
        log("rewarded_ad_completed", parameters: ["type": type.rawValue])
    }

    func purchaseAttempted(productID: MonetizationManager.ProductID) {
        log("purchase_attempted", parameters: ["product": productID.rawValue])
    }

    func purchaseCompleted(productID: MonetizationManager.ProductID) {
        log("purchase_completed", parameters: ["product": productID.rawValue])
    }
}
