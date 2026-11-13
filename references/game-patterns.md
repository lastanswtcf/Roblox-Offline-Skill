# Common Roblox game data patterns

## Standard player profile

A profile may contain a schema version, currency balances, inventory and owned items, upgrades and progression, settings, pet ownership and equipment, plot or tycoon state, offline simulation metadata, and purchase receipt identities where required.

Keep related fields in one key when they must update atomically and fit the current per-key limit.

## Multiple character slots

Use a deterministic slot identifier or nested profile fields. Keep schema migration and ownership rules explicit. Do not create a new DataStore name for each player or character without a justified reason.

## Persistent leaderboard

Use an OrderedDataStore for the numeric ranking value. Keep the player's authoritative profile in a standard DataStore. Define when leaderboard changes are written and how discrepancies are reconciled if one write succeeds and the other fails.

Do not store the full profile in the OrderedDataStore.

## Plot and farming games

Persist canonical plot state rather than only the current Workspace Instances.

Depending on the game, save plot ownership, stable item/plant identifiers, positions in a documented primitive format, crop types, growth timestamps, growth durations, stages, machine state, processing timestamps, and relevant upgrades/unlocks.

On join, validate and reconstruct the world from the profile. Calculate away-time growth on the server.

## Idle and generator games

Persist owned generator identifiers, levels, upgrades, and a simulation timestamp. Derive production rates from server-owned definitions and validated ownership. Apply maximum offline duration, efficiency, and reward caps on the server.

Keep separate online production, offline catch-up, and client visual timers/animations.

## Pets and passive production

Persist stable pet identifiers, ownership, levels, equipped state, and canonical progression. Derive production or multipliers from server-side definitions. A client may show estimated production but cannot decide the authoritative reward.

## Cooldowns and crafting

Persist the timestamp or state required to reconstruct eligibility. Calculate completion from server time after load. Decide whether a timer progresses while the player is away and document that rule.

For crafting and machine cycles, persist enough state to avoid granting the same output twice.

## Developer Products

Process receipts server-side using MarketplaceService.ProcessReceipt. Persist receipt identity and grant state so duplicate delivery cannot duplicate rewards. Do not rely on client-side prompt completion events.

## Trading and transfers

Trading that affects two profiles needs a durable transaction protocol. Use unique transaction IDs, explicit states, idempotent steps, and recovery of incomplete transactions. Cross-server messages may coordinate work but are not the durable transaction record.

## Global events and temporary coordination

Use MessagingService for appropriate cross-server notifications and MemoryStoreService for temporary shared queues or coordination. Neither service replaces the durable player profile or transaction log.
