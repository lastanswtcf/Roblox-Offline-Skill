# Selecting a player-data implementation

## Native DataStoreService

A custom native layer is appropriate when the project needs a small, well-understood persistence surface and the team can implement and test:
- Profile ownership and session locking.
- Per-key request ordering.
- Autosave and shutdown saves.
- Bounded retries and error handling.
- Schema validation and migration.
- Idempotent purchase handling.
- Recovery and observability.

Do not start from a minimal GetAsync/SetAsync snippet and call it production-ready player persistence.

## Roblox's official player-data reference code

Roblox publishes a player data and purchasing reference implementation that demonstrates concepts such as server-side profile management, retries, session locking, and atomic purchase handling.

Roblox explicitly states that this sample is reference code and has not proven itself over a long period in a popular game. Study its architecture and caveats. Do not copy it into a live game without adapting and extensively testing it.

Use the official source index for the current sample and documentation location.

## Third-party profile libraries

A third-party profile library may reduce the work required for session locking, autosaving, and lifecycle management. It is not a Roblox engine service.

Before adopting or changing one:
1. Inspect the exact version in the target project.
2. Review its repository, release history, license, and maintenance.
3. Read its current API and source.
4. Verify session start, session end, autosave, mock, and failure behavior.
5. Determine the exact store names, scopes, key format, and stored envelope.
6. Test old data and migration behavior.
7. Ensure every save path uses the library consistently.

Do not guess library methods from an old tutorial. Do not mix raw DataStore writes with a library-managed key unless its migration instructions explicitly require it.

## Existing libraries

- ProfileStore and ProfileService are third-party profile libraries, not Roblox engine services. Inspect the version actually installed before using their APIs.
- DataStore2 is identified by Roblox as a legacy third-party library. Roblox says not to use it for new experiences. Existing projects should plan a tested migration using Roblox's official migration guidance and a recovery point.

## Decision rule

Prefer the smallest reliable design that meets the real requirement. Do not add a library, extra DataStores, MemoryStore coordination, or external backend just because the technology exists.

Preserve an existing system unless there is a clear technical reason to replace it and a verified migration plan.
