# AGENTS.md

This is a Swift iOS game project for Traffic Getaway.

## Project Goal

Build a polished, replayable iPhone chase game using a two-layer architecture:

- `GameCore`: pure Swift gameplay rules, deterministic, testable, simulator-friendly.
- `Traffic Getaway`: iOS presentation with SpriteKit, Swift/UIKit lifecycle, touch, audio, haptics, menus, StoreKit, and analytics hooks.

## Rules

- Keep gameplay rules in `GameCore` whenever practical.
- Keep SpriteKit, UIKit, StoreKit, haptics, audio, and App Store code out of `GameCore`.
- Do not rewrite unrelated systems.
- Prefer small, testable changes.
- Do not add new menus, currencies, or systems unless the task explicitly asks.
- Preserve existing working features.
- After changing pure gameplay logic, run `GameCore` tests.
- After changing balance, run `GameSim`.
- After changing UI or iOS presentation, validate on Mac with Xcode/iOS Simulator.
- Update `Docs/CODEX_HANDOFF.md` at the end of each significant session.
- Do not expand scope before making the first minute better.

## Important Commands

From the repository root:

```powershell
.\Tools\windows\check_pc_handoff.ps1
```

Run pure Swift tests after installing Swift:

```bash
cd GameCore
swift test
```

Run chase simulation after installing Swift:

```bash
cd GameSim
swift run GameSim --level la_01 --vehicle starter_compact --runs 10000 --seed 12345
```

Build the iOS app on Mac:

```bash
Tools/mac/verify_on_mac.sh
```

## Important Docs

Read these before major work:

- `Docs/DESIGN.md`
- `Docs/BALANCE_TARGETS.md`
- `Docs/KNOWN_BUGS.md`
- `Docs/CODEX_HANDOFF.md`

## Final Response Required

When finished, report:

- What changed
- Files modified
- Tests run
- Simulation results
- Known issues
- Recommended next task
