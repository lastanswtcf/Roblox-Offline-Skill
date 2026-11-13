# Data persistence and offline progression test matrix

A successful happy-path save is not sufficient validation. Test failure behavior as well as normal gameplay.

## Player profile lifecycle

- [ ] A successful missing-key load creates a valid first-time profile.
- [ ] A returning player receives the previously persisted profile.
- [ ] A failed load does not create a writable default profile.
- [ ] Gameplay cannot mutate the profile before it becomes ready.
- [ ] A second server cannot acquire writable ownership while the first session is active.
- [ ] A stale session stops mutating and saving after ownership is lost.
- [ ] A normal departure saves and releases ownership.
- [ ] The next server can acquire the profile after release.

## Failure and retries

- [ ] GetAsync or session-start operation fails transiently.
- [ ] A timeout does not become a new writable default.
- [ ] A save fails transiently and retries within a bounded policy.
- [ ] A delayed old retry cannot overwrite a newer save.
- [ ] Same-key requests are processed in order.
- [ ] An UpdateAsync callback is safe if evaluated more than once.
- [ ] Request budgets become low or throttling occurs.
- [ ] Malformed arguments are not retried forever.
- [ ] A write outcome is uncertain and the retry remains idempotent.
- [ ] Server shutdown begins while profiles are dirty.
- [ ] BindToClose finishes within the documented shutdown window.
- [ ] A crash after the last autosave produces the documented recovery result.

## Offline progression

- [ ] A new profile does not receive unintended offline rewards.
- [ ] A normal absence produces the expected catch-up.
- [ ] An absence longer than the configured cap is clamped.
- [ ] A future timestamp cannot produce negative or excessive rewards.
- [ ] Missing or malformed timestamps follow an explicit recovery policy.
- [ ] Zero, negative, non-finite, and excessive rates are handled safely.
- [ ] Client-provided time and rates are ignored.
- [ ] Two servers cannot award the same offline interval concurrently.
- [ ] A retry or reconnect cannot claim the same interval twice.
- [ ] Reward and timestamp update together in the active profile.
- [ ] Online production is not double-counted as offline production.
- [ ] Crops and machines do not execute unbounded per-second loops.
- [ ] Changes to owned assets or upgrades follow the defined simulation policy.
- [ ] Reward and elapsed-time caps are both tested.

## Schema and recovery

- [ ] Fresh schema validates.
- [ ] Every supported previous schema migrates correctly.
- [ ] Partially migrated records are handled.
- [ ] Malformed records do not silently reset to defaults.
- [ ] Migration is deterministic and does not run twice incorrectly.
- [ ] Migration failure does not mark the profile ready.
- [ ] Profile library key envelopes are preserved.
- [ ] Recovery is tested only in staging or disposable data.
- [ ] Current DataStore version and recovery procedures are understood.

## Studio and deployment safety

- [ ] The staging experience is separate from production.
- [ ] Studio API access is enabled only for the staging experience.
- [ ] Mock tests do not write live keys.
- [ ] Mock data is not mistaken for durable player storage.
- [ ] Data Stores Manager inspection is read-only unless an explicit admin action is required.
- [ ] Production rollback and deletion are not used for ordinary tests.

## Purchases and economy

- [ ] Duplicate ProcessReceipt invocation does not duplicate a grant.
- [ ] Receipt persistence failure has a safe retry decision.
- [ ] A purchase grant and its receipt state follow one durable policy.
- [ ] Trades interrupted between player updates can be recovered.
- [ ] Balances and inventory invariants remain valid after retries and reconnects.
- [ ] Remote arguments cannot set prices, balances, ownership, or rewards.

## Report

Record which tests were actually run and the environment: static review, unit tests, mock integration tests, published staging DataStore tests, Studio runtime tests, and multi-server tests.

Do not report a test as passed if it was only planned or read in documentation.
