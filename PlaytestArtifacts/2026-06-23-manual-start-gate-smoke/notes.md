# Manual Start-Gate Smoke

## Command

```bash
python3 -u scripts/capture_live_telemetry.py --device 8EEF99A1-91E9-4DAA-97E8-5BFA68F2641E --manual --wait-for-start-tap --runs 1 --level la_01 --vehicle starter_compact --output-dir PlaytestArtifacts/2026-06-23-manual-start-gate-smoke/telemetry --timeout 90
```

## Result

- Simulator: iPhone 17e, iOS 26.5.
- The run paused on the existing `Tap to Start` screen before gameplay began.
- Runs: 1.
- Completed: 0/1.
- Active-input runs: 1/1.
- Lane changed events: 3.
- Terminal time: 5.1s.
- Terminal reason: `traffic`.
- Autoplay decisions: 0.
- Debug defaults were cleared after capture.

## Read

This smoke test proves the capture harness can hold manual runs at the start screen, then record active human steering without debug autoplay. It is only a tooling smoke sample, not a balance matrix.
