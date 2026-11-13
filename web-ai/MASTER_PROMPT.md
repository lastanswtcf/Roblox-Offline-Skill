# Roblox Offline Skill
## Master instructions for web-based AI assistants

Package: roblox-offline-skill  
Canonical repository: https://github.com/lastanswtcf/Roblox-Offline-Skill  
Research baseline: 2026-11-13

---

## Read and follow this document

Read this complete file before responding to a Roblox task involving player data, saving, DataStores, or offline progression. Treat it as the technical operating contract for the current conversation or Project.

At the start of a relevant task:

1. Confirm that you have read the complete instructions.
2. Briefly explain the difference between DataStoreService, Creator Hub Data Stores Manager, MemoryStoreService, server memory, and offline progression.
3. Inspect the actual project files and current implementation before proposing edits. If they are not attached or accessible, request the relevant files or explain what cannot be inspected.
4. Verify current Roblox APIs, limits, and behavior against official Roblox Creator Hub documentation.
5. Never invent project architecture, DataStore names, keys, schemas, API methods, library methods, or test results.
6. Preserve existing working systems unless there is a demonstrated technical reason to change them.

Do not immediately output code before understanding the project and the data flow.

If a persistent Memory feature is available and enabled, you may save a short, stable summary of these project rules. Do not claim that the entire document has been memorized, and do not imply that it will be available in every future chat. The complete master prompt remains the source of truth and should remain attached to the Project or conversation.

## 1. Scope

This skill covers Roblox player-data persistence and progress calculated for a player's time away:

- Player profiles, currencies, inventory, pets, upgrades, plots, crops, machines, generators, settings, and leaderboards.
- DataStoreService, standard DataStores, OrderedDataStores, MemoryStoreService, Open Cloud DataStores, and Creator Hub Data Stores Manager.
- Profile loading, session ownership, session locking, autosaving, retries, throttling, request budgets, shutdown, and recovery.
- Offline income, farming timers, pet production, generators, cooldowns, and away-time progression.
- Schema validation, migrations, version history, duplicate purchase receipts, and data integrity.
- Studio testing, staging experiences, mocks, and production safety.

This package is engineering guidance. It is not a hosted database or a plug-and-play persistence framework.

## 2. Roblox terminology

### DataStoreService

Roblox's engine service for persistent cloud key-value data. It is used by server Scripts and ModuleScripts required by server Scripts. It is not local disk storage, and a disconnected client cannot write to Roblox cloud DataStores.

### Creator Hub Data Stores Manager

A Creator Hub dashboard for inspecting and managing experience DataStores, keys, values, metadata, and versions. It can help compare and restore versions. It is not a Luau service or a runtime API.

### MemoryStoreService

A temporary, high-throughput service shared across active Roblox servers. It provides structures such as queues, sorted maps, and hash maps. Data expires. It is useful for short-lived coordination and queues, not as the only permanent player-data store.

### OrderedDataStore

An ordered store for numeric values, commonly persistent leaderboards. It is not a full player profile.

### Server memory

The active server's working copy of player data. It is volatile and can be lost if the process crashes or shuts down before data is successfully saved.

### Offline progression

Usually a server-side catch-up calculation when the player returns. The server loads the saved profile, calculates a bounded result using saved state and elapsed time, updates the profile, and persists it. It does not mean the player's private world continued running on an inactive server.

### Fully disconnected play

Normal published Roblox experiences rely on Roblox services and connectivity. A LocalScript, mock store, MemoryStore, or server RAM cache does not create a fully disconnected experience with durable cloud saving.

## 3. Storage selection

| Need | Correct starting point |
|---|---|
| Player data that survives sessions | Standard DataStore through DataStoreService or a maintained profile layer |
| Persistent numeric leaderboard | OrderedDataStore |
| Temporary cross-server queue or coordination | MemoryStoreService |
| Active server's working profile | Server memory |
| Inspect or restore stored records | Creator Hub Data Stores Manager and supported version APIs |
| External trusted administration | Open Cloud through a protected backend |
| Rewards while a player is away | Persistent profile plus server-side catch-up |
| Fully disconnected standalone play | Not provided by normal Roblox cloud DataStores |

Prefer stable UserId-derived keys. Keep data that must update atomically together in one profile key when it fits the current limits. Split data only for a meaningful size, throughput, or access-pattern reason.

## 4. Inspect before implementation

When project files or Studio access are available:

1. Inspect the project tree, Scripts, ModuleScripts, remotes, packages, and data modules.
2. Find every store name, scope, key builder, and read/write call.
3. Find PlayerAdded, PlayerRemoving, BindToClose, autosave loops, purchase handlers, and every writer for each player key.
4. Identify whether the project uses native DataStoreService, ProfileStore, ProfileService, DataStore2, or a custom wrapper.
5. Identify the actual schema, defaults, schema version, migration behavior, and profile-ready state.
6. Determine how session ownership and same-key write ordering work.
7. Determine what "offline" means in the user's request: away-time catch-up, temporary DataStore failure, mock testing, or fully disconnected play.
8. Preserve the current architecture and stored key format unless a real technical problem requires a migration.

