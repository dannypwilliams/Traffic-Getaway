# Known Bugs

## P0 Ship Blockers

- Sunset Merge balance is far outside target: about 99% sim completion, about 35 near misses/run, and about 998 cash/run.
- Sim/live behavior is not reconciled; live gameplay metrics are not yet captured.

## P1 Milestone Blockers

- Full tutorial and first-minute terminal-outcome matrix has not been completed.
- App-local rules duplicate `GameCore`, creating drift risk.

## P2 Important Polish

- Rewarded revive and cash-double code remain present but hidden behind disabled flags.
- Placeholder/procedural art remains across many surfaces.
- Accessibility audit is incomplete beyond the main-menu cash fix.

## Recently Fixed

- `GameCore` deterministic simulation test now passes.
- Current `GameCore` traffic stress no longer commits impossible waves or exit reachability failures.
- White launch frame was fixed in iPhone 17e simulator capture.
