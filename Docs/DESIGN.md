# Traffic Getaway Design

## Game

Traffic Getaway is a lane-based iPhone chase game. The player dodges traffic, builds score and cash through close calls, survives escalating police pressure, and escapes through timed exit ramps.

## Architecture

The project now has three practical layers:

- `GameCore`: pure Swift rules and deterministic simulation logic.
- `GameSim`: command-line runner for balance simulations using `GameCore`.
- `Traffic Getaway`: iOS app target for SpriteKit rendering, input, UI, haptics, audio, StoreKit, analytics, and platform validation.

The guiding rule is:

> GameCore owns the rules. The iOS app presents the rules.

## GameCore Owns

- Level definitions and unlock order
- Vehicle gameplay stats
- Lane and slot rules
- Car vs motorcycle valid positions
- Exit lane and slot rules
- Difficulty snapshots over time
- Traffic wave safety rules
- Deterministic traffic pattern generation
- Vehicle hitbox and collision helpers
- Near-miss classification helpers
- Scoring, combo, cash, and XP formulas
- Basic progression and unlock helpers
- Seeded simulation
- Reward estimates for cash and XP

## iOS App Owns

- SpriteKit scenes
- Rendering and animation
- Touch controls
- Haptics
- Audio
- Menus and navigation
- StoreKit
- Save data persistence
- Analytics integration
- App Store and TestFlight concerns

## Current Integration Status

`GameCore` and `GameSim` are established as separate Swift packages. The existing iOS target still contains app-local versions of some gameplay data and rules. That keeps this setup low-risk until the Mac can build and playtest the app after each adoption step.

The next integration work should replace app-local rule copies with `GameCore` gradually, starting with low-risk data such as level definitions, lane slots, and vehicle gameplay stats.

## Asset Pipeline

The repo includes `Assets/Source` and `Assets/Processed` folders for future source art and generated spritesheets. Generated assets should be reproducible and documented before being wired into the iOS target.
