# Next Steps

## Highest Priority

Use the new JSONL telemetry to capture a small live-run matrix, then compare live iOS runs against GameSim before tuning Sunset Merge.

## Immediate Task List

1. Capture at least 5 iPhone 17e live runs and one Dynamic Island-class run.
2. Run `python3 scripts/summarize_run_telemetry.py PlaytestArtifacts/**/*.jsonl`.
3. Update `Docs/SIM_LIVE_RECONCILIATION.md` with measured live averages and terminal outcomes.
4. Compare collision rectangles and safe slots for any live crash that feels unfair.
5. Retune Level 1 completion, near misses, and rewards only after the mismatch is explained.

## Do Not Start Yet

- New routes.
- New vehicles.
- Broad art replacement.
- Rewarded ads/revives.
- Live multiplayer or backend features.
