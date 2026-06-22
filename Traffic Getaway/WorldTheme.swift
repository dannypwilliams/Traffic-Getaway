import SpriteKit

enum WorldThemeID: String, Codable, CaseIterable {
    case sunsetCoastFreeway
    case downtownHeat
    case canyonRun
    case desertStraightaway
    case nightTunnelChase
    case boardwalkBlitz
}

enum WorldRoadStyle {
    case openFreeway
    case downtownGrid
    case canyonPass
    case desertRun
    case tunnel
    case boardwalk
}

enum WorldRoadsideStyle {
    case coast
    case downtown
    case canyon
    case desert
    case tunnel
    case beach
}

enum WorldPropSet {
    case palmsAndSigns
    case towersAndSteam
    case cliffsAndWarningSigns
    case cactusAndBarriers
    case tunnelFans
    case beachBarsAndPalms
}

enum WorldTrafficFlavor {
    case commuter
    case denseUrban
    case scenicMixed
    case longHaul
    case nightMetro
    case beachSport
}

enum WorldPoliceFlavor {
    case highwayPatrol
    case cityUnits
    case canyonIntercept
    case desertPursuit
    case tunnelTaskForce
    case boardwalkBikes
}

enum WorldSignageStyle {
    case greenFreeway
    case amberDowntown
    case canyonMarker
    case desertMarker
    case tunnelArrow
    case beachNeon
}

struct WorldTheme {
    let id: WorldThemeID
    let displayName: String
    let shortName: String
    let stageCode: String
    let atmosphereLine: String
    let audioCity: RunCity
    let palette: ArcadeArt.RoadPalette
    let roadStyle: WorldRoadStyle
    let roadsideStyle: WorldRoadsideStyle
    let propSet: WorldPropSet
    let trafficFlavor: WorldTrafficFlavor
    let policeFlavor: WorldPoliceFlavor
    let signageStyle: WorldSignageStyle
    let trafficColors: [SKColor]
    let trafficSpeedOffset: CGFloat
    let policePressureMultiplier: CGFloat
    let unlockHint: String

    var tabTitle: String {
        stageCode
    }

    var worldSelectTitle: String {
        "\(stageCode)  \(shortName.uppercased())"
    }

    func trafficPool(wantedLevel: Int) -> [VehicleType] {
        let policePressure: [VehicleType] = wantedLevel >= 4 ? [.policeMoto] : []
        switch trafficFlavor {
        case .commuter:
            return [.compact, .compact, .sedan, .sedan, .suv, .pickup, .van, .boxTruck] + policePressure
        case .denseUrban:
            return [.compact, .compact, .sedan, .sedan, .sedan, .suv, .van, .boxTruck] + policePressure
        case .scenicMixed:
            return [.sedan, .sportCoupe, .compact, .suv, .pickup, .pickup, .van, .boxTruck] + policePressure
        case .longHaul:
            return [.pickup, .pickup, .suv, .van, .boxTruck, .boxTruck, .sedan, .sportCoupe] + policePressure
        case .nightMetro:
            return [.sportCoupe, .compact, .sedan, .suv, .van, .van, .boxTruck] + policePressure
        case .beachSport:
            return [.sportCoupe, .sportCoupe, .compact, .sedan, .pickup, .suv, .van, .boxTruck] + policePressure
        }
    }

    func paintColor(for type: VehicleType) -> SKColor {
        guard !trafficColors.isEmpty else { return ArcadeArt.Palette.asphaltLight }
        let index: Int
        switch type {
        case .sedan:
            index = 0
        case .compact:
            index = 1
        case .suv:
            index = 2
        case .pickup:
            index = 0
        case .van:
            return SKColor(red: 0.8, green: 0.76, blue: 0.66, alpha: 1)
        case .boxTruck:
            return SKColor(red: 0.58, green: 0.62, blue: 0.64, alpha: 1)
        case .sportCoupe:
            return palette.accent
        case .policeMoto:
            return SKColor(white: 0.06, alpha: 1)
        }
        return trafficColors[index % trafficColors.count]
    }

    func exitSignFill(isEmergency: Bool) -> SKColor {
        if isEmergency {
            return ArcadeArt.Palette.orange.withAlphaComponent(0.94)
        }

        switch signageStyle {
        case .greenFreeway:
            return SKColor(red: 0.02, green: 0.35, blue: 0.16, alpha: 0.94)
        case .amberDowntown:
            return SKColor(red: 0.44, green: 0.24, blue: 0.04, alpha: 0.94)
        case .canyonMarker:
            return SKColor(red: 0.48, green: 0.3, blue: 0.1, alpha: 0.94)
        case .desertMarker:
            return SKColor(red: 0.62, green: 0.42, blue: 0.16, alpha: 0.94)
        case .tunnelArrow:
            return SKColor(red: 0.03, green: 0.11, blue: 0.18, alpha: 0.96)
        case .beachNeon:
            return SKColor(red: 0.02, green: 0.36, blue: 0.42, alpha: 0.94)
        }
    }

