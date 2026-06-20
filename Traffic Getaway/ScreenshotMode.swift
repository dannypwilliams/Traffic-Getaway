import Foundation

enum ScreenshotWeather: String, Codable, CaseIterable {
    case automatic
    case clear
    case rain
    case heavyRain
    case fog
    case nightStorm

    var displayName: String {
        switch self {
        case .automatic:
            return "AUTO"
        case .clear:
            return "CLEAR"
        case .rain:
            return "RAIN"
        case .heavyRain:
            return "HEAVY"
        case .fog:
            return "FOG"
        case .nightStorm:
            return "STORM"
        }
    }

    var next: ScreenshotWeather {
        switch self {
        case .automatic:
            return .clear
        case .clear:
            return .rain
        case .rain:
            return .heavyRain
        case .heavyRain:
            return .fog
        case .fog:
            return .nightStorm
        case .nightStorm:
            return .automatic
        }
    }
}

struct ScreenshotModeState {
    var enabled: Bool
    var hideHUD: Bool
    var forcedCombo: Int
    var showcaseTraffic: Bool
    var weather: ScreenshotWeather
}

final class ScreenshotMode {
    static let shared = ScreenshotMode()

    private enum Key {
        static let enabled = "TrafficGetaway.screenshot.enabled"
        static let hideHUD = "TrafficGetaway.screenshot.hideHUD"
        static let forcedCombo = "TrafficGetaway.screenshot.combo"
        static let showcaseTraffic = "TrafficGetaway.screenshot.showcaseTraffic"
        static let weather = "TrafficGetaway.screenshot.weather"
    }

    private init() {}

    var state: ScreenshotModeState {
        let defaults = UserDefaults.standard
        return ScreenshotModeState(
            enabled: defaults.bool(forKey: Key.enabled),
            hideHUD: defaults.bool(forKey: Key.hideHUD),
            forcedCombo: max(0, min(20, defaults.integer(forKey: Key.forcedCombo))),
            showcaseTraffic: defaults.object(forKey: Key.showcaseTraffic) as? Bool ?? true,
            weather: ScreenshotWeather(rawValue: defaults.string(forKey: Key.weather) ?? ScreenshotWeather.automatic.rawValue) ?? .automatic
        )
    }

    func setEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: Key.enabled)
    }

    func toggleHideHUD() {
        UserDefaults.standard.set(!state.hideHUD, forKey: Key.hideHUD)
    }

    func cycleCombo() {
        let next = state.forcedCombo >= 10 ? 0 : state.forcedCombo + 5
        UserDefaults.standard.set(next, forKey: Key.forcedCombo)
    }

    func toggleShowcaseTraffic() {
        UserDefaults.standard.set(!state.showcaseTraffic, forKey: Key.showcaseTraffic)
    }

    func cycleWeather() {
        UserDefaults.standard.set(state.weather.next.rawValue, forKey: Key.weather)
    }
}
