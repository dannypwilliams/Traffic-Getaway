# Balance Observations

## Current Status

One valid active-input manual run is available. No balance conclusion should be drawn until the required city/vehicle matrix is captured.

## Manual Run 01

- Level/vehicle: `la_01` / Starter Compact.
- Device: iPhone 17e simulator.
- Result: traffic collision at 9.0s.
- Active input: 2 lane changes, 3 lane-change probes, 0 autoplay decisions.
- Near misses/cash: 1 / 14.
- Fairness signal: collision analysis present; last pre-crash lane-change probe intersected traffic and max lane-change path danger was 1.0.
- Read: useful early failure sample, but too short and too narrow for balance.

## Prior Reference Signals

- Previous GameSim evidence reports `la_01` / `starter_compact` around 99.1% completion with high near misses and high cash, suggesting Level 1 may be too easy and over-rewarding.
- Previous active-traffic diagnostic evidence is too punitive and is explicitly not a balance source.
- Previous debug autoplay evidence is useful for repeatability but is not a proxy for human difficulty.
- Previous ungated active manual iPhone 17e attempt is invalid for balance conclusions because only 1/5 runs had active input.
- Current Run 01 is valid active evidence, but a single 9.0s crash cannot validate Level 1 difficulty by itself.

## Required Next Evidence

- Start-gated active iPhone 17e runs for every city.
- Start-gated Dynamic Island-class control/safe-area coverage.
- Starter Compact and Starter Bike runs with complete video, telemetry, summary, and observations.
- City progression attempts that show whether rewards/unlocks are understandable and whether grinding is required.

## Recommendations

Do not tune rewards, traffic density, city difficulty, or progression from this scaffold alone. Capture the required active-run evidence first.
