# Known Bugs

## P0 Ship Blockers

- Sunset Merge balance is far outside target: about 99% sim completion, about 35 near misses/run, and about 998 cash/run.
- Sim/live behavior is not fully reconciled; tightened transition-clearance autoplay completed 5/5 iPhone 17e runs and 4/5 iPhone 17 Pro runs after a strict emergency fallback, and the active-traffic GameSim diagnostic improved from 7.3s to 10.7s average survival, but human-controlled validation and GameSim model ownership are still unresolved.

## P1 Milestone Blockers

- Full tutorial and first-minute terminal-outcome matrix has not been completed.
- App-local rules duplicate `GameCore`, creating drift risk.
- Live lane-change duration/path occupancy, target-slot danger horizon, and active traffic lifetime are guarded in the live debug-autoplay adapter; GameSim has an opt-in diagnostic with risk-aware emergency movement, but it is still too punitive for final balance tuning.

## P2 Important Polish

- Rewarded revive and cash-double code remain present but hidden behind disabled flags.
- Placeholder/procedural art remains across many surfaces.
- Accessibility audit is incomplete beyond the main-menu cash fix.
- Dynamic Island-class debug autoplay still produced 1/5 traffic-collision terminals after `no_transition_safe_slots` decisions.

## Recently Fixed

- `GameCore` deterministic simulation test now passes.
- Current `GameCore` traffic stress no longer commits impossible waves or exit reachability failures.
- White launch frame was fixed in iPhone 17e simulator capture.
- Live collision-frame telemetry now reports colliding vehicle, active traffic roster, player slot, live safe slots, overlap, and last movement decision.
- Live lane-change parity telemetry now reports current slot, target slot, sprite x-position, path danger, active traffic intersection, and completion state during animated moves.
- Debug autoplay now rejects predicted unsafe transition paths with a lane-change-duration horizon and padded predicted traffic hitboxes; the tightened matrix completed 5/5 sampled live runs.
- `GameSim --active-traffic-lifetime` now exists as a deterministic diagnostic for active on-screen traffic and transition safety.
- Final tutorial exit-ramp signage is visible again on the current five-step tutorial, and the final practice can advance from the explicit exit-side predicate after the read gate opens.
- Debug autoplay has a strict emergency transition fallback that improved the sampled iPhone 17 Pro matrix from 3/5 to 4/5 escapes without lane-change intersection probes.
- The active-traffic GameSim diagnostic now uses live-like transition timing and a deterministic transition-risk score; default GameSim remains unchanged while active-lifetime average survival improved to 10.7s.
