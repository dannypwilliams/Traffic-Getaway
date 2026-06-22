import SpriteKit

struct VehicleArtDefinition {
    let gameplaySpriteName: String
    let garageSpriteName: String
    let damagedSpriteName: String
    let headlightSpriteName: String
    let brakeLightSpriteName: String
    let boostGlowSpriteName: String
    let shadowSpriteName: String
    let rarityFrameSpriteName: String
    let fallbackPrimary: SKColor
    let fallbackAccent: SKColor
}

struct CityArtDefinition {
    let roadSurfaceSpriteName: String
    let edgeDecorationSpriteName: String
    let propSpriteNames: [String]
    let lightingAccent: SKColor
    let reflectionAccent: SKColor
}

enum EffectArtSlot: String, CaseIterable {
    case nearMissSpark
    case laneSplitSpark
    case tireSkid
    case boostTrail
    case policeSirenGlow
    case impactBurst
    case cashPickupBurst
    case xpBurst
    case exitRampGlow
    case headlightCone
    case helicopterSpotlight
    case roadSpeedStreak

    var spriteName: String {
        switch self {
        case .nearMissSpark:
            return "fx_near_miss_spark"
        case .laneSplitSpark:
            return "fx_lane_split_spark"
        case .tireSkid:
            return "fx_tire_skid"
        case .boostTrail:
            return "fx_boost_trail"
        case .policeSirenGlow:
            return "fx_police_siren_glow"
        case .impactBurst:
            return "fx_impact_burst"
        case .cashPickupBurst:
            return "fx_cash_pickup_burst"
        case .xpBurst:
            return "fx_xp_burst"
        case .exitRampGlow:
            return "fx_exit_ramp_glow"
        case .headlightCone:
            return "fx_headlight_cone"
        case .helicopterSpotlight:
            return "fx_helicopter_spotlight"
        case .roadSpeedStreak:
            return "fx_road_speed_streak"
        }
    }
}

enum VehicleArtCatalog {
    static func art(for vehicleID: String) -> VehicleArtDefinition {
        vehicleArt[vehicleID] ?? vehicleArt["starter_compact"]!
    }

    static func cityArt(for city: RunCity) -> CityArtDefinition {
        cityArt[city] ?? cityArt[.newYork]!
    }

    static func effectSpriteName(for slot: EffectArtSlot) -> String {
        slot.spriteName
    }

    static let customVehicleAssetIDs = [
        "starter_compact",
        "taxi_burner",
        "police_interceptor",
        "sports_coupe",
        "muscle_car",
        "delivery_van",
        "box_truck",
        "semi_truck",
        "motorcycle_lane_splitter",
        "police_bike",
        "civilian_sedan",
        "suv",
        "bus",
        "armored_van"
    ]

