# AI platform installation and usage

Repository: https://github.com/lastanswtcf/Roblox-Offline-Skill  
Skill identifier: roblox-offline-skill

The package uses the common Agent Skill folder structure: one folder with SKILL.md and its supporting resources. Install the entire folder so references and examples remain available.

## Git requirement

Install Git and verify it is available:

~~~powershell
git --version
~~~

The repository is public, so normal HTTPS cloning works. No GitHub token is required for read access.

## Codex CLI and IDE extension

### Project installation

Run from the Roblox project's root:

~~~powershell
New-Item -ItemType Directory -Force ".agents/skills" | Out-Null
git clone https://github.com/lastanswtcf/Roblox-Offline-Skill.git ".agents/skills/roblox-offline-skill"
~~~

### User installation

~~~powershell
New-Item -ItemType Directory -Force "$HOME/.agents/skills" | Out-Null
git clone https://github.com/lastanswtcf/Roblox-Offline-Skill.git "$HOME/.agents/skills/roblox-offline-skill"
~~~

Explicitly invoke the skill with:

~~~text
$roblox-offline-skill
~~~

Codex also selects relevant skills automatically from their name and description. If a recently changed skill is not appearing, start a new Codex session.

## Google Antigravity

### Project installation

Antigravity App, IDE, and CLI discover workspace skills from .agents/skills:

~~~powershell
New-Item -ItemType Directory -Force ".agents/skills" | Out-Null
git clone https://github.com/lastanswtcf/Roblox-Offline-Skill.git ".agents/skills/roblox-offline-skill"
~~~

### Global installation

For Antigravity App and the shared App/CLI global location:

~~~powershell
New-Item -ItemType Directory -Force "$HOME/.gemini/config/skills" | Out-Null
git clone https://github.com/lastanswtcf/Roblox-Offline-Skill.git "$HOME/.gemini/config/skills/roblox-offline-skill"
~~~

Antigravity CLI also recognizes additional CLI-specific global skill paths. The shared config location above is the recommended global choice when using both App and CLI.

Invoke in the agent prompt:

~~~text
/roblox-offline-skill
~~~

After changing files during an active CLI session, refresh skills:

~~~text
/skills reload
~~~

This repository is a standalone skill directory. It is not an Antigravity plugin package.

## Gemini CLI

### Recommended project installation

~~~powershell
gemini skills install https://github.com/lastanswtcf/Roblox-Offline-Skill.git --scope workspace
~~~

To install for the current user instead:

~~~powershell
gemini skills install https://github.com/lastanswtcf/Roblox-Offline-Skill.git --scope user
~~~

Gemini CLI also discovers skills from the interoperable .agents/skills alias. To install manually:

~~~powershell
New-Item -ItemType Directory -Force ".agents/skills" | Out-Null
git clone https://github.com/lastanswtcf/Roblox-Offline-Skill.git ".agents/skills/roblox-offline-skill"
~~~

Useful commands:

~~~text
/skills list
/skills reload
/roblox-offline-skill
~~~

The slash command is generated from the skill name after discovery.

## Claude Code

### Project installation

~~~powershell
New-Item -ItemType Directory -Force ".claude/skills" | Out-Null
git clone https://github.com/lastanswtcf/Roblox-Offline-Skill.git ".claude/skills/roblox-offline-skill"
~~~

### User installation

~~~powershell
New-Item -ItemType Directory -Force "$HOME/.claude/skills" | Out-Null
git clone https://github.com/lastanswtcf/Roblox-Offline-Skill.git "$HOME/.claude/skills/roblox-offline-skill"
~~~

Invoke explicitly:

~~~text
/roblox-offline-skill
~~~

Claude Code can also select the skill automatically when the request matches its description.

## GitHub Copilot

For project-level use, Copilot supports .agents/skills, .github/skills, and .claude/skills. Recommended installation:

