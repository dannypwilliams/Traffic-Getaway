import SpriteKit

enum WorldThemeID: String, Codable, CaseIterable {
    case losAngeles
    case newYork
    case miami
}

enum WorldRoadStyle {
    case openFreeway
    case urbanExpressway
    case tropicalBoulevard
}

enum WorldLaneStyle {
    case cleanFreeway
    case denseUrban
    case brightCoastal
}

enum WorldShoulderStyle {
    case sunlitConcrete
    case shadowedBarrier
    case pastelWaterfront
}

enum WorldSkylineStyle {
    case laLowRiseCoast
    case newYorkVertical
    case miamiPastelCoast
}

enum WorldRoadsideStyle {
    case losAngeles
    case newYork
    case miami
}

enum WorldPropSet {
    case losAngeles
    case newYork
    case miami
}

enum WorldTrafficFlavor {
    case losAngeles
    case newYork
    case miami
}

enum WorldPoliceFlavor {
    case highwayPatrol
    case urbanUnits
    case miamiPatrol
}

enum WorldSignageStyle {
    case laFreeway
    case nyExpressway
    case miamiBeach
}

enum WorldLightingMood {
    case sunlitCalifornia
    case coolUrbanShadow
    case tropicalNeon
}

struct WorldTheme {
    let id: WorldThemeID
    let displayName: String
    let shortDescription: String
    let palette: ArcadeArt.RoadPalette
    let roadStyle: WorldRoadStyle
    let laneStyle: WorldLaneStyle
    let shoulderStyle: WorldShoulderStyle
    let skylineStyle: WorldSkylineStyle
    let roadsideStyle: WorldRoadsideStyle
    let propSet: WorldPropSet
    let signageStyle: WorldSignageStyle
    let trafficColorSet: [SKColor]
    let policeFlavor: WorldPoliceFlavor
    let lightingMood: WorldLightingMood
    let exitSignStyle: WorldSignageStyle
    let difficultyFlavor: String
    let unlockRequirement: String
    let audioCity: RunCity
    let trafficFlavor: WorldTrafficFlavor
    let trafficSpeedOffset: CGFloat
    let policePressureMultiplier: CGFloat

    var shortName: String {
        displayName
    }

    var stageCode: String {
        switch id {
        case .losAngeles:
            return "LA"
        case .newYork:
            return "NY"
        case .miami:
            return "MIA"
        }
    }

    var tabTitle: String {
        stageCode
    }

    var worldSelectTitle: String {
        "\(stageCode)  \(displayName.uppercased())"
    }

    var atmosphereLine: String {
        shortDescription
    }

    var unlockHint: String {
        unlockRequirement
    }

    var trafficColors: [SKColor] {
        trafficColorSet
    }

    func trafficPool(wantedLevel: Int) -> [VehicleType] {
        var policePressure: [VehicleType] = []
        if wantedLevel >= 4 {
            policePressure.append(.policeMoto)
        }
        if case .miamiPatrol = policeFlavor, wantedLevel >= 5 {
            policePressure.append(.policeMoto)
        }

        switch trafficFlavor {
        case .losAngeles:
            return [.compact, .sedan, .sedan, .sportCoupe, .suv, .pickup, .van, .boxTruck] + policePressure
        case .newYork:
            return [.compact, .compact, .sedan, .sedan, .suv, .van, .boxTruck, .boxTruck] + policePressure
        case .miami:
            return [.sportCoupe, .sportCoupe, .compact, .compact, .sedan, .pickup, .suv, .van] + policePressure
        }
    }

    func paintColor(for type: VehicleType) -> SKColor {
        guard !trafficColorSet.isEmpty else { return ArcadeArt.Palette.asphaltLight }
        let index: Int
        switch type {
        case .compact:
            index = 0
        case .sedan:
            index = 1
        case .suv:
            index = 2
        case .pickup:
            index = 3
        case .van:
            index = 4
        case .boxTruck:
            index = 6
        case .sportCoupe:
            index = 5
        case .policeMoto:
            return policeBodyColor
        }
        return trafficColorSet[index % trafficColorSet.count]
    }

    var policeBodyColor: SKColor {
        switch policeFlavor {
        case .highwayPatrol:
            return SKColor(red: 0.035, green: 0.04, blue: 0.05, alpha: 1)
        case .urbanUnits:
            return SKColor(red: 0.015, green: 0.025, blue: 0.04, alpha: 1)
        case .miamiPatrol:
            return SKColor(red: 0.02, green: 0.045, blue: 0.08, alpha: 1)
        }
    }

    var policeAccentColor: SKColor {
        switch policeFlavor {
        case .highwayPatrol:
            return ArcadeArt.Palette.cream.withAlphaComponent(0.86)
        case .urbanUnits:
            return palette.secondAccent.withAlphaComponent(0.9)
        case .miamiPatrol:
            return palette.accent.withAlphaComponent(0.92)
        }
    }

