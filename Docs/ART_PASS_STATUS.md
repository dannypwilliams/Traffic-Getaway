# Traffic Getaway Art Pass Status

Last updated: 2026-06-22

## Current Direction

Traffic Getaway now targets one shared visual language across all cities: low-detail 32-bit arcade freeway chase visuals with chunky readable vehicles, clean mobile contrast, simple shadows, and fast color-blocked scenery.

Los Angeles, New York, and Miami use the same simplified SpriteKit asset language, but each city has its own palette, road mood, props, traffic colors, police flavor, signage, and atmosphere. Los Angeles is the only city using the bright Sunlit California palette.

## Three-City World Identity Pass

1. Current city/world theme model: Complete
   - `WorldTheme.swift` now defines exactly three city identities: Los Angeles, New York, and Miami.
   - The older six-world catalog has been removed from source data.

2. Existing Los Angeles/Sunlit California visuals: Complete
   - Los Angeles keeps warm asphalt, turquoise/ocean blue, orange/gold accents, palms, low-rise coastal hints, and green freeway exit signs.

3. Whether New York exists: Complete
   - New York has a cool gray/navy/steel palette, taxi-yellow accents, dense urban roads, blocky vertical skyline, steam/building props, urban police pressure, and expressway/tunnel exit signage.

4. Whether Miami exists: Complete
   - Miami has aqua/coral/pink tropical colors, pastel waterfront road edges, hotel/neon/palm props, sportier traffic colors, and beach-style exit signage.

5. How road colors are selected: Complete
   - Gameplay, samples, level select, gallery, and menu traffic read `WorldTheme.palette`.

6. How background colors are selected: Complete
   - `GameScene` uses the active city palette and `skylineStyle`.

7. How props are selected: Complete
   - `GameScene` switches on `WorldTheme.propSet` for LA, New York, and Miami.

8. How traffic palettes are selected: Complete
   - `ArcadeArt.trafficSpec` pulls civilian colors from the active city's `trafficColorSet`.

9. How police visuals are selected: Needs polish
   - Police vehicles now receive active city body/accent/glow colors and city pressure multipliers.
   - The silhouette is still shared procedural police art.

10. How city names appear in UI: Needs polish
   - City names now appear on the city select cards, pre-run overlay, HUD city code, in-game settings/pause overlay, game-over overlay, results, main menu next chase, and city transition banners.
   - Main-menu settings and deeper store/onboarding surfaces remain broader UI cleanup targets.

11. How level/world select works: Complete pending visual playtest
   - The previous world picker is now a three-city picker with full city cards, short identity text, difficulty flavor, road previews, palette strips, select/locked state, and the existing route list underneath.
   - Story progression now opens with Los Angeles, then New York, then Miami.

12. Whether any world still incorrectly uses California colors: Complete
   - New York and Miami no longer inherit the Los Angeles/Sunlit California palette through `ArcadeArt.roadPalette(for:)` or `WorldThemeCatalog`.

13. Remaining hardcoded California-specific visuals: Needs polish
   - Some vehicle and paint names still reference sunset, ocean, or Miami as garage flavor.
   - `Docs/ASSET_AUDIT.md` was updated only for the central style name; a deeper asset audit can follow.

14. Missing city-specific assets or placeholders: Needs polish
   - All city props remain procedural SpriteKit placeholders, not final authored bitmap assets.

15. Default SwiftUI screens that do not match the game style: Not implemented
   - This project is SpriteKit/UIKit-based in the inspected surfaces. Store, settings, onboarding, and some overlays still need a broader art cleanup pass.

## Audit Answers

- Is the current art system city-agnostic?
  - Mostly yes. The main gameplay, menu, gallery, results, traffic, exits, and police presentation now route through `WorldTheme`. Some older menus still use hand-picked neon/cyan/magenta colors.

- Are any Los Angeles colors hardcoded globally?
  - The former global Sunlit California road palette path was removed. Shared constants still include orange/gold/cream/navy as global UI colors by design, while city-specific colors live in theme data.

- Can the same vehicle system work across LA, New York, and Miami?
  - Yes. Vehicle shapes are reusable and fictional; traffic body colors and police accents now vary by city theme.

- Can props/signage/backgrounds change per city?
  - Yes. `propSet`, `skylineStyle`, `signageStyle`, and `exitSignStyle` drive those differences.

- What needs to be refactored so each city can have its own identity?
  - Final authored prop/sprite production and deeper cleanup of non-gameplay menus.

## Current State

- Shared art style: Complete as code-drawn low-detail arcade style.
- Los Angeles: Complete for procedural theme identity; final assets pending.
- New York: Complete for procedural theme identity; final assets pending.
- Miami: Complete for procedural theme identity; final assets pending.
- City select: Complete for three-city cards, route selection, locked/unlocked state, and LA-first progression; visual playtest still pending.
- Gameplay HUD: Complete for city code and active palette.
- Pre-run UI: Complete for current city and selected vehicle.
- In-game settings/pause overlay: Complete for current city label and city accent.
- Game-over UI: Complete for current city and selected vehicle.
- Results UI: Complete for city, selected vehicle, city-themed accents, and next-city unlock messaging.
- Exit events: Complete for city-colored sign fills/text and ramp accents.
- Traffic palettes: Complete for per-city traffic color sets.
- Police variants: Needs polish; city-colored procedural police art is active, unique silhouettes are not.
- Remaining missing assets: Procedural city props, final signage art, final skyline art, and authored production sprites.

## Validation Status

- Windows handoff check: Complete for file presence and line endings; Swift checks skipped because Swift is not on PATH.
- Swift/GameCore tests: Attempted and blocked; `swift test` cannot run because Swift is not on PATH.
- GameSim: Attempted and blocked for `la_01` and `all`; `swift run GameSim` cannot run because Swift is not on PATH.
- Mac/Xcode/iOS Simulator: Required and pending.

## Next Best Art Task

Run on Mac/iOS Simulator and inspect Los Angeles, New York, and Miami in gameplay. Verify lane readability, traffic/police contrast, prop placement outside lanes, exit readability at speed, city select layout, results layout, and frame-rate/node-count health.
