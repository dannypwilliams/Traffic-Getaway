# Traffic Getaway Asset Audit

Art direction target: low-detail 32-bit arcade freeway chase, with city-specific palettes for Los Angeles, New York, and Miami.

## 1. Player Vehicles

- The garage/player vehicles are code-drawn in `VehicleRenderer.swift`.
- The default starter ID is still `starter_compact` for save compatibility, but its presentation is now the fictional `Sunset Cruiser`: orange/gold, chunkier muscle silhouette, and tagged as `vehicle.player.sunset_cruiser`.
- Existing unlockable cars and motorcycles are fictional and procedural. They are acceptable for this first pass, but some still use neon-night palettes that should be revisited in a later California pass.
- No real logos or real-world badges were found.

## 2. Traffic Vehicles

- Traffic was previously represented by mixed city-flavored categories: taxi, truck, bus, sports, sedan, and police motorcycle.
- Gameplay traffic is now named around the requested civilian pool: sedan, compact, SUV, pickup, van, box truck, sport coupe, and police motorcycle.
- Traffic art is now built through `ArcadeArt` specs with named asset IDs, consistent shadows, chunky top-down silhouettes, glass, wheels, and simplified lights.
- Box trucks remain the only two-lane traffic class.

## 3. Police Vehicles

- Police cruiser and SUV support existed as code-drawn vehicles inside `GameScene.swift`.
- Police visuals now route through `ArcadeArt` with `vehicle.police.cruiser`, `vehicle.police.suv`, and `vehicle.police.motorcycle`.
- Red/blue light glow remains procedural and respects reduced flashing.
- Police vehicles are still code-drawn; they need final bespoke sprites later.

## 4. Motorcycles

- Playable motorcycles already exist in `CarData.swift` and `VehicleRenderer.swift`.
- Police motorcycles are now part of the traffic/police asset naming system.
- Motorcycle hitboxes remain narrow through existing vehicle class and collision multipliers.
- A future pass should give each playable bike a more distinct low-detail California silhouette.

## 5. Road And Lane Assets

- The main road was dark/neon city themed.
- The gameplay road now uses `ArcadeArt.roadPalette(for:)`: brighter asphalt, cream lane dashes, warm shoulders, gold edge treatment, and cleaner freeway chevrons.
- Lane markers, road texture, shoulders, and speed streaks are still procedural, but no longer read as debug placeholders.

## 6. Environment Props

- Existing side props include buildings, signs, palms, vents, and simple city decoration.
- `ArcadeArt` now includes reusable palm and freeway sign samples for gallery inspection.
- Side props are still sparse and procedural. Later custom props should include palms, low skyline blocks, guardrails, signs, overpass pieces, and beach/city edge hints.

## 7. UI And Menu Assets

- The app uses SpriteKit menus rather than SwiftUI screens.
- UI styling previously leaned on neon cyan/magenta and many hand-picked button colors.
- `UITheme` and `UIHelpers` now default to dark navy panels, warm cream text, orange/gold accent lines, and blockier arcade buttons.
- The main menu background traffic now uses procedural vehicle art instead of colored rounded rectangles.
- Many scene-specific buttons still pass explicit old colors; they inherit improved button geometry but need a second cleanup pass.

## 8. Effects And Particles

- Effects are procedural `SKShapeNode` bursts and streaks, not particle files.
- Tire smoke, speed streaks, crash sparks, siren glow, and boost trails are now represented in `ArcadeArt.EffectAsset` and shown in the gallery.
- Main gameplay smoke/sparks/streaks were retuned toward warm cream/gold/orange readability.
- No `SKEmitterNode` particle files were found.

## 9. Missing Or Broken Assets

- No missing named image references were found in the iOS target.
- The asset catalog currently contains only app icons.
- The project has `Assets/Source` and `Assets/Processed` placeholders for a future reproducible asset pipeline.
- The new fallback policy is code-drawn and styled; it avoids magenta debug boxes or raw missing-image text in gameplay.

## 10. Current Placeholders That Must Be Replaced

- Several menus still use decorative skyline lines, dots, and older neon accent colors.
- Onboarding still has a miniature procedural road and text-like arrows that should become proper icon/button assets.
- Debug and release tools are intentionally utilitarian, but should stay developer-only.
- Atmosphere effects still include rain, fog, lightning, and city glows that are not yet aligned to the sunlit California baseline.
- Final production still needs custom sprites or generated spritesheets for vehicle families, road pieces, props, UI icons, and effect atlases.

## New Art Foundation

- Central system name: `LowDetailArcadeChase`.
- Registry and fallback file: `Traffic Getaway/ArcadeArt.swift`.
- Developer gallery: debug menu `ART GALLERY`, implemented by `Traffic Getaway/ArtGalleryScene.swift`.