~~~powershell
New-Item -ItemType Directory -Force ".agents/skills" | Out-Null
git clone https://github.com/lastanswtcf/Roblox-Offline-Skill.git ".agents/skills/roblox-offline-skill"
~~~

For a user-level install:

~~~powershell
New-Item -ItemType Directory -Force "$HOME/.copilot/skills" | Out-Null
git clone https://github.com/lastanswtcf/Roblox-Offline-Skill.git "$HOME/.copilot/skills/roblox-offline-skill"
~~~

Copilot loads relevant skills automatically. In a prompt, mention that the Roblox Offline Skill should be followed. GitHub CLI also has a skill-management command in supported versions; check the installed command's own help before relying on preview features.

## Cursor

Cursor discovers skills from .agents/skills and .cursor/skills. Recommended project installation:

~~~powershell
New-Item -ItemType Directory -Force ".agents/skills" | Out-Null
git clone https://github.com/lastanswtcf/Roblox-Offline-Skill.git ".agents/skills/roblox-offline-skill"
~~~

For a user-level install:

~~~powershell
New-Item -ItemType Directory -Force "$HOME/.cursor/skills" | Out-Null
git clone https://github.com/lastanswtcf/Roblox-Offline-Skill.git "$HOME/.cursor/skills/roblox-offline-skill"
~~~

Invoke from Cursor Agent:

~~~text
/roblox-offline-skill
~~~

The skill can also be attached as context using the Agent's skill picker.

## Web-based AI assistants

Web chats do not all load local skill directories. Use the self-contained web-ai/MASTER_PROMPT.md when the web product does not support native skill packages.

### ChatGPT web

1. Create or open a ChatGPT Project.
2. Add web-ai/MASTER_PROMPT.md as a Project source.
3. Copy the Project instruction below into Project settings.

Project instruction:

    Before any Roblox player-data, DataStore, persistence, or offline progression task, read the complete Roblox Offline Skill master prompt from the Project sources. Follow its safety rules, inspect the actual project before proposing edits, verify current Roblox behavior using Roblox Creator Hub, and report only tests that were actually run.

If a Memory feature is available and enabled, the AI may retain a short stable summary. Keep the complete master prompt as the source of truth.

### Claude.ai

1. Download the repository ZIP or clone the repository.
2. Put the complete package inside a folder named roblox-offline-skill.
3. Keep SKILL.md, references/, examples/, and web-ai/ inside that folder.
4. ZIP the roblox-offline-skill folder itself.
5. In Claude, open Customize → Skills → Create skill → Upload a skill.
6. Upload the ZIP and enable the skill.

Custom Skills availability depends on the Claude plan and current workspace settings. If the Skills feature is unavailable, attach web-ai/MASTER_PROMPT.md to the conversation.

### Gemini web

Gemini Apps can import code folders and supported GitHub repositories into a chat. Use the repository URL:

    https://github.com/lastanswtcf/Roblox-Offline-Skill

Alternatively, attach web-ai/MASTER_PROMPT.md. Check that the import completed before asking the model to analyze all project files.

### DeepSeek web

Paste the complete contents of web-ai/MASTER_PROMPT.md into the conversation, or attach the Markdown file if file upload is available in the current interface. Ask the model to confirm it has processed the complete document before starting implementation.

## Update an installed copy

Run this from inside the installed roblox-offline-skill directory:

~~~powershell
git pull --ff-only
~~~

Do not clone over an existing destination. If the directory is not a Git clone, use the installer script or replace it deliberately after preserving local modifications.

## Local installer scripts

From the repository root:

~~~powershell
.scriptsinstall.ps1 -Target all -Scope project
~~~

To install for the current Windows user:

~~~powershell
.scriptsinstall.ps1 -Target all -Scope user
~~~

On Linux or macOS:

~~~bash
./scripts/install.sh all project
./scripts/install.sh all user
~~~

The scripts refuse to overwrite an existing installation unless the force option is explicitly supplied. Review any local changes before using force.
