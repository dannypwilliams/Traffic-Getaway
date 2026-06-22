# Next Steps

1. Install or expose Swift and Git on the Windows desktop PATH.
2. Run `cd GameCore && swift test`.
3. Run `cd GameSim && swift run GameSim --level la_01 --vehicle starter_compact --runs 10000 --seed 12345`.
4. Also run `cd GameSim && swift run GameSim --level sunset_merge --vehicle starter_compact --runs 10000 --seed 12345`.
5. On Mac, run `Tools/mac/verify_on_mac.sh`.
6. Play Sunset Merge at least 5 times and validate the 42-second exit timing.
7. Compare `GameCore` data against the iOS app data after the Mac build is green.
8. Start gradual app adoption of `GameCore`, beginning with level definitions and lane rules.
9. Update `Docs/CODEX_HANDOFF.md` after each session.
