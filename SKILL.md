---
name: roblox-offline-skill
description: Designs, implements, debugs, and reviews Roblox persistent player data and offline progression. Use for DataStoreService, profiles, session locking, autosaves, migrations, safe Studio testing, idle income, crops, pets, generators, and data-loss prevention.
---

# Roblox Offline Skill

## Purpose

Use this skill to build and review reliable Roblox player-data systems and progression calculated for time away from the game. It covers architecture, implementation, testing, operations, and recovery. It is guidance for an AI agent, not a deployed persistence framework.

## Trigger conditions

Use this skill when a task involves:
- Saving, loading, resetting, migrating, restoring, or inspecting player data.
- DataStoreService, standard DataStores, OrderedDataStores, MemoryStoreService, Open Cloud DataStores, or Creator Hub Data Stores Manager.
- Player profiles, currencies, inventory, pets, upgrades, plots, crops, machines, generators, leaderboards, and persistent settings.
- Session ownership, session locking, autosaving, retries, request budgets, throttling, PlayerRemoving, or BindToClose.
- Offline earnings, idle income, farming timers, production, cooldowns, or progress after reconnecting.
- Data loss, stale writes, duplicated rewards, corrupted records, purchase receipts, or schema migrations.

Do not use this skill for unrelated UI, map, animation, combat, or general gameplay tasks unless they touch persistent player data.

## Core facts

1. DataStoreService provides persistent Roblox cloud storage. It is accessed by server code and requires Roblox services connectivity.
2. Creator Hub Data Stores Manager is a dashboard for viewing and managing data. It is not a Luau service or a runtime database API.
3. MemoryStoreService provides temporary cross-server data. Entries expire and it is not a permanent player profile store.
4. OrderedDataStore is for ordered numeric values, commonly persistent leaderboard scores. It is not a full player profile.
5. Server memory is the active server's volatile working copy. It can be lost if the process exits before a successful save.
6. Offline progression normally means bounded catch-up calculated by the server after a player returns. It does not mean a private world continued simulating with no active server.
7. A fully disconnected client cannot write Roblox cloud DataStores. Do not promise a normal published Roblox experience can keep playing and cloud-saving without connectivity.
8. DataStoreService calls belong in server Scripts or ModuleScripts required by server Scripts. Never save canonical data from a LocalScript.
9. UpdateAsync is a read-modify-write operation. It does not, by itself, implement session locking.
10. A successful request does not prove that the returned profile is structurally valid or compatible with the current schema.
11. A failed load is not equivalent to a missing key or a new player.
12. Never claim code was tested in Roblox Studio unless the target experience was actually run in Studio.

## Required workflow

### 1. Inspect before editing

Inspect the actual experience, files, scripts, ModuleScripts, remotes, packages, and available Studio integrations.

Identify:
- Every DataStore name, scope, key builder, key prefix, and store adapter.
- All GetAsync, SetAsync, UpdateAsync, IncrementAsync, RemoveAsync, version, and listing calls.
- PlayerAdded, PlayerRemoving, BindToClose, autosave tasks, purchase receipt handlers, and every writer for each profile key.
- The current schema, default template, migration version, and the exact point when a profile becomes writable.
- Whether the project uses native DataStoreService, a third-party profile library, or a custom wrapper.
- How profile ownership, retries, same-key ordering, and shutdown are currently handled.
- What the user means by offline: away-time catch-up, temporary service outage, mock testing, or fully disconnected play.

Do not infer the architecture from a screenshot, a repository name, or a few isolated code fragments. Preserve a working system unless evidence shows a concrete reason to change it.

### 2. Verify Roblox behavior

Use references/official-roblox-sources.md as the source index. Re-check current Roblox Creator Hub documentation for API signatures, quotas, service behavior, configuration, and deprecations before coding.

Use Roblox documentation for engine guarantees. For third-party packages, inspect the exact version installed in the target project and verify that package's own API. Do not invent library methods from memory or old examples.

### 3. Choose storage by requirement

| Requirement | Correct starting point |
|---|---|
| Durable player progress | Standard DataStore through DataStoreService or a maintained profile layer |
| Persistent numeric ranking | OrderedDataStore |
| Temporary shared cross-server state | MemoryStoreService |
| Current server's live profile | Server memory |
| Inspect or recover stored entries | Creator Hub Data Stores Manager and version APIs |
| External administration | Open Cloud through a trusted backend |
| Progress for time away | Persistent profile plus server-side catch-up calculation |
| Full disconnected standalone play | Not provided by normal Roblox cloud DataStores |

Prefer one stable UserId-based profile key when the profile fits and its fields need coherent updates. Split only for a real size, throughput, or access-pattern reason. Do not create a DataStore per player.

### 4. Load and own profiles safely

A profile becomes writable only after successful loading and exclusive ownership under the selected architecture.

1. Begin loading when the server receives PlayerAdded.
2. Acquire the profile/session lock using the existing persistence layer.
3. Distinguish a valid missing-key result from network failure, throttling, session conflict, malformed data, and unsupported schema.
4. Validate the payload and apply ordered, deterministic migrations.
5. Publish the profile as ready only after all required steps succeed.
6. Let server gameplay modify the server-owned working copy through controlled methods.
7. Stop mutations immediately if the profile library reports that ownership ended.

Never create a writable default profile after a transient load failure. That can overwrite a returning player's real data.

### 5. Save with ordering and bounded retries

