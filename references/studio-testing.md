# Studio and staging tests

## Never test live player data casually

Roblox Studio can access the same DataStores as the live application when Studio access to API services is enabled. Roblox explicitly warns against enabling this setting for live games because Studio tests can overwrite production data.

Use a separate published development or staging experience.

## Safe setup

1. Create a separate development/staging experience.
2. Publish the staging experience.
3. Open Studio's File > Experience Settings > Security.
4. Enable Studio Access to API Services only for the staging experience.
5. Use a distinct test DataStore name, key prefix, or schema where appropriate.
6. Use disposable test accounts and records.
7. Confirm the currently opened experience and store names before running write or delete tests.
8. Keep production Open Cloud keys and credentials out of test files.

If multiple Roblox places share the same experience DataStores, verify that the staging environment is truly isolated at the experience level rather than assuming a different place ID makes it safe.

## Use mocks for logic tests

A mock or in-memory adapter is useful for schema validation, migration functions, offline reward calculations, profile lifecycle logic, retry order, idempotency, failure injection, reconnect, and stale-session scenarios.

A mock is not a durable player save. It does not prove that a real Roblox cloud DataStore request will succeed, and it must not be described as a local offline database.

For custom persistence code, define a narrow adapter interface and implement:
- A DataStoreService adapter for server use.
- An in-memory fake for deterministic tests.

The fake should simulate successful reads/writes, missing keys, transient errors, throttling, malformed data, stale owners, and uncertain write outcomes.

## Separate verification levels

| Test type | What it demonstrates | What it does not demonstrate |
|---|---|---|
| Static review | Code and architecture were inspected | Runtime correctness |
| Pure unit test | Isolated calculations and transformations | Roblox network behavior |
| Mock integration | Components cooperate against a fake adapter | Live DataStore behavior |
| Published staging test | Real cloud DataStore operations in the test experience | Production traffic behavior |
| Studio runtime test | Scripts execute in the actual Studio session | Multi-server correctness unless explicitly tested |
| Multi-server test | Session conflicts and concurrent access paths | Every possible production failure |

Do not claim a stronger validation level than was actually performed.

## Safe destructive testing

Test data resets, key deletion, version rollback, and migration recovery only against disposable staging data.

Before any production operation:
- Identify the exact experience, DataStore, scope, key, and current version.
- Confirm the action and expected result.
- Preserve a recovery point.
- Review whether a profile library owns the key.
- Ensure no active server owns the profile being repaired.
- Record what changed.

Never send an AI agent a broad instruction to clear or reset all player data in production.