    func exitSignText(side: ExitSide, isEmergency: Bool) -> String {
        if isEmergency {
            return "ALT \(side.displayName)"
        }

        switch signageStyle {
        case .greenFreeway:
            return "\(side.displayName) EXIT"
        case .amberDowntown:
            return "\(side.displayName) CUT"
        case .canyonMarker:
            return "\(side.displayName) PASS"
        case .desertMarker:
            return "\(side.displayName) OFFRAMP"
        case .tunnelArrow:
            return "\(side.displayName) TUNNEL"
        case .beachNeon:
            return "\(side.displayName) BLITZ"
        }
    }
}

enum WorldThemeCatalog {
    static let all: [WorldTheme] = [
        WorldTheme(
            id: .sunsetCoastFreeway,
            displayName: "Sunset Coast Freeway",
            shortName: "Sunset Coast",
            stageCode: "W1",
            atmosphereLine: "Warm ocean air, broad lanes, gold edge lights.",
            audioCity: .losAngeles,
            palette: ArcadeArt.RoadPalette(
                background: SKColor(red: 0.64, green: 0.84, blue: 0.94, alpha: 1),
                road: SKColor(red: 0.34, green: 0.35, blue: 0.36, alpha: 1),
                shoulder: SKColor(red: 0.78, green: 0.66, blue: 0.43, alpha: 1),
                laneMarker: ArcadeArt.Palette.cream,
                accent: ArcadeArt.Palette.orange,
                secondAccent: SKColor(red: 0.1, green: 0.63, blue: 0.6, alpha: 1),
                roadTexture: ArcadeArt.Palette.asphaltLight,
                edgeLine: ArcadeArt.Palette.gold,
                panel: ArcadeArt.Palette.navyPanel
            ),
            roadStyle: .openFreeway,
            roadsideStyle: .coast,
            propSet: .palmsAndSigns,
            trafficFlavor: .commuter,
            policeFlavor: .highwayPatrol,
            signageStyle: .greenFreeway,
            trafficColors: [
                SKColor(red: 0.18, green: 0.52, blue: 0.82, alpha: 1),
                SKColor(red: 0.96, green: 0.58, blue: 0.16, alpha: 1),
                SKColor(red: 0.24, green: 0.66, blue: 0.42, alpha: 1)
            ],
            trafficSpeedOffset: 0,
            policePressureMultiplier: 0.98,
            unlockHint: "Opening route"
        ),
        WorldTheme(
            id: .downtownHeat,
            displayName: "Downtown Heat",
            shortName: "Downtown",
            stageCode: "W2",
            atmosphereLine: "Tight city shoulders, warm windows, short escape reads.",
            audioCity: .newYork,
            palette: ArcadeArt.RoadPalette(
                background: SKColor(red: 0.46, green: 0.62, blue: 0.74, alpha: 1),
                road: SKColor(red: 0.25, green: 0.27, blue: 0.3, alpha: 1),
                shoulder: SKColor(red: 0.29, green: 0.31, blue: 0.34, alpha: 1),
                laneMarker: ArcadeArt.Palette.cream,
                accent: ArcadeArt.Palette.gold,
                secondAccent: SKColor(red: 0.15, green: 0.58, blue: 0.82, alpha: 1),
                roadTexture: SKColor(red: 0.48, green: 0.5, blue: 0.52, alpha: 1),
                edgeLine: ArcadeArt.Palette.gold,
                panel: ArcadeArt.Palette.navyPanel
            ),
            roadStyle: .downtownGrid,
            roadsideStyle: .downtown,
            propSet: .towersAndSteam,
            trafficFlavor: .denseUrban,
            policeFlavor: .cityUnits,
            signageStyle: .amberDowntown,
            trafficColors: [
                SKColor(red: 0.36, green: 0.45, blue: 0.52, alpha: 1),
                SKColor(red: 0.72, green: 0.68, blue: 0.58, alpha: 1),
                SKColor(red: 0.54, green: 0.35, blue: 0.32, alpha: 1)
            ],
            trafficSpeedOffset: -4,
            policePressureMultiplier: 1.02,
            unlockHint: "Clear W1 routes"
        ),
        WorldTheme(
            id: .canyonRun,
            displayName: "Canyon Run",
            shortName: "Canyon",
            stageCode: "W3",
            atmosphereLine: "Narrow sunlit cuts, warning markers, dusty patrol pressure.",
            audioCity: .losAngeles,
            palette: ArcadeArt.RoadPalette(
                background: SKColor(red: 0.77, green: 0.8, blue: 0.75, alpha: 1),
                road: SKColor(red: 0.31, green: 0.32, blue: 0.31, alpha: 1),
                shoulder: SKColor(red: 0.5, green: 0.35, blue: 0.2, alpha: 1),
                laneMarker: SKColor(red: 0.98, green: 0.9, blue: 0.64, alpha: 1),
                accent: SKColor(red: 0.92, green: 0.46, blue: 0.16, alpha: 1),
                secondAccent: SKColor(red: 0.14, green: 0.56, blue: 0.52, alpha: 1),
                roadTexture: SKColor(red: 0.5, green: 0.5, blue: 0.46, alpha: 1),
                edgeLine: SKColor(red: 0.96, green: 0.7, blue: 0.24, alpha: 1),
                panel: ArcadeArt.Palette.navyPanel
            ),
            roadStyle: .canyonPass,
            roadsideStyle: .canyon,
            propSet: .cliffsAndWarningSigns,
            trafficFlavor: .scenicMixed,
            policeFlavor: .canyonIntercept,
            signageStyle: .canyonMarker,
            trafficColors: [
                SKColor(red: 0.18, green: 0.44, blue: 0.56, alpha: 1),
                SKColor(red: 0.7, green: 0.38, blue: 0.18, alpha: 1),
                SKColor(red: 0.42, green: 0.48, blue: 0.36, alpha: 1)
            ],
            trafficSpeedOffset: 4,
            policePressureMultiplier: 1.04,
            unlockHint: "Clear W2 routes"
        ),
        WorldTheme(
            id: .desertStraightaway,
            displayName: "Desert Straightaway",
            shortName: "Desert",
            stageCode: "W4",
            atmosphereLine: "Long exposed asphalt, heat haze, heavier highway traffic.",
            audioCity: .losAngeles,
            palette: ArcadeArt.RoadPalette(
                background: SKColor(red: 0.86, green: 0.75, blue: 0.55, alpha: 1),
                road: SKColor(red: 0.36, green: 0.34, blue: 0.31, alpha: 1),
                shoulder: SKColor(red: 0.74, green: 0.54, blue: 0.28, alpha: 1),
                laneMarker: SKColor(red: 1, green: 0.92, blue: 0.68, alpha: 1),
                accent: SKColor(red: 0.92, green: 0.36, blue: 0.12, alpha: 1),
                secondAccent: SKColor(red: 0.17, green: 0.52, blue: 0.6, alpha: 1),
                roadTexture: SKColor(red: 0.58, green: 0.54, blue: 0.48, alpha: 1),
                edgeLine: SKColor(red: 0.98, green: 0.75, blue: 0.28, alpha: 1),
                panel: ArcadeArt.Palette.navyPanel
            ),
            roadStyle: .desertRun,
            roadsideStyle: .desert,
            propSet: .cactusAndBarriers,
            trafficFlavor: .longHaul,
            policeFlavor: .desertPursuit,
            signageStyle: .desertMarker,
            trafficColors: [
                SKColor(red: 0.7, green: 0.46, blue: 0.22, alpha: 1),
                SKColor(red: 0.2, green: 0.45, blue: 0.58, alpha: 1),
                SKColor(red: 0.62, green: 0.62, blue: 0.52, alpha: 1)
            ],
            trafficSpeedOffset: 8,
            policePressureMultiplier: 1.06,
            unlockHint: "Clear W3 routes"
        ),
        WorldTheme(
            id: .nightTunnelChase,
            displayName: "Night Tunnel Chase",
            shortName: "Night Tunnel",
            stageCode: "W5",
            atmosphereLine: "Dark tunnel walls, blue guide lights, sharp exit arrows.",
            audioCity: .newYork,
            palette: ArcadeArt.RoadPalette(
                background: SKColor(red: 0.03, green: 0.05, blue: 0.08, alpha: 1),
                road: SKColor(red: 0.16, green: 0.18, blue: 0.22, alpha: 1),
                shoulder: SKColor(red: 0.08, green: 0.1, blue: 0.14, alpha: 1),
                laneMarker: SKColor(red: 0.74, green: 0.86, blue: 1, alpha: 1),
                accent: SKColor(red: 0.22, green: 0.66, blue: 1, alpha: 1),
                secondAccent: SKColor(red: 1, green: 0.38, blue: 0.16, alpha: 1),
                roadTexture: SKColor(red: 0.34, green: 0.38, blue: 0.44, alpha: 1),
                edgeLine: SKColor(red: 0.28, green: 0.72, blue: 1, alpha: 1),
                panel: ArcadeArt.Palette.navyPanelDeep
            ),
            roadStyle: .tunnel,
            roadsideStyle: .tunnel,
            propSet: .tunnelFans,
            trafficFlavor: .nightMetro,
            policeFlavor: .tunnelTaskForce,
            signageStyle: .tunnelArrow,
            trafficColors: [
                SKColor(red: 0.1, green: 0.22, blue: 0.36, alpha: 1),
                SKColor(red: 0.42, green: 0.48, blue: 0.58, alpha: 1),
                SKColor(red: 0.58, green: 0.3, blue: 0.2, alpha: 1)
            ],
            trafficSpeedOffset: 6,
            policePressureMultiplier: 1.08,
            unlockHint: "Clear W4 routes"
        ),
        WorldTheme(
            id: .boardwalkBlitz,
            displayName: "Boardwalk Blitz",
            shortName: "Boardwalk",
            stageCode: "W6",
            atmosphereLine: "Beachfront neon, palm silhouettes, fast bright traffic.",
            audioCity: .miami,
            palette: ArcadeArt.RoadPalette(
                background: SKColor(red: 0.53, green: 0.86, blue: 0.9, alpha: 1),
                road: SKColor(red: 0.3, green: 0.34, blue: 0.37, alpha: 1),
                shoulder: SKColor(red: 0.76, green: 0.67, blue: 0.47, alpha: 1),
                laneMarker: ArcadeArt.Palette.cream,
                accent: SKColor(red: 0.98, green: 0.48, blue: 0.16, alpha: 1),
                secondAccent: SKColor(red: 0.04, green: 0.68, blue: 0.86, alpha: 1),
                roadTexture: ArcadeArt.Palette.asphaltLight,
                edgeLine: SKColor(red: 1.0, green: 0.82, blue: 0.3, alpha: 1),
                panel: ArcadeArt.Palette.navyPanel
            ),
            roadStyle: .boardwalk,
            roadsideStyle: .beach,
            propSet: .beachBarsAndPalms,
            trafficFlavor: .beachSport,
            policeFlavor: .boardwalkBikes,
            signageStyle: .beachNeon,
            trafficColors: [
                SKColor(red: 0.92, green: 0.22, blue: 0.48, alpha: 1),
                SKColor(red: 0.12, green: 0.55, blue: 0.86, alpha: 1),
                SKColor(red: 0.98, green: 0.62, blue: 0.14, alpha: 1)
            ],
            trafficSpeedOffset: 12,
            policePressureMultiplier: 1.05,
            unlockHint: "Clear W5 routes"
        )
    ]

