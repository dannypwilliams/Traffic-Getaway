# Manual Active iPhone 17e Attempt

## Command

```bash
python3 -u scripts/capture_live_telemetry.py --device 8EEF99A1-91E9-4DAA-97E8-5BFA68F2641E --manual --runs 5 --level la_01 --vehicle starter_compact --output-dir PlaytestArtifacts/2026-06-23-manual-active-17e-codex-matrix/telemetry --timeout 150
```

## Result

- Runs: 5.
- Completed: 0/5.
- Active-input runs: 1/5.
- Lane changed events: 5.
- Avg terminal time: 12.6s.
- Terminal reasons: `police_caught` 4, `roadblock` 1.
- Autoplay decisions: 0.

## Read

This is not a valid active-steering matrix. Four runs were effectively passive launches that reached the police-capture terminal before sustained input began. The single active-input sample survived to 27.0s, recorded 5 lane changes and 8 near misses, then ended on a roadblock.

The useful finding is tooling-related: direct-start manual capture starts the chase immediately, which makes it too easy for setup latency to turn intended active tests into passive police-capture samples. A debug-only start gate was added afterward so manual matrix captures can pause on the existing start screen until the player is ready.
