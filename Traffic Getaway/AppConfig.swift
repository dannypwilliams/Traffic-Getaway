import Foundation

enum ControlPreference: String, Codable, CaseIterable {
    case swipeAndTap
    case swipeOnly
    case tapOnly

    var displayName: String {
        switch self {
        case .swipeAndTap:
            return "SWIPE + TAP"
        case .swipeOnly:
            return "SWIPE ONLY"
        case .tapOnly:
            return "TAP ONLY"
        }
    }

    var allowsSwipe: Bool {
        self == .swipeAndTap || self == .swipeOnly
    }

    var allowsTap: Bool {
        self == .swipeAndTap || self == .tapOnly
    }

    var next: ControlPreference {
        switch self {
        case .swipeAndTap:
            return .swipeOnly
        case .swipeOnly:
            return .tapOnly
        case .tapOnly:
            return .swipeAndTap
        }
    }
}

enum DebugCityOverride: String, Codable, CaseIterable {
    case automatic
    case newYork
    case losAngeles
    case miami

    var displayName: String {
        switch self {
        case .automatic:
            return "AUTO"
        case .newYork:
            return "NEW YORK"
        case .losAngeles:
            return "LOS ANGELES"
        case .miami:
            return "MIAMI"
        }
    }

    var next: DebugCityOverride {
        switch self {
        case .automatic:
            return .newYork
        case .newYork:
            return .losAngeles
        case .losAngeles:
            return .miami
        case .miami:
            return .automatic
        }
    }
}

enum AppConfig {
    #if DEBUG
    static let debugMode = true
    #else
    static let debugMode = false
    #endif

    static let adsEnabled = false
    static let simulatedPurchasesEnabled = true
    static let analyticsEnabled = true
    static let showDebugMenu = debugMode
    static let startingCashForTesting = 0
    static let forceOnboarding = false
    static let enableInterstitialAds = false
    static let rewardedRevivesEnabled = false
    static let rewardedCashDoublesEnabled = false
    static let liveRunTelemetryEnabled = debugMode

    private enum DefaultsKey {
        static let forcedCity = "TrafficGetaway.debug.forcedCity"
        static let forcedWantedLevel = "TrafficGetaway.debug.forcedWantedLevel"
        static let forcedLevelID = "TrafficGetaway.debug.forcedLevelID"
        static let forceExitEvent = "TrafficGetaway.debug.forceExitEvent"
        static let showTrafficSpawnHeatmap = "TrafficGetaway.debug.showTrafficSpawnHeatmap"
        static let showOpenLaneAnalysis = "TrafficGetaway.debug.showOpenLaneAnalysis"
        static let printRejectedTrafficWaves = "TrafficGetaway.debug.printRejectedTrafficWaves"
        static let debugAutoplay = "TrafficGetaway.debug.autoplay"
        static let showPerformanceOverlay = "TrafficGetaway.debug.performanceOverlay"
        static let autoStartLevelID = "TrafficGetaway.debug.autoStartLevelID"
        static let autoStartVehicleID = "TrafficGetaway.debug.autoStartVehicleID"
    }

    static var forcedCity: DebugCityOverride {
        get {
            let raw = UserDefaults.standard.string(forKey: DefaultsKey.forcedCity) ?? DebugCityOverride.automatic.rawValue
            return DebugCityOverride(rawValue: raw) ?? .automatic
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: DefaultsKey.forcedCity)
        }
    }

    static var forcedWantedLevel: Int {
        get {
            let value = UserDefaults.standard.integer(forKey: DefaultsKey.forcedWantedLevel)
            return value == 0 ? 0 : max(0, min(6, value))
        }
        set {
            UserDefaults.standard.set(max(0, min(6, newValue)), forKey: DefaultsKey.forcedWantedLevel)
        }
    }

    static var forcedLevelID: String {
        get { UserDefaults.standard.string(forKey: DefaultsKey.forcedLevelID) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: DefaultsKey.forcedLevelID) }
    }

    static var forceExitEvent: Bool {
        get { UserDefaults.standard.bool(forKey: DefaultsKey.forceExitEvent) }
        set { UserDefaults.standard.set(newValue, forKey: DefaultsKey.forceExitEvent) }
    }

    static var showTrafficSpawnHeatmap: Bool {
        get { UserDefaults.standard.bool(forKey: DefaultsKey.showTrafficSpawnHeatmap) }
        set { UserDefaults.standard.set(newValue, forKey: DefaultsKey.showTrafficSpawnHeatmap) }
    }

    static var showOpenLaneAnalysis: Bool {
        get { UserDefaults.standard.bool(forKey: DefaultsKey.showOpenLaneAnalysis) }
        set { UserDefaults.standard.set(newValue, forKey: DefaultsKey.showOpenLaneAnalysis) }
    }

    static var printRejectedTrafficWaves: Bool {
        get { UserDefaults.standard.bool(forKey: DefaultsKey.printRejectedTrafficWaves) }
        set { UserDefaults.standard.set(newValue, forKey: DefaultsKey.printRejectedTrafficWaves) }
    }

    static var debugAutoplay: Bool {
        get { UserDefaults.standard.bool(forKey: DefaultsKey.debugAutoplay) }
        set { UserDefaults.standard.set(newValue, forKey: DefaultsKey.debugAutoplay) }
    }

    static var showPerformanceOverlay: Bool {
        get { UserDefaults.standard.bool(forKey: DefaultsKey.showPerformanceOverlay) }
        set { UserDefaults.standard.set(newValue, forKey: DefaultsKey.showPerformanceOverlay) }
    }

    static var debugAutoStartLevelID: String {
        guard debugMode else { return "" }
        return UserDefaults.standard.string(forKey: DefaultsKey.autoStartLevelID) ?? ""
    }

    static var debugAutoStartVehicleID: String {
        guard debugMode else { return "" }
        return UserDefaults.standard.string(forKey: DefaultsKey.autoStartVehicleID) ?? ""
    }

    static func cycleForcedLevel() {
        guard !LevelCatalog.all.isEmpty else { return }
        if forcedLevelID.isEmpty {
            forcedLevelID = LevelCatalog.all[0].levelID
            return
        }
        let currentIndex = LevelCatalog.all.firstIndex { $0.levelID == forcedLevelID } ?? -1
        let nextIndex = currentIndex + 1
        forcedLevelID = LevelCatalog.all.indices.contains(nextIndex) ? LevelCatalog.all[nextIndex].levelID : ""
    }
}