- Handle network calls with pcall or the project's established error layer.
- Retry transient errors only, using bounded exponential backoff and random jitter.
- Do not retry invalid arguments or permanent failures forever.
- Serialize writes per key. An old delayed retry must not overwrite a newer successful save.
- Design retryable operations to be idempotent because a failed response can leave the write outcome uncertain.
- Use UpdateAsync when the new value depends on current stored state or concurrent writes are possible.
- SetAsync is valid for intentional whole-value replacement when exclusive ownership and replacement semantics are established. Do not call it universally forbidden.
- Keep UpdateAsync transform callbacks deterministic, non-yielding, and free of external side effects. Never perform waits, HTTP calls, remote calls, receipt grants, analytics, or Instance creation inside the callback.
- A nil return from an UpdateAsync transform cancels the write.
- Observe current request budgets and throttle behavior. UpdateAsync consumes both read and write budget.
- Stagger autosaves. Do not save every frame or for every tiny gameplay event.

### 6. Implement offline progression correctly

Read references/offline-progression.md and examples/offline-progress.luau before building an offline reward system.

The server must:
1. Load and validate the profile.
2. Confirm exclusive session ownership.
3. Read saved timestamps and server-owned production inputs.
4. Get current server-side epoch time.
5. Calculate non-negative elapsed time and clamp it to a configured maximum.
6. Derive production rates from validated ownership and server-side definitions.
7. Apply configured offline efficiency, eligibility, and reward caps.
8. Update the reward and its corresponding simulation timestamp together in the profile working copy.
9. Persist through the active profile layer.
10. Replicate presentation data to the client.

Use os.time() or another documented server-side epoch timestamp for cross-session calculations. Never use os.clock() as an epoch timestamp. Never trust a client clock, elapsed duration, production rate, crop stage, asset list, or last-claim timestamp.

Do not award the same interval twice. Do not double-count online production. Do not run an unbounded loop once per offline second. Handle missing, malformed, zero, negative, and future timestamps deliberately.

### 7. Protect development and production data

- Use a separate published development or staging experience for live DataStore integration tests.
- Enable Studio Access to API Services only on that isolated test experience.
- Roblox warns that Studio can access the same DataStores as the live application. Never enable the setting on production for routine testing.
- Use mocks or an in-memory adapter for deterministic logic tests. A mock is not a real player save and not durable storage.
- Use disposable accounts and test keys.
- Do not delete, revert, rename, or overwrite production data without explicit operator authorization, exact target identification, and a recovery plan.
- Keep Open Cloud credentials on a trusted backend. Never expose them in a LocalScript, client, public repository, or prompt context.

### 8. Verify and report honestly

Use references/test-matrix.md. Cover first-time and returning profiles, load failures, conflicts, stale owners, write ordering, retries, autosave, shutdown, crash recovery, malformed payloads, migrations, offline caps, repeated claims, and duplicate receipts.

Report the validation level accurately:
- Static review
- Pure unit tests
- Mock/in-memory integration tests
- Published staging DataStore tests
- Roblox Studio runtime tests
- Multi-server/session-conflict tests

These are different checks. If Studio or staging was not available, state that runtime validation remains outstanding.

## Non-negotiable prohibitions

- Never save canonical player data from a LocalScript.
- Never trust client-supplied UserIds, balances, prices, inventory, ownership, reward rates, timestamps, elapsed time, or purchase results.
- Never treat a transient load error as a new player.
- Never use MemoryStoreService or server RAM as permanent profile storage.
- Never use DataStore2 for a new experience. Roblox currently identifies it as a legacy library.
- Never yield or perform side effects in UpdateAsync callbacks.
- Never allow same-key writes and retries to race.
- Never force-steal an active session as a normal retry.
- Never write raw values over a key managed by a profile library.
- Never claim UpdateAsync alone implements a session lock.
- Never run unbounded offline simulation loops.
- Never expose Open Cloud secrets.
- Never destructively modify production data without explicit authorization and a recovery plan.
- Never claim Studio testing that did not happen.

## Reference map

Load only the documents needed for the current task:

- references/architecture-and-services.md: service roles, DataStore Manager, Open Cloud, and storage selection.
- references/player-data-lifecycle.md: profile lifecycle, in-memory working copies, readiness, leaving, and shutdown.
- references/session-locking-and-failures.md: session ownership, UpdateAsync, write ordering, retries, throttling, and unknown outcomes.
- references/offline-progression.md: idle rewards, crop timers, generators, timestamp math, caps, and disconnected limitations.
- references/studio-testing.md: API access, staging, mocks, and safe test isolation.
- references/schema-migrations-and-recovery.md: serialization, schema versions, migrations, version history, and recovery.
- references/security-and-purchases.md: remotes, server authority, receipts, Open Cloud secrets, and data privacy.
- references/performance-and-limits.md: documented limits, budgets, throughput, and operational tuning.
- references/library-selection.md: native DataStoreService, official reference code, and third-party package evaluation.
- references/game-patterns.md: profiles, leaderboards, plots, idle systems, trading, and purchases.
- references/test-matrix.md: verification scenarios.
- references/official-roblox-sources.md: Roblox Creator Hub source links only.
- examples/profile-template.luau: illustrative profile shape.
- examples/offline-progress.luau: pure bounded offline reward calculation.

## Required implementation response

For implementation and debugging tasks:
1. Summarize the existing architecture found in the actual project.
2. Explain the intended data flow and smallest safe change.
3. List the exact files to create or modify.
4. Deliver complete, context-aware code, not disconnected fragments.
5. Explain setup, staging, and any schema migration steps.
6. Report actual tests and remaining runtime checks.
7. State material limits and risks without inventing guarantees.

Respect the user's requested language and style. Preserve working systems. Do not add unrelated features or replace an existing persistence library for stylistic reasons.
