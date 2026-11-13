[CmdletBinding()]
param(
    [ValidateSet("codex", "antigravity", "gemini-cli", "claude-code", "copilot", "cursor", "all")]
    [string]$Target = "all",

    [ValidateSet("project", "user")]
    [string]$Scope = "project",

    [string]$ProjectPath = (Get-Location).Path,

    [switch]$Force
)

$ErrorActionPreference = "Stop"

$sourceRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$skillName = "roblox-offline-skill"

$requiredItems = @("SKILL.md", "references", "examples", "web-ai")
foreach ($item in $requiredItems) {
    if (-not (Test-Path -LiteralPath (Join-Path $sourceRoot $item))) {
        throw "Required package item is missing: $item"
    }
}

$projectDirectories = @{
    "codex"       = ".agents/skills"
    "antigravity" = ".agents/skills"
    "gemini-cli"  = ".agents/skills"
    "copilot"     = ".agents/skills"
    "cursor"      = ".agents/skills"
    "claude-code" = ".claude/skills"
}

$userDirectories = @{
    "codex"       = ".agents/skills"
    "antigravity" = ".gemini/config/skills"
    "gemini-cli"  = ".agents/skills"
    "copilot"     = ".copilot/skills"
    "cursor"      = ".cursor/skills"
    "claude-code" = ".claude/skills"
}

$selectedTargets = if ($Target -eq "all") {
    @("codex", "antigravity", "gemini-cli", "copilot", "cursor", "claude-code")
} else {
    @($Target)
}

$directoryMap = if ($Scope -eq "project") { $projectDirectories } else { $userDirectories }
$basePath = if ($Scope -eq "project") {
    (Resolve-Path -LiteralPath $ProjectPath).Path
} else {
    $HOME
}

$destinations = @{}
foreach ($platform in $selectedTargets) {
    $relativeRoot = $directoryMap[$platform]
    $parentPath = Join-Path $basePath $relativeRoot
    $destinationPath = Join-Path $parentPath $skillName
    $normalized = [IO.Path]::GetFullPath($destinationPath)

    if (-not $destinations.ContainsKey($normalized)) {
        $destinations[$normalized] = $platform
    }
}

$packageItems = @("SKILL.md", "references", "examples", "web-ai", "AI-PLATFORMS.md")

foreach ($destinationPath in $destinations.Keys) {
    $parentPath = Split-Path -Parent $destinationPath
    New-Item -ItemType Directory -Path $parentPath -Force | Out-Null

    if (Test-Path -LiteralPath $destinationPath) {
        if (-not $Force) {
            throw "Destination already exists: $destinationPath. Review it, or rerun with -Force to replace only this skill folder."
        }

        Remove-Item -LiteralPath $destinationPath -Recurse -Force
    }

    New-Item -ItemType Directory -Path $destinationPath -Force | Out-Null

    foreach ($item in $packageItems) {
        $sourceItem = Join-Path $sourceRoot $item
        if (Test-Path -LiteralPath $sourceItem) {
            Copy-Item -LiteralPath $sourceItem -Destination $destinationPath -Recurse -Force
        }
    }

    Write-Host "Installed $skillName to $destinationPath"
}

Write-Host "Installation completed. Open a new agent session or reload skills where the platform requires it."