    private static let vehicleArt: [String: VehicleArtDefinition] = [
        "starter_compact": makeVehicle(prefix: "vehicle_starter_compact", primary: SKColor(red: 0.92, green: 0.05, blue: 0.08, alpha: 1), accent: SKColor(red: 1, green: 0.86, blue: 0.2, alpha: 1)),
        "yellow_cab": makeVehicle(prefix: "vehicle_taxi_burner", primary: SKColor(red: 1, green: 0.82, blue: 0.02, alpha: 1), accent: .black),
        "taxi_burner": makeVehicle(prefix: "vehicle_taxi_burner", primary: SKColor(red: 1, green: 0.82, blue: 0.02, alpha: 1), accent: .black),
        "police_interceptor": makeVehicle(prefix: "vehicle_police_interceptor", primary: SKColor(white: 0.05, alpha: 1), accent: SKColor(red: 0.18, green: 0.55, blue: 1, alpha: 1)),
        "sunset_coupe": makeVehicle(prefix: "vehicle_sports_coupe", primary: SKColor(red: 1, green: 0.42, blue: 0.14, alpha: 1), accent: SKColor(red: 0.7, green: 0.16, blue: 1, alpha: 1)),
        "sports_coupe": makeVehicle(prefix: "vehicle_sports_coupe", primary: SKColor(red: 1, green: 0.42, blue: 0.14, alpha: 1), accent: SKColor(red: 0.7, green: 0.16, blue: 1, alpha: 1)),
        "muscle_v8": makeVehicle(prefix: "vehicle_muscle_car", primary: SKColor(red: 0.12, green: 0.13, blue: 0.16, alpha: 1), accent: SKColor(red: 1, green: 0.2, blue: 0.05, alpha: 1)),
        "muscle_car": makeVehicle(prefix: "vehicle_muscle_car", primary: SKColor(red: 0.12, green: 0.13, blue: 0.16, alpha: 1), accent: SKColor(red: 1, green: 0.2, blue: 0.05, alpha: 1)),
        "delivery_van": makeVehicle(prefix: "vehicle_delivery_van", primary: SKColor(red: 0.78, green: 0.82, blue: 0.86, alpha: 1), accent: SKColor(red: 1, green: 0.58, blue: 0.05, alpha: 1)),
        "box_truck": makeVehicle(prefix: "vehicle_box_truck", primary: SKColor(red: 0.55, green: 0.58, blue: 0.62, alpha: 1), accent: SKColor(red: 0.2, green: 0.9, blue: 1, alpha: 1)),
        "semi_truck": makeVehicle(prefix: "vehicle_semi_truck", primary: SKColor(red: 0.18, green: 0.22, blue: 0.28, alpha: 1), accent: SKColor(red: 1, green: 0.18, blue: 0.12, alpha: 1)),
        "starter_bike": makeVehicle(prefix: "vehicle_motorcycle_lane_splitter", primary: SKColor(red: 0.86, green: 0.08, blue: 0.1, alpha: 1), accent: SKColor(red: 1, green: 0.78, blue: 0.22, alpha: 1)),
        "motorcycle_lane_splitter": makeVehicle(prefix: "vehicle_motorcycle_lane_splitter", primary: SKColor(red: 0.86, green: 0.08, blue: 0.1, alpha: 1), accent: SKColor(red: 1, green: 0.78, blue: 0.22, alpha: 1)),
        "police_moto": makeVehicle(prefix: "vehicle_police_bike", primary: SKColor(white: 0.05, alpha: 1), accent: SKColor(red: 0.25, green: 0.55, blue: 1, alpha: 1)),
        "police_bike": makeVehicle(prefix: "vehicle_police_bike", primary: SKColor(white: 0.05, alpha: 1), accent: SKColor(red: 0.25, green: 0.55, blue: 1, alpha: 1)),
        "civilian_sedan": makeVehicle(prefix: "vehicle_civilian_sedan", primary: SKColor(red: 0.2, green: 0.5, blue: 0.78, alpha: 1), accent: SKColor(red: 0.62, green: 0.9, blue: 1, alpha: 1)),
        "suv": makeVehicle(prefix: "vehicle_suv", primary: SKColor(red: 0.22, green: 0.24, blue: 0.28, alpha: 1), accent: SKColor(red: 0.95, green: 0.95, blue: 0.82, alpha: 1)),
        "bus": makeVehicle(prefix: "vehicle_bus", primary: SKColor(red: 1, green: 0.44, blue: 0.08, alpha: 1), accent: SKColor(red: 1, green: 0.85, blue: 0.2, alpha: 1)),
        "armored_van": makeVehicle(prefix: "vehicle_armored_van", primary: SKColor(red: 0.18, green: 0.2, blue: 0.24, alpha: 1), accent: SKColor(red: 0.8, green: 0.84, blue: 0.88, alpha: 1))
    ]

    private static let cityArt: [RunCity: CityArtDefinition] = [
        .newYork: CityArtDefinition(
            roadSurfaceSpriteName: "city_ny_wet_asphalt",
            edgeDecorationSpriteName: "city_ny_bridge_tunnel_edges",
            propSpriteNames: ["prop_ny_steam_vent", "prop_ny_bridge_cable", "prop_ny_tunnel_light"],
            lightingAccent: SKColor(red: 0.52, green: 0.86, blue: 1, alpha: 1),
            reflectionAccent: SKColor(red: 1, green: 0.82, blue: 0.12, alpha: 1)
        ),
        .losAngeles: CityArtDefinition(
            roadSurfaceSpriteName: "city_la_sunset_freeway",
            edgeDecorationSpriteName: "city_la_palm_overpass_edges",
            propSpriteNames: ["prop_la_palm_shadow", "prop_la_freeway_sign", "prop_la_overpass", "prop_la_helicopter_spotlight"],
            lightingAccent: SKColor(red: 1, green: 0.42, blue: 0.12, alpha: 1),
            reflectionAccent: SKColor(red: 0.95, green: 0.18, blue: 0.9, alpha: 1)
        ),
        .miami: CityArtDefinition(
            roadSurfaceSpriteName: "city_miami_neon_wet_road",
            edgeDecorationSpriteName: "city_miami_ocean_deco_edges",
            propSpriteNames: ["prop_miami_ocean_strip", "prop_miami_art_deco_sign", "prop_miami_neon_hotel"],
            lightingAccent: SKColor(red: 0, green: 0.95, blue: 1, alpha: 1),
            reflectionAccent: SKColor(red: 1, green: 0.1, blue: 0.72, alpha: 1)
        )
    ]

    private static func makeVehicle(prefix: String, primary: SKColor, accent: SKColor) -> VehicleArtDefinition {
        VehicleArtDefinition(
            gameplaySpriteName: "\(prefix)_gameplay",
            garageSpriteName: "\(prefix)_garage",
            damagedSpriteName: "\(prefix)_damaged",
            headlightSpriteName: "\(prefix)_headlights",
            brakeLightSpriteName: "\(prefix)_brake_lights",
            boostGlowSpriteName: "\(prefix)_boost_glow",
            shadowSpriteName: "\(prefix)_shadow",
            rarityFrameSpriteName: "\(prefix)_rarity_frame",
            fallbackPrimary: primary,
            fallbackAccent: accent
        )
    }
}
