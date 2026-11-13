# Player data lifecycle

## Profile lifecycle

A robust player-data system has one clear owner for each active profile.

1. The server receives PlayerAdded.
2. The persistence layer loads the player's record.
3. Exclusive session ownership is acquired using the selected architecture.
4. The server validates the data and applies supported migrations.
5. Only then is the profile marked ready.
6. Gameplay systems mutate the server-owned in-memory profile.
7. The persistence layer saves periodically and at justified checkpoints.
8. PlayerRemoving triggers final save and release logic.
9. BindToClose gives remaining profiles a bounded final save opportunity.

Do not let gameplay systems mutate a profile before it is ready. Do not mark a profile ready merely because a default table exists.

## First-time player versus load failure

Distinguish these outcomes:

| Outcome | Meaning | Safe response |
|---|---|---|
| Successful load with existing value | Returning player | Validate and load |
| Successful load with nil/missing value | New player, subject to store semantics | Create a default profile under the active owner |
| Network or service failure | Load outcome unavailable | Retry or reject safely |
| Throttling or request-budget exhaustion | Request could not be served normally | Back off and preserve data safety |
| Session conflict | Another server may own the profile | Follow the existing lock policy |
| Corrupt or unsupported data | Payload cannot be safely used | Recovery path; do not silently reset |
| Migration failure | New schema was not safely produced | Do not publish as writable |

A failed read is not proof of a new player. Never create a writable default profile after a transient load failure. This is a common route to overwriting real progress.

If the game deliberately supports a degraded read-only mode, make the mode explicit, prevent canonical writes, and tell the player that progress may not save.

## Server-authoritative working copy

DataStore calls are asynchronous network operations and are subject to platform quotas. Roblox's player-data guidance recommends loading data into server memory and updating the local copy during gameplay, rather than making a DataStore request for every small change.

The working profile should:
- Live on the server.
- Be accessible through controlled profile/data methods.
- Be validated before it is exposed to game systems.
- Be replicated selectively to clients only for display and input.
- Be persisted on a planned schedule and at important checkpoints.

The client may display a balance or inventory, but the server owns the canonical value.

## Save checkpoints

A typical save policy includes periodic autosave, player departure, server shutdown, critical checkpoints such as processing a purchase, and explicit checkpoints for high-value transactions when justified by request budgets.

The autosave interval is a design choice. It must fit current budgets, player counts, record size, and any session-lock expiration policy used by the selected library. Roblox's official player-data sample currently uses a 180-second periodic save interval, but that is a sample choice, not a universal required interval.

Stagger saves across players and servers. Do not start synchronized save bursts.

## PlayerRemoving

PlayerRemoving is one part of the save lifecycle, not the only protection against data loss.

- Stop gameplay mutations for the departing player.
- Route the final save through the same profile owner and ordered queue.
- Release the session only according to the selected persistence implementation.
- Avoid starting a competing save while an autosave or transaction is still in flight.

## BindToClose

Use DataModel:BindToClose for a final server-shutdown save opportunity.

Roblox documents that multiple bound functions run in parallel, the experience server waits up to 30 seconds for bound functions to finish, and the server shuts down after that time even if a function is still running.

Design the shutdown handler to coordinate active profile saves without assuming an unlimited shutdown window. Avoid duplicate concurrent writes from autosave, PlayerRemoving, and BindToClose.

## Lost ownership

When the session owner is lost or a profile library signals that a profile is no longer active:
- Stop profile mutations immediately.
- Stop all pending writes from that former owner.
- Prevent the old server from publishing new state as canonical.
- Follow the selected library's documented policy, commonly removing the player from the experience.

Do not continue saving stale in-memory state after ownership is lost.

## Crash behavior

A server crash may bypass PlayerRemoving and BindToClose. Periodic saves reduce the amount of unsaved data, but cannot guarantee that every in-memory change reaches the backend.

Persisted data can be loaded by a later server. Unsaved in-memory changes can be lost. A RAM retry queue is lost with the process.
