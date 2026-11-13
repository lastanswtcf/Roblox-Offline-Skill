# Roblox data architecture and service selection

## DataStoreService

DataStoreService is the Roblox engine service for data that must persist between play sessions. It is stored in Roblox cloud infrastructure and is accessible across places and servers in the same experience.

Access it only from server Scripts or ModuleScripts required by server Scripts. Use stable keys derived from Player.UserId.

Typical APIs include GetDataStore, GetOrderedDataStore, GetAsync, SetAsync, UpdateAsync, IncrementAsync, RemoveAsync, version APIs, and GetRequestBudgetForRequestType. Verify current signatures before using less familiar APIs.

## Standard DataStores

Use a standard DataStore for player profiles, currencies, inventories, upgrades, settings, plot state, and other durable values.

Roblox recommends a small fixed set of stores with stable key patterns rather than one DataStore per player. A common pattern is a PlayerData store with keys such as User_123456.

Keep values that must update atomically together in one key when the profile fits the current per-key limit. Split only for a real size, throughput, or access-pattern reason.

## OrderedDataStores

Use OrderedDataStores for numeric values that can be sorted, commonly persistent leaderboards. Do not store an entire player profile in an OrderedDataStore.

Keep the authoritative profile in a standard DataStore and maintain leaderboard values with an explicit reconciliation policy. Roblox documents that OrderedDataStores do not support normal DataStore metadata and versioning in the same way as standard DataStores.

## MemoryStoreService

MemoryStoreService is a high-throughput, low-latency, temporary data service shared across servers in a live experience. It provides sorted maps, queues, and hash maps.

Use it for matchmaking, short-lived queues, temporary cross-server coordination, ephemeral shared state, and reconstructible caches. Entries expire. It is not the only source of truth for permanent currency, inventory, purchases, or long-term progression.

## Creator Hub Data Stores Manager

Data Stores Manager is an administrative dashboard in Creator Hub. It can display DataStores, keys, values, metadata, update times, storage usage, and versions. It also supports comparing versions and reverting a key to a previous version when the user has the required permissions.

Current navigation documented by Roblox:
1. Open Creator Dashboard and select the experience.
2. Open Configurations.
3. Open Data stores manager.

Reverting is a write and must be reviewed. Deleting a key or store is destructive and has a deletion cooldown. Backend caching may allow reads or writes to continue briefly after deletion is scheduled.

Data Stores Manager is not a service available to game scripts. Runtime access still uses DataStoreService or Open Cloud.

## Open Cloud DataStores

Open Cloud provides external API access to experience DataStores. Use it for trusted backends, support tools, and controlled administrative workflows.

- Keep API keys on a trusted server.
- Use the narrowest permissions required.
- Never ship an Open Cloud key in a Roblox client or LocalScript.
- Rate-limit maintenance tasks because Open Cloud and game-server requests share experience-level budgets.
- Make administrative actions auditable.

## Storage selection

| Requirement | Use |
|---|---|
| Durable player profile | Standard DataStore / DataStoreService |
| Persistent numeric leaderboard | OrderedDataStore |
| Temporary cross-server queue | MemoryStoreService queue |
| Temporary sorted cross-server values | MemoryStoreService sorted map |
| Temporary keyed shared state | MemoryStoreService hash map |
| Current server's active profile | Server memory |
| Inspect or compare stored keys | Creator Hub Data Stores Manager |
| External trusted maintenance | Open Cloud through a protected backend |
| Away-time progression | Standard profile plus server-side catch-up |

## Naming and keys

- Prefer stable UserId-based identifiers over usernames or display names.
- Use a small number of predictable store names.
- Use stable prefixes and document the key schema.
- Keep store names, keys, and scopes within current Roblox limits.
- Preserve existing production naming and scopes until a migration plan has been tested.
- Avoid secrets and unnecessary personal information in keys or metadata.
