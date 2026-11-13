<div align="center">

# Roblox Offline Skill

**A focused Roblox engineering skill for persistent player data and reliable offline progression.**

[Repository](https://github.com/lastanswtcf/Roblox-Offline-Skill) · [Core skill](SKILL.md) · [Web AI prompt](web-ai/MASTER_PROMPT.md) · [Roblox documentation index](references/official-roblox-sources.md)

</div>

> [!IMPORTANT]
> This package teaches AI agents how to design, implement, review, and test Roblox data systems. It is not a runtime framework or a drop-in database.

> [!WARNING]
> Roblox DataStores are cloud services. They do not provide a standalone Roblox game that continues to run and save while completely disconnected. Most offline progress systems calculate a bounded catch-up result on the server when the player returns.

## What it covers

- Persistent player profiles and server-authoritative data.
- DataStoreService, OrderedDataStores, MemoryStoreService, Open Cloud, and Creator Hub Data Stores Manager.
- Profile loading, session ownership, session locking, autosaving, retries, and shutdown.
- Idle income, crops, pets, generators, machines, cooldowns, and away-time progression.
- Data validation, migrations, recovery, purchase receipts, and data integrity.
- Safe Studio testing, staging environments, quotas, and performance.

## Architecture at a glance

| Roblox component | Use it for | Do not use it as |
|---|---|---|
| DataStoreService | Persistent data between sessions | Local file storage |
| OrderedDataStore | Ordered numeric values such as persistent leaderboard scores | A full player profile |
| MemoryStoreService | Temporary cross-server queues, maps, and coordination | Permanent player saves |
| Server memory | The active session's working copy | Durable storage after a crash |
| Creator Hub Data Stores Manager | Inspecting, comparing, and managing stored records | A Luau service or runtime API |
| Offline progression | Server-side catch-up based on saved state and elapsed time | A simulation that kept running after the player left |

## Install for coding agents

The skill is installed as a folder containing **SKILL.md** and its supporting **references/** and **examples/** directories.

### Codex, Antigravity, Gemini CLI, GitHub Copilot, and Cursor

Run from the root of the Roblox project:

~~~powershell
New-Item -ItemType Directory -Force ".agents/skills" | Out-Null
git clone https://github.com/lastanswtcf/Roblox-Offline-Skill.git ".agents/skills/roblox-offline-skill"
~~~

This shared **.agents/skills/** location is supported by the listed agents. Platform-specific invocation and alternative commands are in [AI-PLATFORMS.md](AI-PLATFORMS.md).

### Claude Code

Run from the root of the Roblox project:

~~~powershell
New-Item -ItemType Directory -Force ".claude/skills" | Out-Null
git clone https://github.com/lastanswtcf/Roblox-Offline-Skill.git ".claude/skills/roblox-offline-skill"
~~~

### Update an existing installation

Run the following from inside the installed skill directory:

~~~powershell
git pull --ff-only
~~~

Do not clone over an existing directory. For a fresh install, choose a new destination or remove the old copy deliberately.

## Use with web-based AI assistants

Web chat products do not all load local Agent Skills automatically. Use the dedicated [web AI master prompt](web-ai/MASTER_PROMPT.md).

| Platform | Recommended setup |
|---|---|
| ChatGPT web | Add the master prompt to a ChatGPT Project's sources and add the short Project instruction included in that file |
| Claude.ai | Upload a ZIP containing the complete skill folder using Customize → Skills, when Custom Skills are available |
| Gemini web | Import this public GitHub repository as code, or attach the master prompt |
| DeepSeek web | Paste or attach the master prompt, depending on the current chat interface |

A web chat can use the attached prompt as conversation context. A Memory feature, when available, may retain a short summary, but it should not be treated as a permanent copy of the complete skill.

## Repository layout

~~~text
.
├── README.md
├── SKILL.md
├── AI-PLATFORMS.md
├── web-ai/
│   └── MASTER_PROMPT.md
├── references/
│   ├── architecture-and-services.md
│   ├── player-data-lifecycle.md
│   ├── session-locking-and-failures.md
│   ├── offline-progression.md
│   ├── studio-testing.md
│   ├── schema-migrations-and-recovery.md
│   ├── security-and-purchases.md
│   ├── performance-and-limits.md
│   ├── library-selection.md
│   ├── game-patterns.md
│   ├── test-matrix.md
│   └── official-roblox-sources.md
├── examples/
│   ├── offline-progress.luau
│   └── profile-template.luau
├── tests/
│   ├── offline-progress.test.server.luau
│   └── README.md
├── scripts/
│   ├── install.ps1
│   ├── install.sh
│   └── validate.py
└── .github/
    └── workflows/
        └── validate.yml
~~~

## How the skill works

The AI should follow this order:

1. Inspect the actual Roblox experience and its current data architecture.
2. Identify the real stores, keys, schemas, profile library, and all writers.
3. Verify engine behavior against current Roblox Creator Hub documentation.
4. Select the smallest suitable storage design.
5. Keep all canonical player data server-authoritative.
6. Implement safe load, ownership, save, migration, and recovery behavior.
7. Calculate offline progress only after a successful profile load and session acquisition.
8. Test failure paths and report exactly what was and was not executed.

The core workflow and non-negotiable rules are in [SKILL.md](SKILL.md). Detailed material is loaded from **references/** only when relevant.

## Validate the package and examples

Run the repository checks from its root:

~~~powershell
python scripts/validate.py
bash -n scripts/install.sh
~~~

The validator checks required files, SKILL.md metadata and line count, README relative links, referenced resources, Roblox-only URLs in the official source index, and removal of the previous repository name.

A GitHub Actions workflow runs these checks on pushes and pull requests to main.

The Luau calculator test is separate from cloud persistence. Follow [tests/README.md](tests/README.md) to place the ModuleScript and test Script in a staging place, then run it in Roblox Studio. It does not test DataStoreService, session locking, or multi-server behavior.

## Critical safety rules

> [!WARNING]
> Never enable Studio Access to API Services on a live production experience for routine testing. Studio can access the same DataStores as the live application. Use a separate published staging experience.

> [!IMPORTANT]
> A failed profile load is not a new player. Never replace real player data with defaults after a transient service or session error.

> [!CAUTION]
> Never overwrite a key managed by an existing profile library using raw DataStore calls. Never change a live key format or schema without a migration and recovery plan.

> [!NOTE]
> UpdateAsync is a read-modify-write operation. It does not automatically implement session locking, and its transform callback cannot yield.

> [!TIP]
> Store a coherent profile when possible. Update offline rewards and their simulation timestamp together, then persist through the active profile owner.

## Official Roblox documentation

The authoritative Roblox source list is maintained in [references/official-roblox-sources.md](references/official-roblox-sources.md). It contains Roblox Creator Hub documentation only.

Research baseline: **2026-11-13**. Limits and engine behavior can change. Re-check current Roblox documentation before production changes.

## Scope

This is an engineering instruction package. It does not guarantee zero data loss, replace a target-specific security review, or prove a system is production-ready. Every implementation must be adapted and tested against the actual experience.
