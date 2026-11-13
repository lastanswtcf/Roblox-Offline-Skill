# Performance, quotas, and operational limits

Research baseline: 2026-11-13. Values below are documented by Roblox at this baseline and must be rechecked before production changes.

## Data limits

| Item | Current documented limit |
|---|---:|
| DataStore name | 50 characters |
| Key name | 50 characters |
| Scope | 50 characters |
| Value size per key | 4,194,304 bytes |
| User-defined metadata key | 50 characters |
| User-defined metadata value | 250 characters |
| User-defined metadata total | 300 characters |

Use string.len() to check key/name lengths and HttpService:JSONEncode in tests to estimate serialized values. Keep a safety margin instead of targeting the hard limit.

## Per-key throughput

Roblox currently documents these throughput limits per key, shared across servers in an experience:

| Request type | Throughput |
|---|---:|
| Read | 25 MB per minute |
| Write | 4 MB per minute |

UpdateAsync counts against both read and write throughput. Roblox rounds each request's throughput up to the next kilobyte.

## Experience-level request budgets

Roblox's current standard DataStore experience limits are shared by game servers and Open Cloud. The documented formulas at this baseline include:

| Request type | Shared requests per minute |
|---|---:|
| Standard read | 300 + concurrent users × 40 |
| Standard write | 300 + concurrent users × 20 |
| List | 300 + concurrent users × 2 |
| Remove | 300 + concurrent users × 40 |

These are platform limits, not targets. Server-level limits, key throughput, request queues, and data store type also apply. UpdateAsync consumes both read and write request budgets. Re-check the live limits page rather than hardcoding assumptions.

## Storage allocation

Roblox currently documents the latest-version storage allocation formula:

    500 MB + 1 MB × lifetime user count

A lifetime user is a user who has joined the experience at least once. Only the latest version of each key counts toward storage usage. Roblox compresses DataStore values automatically; avoid pre-compressing unless measurement shows a specific benefit.

## Throttling queues

Roblox currently documents request queues with a maximum of 30 pending requests per queue. When a queue reaches its limit, requests can fail with error codes in the 301–306 range. Queueing and throttling behavior should be handled as an expected operational failure mode.

## Operational guidance

- Use a small fixed set of data stores.
- Use one or a few deterministic keys per player.
- Keep values that must change atomically together.
- Avoid hot shared keys and excessive write frequency.
- Load into server memory and persist at sensible checkpoints.
- Stagger recurring saves and use bounded jitter.
- Observe current request budgets.
- Retry transient failures in order per key.
- Track errors, latency, throttling, payload size, and storage growth.
- Rate-limit Open Cloud maintenance because it shares the experience-level budget.
- Do not treat historic quota values as permanent constants.

## Monitoring

Useful operational signals include load and save success rates, retry counts and terminal failures, session conflicts and lost ownership, request budget at save time, average and maximum profile size, per-key throughput and throttling errors, BindToClose duration, offline reward caps and anomaly counts, and migration success/failure counts.

Avoid logging raw private profile values or secrets.