    func exitSignFill(isEmergency: Bool) -> SKColor {
        if isEmergency {
            return ArcadeArt.Palette.orange.withAlphaComponent(0.94)
        }

        switch exitSignStyle {
        case .laFreeway:
            return SKColor(red: 0.02, green: 0.35, blue: 0.16, alpha: 0.94)
        case .nyExpressway:
            return SKColor(red: 0.03, green: 0.12, blue: 0.2, alpha: 0.96)
        case .miamiBeach:
            return SKColor(red: 0.04, green: 0.42, blue: 0.48, alpha: 0.94)
        }
    }

    func exitSignText(side: ExitSide, isEmergency: Bool) -> String {
        if isEmergency {
            return "ALT \(side.displayName)"
        }

        switch exitSignStyle {
        case .laFreeway:
            return "\(side.displayName) EXIT"
        case .nyExpressway:
            return "\(side.displayName) TUNNEL"
        case .miamiBeach:
            return "\(side.displayName) BEACH"
        }
    }
}

enum WorldThemeCatalog {
    static let all: [WorldTheme] = [
        WorldTheme(
            id: .losAngeles,
            displayName: "Los Angeles",
            shortDescription: "Sunlit California freeway, palms, ocean blue, and warm open lanes.",
            palette: ArcadeArt.RoadPalette(
                background: SKColor(red: 0.58, green: 0.82, blue: 0.96, alpha: 1),
                road: SKColor(red: 0.35, green: 0.36, blue: 0.36, alpha: 1),
                shoulder: SKColor(red: 0.84, green: 0.71, blue: 0.48, alpha: 1),
                laneMarker: ArcadeArt.Palette.cream,
                accent: ArcadeArt.Palette.orange,
                secondAccent: SKColor(red: 0.1, green: 0.63, blue: 0.6, alpha: 1),
                roadTexture: ArcadeArt.Palette.asphaltLight,
                edgeLine: ArcadeArt.Palette.gold,
                panel: ArcadeArt.Palette.navyPanel
            ),
            roadStyle: .openFreeway,
            laneStyle: .cleanFreeway,
            shoulderStyle: .sunlitConcrete,
            skylineStyle: .laLowRiseCoast,
            roadsideStyle: .losAngeles,
            propSet: .losAngeles,
            signageStyle: .laFreeway,
            trafficColorSet: [
                ArcadeArt.Palette.cream,
                SKColor(red: 0.25, green: 0.58, blue: 0.82, alpha: 1),
                SKColor(red: 0.95, green: 0.54, blue: 0.16, alpha: 1),
                SKColor(red: 0.12, green: 0.62, blue: 0.58, alpha: 1),
                SKColor(white: 0.94, alpha: 1),
                SKColor(red: 0.32, green: 0.62, blue: 0.38, alpha: 1),
                SKColor(red: 0.72, green: 0.64, blue: 0.5, alpha: 1)
            ],
            policeFlavor: .highwayPatrol,
            lightingMood: .sunlitCalifornia,
            exitSignStyle: .laFreeway,
            difficultyFlavor: "Starter readable freeway",
            unlockRequirement: "Starter city",
            audioCity: .losAngeles,
            trafficFlavor: .losAngeles,
            trafficSpeedOffset: 0,
            policePressureMultiplier: 0.98
        ),
        WorldTheme(
            id: .newYork,
            displayName: "New York",
            shortDescription: "Cool dense expressway, vertical blocks, taxi color, bridges, and tunnel cues.",
            palette: ArcadeArt.RoadPalette(
                background: SKColor(red: 0.22, green: 0.3, blue: 0.4, alpha: 1),
                road: SKColor(red: 0.22, green: 0.24, blue: 0.27, alpha: 1),
                shoulder: SKColor(red: 0.32, green: 0.34, blue: 0.36, alpha: 1),
                laneMarker: SKColor(red: 0.9, green: 0.88, blue: 0.8, alpha: 1),
                accent: SKColor(red: 1, green: 0.78, blue: 0.08, alpha: 1),
                secondAccent: SKColor(red: 0.26, green: 0.5, blue: 0.68, alpha: 1),
                roadTexture: SKColor(red: 0.42, green: 0.45, blue: 0.48, alpha: 1),
                edgeLine: SKColor(red: 0.78, green: 0.82, blue: 0.84, alpha: 1),
                panel: ArcadeArt.Palette.navyPanelDeep
            ),
            roadStyle: .urbanExpressway,
            laneStyle: .denseUrban,
            shoulderStyle: .shadowedBarrier,
            skylineStyle: .newYorkVertical,
            roadsideStyle: .newYork,
            propSet: .newYork,
            signageStyle: .nyExpressway,
            trafficColorSet: [
                SKColor(red: 1, green: 0.78, blue: 0.08, alpha: 1),
                SKColor(red: 0.03, green: 0.035, blue: 0.045, alpha: 1),
                SKColor(red: 0.28, green: 0.46, blue: 0.58, alpha: 1),
                SKColor(red: 0.48, green: 0.5, blue: 0.52, alpha: 1),
                SKColor(red: 0.86, green: 0.84, blue: 0.76, alpha: 1),
                SKColor(red: 0.56, green: 0.18, blue: 0.14, alpha: 1),
                SKColor(red: 0.42, green: 0.32, blue: 0.22, alpha: 1)
            ],
            policeFlavor: .urbanUnits,
            lightingMood: .coolUrbanShadow,
            exitSignStyle: .nyExpressway,
            difficultyFlavor: "Dense urban pressure",
            unlockRequirement: "Clear Los Angeles routes",
            audioCity: .newYork,
            trafficFlavor: .newYork,
            trafficSpeedOffset: -4,
            policePressureMultiplier: 1.05
        ),
        WorldTheme(
            id: .miami,
            displayName: "Miami",
            shortDescription: "Tropical pastel chase with aqua water, coral signs, palms, and neon accents.",
            palette: ArcadeArt.RoadPalette(
                background: SKColor(red: 0.55, green: 0.88, blue: 0.9, alpha: 1),
                road: SKColor(red: 0.3, green: 0.34, blue: 0.37, alpha: 1),
                shoulder: SKColor(red: 0.86, green: 0.72, blue: 0.52, alpha: 1),
                laneMarker: SKColor(red: 1, green: 0.97, blue: 0.88, alpha: 1),
                accent: SKColor(red: 0.96, green: 0.34, blue: 0.28, alpha: 1),
                secondAccent: SKColor(red: 0.04, green: 0.68, blue: 0.86, alpha: 1),
                roadTexture: ArcadeArt.Palette.asphaltLight,
                edgeLine: SKColor(red: 1, green: 0.82, blue: 0.36, alpha: 1),
                panel: ArcadeArt.Palette.navyPanel
            ),
            roadStyle: .tropicalBoulevard,
            laneStyle: .brightCoastal,
            shoulderStyle: .pastelWaterfront,
            skylineStyle: .miamiPastelCoast,
            roadsideStyle: .miami,
            propSet: .miami,
            signageStyle: .miamiBeach,
            trafficColorSet: [
                SKColor(red: 0.94, green: 0.34, blue: 0.3, alpha: 1),
                SKColor(red: 0.08, green: 0.7, blue: 0.82, alpha: 1),
                SKColor(white: 0.96, alpha: 1),
                SKColor(red: 1, green: 0.82, blue: 0.38, alpha: 1),
                SKColor(red: 0.96, green: 0.42, blue: 0.64, alpha: 1),
                SKColor(red: 0.04, green: 0.58, blue: 0.54, alpha: 1),
                SKColor(red: 0.48, green: 0.86, blue: 0.26, alpha: 1)
            ],
            policeFlavor: .miamiPatrol,
            lightingMood: .tropicalNeon,
            exitSignStyle: .miamiBeach,
            difficultyFlavor: "Fast flashy coastal chaos",
            unlockRequirement: "Clear New York routes",
            audioCity: .miami,
            trafficFlavor: .miami,
            trafficSpeedOffset: 8,
            policePressureMultiplier: 1.03
        )
    ]

    static var defaultTheme: WorldTheme {
        theme(id: .losAngeles)
    }

    static func theme(id: WorldThemeID) -> WorldTheme {
        all.first { $0.id == id } ?? all[0]
    }

    static func theme(for level: LevelDefinition) -> WorldTheme {
        legacyTheme(for: level.city)
    }

    static func legacyTheme(for city: RunCity) -> WorldTheme {
        switch city {
        case .newYork:
            return theme(id: .newYork)
        case .losAngeles:
            return theme(id: .losAngeles)
        case .miami:
            return theme(id: .miami)
        }
    }

    static func legacyTheme(for city: CityTheme) -> WorldTheme {
        legacyTheme(for: city.runCity)
    }

    static func endlessTheme(score: Int) -> WorldTheme {
        let phase = max(0, score) / 1600 % all.count
        return all[phase]
    }

    static func levels(in themeID: WorldThemeID) -> [LevelDefinition] {
        LevelCatalog.all.filter { theme(for: $0).id == themeID }
    }
}

extension LevelDefinition {
    var worldTheme: WorldTheme {
        WorldThemeCatalog.theme(for: self)
    }
}
