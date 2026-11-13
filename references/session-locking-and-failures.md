# Session locking, concurrency, retries, and failures

## Why session ownership exists

If two servers load the same player's profile and both believe they can write it, a stale in-memory copy can overwrite newer progress. This can cause lost items, duplicated rewards, balance errors, and transaction inconsistencies.

A session-lock design must define:
- Profile owner identity.
- How ownership is acquired and refreshed.
- What happens when a second server requests the same profile.
- How a profile is released.
- How stale sessions are detected and recovered.
- What the former owner must do when ownership is lost.

Using UpdateAsync alone does not automatically implement this protocol. Use the selected profile library's documented lifecycle or build and test a complete lock protocol.

Never force-steal an apparently active session as a routine retry.

## UpdateAsync behavior

Use UpdateAsync when the new value depends on the current stored value or when concurrent updates are possible.

Its transform callback:
- Receives the current value and key information where supported.
- Returns the new value, or nil to cancel the update.
- Cannot yield.
- Must not perform external side effects.
- Should be deterministic and safe to run more than once.

Do not put waits, HTTP requests, remote calls, receipt grants, analytics, Instance creation, or other side effects inside the callback.

UpdateAsync consumes both read and write request budgets.

SetAsync is appropriate for deliberate full-value replacement when the caller has established exclusive ownership and replacement semantics are intended. It can cause inconsistency if multiple servers race on the same key. Do not label it universally forbidden.

## Preserve per-key ordering

Roblox's official player-data guidance demonstrates that a delayed retry can arrive after a newer save and overwrite it.

Unsafe sequence:
1. Save A starts and fails or returns an uncertain result.
2. A retry for A is scheduled.
3. Save B succeeds with newer state.
4. The old retry for A runs afterward and can restore stale data.

Use one serialized write queue per key or a profile library that guarantees ordered operations. Do not launch independent retry loops for the same profile.

A failed response can have an unknown outcome: the backend may have completed a write even if the server did not receive a successful response. Design retried operations to be idempotent.

## Retry policy

A safe retry policy:
- Wrap network calls in pcall or the project's established error-handling layer.
- Retry transient failures only.
- Use exponential backoff with random jitter.
- Cap delay and attempt count.
- Preserve same-key ordering.
- Stop retrying permanent errors such as invalid arguments.
- Report final failure rather than silently dropping it.

Do not recursively retry forever. Do not create one independent retry task for every gameplay event.

## Throttling and request budgets

- Observe DataStoreService:GetRequestBudgetForRequestType for the relevant request type.
- Budgets are dynamic and depend on current experience activity and request type.
- UpdateAsync consumes read and write budgets.
- Game-server and Open Cloud calls share experience-level request budgets.
- Per-key throughput limits also apply.
- Stagger recurring jobs and reduce unnecessary writes.
- Keep DataStore payloads and key access patterns efficient.

Do not copy historic request-limit numbers into code as permanent constants. See performance-and-limits.md for current documented values and links.

## Engine cache

Roblox documents a default local cache window for GetAsync. A fresh read can return cached data rather than observing another server's most recent write immediately.

Do not use a cached GetAsync value as a substitute for session ownership or transactional conflict handling. Review current cache options and behavior before relying on read-after-write semantics.

## Save failure while the server remains alive

- Keep the newest working profile state while ownership remains valid.
- Keep dirty state until the chosen persistence policy confirms a save.
- Retry transient errors in order.
- Surface structured diagnostics without logging secrets.
- Do not release ownership while an unsaved write is still required by the system's policy.
- If ownership is lost, stop writing.
- If the server crashes before persistence succeeds, volatile changes can be lost.

Never claim that an in-memory queue, MemoryStore, or retry loop makes DataStore outages fully durable or crash-proof.
