# Security, purchases, and data integrity

## Server authority

All canonical player data and rewards must be controlled by the server. Derive the player's identity from the server-side Player instance.

Never trust client-submitted:
- UserId or target profile key.
- Currency balances or purchase prices.
- Item ownership, inventory contents, or equipment.
- Production rates, reward amounts, upgrade levels, or eligibility.
- Offline timestamps or elapsed time.
- Admin permissions or transaction state.

Validate every RemoteEvent and RemoteFunction argument for type, range, length, ownership, state, and rate limits.

Replicate only data the client needs for presentation. Client values are not authoritative save data.

## Validate loaded records

A successful DataStore call does not prove the payload is valid.

Validate:
- Top-level type and SchemaVersion.
- Required fields and expected table shapes.
- Numeric values for finite values and allowed ranges.
- Integer constraints where required.
- String length and accepted identifiers.
- Inventory counts and collection sizes.
- Asset IDs against server-owned definitions.
- Timestamp plausibility.
- Cross-field invariants such as balances, equipped items, ownership, and upgrade limits.

Do not silently wipe or replace a corrupt profile with defaults. Preserve a recovery path and log enough context to investigate without exposing secrets or unnecessary personal data.

## Developer Products

Use MarketplaceService.ProcessReceipt on the server as the authority for Developer Product fulfillment.

Design receipt handling to be idempotent:
- Identify a receipt using the Roblox-provided receipt identity.
- Record the receipt and corresponding grant state durably.
- Prevent duplicate callbacks from granting the same reward twice.
- Handle retry and uncertain persistence outcomes safely.
- Return the appropriate receipt decision only after following the game's durable grant policy.

Do not grant a purchase merely because a client prompt event or UI callback says it completed.

Check the current MarketplaceService API reference before implementing callback signatures or changing an existing purchase system.

## Multi-profile operations

Trading, gifting, auctions, and transfers that affect multiple profiles require a transaction protocol.

Define a unique transaction ID, validated participants and ownership, durable transaction states, idempotent steps, recovery of incomplete operations, and compensation or reconciliation behavior if one side completes before the other.

MemoryStore or MessagingService can coordinate servers, but transient messages are not the durable record of a completed transaction.

## Open Cloud credentials

- Store API keys on a trusted backend.
- Use the narrowest available permissions.
- Do not embed credentials in a Roblox client or LocalScript.
- Do not commit secrets to a repository.
- Do not paste live credentials into a prompt or log.
- Rate-limit external administrative scripts because Open Cloud and game-server calls share experience-level budgets.

## User data minimization and erasure

Store only information needed by the experience. Prefer UserId associations and stable key prefixes that make a player's data discoverable for support and erasure workflows.

Roblox documents automated right-to-be-forgotten processing for data stores that use static, predictable store and key patterns. If the schema does not fit that workflow, review Roblox's documented right-to-erasure webhook approach.

When implementing erasure, account for every profile key, purchase record, secondary store, and trusted external copy. Do not delete unrelated or shared game state.
