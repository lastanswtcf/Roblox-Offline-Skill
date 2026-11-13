# Offline progression

## Define offline correctly

In most Roblox idle, simulator, farming, tycoon, and pet games, offline progression means:
1. Save the state and timestamp needed to calculate production.
2. The player leaves.
3. The player returns later.
4. A server loads the profile and calculates a bounded catch-up result.
5. The server updates the profile and displays the result.

The world does not need to remain active for the player's entire absence. This is a mathematical catch-up calculation, not proof that a private plot or server kept running.

A fully disconnected Roblox client cannot communicate with Roblox cloud DataStores. A server-side RAM cache is volatile and cannot guarantee persistence through a crash.

## State to persist

Persist the minimum canonical state required to reproduce progression:
- LastSimulationAt or LastClaimedAt as a server-side epoch timestamp.
- Owned generators, machines, crops, pets, plots, or production assets.
- Levels, upgrades, rates, and eligibility, or enough data to derive them from server-owned definitions.
- Offline efficiency and cap policy version where it can change between releases.
- Optional totals for diagnostics and economy analysis.

Do not persist values that can be safely and deterministically derived unless there is a measured reason.

## Correct catch-up sequence

Run after a successful profile load and exclusive session ownership:

1. Validate the profile and production inputs.
2. Read the saved timestamp.
3. Read current server-side epoch time.
4. Compute elapsed time as now minus the saved timestamp.
5. Treat negative elapsed time as an anomaly, not a reward.
6. Clamp elapsed time to a configured maximum.
7. Derive production from validated ownership and server-side definitions.
8. Apply offline efficiency and reward caps.
9. Update both reward/state and timestamp together in the profile working copy.
10. Persist through the active profile owner.
11. Replicate the result to the client for presentation.

Use a server-side epoch timestamp such as os.time(). DateTime.now().UnixTimestamp is also an epoch timestamp, but calculate authoritative values on the server. Do not persist os.clock() as a timestamp for comparison across server sessions.

## Basic constant-rate calculation

    rawElapsed = now - lastSimulationAt
    elapsed = clamp(rawElapsed, 0, maxOfflineSeconds)
    rawReward = ratePerSecond * elapsed * offlineEfficiency
    reward = min(rawReward, maxOfflineReward)

The rate, duration cap, efficiency, and reward cap must come from trusted server configuration and validated server-owned state.

If the game stores multiple generators, derive each generator's contribution from its saved ownership and upgrade state. Do not trust a client-provided production rate.

## Atomicity and duplicate claims

Reward and timestamp must be advanced in the same coherent profile mutation.

If reward is saved without its timestamp, the next load can award the same interval again. If the timestamp is advanced without the reward, the player can lose the interval.

With a single profile key, update the reward and timestamp together in the profile data and save through the active owner. If data is split over multiple keys, define a transaction/recovery protocol instead of assuming two writes are atomic.

Do not apply catch-up concurrently from two servers. Session ownership must already be established.

## Caps and edge cases

Define and test:
- Maximum offline duration.
- Offline efficiency relative to online production.
- Maximum reward.
- Which assets continue producing while away.
- Whether boosts expire during absence.
- Whether a player can earn on multiple plots or slots.
- Whether partial crop cycles progress while away.
- How game updates affect old production rules.
- Handling for missing or malformed timestamps.
- Handling for future timestamps and clock anomalies.
- Handling for zero, negative, non-finite, or unreasonably large rates.

A future timestamp should not create negative rewards or a later unbounded catch-up. Use a deliberate safe recovery policy and log the anomaly.

## Crops, machines, pets, and timers

For independently progressing objects, store the object state and timestamp needed to reconstruct it correctly.

Examples:
- Crops: crop type, growth start time, growth duration, stage rules, and harvest state.
- Generators: stable type identifier, level, upgrades, and production rules.
- Pets: stable pet ID, equipped/owned status, level, and server-defined production or multiplier.
- Machines: processing recipe, start time, duration, and output rules.
- Cooldowns: last activation or next eligible time.

Use bounded state transitions or direct time calculations. Do not loop once per second for an absence lasting hours or days.

Do not double-count online production and offline catch-up. Define the exact timestamp boundary represented by each saved snapshot.

## Reward timing and client UI

The server owns the amount and eligibility. The client may display an offline summary, animate a reward, show a timer, or request a claim interaction if the game uses one.

The client must not decide authoritative elapsed time, rate, amount, or timestamp. Do not grant currency merely because a client reports that an animation completed.

## What offline progression does not solve

It does not:
- Make DataStoreService work without Roblox connectivity.
- Preserve unsaved in-memory changes after a crash.
- Keep a player's Workspace or private plot simulating while no server is running.
- Replace session locking.
- Make a mock store into a production database.
- Guarantee a particular reward unless the saved snapshot and calculation rules support it.
