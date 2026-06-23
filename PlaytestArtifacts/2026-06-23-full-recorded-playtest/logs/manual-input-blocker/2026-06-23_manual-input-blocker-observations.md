# Manual Input Blocker Observation

## Scope

Continuation attempt for the full recorded playtest on 2026-06-23 after production commit `3a5226c751bce495c233c3cd95bb19db769363e5`.

## Evidence

- `2026-06-23_manual-start-gate-no-host-input_probe.log`: launched iPhone 17e in `--manual --wait-for-start-tap` mode for `ny_01` / `starter_compact`; the app printed the manual start prompt and timed out after 15 seconds with no `run_ended` telemetry.
- `2026-06-23_host-input-unavailable_probe.log`: host screen capture was available but showed the macOS lock screen, so it was not committed because it contains personal lock-screen content. AppleScript click injection failed with error `-25208`; Simulator reported frontmost/visible but no windows; no `cliclick` or `xdotool` helper was installed.
- `2026-06-23_manual-input-blocker-debug-defaults-check.log`: post-probe check found no remaining `TrafficGetaway.debug.*` defaults.

## Result

No active-input run was captured and no matrix count is increased. The probe is retained only as test-environment evidence explaining why New York/Miami active human-play coverage could not continue in the current locked host session.

## Next Unblock

Unlock the host session or provide another reliable Simulator input path, then rerun the required manual start-gated active-play captures with visible steering and telemetry-confirmed lane changes.
