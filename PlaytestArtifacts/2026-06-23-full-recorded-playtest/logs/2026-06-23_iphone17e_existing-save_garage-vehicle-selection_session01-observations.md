# Existing-Save Garage Vehicle Selection Session 01 Observations

- Date: 2026-06-23
- Device: iPhone 17e simulator, iOS 26.5
- Flow: result screen `GARAGE` button to Garage, Cars tab, Bikes tab, return to main menu
- Video: `videos/progression/2026-06-23_iphone17e_existing-save_garage-vehicle-selection_session01.mp4`
- Current selected car screenshot: `screenshots/progression/2026-06-23_iphone17e_existing-save_garage-vehicle-selection_session01_current-car.png`
- Locked bike screenshot: `screenshots/progression/2026-06-23_iphone17e_existing-save_garage-vehicle-selection_session01_locked-bike.png`
- Menu return screenshot: `screenshots/progression/2026-06-23_iphone17e_existing-save_garage-vehicle-selection_session01_menu-return.png`
- Telemetry: none; this session did not start a gameplay run.

## Observed Result

From the `CAPTURED` result screen, tapping `GARAGE` opened the Garage. The Garage displayed cash `$443`, the selected `SUNSET CRUISER`, the Cars tab, vehicle stats, and a green `SELECTED` state. Tapping `BIKES` switched to `STARTER BIKE` and showed motorcycle stats plus `NEED $107 MORE`, confirming the bike was visible but locked in this save state. Tapping `BACK` returned to the main menu, which displayed the same selected `SUNSET CRUISER`, cash `$443`, best score 741, Level 2 progress `116 / 200 XP`, and the `GARAGE` entry point.

## Validity

Partial for vehicle-selection coverage. This records Garage access, tab switching, selected-vehicle display, locked-vehicle messaging, and return navigation. It does not prove selecting an alternate unlocked vehicle because the only observed bike was locked and the current car was already selected.
