# Manual Capture Tooling Notes

## Scope

This pass added manual telemetry capture support for first-minute validation. It did not collect the human-controlled matrix yet.

## Command

```bash
python3 -u scripts/capture_live_telemetry.py --device <SIMULATOR_UDID> --manual --runs 5 --level la_01 --vehicle starter_compact --output-dir PlaytestArtifacts/<timestamp>-manual-first-minute/telemetry --timeout 180
python3 scripts/summarize_run_telemetry.py PlaytestArtifacts/<timestamp>-manual-first-minute/telemetry > PlaytestArtifacts/<timestamp>-manual-first-minute/summary.md
```

## Behavior

- Installs the verified simulator app unless `--app ''` is passed.
- Writes direct-start level and vehicle defaults.
- Leaves `TrafficGetaway.debug.autoplay` disabled when `--manual` is used.
- Waits for each `run_ended` telemetry file, then copies it into the requested artifact directory.
- Clears debug defaults at the end unless `--keep-defaults` is passed.

## Verification

- `python3 -m py_compile scripts/capture_live_telemetry.py scripts/summarize_run_telemetry.py`
- `python3 scripts/capture_live_telemetry.py --help`
- Manual defaults self-check confirmed `TrafficGetaway.debug.autoplay` is `false` in manual mode and cleared afterward.