    static var defaultTheme: WorldTheme {
        theme(id: .sunsetCoastFreeway)
    }

    static func theme(id: WorldThemeID) -> WorldTheme {
        all.first { $0.id == id } ?? all[0]
    }

    static func theme(for level: LevelDefinition) -> WorldTheme {
        let id = levelThemeIDs[level.levelID] ?? legacyThemeID(for: level.city)
        return theme(id: id)
    }

    static func legacyTheme(for city: RunCity) -> WorldTheme {
        theme(id: legacyThemeID(for: city))
    }

    static func legacyTheme(for city: CityTheme) -> WorldTheme {
        legacyTheme(for: city.runCity)
    }

    static func endlessTheme(score: Int) -> WorldTheme {
        switch score {
        case 5000...:
            return theme(id: .boardwalkBlitz)
        case 4000..<5000:
            return theme(id: .nightTunnelChase)
        case 3000..<4000:
            return theme(id: .desertStraightaway)
        case 2000..<3000:
            return theme(id: .canyonRun)
        case 1000..<2000:
            return theme(id: .downtownHeat)
        default:
            return defaultTheme
        }
    }

    static func levels(in themeID: WorldThemeID) -> [LevelDefinition] {
        LevelCatalog.all.filter { theme(for: $0).id == themeID }
    }

    private static let levelThemeIDs: [String: WorldThemeID] = [
        "ny_01": .sunsetCoastFreeway,
        "ny_02": .downtownHeat,
        "ny_03": .downtownHeat,
        "ny_04": .canyonRun,
        "ny_05": .nightTunnelChase,
        "la_01": .sunsetCoastFreeway,
        "la_02": .downtownHeat,
        "la_03": .canyonRun,
        "la_04": .desertStraightaway,
        "la_05": .desertStraightaway,
        "mia_01": .boardwalkBlitz,
        "mia_02": .boardwalkBlitz,
        "mia_03": .nightTunnelChase,
        "mia_04": .nightTunnelChase,
        "mia_05": .boardwalkBlitz
    ]

    private static func legacyThemeID(for city: RunCity) -> WorldThemeID {
        switch city {
        case .newYork:
            return .downtownHeat
        case .losAngeles:
            return .sunsetCoastFreeway
        case .miami:
            return .boardwalkBlitz
        }
    }
}

extension LevelDefinition {
    var worldTheme: WorldTheme {
        WorldThemeCatalog.theme(for: self)
    }
}
