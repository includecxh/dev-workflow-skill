# install.ps1 — Install dev-workflow skill + bundled sub-skills for Claude Code
# Usage: .\install.ps1

$ErrorActionPreference = "Stop"

$SkillsDir = Join-Path $env:USERPROFILE ".claude\skills"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "=== dev-workflow installer ===" -ForegroundColor Cyan
Write-Host ""

# 1. Check prerequisites
Write-Host "[1/4] Checking prerequisites..."

$hasClaude = Get-Command claude -ErrorAction SilentlyContinue
if (-not $hasClaude) {
    Write-Host "  WARNING: 'claude' CLI not found. Install Claude Code first: https://claude.com/claude-code" -ForegroundColor Yellow
    Write-Host "  Continuing anyway - the skill will work once Claude Code is installed."
}

$hasGit = Get-Command git -ErrorAction SilentlyContinue
if (-not $hasGit) {
    Write-Host "  ERROR: 'git' is required but not found. Please install git first." -ForegroundColor Red
    exit 1
}

Write-Host "  OK: Prerequisites met" -ForegroundColor Green

# 2. Create skills directory
Write-Host ""
Write-Host "[2/4] Creating skills directory..."
if (-not (Test-Path $SkillsDir)) {
    New-Item -ItemType Directory -Path $SkillsDir -Force | Out-Null
}
Write-Host "  OK: $SkillsDir ready" -ForegroundColor Green

# 3. Install main skill
Write-Host ""
Write-Host "[3/4] Installing dev-workflow skill..."

$targetDir = Join-Path $SkillsDir "dev-workflow"
if (Test-Path $targetDir) {
    Write-Host "  WARNING: Existing dev-workflow found at $targetDir" -ForegroundColor Yellow
    $reply = Read-Host "  Overwrite? [y/N]"
    if ($reply -ne 'y' -and $reply -ne 'Y') {
        Write-Host "  Skipped. To install alongside, rename the existing directory first."
    } else {
        Remove-Item -Recurse -Force $targetDir
        Copy-Item -Recurse -Force $ScriptDir $targetDir
        # Remove install scripts from the installed copy (they're only needed during install)
        Write-Host "  OK: Overwritten" -ForegroundColor Green
    }
} else {
    Copy-Item -Recurse -Force $ScriptDir $targetDir
    Write-Host "  OK: Installed to $targetDir" -ForegroundColor Green
}

# 4. Install bundled sub-skills
Write-Host ""
Write-Host "[4/4] Installing bundled sub-skills..."

$BundledDir = Join-Path $ScriptDir "bundled-skills"
$SkillsToInstall = @("brainstorming", "writing-plans", "executing-plans", "using-git-worktrees", "finishing-a-development-branch")
$OptionalSkills = @("ui-ux-pro-max")

foreach ($skill in $SkillsToInstall) {
    $skillTarget = Join-Path $SkillsDir $skill
    if (Test-Path $skillTarget) {
        # Check if existing version has dual-mode support
        $skillFile = Join-Path $skillTarget "SKILL.md"
        $hasDualMode = $false
        if (Test-Path $skillFile) {
            $content = Get-Content $skillFile -Raw -ErrorAction SilentlyContinue
            if ($content -match "Merged|Sequential") {
                $hasDualMode = $true
            }
        }

        if ($hasDualMode) {
            Write-Host "  SKIP: $skill - already has dual-mode support" -ForegroundColor DarkGray
            continue
        } else {
            Write-Host "  WARNING: $skill - existing version lacks dual-mode support" -ForegroundColor Yellow
            $reply = Read-Host "  Replace with bundled version? [y/N]"
            if ($reply -ne 'y' -and $reply -ne 'Y') {
                Write-Host "  SKIP: The workflow may not work correctly with the original version." -ForegroundColor DarkGray
                continue
            }
            Remove-Item -Recurse -Force $skillTarget
        }
    }

    $skillSource = Join-Path $BundledDir $skill
    Copy-Item -Recurse -Force $skillSource $skillTarget
    Write-Host "  OK: $skill installed" -ForegroundColor Green
}

# 4b. Install optional frontend skill (ui-ux-pro-max)
foreach ($skill in $OptionalSkills) {
    $skillTarget = Join-Path $SkillsDir $skill
    if (Test-Path $skillTarget) {
        Write-Host "  SKIP: $skill - already installed" -ForegroundColor DarkGray
        continue
    }
    $skillSource = Join-Path $BundledDir $skill
    Copy-Item -Recurse -Force $skillSource $skillTarget
    Write-Host "  OK: $skill installed (frontend design support)" -ForegroundColor Green
}

# 5. Verify
Write-Host ""
Write-Host "=== Verification ===" -ForegroundColor Cyan

$allInstalled = $true

$mainSkillFile = Join-Path $SkillsDir "dev-workflow\SKILL.md"
if (Test-Path $mainSkillFile) {
    Write-Host "  OK: dev-workflow" -ForegroundColor Green
} else {
    Write-Host "  FAIL: dev-workflow not found" -ForegroundColor Red
    $allInstalled = $false
}

foreach ($skill in $SkillsToInstall) {
    $skillFile = Join-Path $SkillsDir "$skill\SKILL.md"
    if (Test-Path $skillFile) {
        Write-Host "  OK: $skill" -ForegroundColor Green
    } else {
        Write-Host "  FAIL: $skill not found" -ForegroundColor Red
        $allInstalled = $false
    }
}

Write-Host ""
if ($allInstalled) {
    Write-Host "Installation complete! The dev-workflow skill is ready." -ForegroundColor Green
    Write-Host ""
    Write-Host "To use: just make any development request in Claude Code."
    Write-Host "The skill will automatically classify and route your request."
} else {
    Write-Host "WARNING: Some skills are missing. Please check the errors above." -ForegroundColor Red
    exit 1
}