A failed load is not a new player. Do not create a writable default profile after a transient error.

## 5. Safe profile lifecycle

A profile must become writable only after successful loading and exclusive ownership under the selected architecture.

Recommended lifecycle:

1. The server receives PlayerAdded.
2. The persistence layer loads the profile and acquires session ownership.
3. The server validates the payload.
4. Supported schema migrations run in a deterministic order.
5. The profile is marked ready only after all required steps succeed.
6. Gameplay systems mutate the server-owned profile working copy.
7. Saves run periodically and at justified checkpoints, with per-key ordering.
8. PlayerRemoving performs final save/release handling.
9. BindToClose coordinates a bounded final save for active profiles.

Rules:

- Derive identity from the server-side Player.UserId.
- Distinguish a successful missing-key result from a failed request, throttle, session conflict, corrupt payload, or unsupported schema.
- Never replace real data with defaults after a transient load failure.
- Do not allow two servers to mutate one active profile at the same time.
- Stop writes if profile ownership is lost.
- Avoid racing autosave, PlayerRemoving, and BindToClose.
- A retry queue stored only in RAM is not durable after a crash.

## 6. Safe DataStore writes

- Handle network calls with pcall or the project's established error layer.
- Retry only transient failures using bounded exponential backoff and jitter.
- Preserve same-key request ordering. An old retry must not overwrite a newer save.
- Make retryable operations idempotent because the write result can be uncertain after a network failure.
- Use UpdateAsync for read-modify-write logic or when concurrent updates are possible.
- SetAsync can be valid for intentional whole-value replacement when exclusive ownership and replacement semantics are established. It is not universally forbidden.
- UpdateAsync transform callbacks must not yield and must not perform external side effects. Keep them deterministic and safe to evaluate more than once.
- Never place task.wait, HTTP requests, remote calls, receipt grants, analytics, or Instance creation inside an UpdateAsync callback.
- Returning nil from the transform cancels the update.
- UpdateAsync consumes read and write request budgets.
- Observe GetRequestBudgetForRequestType and current throttling behavior.
- Stagger autosaves and periodic jobs. Do not save every frame or on every tiny value change.
- Re-check live Roblox quotas before production work. Do not hardcode old limits as permanent guarantees.

## 7. Offline progression rules

Run the catch-up only after a successful profile load, validation, and exclusive session ownership.

Persist the state needed to calculate production, such as:
- LastSimulationAt or LastClaimedAt as a server-side epoch timestamp.
- Owned assets: generators, machines, crops, plots, and pets.
- Levels, upgrades, and the canonical data needed to derive production rates.
- Relevant eligibility, boost-expiry, efficiency, and cap policy.

Correct sequence:

1. Load and validate the profile.
2. Confirm the session owner.
3. Read saved timestamps and production inputs.
4. Get current server-side epoch time.
5. Compute non-negative elapsed time.
6. Clamp elapsed time to a configured maximum.
7. Derive production rates from server-owned definitions and validated ownership.
8. Apply offline efficiency, eligibility rules, and reward caps.
9. Update the reward and its simulation timestamp together in the profile state.
10. Persist through the active profile owner.
11. Replicate the result to the client for presentation.

Rules:

- Use a server-side epoch timestamp such as os.time(). DateTime.now().UnixTimestamp is also an epoch timestamp; calculate authoritative values on the server.
- Do not persist os.clock() for cross-session time comparisons.
- Never trust a client timestamp, client elapsed time, production rate, crop stage, asset list, or reward amount.
- Never award the same interval twice after reconnects, retries, or concurrent joins.
- Handle missing, malformed, zero, negative, non-finite, and future values deliberately.
- Define maximum offline duration, offline efficiency, eligible assets, boost expiry, and maximum reward.
- Do not use an unbounded per-second loop for long absences.
- Do not double-count production already credited during active gameplay.
- If crops or machines progress independently, persist enough state and timestamps to reconstruct each one.
- Never describe away-time catch-up as a simulation that actually ran while the player was disconnected.

For a constant-rate system, the conceptual calculation is:

    elapsed = clamp(now - lastSimulationAt, 0, maxOfflineSeconds)
    reward = min(ratePerSecond * elapsed * offlineEfficiency, maxOfflineReward)

Every input must come from validated server-owned state or trusted configuration.

## 8. Studio and production safety

Roblox warns that Studio can access the same DataStores as the live application when Studio API access is enabled.

Use this safe workflow:

1. Create a separate development or staging experience.
2. Publish the staging experience.
3. Enable Studio Access to API Services only for the staging experience.
4. Use test-specific store names or keys where appropriate.
5. Use disposable accounts and data.
6. Verify the active experience before any write or delete test.
7. Use mocks or in-memory fakes for deterministic unit tests.

A mock is not a production save and is not durable disk storage. Do not describe it as a way for real players to save offline.

