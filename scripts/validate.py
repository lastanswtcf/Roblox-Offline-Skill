from __future__ import annotations

import re
import sys
from pathlib import Path
from urllib.parse import urlparse


ROOT = Path(__file__).resolve().parents[1]
REQUIRED_FILES = (
    "README.md",
    "SKILL.md",
    "AI-PLATFORMS.md",
    "web-ai/MASTER_PROMPT.md",
    "references/architecture-and-services.md",
    "references/player-data-lifecycle.md",
    "references/session-locking-and-failures.md",
    "references/offline-progression.md",
    "references/studio-testing.md",
    "references/schema-migrations-and-recovery.md",
    "references/security-and-purchases.md",
    "references/performance-and-limits.md",
    "references/library-selection.md",
    "references/game-patterns.md",
    "references/test-matrix.md",
    "references/official-roblox-sources.md",
    "examples/offline-progress.luau",
    "examples/profile-template.luau",
    "tests/offline-progress.test.server.luau",
    "tests/README.md",
    "scripts/install.ps1",
    "scripts/install.sh",
    "scripts/validate.py",
)


def fail(message: str) -> None:
    print(f"FAIL: {message}")
    raise SystemExit(1)


def read_text(relative_path: str) -> str:
    path = ROOT / relative_path
    if not path.is_file():
        fail(f"Required file is missing: {relative_path}")
    try:
        return path.read_text(encoding="utf-8")
    except UnicodeDecodeError as exc:
        fail(f"File is not valid UTF-8: {relative_path}: {exc}")


def main() -> None:
    missing = [name for name in REQUIRED_FILES if not (ROOT / name).is_file()]
    if missing:
        fail("Missing required files: " + ", ".join(missing))

    readme = read_text("README.md")
    skill = read_text("SKILL.md")
    source_index = read_text("references/official-roblox-sources.md")

    frontmatter = re.match(r"^---\n(.*?)\n---\n", skill, flags=re.DOTALL)
    if not frontmatter:
        fail("SKILL.md has no valid YAML frontmatter block")

    name_match = re.search(r"^name:\s*([a-z0-9-]+)\s*$", frontmatter.group(1), flags=re.MULTILINE)
    description_match = re.search(r"^description:\s*(.+)$", frontmatter.group(1), flags=re.MULTILINE)
    if not name_match or name_match.group(1) != "roblox-offline-skill":
        fail("SKILL.md name must be roblox-offline-skill")
    if not description_match or not description_match.group(1).strip():
        fail("SKILL.md description is missing")

    skill_lines = len(skill.splitlines())
    if skill_lines > 500:
        fail(f"SKILL.md exceeds 500 lines ({skill_lines})")

    markdown_links = re.findall(r"\[[^\]]+\]\(([^)]+)\)", readme)
    for link in markdown_links:
        target = link.strip().split()[0].strip("<>")
        if target.startswith(("https://", "http://", "mailto:", "#")):
            continue
        local_target = target.split("#", 1)[0]
        if local_target and not (ROOT / local_target).exists():
            fail(f"README contains a broken relative link: {target}")

    reference_paths = re.findall(
        r"(?m)^-\s+((?:references|examples)/[A-Za-z0-9_./-]+)",
        skill,
    )
    unresolved_references = [path for path in reference_paths if not (ROOT / path).is_file()]
    if unresolved_references:
        fail("SKILL.md references missing files: " + ", ".join(unresolved_references))

    source_urls = re.findall(r"https://[^\s)<>]+", source_index)
    if not source_urls:
        fail("Official Roblox source index contains no URLs")

    non_roblox_urls = [
        url for url in source_urls
        if urlparse(url).hostname != "create.roblox.com"
    ]
    if non_roblox_urls:
        fail("Official source index must contain Roblox Creator Hub URLs only: " + ", ".join(non_roblox_urls))

    old_repository = "Saver-Roblox-Data-Oflline-" + "Skills"
    checked_files = (
        "README.md",
        "SKILL.md",
        "AI-PLATFORMS.md",
        "web-ai/MASTER_PROMPT.md",
        "references/official-roblox-sources.md",
    )
    for relative_path in checked_files:
        if old_repository in read_text(relative_path):
            fail(f"Old repository name remains in {relative_path}")

    print("Roblox Offline Skill validation passed.")
    print(f"Required files: {len(REQUIRED_FILES)}")
    print(f"SKILL.md lines: {skill_lines}/500")
    print(f"Official Roblox documentation links: {len(source_urls)}")
    print(f"Resolved README links: {len(markdown_links)}")


if __name__ == "__main__":
    main()
