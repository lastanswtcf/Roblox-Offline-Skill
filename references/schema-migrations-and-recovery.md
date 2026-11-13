# Schema design, migrations, and recovery

## Use a versioned schema

A player profile should contain an explicit SchemaVersion or equivalent migration marker.

A deliberate schema helps validate old and current records, apply migrations predictably, keep compatibility across releases, diagnose corrupt records, and recover data without guessing.

Prefer predictable serializable values: booleans, numbers, strings, and tables with supported keys.

## Serialization rules

Do not attempt to store Roblox Instances, functions, threads, connections, or raw engine userdata directly as ordinary DataStore values.

Convert game-specific structures into documented primitives:
- Vector3: numeric X, Y, Z values or a fixed numeric tuple.
- CFrame: a documented component representation.
- Color3: explicit numeric RGB channels.
- Instance references: stable IDs that can be resolved from server-owned definitions.
- EnumItems: stable string or numeric identifiers defined by the game.

Prefer dictionaries with string keys for structured records and dense arrays for ordered lists. Avoid sparse numeric arrays and mixed key types where serialization behavior is unclear.

Estimate payload size in tests with HttpService:JSONEncode and keep a safety margin under the current per-key limit.

## Migration requirements

Migrations should be deterministic, ordered, idempotent where feasible, explicitly versioned, tested against representative old fixtures, applied only after successful load and session ownership, and persisted through the current profile owner.

Do not advance SchemaVersion until all required migration steps succeed. Do not silently replace unknown or malformed data with defaults. Preserve the original record or route it to a controlled recovery flow.

## Migration process

Before changing a live profile:
1. Identify all store names, scopes, key prefixes, schema versions, and profile libraries.
2. Determine every script and service that reads or writes the affected data.
3. Capture a recovery point using a supported version or snapshot workflow.
4. Export representative records for every known schema.
5. Write explicit migration code for each supported old version.
6. Test fresh, current, old, partially migrated, and malformed records.
7. Verify that old and new code cannot race on the same key during rollout.
8. Deploy with telemetry for migration success and failure.
9. Remove legacy paths only after the compatibility window is complete.

Never rename a live DataStore, scope, key prefix, or profile envelope without a migration plan.

## DataStore version history

Roblox currently documents that the first write to a key in each UTC hour creates a versioned backup. Later writes to that same key in the same UTC hour overwrite the previous data for that hour.

Versioned backups expire 30 days after a new write overwrites them. The latest version does not expire.

Treat version history as a recovery aid, not a full backup strategy. A version revert is itself a write and should be reviewed against the current schema and active session ownership.

## Data Stores Manager recovery

Data Stores Manager can inspect key values and metadata, show the last update time and status, browse version history, compare a previous version with the current value, and revert a key when the operator has permission.

A revert conditionally writes a new version. It is not a read-only action.

Deletion is a separate, consequential operation. Marking a store or key for deletion has a cooldown. Backend caches may allow reads or writes to continue briefly after deletion has been scheduled. Do not rely on deletion as an immediate or reversible reset.

## Multiple stores and split profiles

If a profile approaches current size or throughput limits, split only where the access pattern justifies it.

When values must change together, keep them in the same key. If values are split across keys, design a transaction state machine or a recovery process for partial completion. Two separate DataStore writes are not automatically atomic with each other.

Do not change a library-managed key envelope using raw SetAsync or UpdateAsync calls unless the library's documented migration procedure explicitly requires it.
