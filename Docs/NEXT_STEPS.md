# Next Steps

## Highest Priority

Fix the remaining lane-change transition/GameSim model mismatch before tuning Sunset Merge.

## Immediate Task List

1. Add a lane-change parity probe: current slot, target slot, sprite x-position, interpolated path occupancy, colliding vehicle, and active traffic danger for each lane-change tick.
2. Decide whether GameSim should model live lane-change duration/path occupancy, or whether live safety selection/autoplay needs transition-clearance checks and longer lead time before moving.
3. Rerun `PlaytestArtifacts/2026-06-23-live-collision-analysis-matrix/` after the parity fix and confirm live terminal time moves toward GameSim.
4. Capture one human-controlled iPhone 17e matrix and one Dynamic Island-class run.
5. Retune Level 1 completion, near misses, and rewards only after sim/live state agrees.

## Do Not Start Yet

- New routes.
- New vehicles.
- Broad art replacement.
- Rewarded ads/revives.
- Live multiplayer or backend features.
