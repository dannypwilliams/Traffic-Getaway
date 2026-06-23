# Next Steps

## Highest Priority

Fix the remaining debug-autoplay/GameSim decision-state mismatch before tuning Sunset Merge.

## Immediate Task List

1. Compare live no-reachable-safe-slot and collision frames against GameSim per-wave state for the same seeds.
2. Decide whether GameSim should model live movement cadence and active traffic lifetime, or whether live safety selection needs a longer route horizon.
3. Rerun `PlaytestArtifacts/2026-06-22-live-autoplay-decision-matrix/` after the parity fix and confirm live terminal time moves toward GameSim.
4. Capture one human-controlled iPhone 17e matrix and one Dynamic Island-class run.
5. Retune Level 1 completion, near misses, and rewards only after sim/live state agrees.

## Do Not Start Yet

- New routes.
- New vehicles.
- Broad art replacement.
- Rewarded ads/revives.
- Live multiplayer or backend features.
