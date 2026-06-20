import Foundation

/// Placeholder monetization architecture. It deliberately avoids real ad or IAP SDKs,
/// but keeps the call sites close to production shape for a future integration.
final class MonetizationManager {
    static let shared = MonetizationManager()

    enum RewardedAdType: String {
        case revive
        case doubleCash
        case bonusDailyReward
    }

    enum ProductID: String, CaseIterable {
        case removeAds = "remove_ads"
        case cashSmall = "cash_pack_small"
        case cashMedium = "cash_pack_medium"
        case cashLarge = "cash_pack_large"
        case starterBundle = "starter_bundle"

        var displayName: String {
            switch self {
            case .removeAds:
                return "REMOVE ADS"
            case .cashSmall:
                return "SMALL CASH PACK"
            case .cashMedium:
                return "MEDIUM CASH PACK"
            case .cashLarge:
                return "LARGE CASH PACK"
            case .starterBundle:
                return "STARTER BUNDLE"
            }
        }

        var description: String {
            switch self {
            case .removeAds:
                return "Keeps revives and cash doubles ad-free when ad placements are enabled."
            case .cashSmall:
                return "Adds $1,000 to your garage fund."
            case .cashMedium:
                return "Adds $5,000 for faster car unlocks."
            case .cashLarge:
                return "Adds $15,000 for serious collecting."
            case .starterBundle:
                return "Adds cash, XP, and unlocks Candy Red paint."
            }
        }

        var simulatedCash: Int {
            switch self {
            case .removeAds:
                return 0
            case .cashSmall:
                return 1_000
            case .cashMedium:
                return 5_000
            case .cashLarge:
                return 15_000
            case .starterBundle:
                return 2_500
            }
        }
    }

    enum MonetizationResult {
        case success
        case unavailable
        case alreadyOwned
    }

    private init() {}

    var shouldPromptForRewardedAds: Bool {
        AppConfig.adsEnabled && !isRemoveAdsOwned()
    }

    func showRewardedAd(type: RewardedAdType, completion: @escaping (Bool) -> Void) {
        AnalyticsManager.shared.rewardedAdRequested(type: type)

        let ownsRemoveAds = isRemoveAdsOwned()
        guard AppConfig.adsEnabled || ownsRemoveAds || AppConfig.debugMode else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                AnalyticsManager.shared.rewardedAdCompleted(type: type)
                completion(true)
            }
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            AnalyticsManager.shared.rewardedAdCompleted(type: type)
            completion(true)
        }
    }

    func purchase(productID: ProductID, completion: @escaping (MonetizationResult) -> Void) {
        AnalyticsManager.shared.purchaseAttempted(productID: productID)

        guard AppConfig.simulatedPurchasesEnabled else {
            completion(.unavailable)
            return
        }

        if productID == .removeAds && isRemoveAdsOwned() {
            completion(.alreadyOwned)
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            self.applySimulatedPurchase(productID)
            AnalyticsManager.shared.purchaseCompleted(productID: productID)
            completion(.success)
        }
    }

    func restorePurchases(completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            completion(self.isRemoveAdsOwned())
        }
    }

    func isRemoveAdsOwned() -> Bool {
        SaveManager.shared.data.removeAdsOwned
    }

    private func applySimulatedPurchase(_ productID: ProductID) {
        switch productID {
        case .removeAds:
            SaveManager.shared.setRemoveAdsOwned(true)
        case .cashSmall, .cashMedium, .cashLarge:
            SaveManager.shared.addCash(productID.simulatedCash)
        case .starterBundle:
            SaveManager.shared.addCash(productID.simulatedCash)
            _ = SaveManager.shared.addXP(300)
            SaveManager.shared.unlockPaint("candy_red")
        }
    }
}
