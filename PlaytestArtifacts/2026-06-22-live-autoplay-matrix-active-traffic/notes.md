# Live Autoplay Matrix With Active Traffic

## Session

- Date: 2026-06-22 local session.
- Simulator: iPhone 17e, iOS 26.5.
- Build: Debug simulator build from `Tools/mac/verify_on_mac.sh`.
- Level: `la_01`.
- Vehicle: `starter_compact`.
- Capture command: `python3 scripts/capture_live_telemetry.py --device 8EEF99A1-91E9-4DAA-97E8-5BFA68F2641E --runs 5 --level la_01 --vehicle starter_compact --output-dir PlaytestArtifacts/2026-06-22-live-autoplay-matrix-active-traffic/telemetry --timeout 100`

## Result

- Runs: 5.
- Completed: 0/5.
- Avg terminal time: 6.4s.
- Median terminal time: 4.4s.
- Avg traffic waves: 6.2.
- Avg near misses: 2.2.
- Terminal reasons: traffic collision in all 5.
- Collision rectangles and active traffic snapshots were present in all 5 collision samples.

## Interpretation

This matrix is evidence of a live debug-autoplay control-policy mismatch against GameSim, not proof that traffic should be tuned down. The next pass should log autoplay lane-choice decisions and compare them to the GameSim safe-slot route policy.