Never delete, revert, rename, or overwrite production keys without explicit operator authorization, exact target identification, and a recovery plan.

## 9. Libraries

### Native DataStoreService

A custom layer must implement and test profile ownership, session locking, write ordering, autosaves, shutdown, bounded retries, validation, migrations, idempotency, recovery, and observability. A basic GetAsync/SetAsync example is not production-ready.

### ProfileStore and ProfileService

These are third-party libraries, not Roblox engine services. Inspect the exact version installed in the project, its source and API documentation, session lifecycle, failure behavior, key format, and migration instructions.

Do not invent methods from old tutorials. Do not mix raw DataStore writes with a library-managed key unless the library's migration documentation explicitly requires it.

### DataStore2

Roblox identifies DataStore2 as a legacy third-party library and recommends not using it for new experiences. Existing games need a controlled migration, not a blind rewrite.

### Roblox player-data reference code

Roblox provides a player data and purchasing reference implementation. It is reference code, not proof that a particular target game is production-ready. Read its stated limitations and test any adaptation.

## 10. Schema, migration, and recovery

- Use an explicit schema version.
- Keep migrations deterministic, ordered, and idempotent where feasible.
- Test fresh, current, old, partially migrated, and malformed records.
- Migrate only after successful load and session ownership.
- Do not advance the schema version until migration succeeds.
- Do not silently reset corrupt data to defaults.
- Preserve a recovery point before risky changes.
- Serialize Instances and engine userdata into documented primitive representations.
- Prefer string-keyed dictionaries for structured data and dense arrays for lists.
- Estimate record size in tests and keep a safety margin.
- Do not rename a live store, scope, key prefix, or profile envelope without a migration plan.
- Do not write raw values over a profile-library-managed key.

Roblox DataStore version history is useful for recovery but is not a complete backup strategy. Re-check current retention and versioning rules before a production restore. A version revert is a write.

## 11. Purchases and security

- Use MarketplaceService.ProcessReceipt on the server for Developer Product fulfillment.
- Make receipt grants idempotent. Duplicate receipt processing must not duplicate rewards.
- Do not treat a client prompt event as proof of purchase.
- Validate every RemoteEvent and RemoteFunction argument.
- Keep balances, prices, inventory, ownership, permissions, production, and rewards server-authoritative.
- Use a durable transaction protocol for trades and transfers that affect multiple profiles.
- Keep Open Cloud API keys on a trusted backend and use the narrowest permissions.
- Never expose secrets in clients, public source, prompts, or logs.
- Store only data required by the experience and follow Roblox's current user-data erasure requirements.

## 12. Required testing and reporting

Use the package's test matrix. At minimum, test:
- First-time and returning players.
- Load failure versus missing key.
- Concurrent session requests and lost ownership.
- Delayed old retries and same-key write ordering.
- Autosave, PlayerRemoving, BindToClose, and crash behavior.
- Malformed data and every supported migration.
- Offline reward caps, future timestamps, repeated claims, and atomic reward/timestamp updates.
- Duplicate purchase receipt handling.
- Staging isolation and production-data protection.

Clearly distinguish:
- Static code review.
- Pure unit tests.
- Mock/in-memory integration tests.
- Published staging DataStore tests.
- Roblox Studio runtime tests.
- Multi-server/session-conflict tests.

Do not claim Studio, staging, or multi-server testing unless it actually ran in that environment. If runtime access was unavailable, say so.

## 13. Response requirements

Before editing, briefly summarize:
- The existing persistence architecture.
- Where profile data is loaded, mutated, saved, and released.
- How offline progression currently works, if present.
- The smallest safe change needed.

Then provide:
- Exact file paths.
- Complete code that fits the real project.
- Setup and deployment steps.
- Migration and recovery instructions when data formats change.
- Tests actually performed and remaining checks.

Preserve existing working behavior. Do not add unrelated features or replace systems for stylistic reasons.

## 14. Official Roblox source index

Use Roblox Creator Hub and Roblox engine API reference as the authority for Roblox platform behavior. The repository's official source index contains Roblox documentation only:

https://github.com/lastanswtcf/Roblox-Offline-Skill/blob/main/references/official-roblox-sources.md

Verify every API method, callback, enum, limit, and configurable setting against current Roblox documentation before generating production code.

---

## Platform usage

This prompt is a portable context document for web chats. Coding-agent installation instructions are maintained separately in AI-PLATFORMS.md.

- ChatGPT web: add this file to a Project's sources and use the Project instruction below.
- Claude.ai: upload a ZIP of the complete skill directory through Customize → Skills when Custom Skills are available. Otherwise attach this file to the chat.
- Gemini web: import the public repository as code or attach this file.
- DeepSeek web: paste or attach this file where the current chat interface supports file uploads.

Suggested ChatGPT Project instruction:

    Before Roblox persistence or offline progression work, read the complete Roblox Offline Skill master prompt in Project sources. Inspect the real project, follow all data-safety rules, verify Roblox APIs and limits through Roblox Creator Hub, and report only tests that actually ran.
