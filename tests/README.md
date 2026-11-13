# Offline progression example tests

The test script validates the pure reward calculator. It does not call DataStoreService and does not replace an integration test against a published staging experience.

## Studio setup

1. Create a test place or use a dedicated staging experience.
2. Create a Folder in ServerScriptService named OfflineProgressTests.
3. Add a ModuleScript inside it named OfflineProgress.
4. Copy the complete contents of examples/offline-progress.luau into that ModuleScript.
5. Add a Script beside the ModuleScript.
6. Copy tests/offline-progress.test.server.luau into that Script.
7. Run the place in Roblox Studio and inspect the Output window.

The test script requires the sibling ModuleScript named OfflineProgress. It uses assert statements and prints a success message when the cases pass.

## Covered cases

- First simulation initializes the timestamp without granting rewards.
- Elapsed time calculation and configured reward cap.
- Maximum offline duration.
- Future timestamps and clock-anomaly handling.
- Negative production rate rejection.
- Non-finite configuration rejection.

## What this does not test

- DataStoreService requests or request budgets.
- Session locking or concurrent servers.
- Profile libraries, autosaves, or BindToClose.
- Persistence across shutdown.
- Actual game economy rules or production rates.

Run those tests separately using the test matrix in ../references/test-matrix.md and a separate published staging experience.
