# Official Roblox documentation

This file contains Roblox documentation sources only.

Research baseline: 2026-11-13. Roblox may update API behavior, limits, navigation, and platform policies. Re-open the relevant Creator Hub page before relying on changeable details.

## DataStores and player data

- [Data stores overview](https://create.roblox.com/docs/cloud-services/data-stores)
- [Best practices for data stores](https://create.roblox.com/docs/cloud-services/data-stores/best-practices)
- [Data store limits and error codes](https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits)
- [Data store versioning, listing, and caching](https://create.roblox.com/docs/cloud-services/data-stores/versioning-listing-and-caching)
- [Implement player data and purchasing systems](https://create.roblox.com/docs/cloud-services/data-stores/player-data-purchasing)
- [Data Stores Manager](https://create.roblox.com/docs/cloud-services/data-stores/data-stores-manager)
- [Choose between cloud services](https://create.roblox.com/docs/cloud-services/data-stores-vs-memory-stores)
- [Open Cloud data stores](https://create.roblox.com/docs/cloud/guides/data-stores)
- [Right to be forgotten for DataStores](https://create.roblox.com/docs/cloud-services/data-stores/right-to-be-forgotten)

## Memory and messaging

- [Memory stores](https://create.roblox.com/docs/cloud-services/memory-stores)
- [MessagingService](https://create.roblox.com/docs/reference/engine/classes/MessagingService)

## Engine API references

- [DataStoreService](https://create.roblox.com/docs/reference/engine/classes/DataStoreService)
- [GlobalDataStore](https://create.roblox.com/docs/reference/engine/classes/GlobalDataStore)
- [OrderedDataStore](https://create.roblox.com/docs/reference/engine/classes/OrderedDataStore)
- [MemoryStoreService](https://create.roblox.com/docs/reference/engine/classes/MemoryStoreService)
- [DataModel and BindToClose](https://create.roblox.com/docs/reference/engine/classes/DataModel)
- [MarketplaceService](https://create.roblox.com/docs/reference/engine/classes/MarketplaceService)
- [HttpService](https://create.roblox.com/docs/reference/engine/classes/HttpService)
- [DateTime](https://create.roblox.com/docs/reference/engine/datatypes/DateTime)
- [Player](https://create.roblox.com/docs/reference/engine/classes/Player)
- [RunService](https://create.roblox.com/docs/reference/engine/classes/RunService)

## Revalidation checklist

Before a production change, confirm:
1. The service and API method are still documented and supported.
2. The exact method signature and return values.
3. Current key, payload, throughput, storage, and request-budget limits.
4. Current Studio API-service settings and staging workflow.
5. The active profile library's exact version and storage format.
6. Current version history, deletion, and recovery behavior.
7. Purchase receipt requirements and current MarketplaceService behavior.
8. Current right-to-be-forgotten requirements for the data schema.
