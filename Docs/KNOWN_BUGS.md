# Known Bugs

## P0 Ship Blockers

- Sunset Merge balance is far outside target: about 99% sim completion, about 35 near misses/run, and about 998 cash/run.
- Sim/live behavior is not reconciled; live telemetry exists, but live autoplay still crashes far earlier than GameSim, now narrowed to transition clearance, target-slot danger horizon, and active traffic lifetime.

## P1 Milestone Blockers

- Full tutorial and first-minute terminal-outcome matrix has not been completed.
- App-local rules duplicate `GameCore`, creating drift risk.
- Live lane-change duration/path occupancy, target-slot danger horizon, and active traffic lifetime are not modeled by GameSim closely enough to explain early live crashes.

## P2 Important Polish

- Rewarded revive and cash-double code remain present but hidden behind disabled flags.
- Placeholder/procedural art remains across many surfaces.
- Accessibility audit is incomplete beyond the main-menu cash fix.

## Recently Fixed

- `GameCore` deterministic simulation test now passes.
- Current `GameCore` traffic stress no longer commits impossible waves or exit reachability failures.
- White launch frame was fixed in iPhone 17e simulator capture.
- Live collision-frame telemetry now reports colliding vehicle, active traffic roster, player slot, live safe slots, overlap, and last movement decision.
- Live lane-change parity telemetry now reports current slot, target slot, sprite x-position, path danger, active traffic intersection, and completion state during animated moves.
