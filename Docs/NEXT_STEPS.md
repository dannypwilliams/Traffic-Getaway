# Next Steps

## Highest Priority

Validate the tightened transition-clearance model with human input before tuning Sunset Merge.

## Immediate Task List

1. Capture active-steering manual iPhone 17e runs; passive no-input coverage now exists and is green.
2. Capture active-steering manual Dynamic Island-class runs; passive no-input iPhone 17 Pro coverage now exists and is green.
3. Continue calibrating `GameSim --active-traffic-lifetime` against live telemetry; the first calibration improved average survival from 7.3s to 10.7s, but the mode is still too punitive.
4. Investigate the remaining iPhone 17 Pro debug-autoplay traffic collision after `no_transition_safe_slots`; the strict emergency fallback reduced this from 2/5 to 1/5.
5. Retune Level 1 completion, near misses, and rewards only after sim/live state agrees.

## Manual Matrix Command

Use the direct-start manual capture mode so the run starts on `la_01` with `starter_compact`, but player input remains manual:

```bash
python3 -u scripts/capture_live_telemetry.py --device <SIMULATOR_UDID> --manual --runs 5 --level la_01 --vehicle starter_compact --output-dir PlaytestArtifacts/<timestamp>-manual-first-minute/telemetry --timeout 180
python3 scripts/summarize_run_telemetry.py PlaytestArtifacts/<timestamp>-manual-first-minute/telemetry > PlaytestArtifacts/<timestamp>-manual-first-minute/summary.md
```

## Do Not Start Yet

- New routes.
- New vehicles.
- Broad art replacement.
- Rewarded ads/revives.
- Live multiplayer or backend features.
