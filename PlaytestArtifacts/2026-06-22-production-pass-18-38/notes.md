# Production Pass Evidence Notes

## Build Metadata

- Branch: `main...origin/main [ahead 1]`.
- Starting HEAD: `a5af66b Testrun`.
- Simulator: iPhone 17e, iOS 26.5.
- Build: Debug iOS Simulator via `Tools/mac/verify_on_mac.sh`.

## Captures

- `screenshots/01-launch.png`: reproduced white first frame before launch-screen color fix.
- `screenshots/02-launch-after-fix.png`: dark first tutorial screen after fix.
- `screenshots/04-live-telemetry-run.png`: live chase after onboarding skip during telemetry smoke test.
- `screenshots/05-debug-diagnostics-overlay.png`: debug open-path overlay with lane/slot guides, safe-slot columns, hitboxes, wave ID, and seed.
- `logs/simulator-launch.log`: pre-fix launch logs.
- `logs/simulator-launch-after-fix.log`: post-fix launch logs.
- `logs/simulator-telemetry-run.log`: simulator system log for the telemetry smoke test.
- `telemetry/2026-06-22_18-49-43-la_01-starter_compact-17033032432948192956.jsonl`: first live JSONL sample; 24 events total.

## Result

The launch white-frame issue was reproduced and fixed in the tested simulator capture. Live telemetry is now proven with one terminal crash sample, `scripts/summarize_run_telemetry.py` can summarize exported JSONL files, and the debug collision/traffic-plan overlay has screenshot evidence. Full tutorial/play outcome validation remains pending.
