# install.ps1 — Install dev-workflow skill for Claude Code
# Usage: .\install.ps1
#
# All sub-skills are bundled within the dev-workflow directory (bundled-skills/).
# They are NOT installed as separate global skills — this ensures zero pollution
# of the user's existing skill setup.

$ErrorActionPreference = "Stop"

$SkillsDir = Join-Path $env:USERPROFILE ".claude\skills"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RuntimeConfig = Join-Path $ScriptDir ".runtime-config"

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

# 3. Install dev-workflow skill (includes all bundled sub-skills)
Write-Host ""
Write-Host "[3/4] Installing dev-workflow skill (includes all bundled sub-skills)..."

$targetDir = Join-Path $SkillsDir "dev-workflow"
if (Test-Path $targetDir) {
    Write-Host "  WARNING: Existing dev-workflow found at $targetDir" -ForegroundColor Yellow
    $reply = Read-Host "  Overwrite? [y/N]"
    if ($reply -ne 'y' -and $reply -ne 'Y') {
        Write-Host "  Skipped. To install alongside, rename the existing directory first."
    } else {
        Remove-Item -Recurse -Force $targetDir
        Copy-Item -Recurse -Force $ScriptDir $targetDir
        # Remove install scripts from the installed copy
        Remove-Item -Force (Join-Path $targetDir "install.sh") -ErrorAction SilentlyContinue
        Remove-Item -Force (Join-Path $targetDir "install.ps1") -ErrorAction SilentlyContinue
        Write-Host "  OK: Overwritten" -ForegroundColor Green
    }
} else {
    Copy-Item -Recurse -Force $ScriptDir $targetDir
    # Remove install scripts from the installed copy
    Remove-Item -Force (Join-Path $targetDir "install.sh") -ErrorAction SilentlyContinue
    Remove-Item -Force (Join-Path $targetDir "install.ps1") -ErrorAction SilentlyContinue
    Write-Host "  OK: Installed to $targetDir" -ForegroundColor Green
}

# Update RuntimeConfig path after installation
$RuntimeConfig = Join-Path $targetDir ".runtime-config"

# 4. Detect Python runtime for ui-ux-pro-max
Write-Host ""
Write-Host "[4/4] Detecting Python runtime for ui-ux-pro-max..."

# Detect Python runtime for ui-ux-pro-max
# Priority: uv > python3 > auto-install uv > none
function Detect-PythonRuntime {
    # 1. Check uv (preferred — auto-manages Python versions)
    $hasUv = Get-Command uv -ErrorAction SilentlyContinue
    if ($hasUv) {
        Set-Content -Path $RuntimeConfig -Value "python_runtime=uv"
        Write-Host "  OK: uv found - will use 'uv run' for ui-ux-pro-max" -ForegroundColor Green
        return
    }

    # 2. Check python3 (fallback — must be real, not Windows Store stub)
    $hasPython3 = Get-Command python3 -ErrorAction SilentlyContinue
    if ($hasPython3) {
        # Verify it's a real Python, not a Windows Store placeholder
        # Windows Store stubs exist at C:\Users\...\AppData\Local\Microsoft\WindowsApps\
        # and will open the Microsoft Store instead of running Python
        try {
            $version = python3 --version 2>&1
            if ($LASTEXITCODE -eq 0 -and $version -match "^Python \d+\.\d+") {
                Set-Content -Path $RuntimeConfig -Value "python_runtime=python3"
                Write-Host "  OK: python3 found ($version) - will use 'python3' for ui-ux-pro-max" -ForegroundColor Green
                return
            } else {
                Write-Host "  WARNING: python3 found but appears to be a Windows Store stub (not real Python)" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "  WARNING: python3 found but failed to execute - likely a Windows Store stub" -ForegroundColor Yellow
        }
    }

    # Also check 'python' (without the 3) — some Windows installs only have 'python'
    $hasPython = Get-Command python -ErrorAction SilentlyContinue
    if ($hasPython) {
        try {
            $version = python --version 2>&1
            if ($LASTEXITCODE -eq 0 -and $version -match "^Python \d+\.\d+") {
                # Exclude Windows Store stub by checking the path
                $pythonPath = (Get-Command python).Source
                if ($pythonPath -notmatch "WindowsApps") {
                    Set-Content -Path $RuntimeConfig -Value "python_runtime=python"
                    Write-Host "  OK: python found ($version) - will use 'python' for ui-ux-pro-max" -ForegroundColor Green
                    return
                } else {
                    Write-Host "  WARNING: python found at WindowsApps path - likely a Windows Store stub" -ForegroundColor Yellow
                }
            }
        } catch {
            # Silently continue to uv installation
        }
    }

    # 3. Neither available — offer to install uv
    Write-Host "  WARNING: ui-ux-pro-max requires a Python runtime but none was found." -ForegroundColor Yellow
    Write-Host "     uv is a lightweight Python runner (~10MB, installs in seconds)."
    $reply = Read-Host "     Install uv now? [Y/n]"
    if ($reply -eq 'n' -or $reply -eq 'N') {
        Write-Host "  SKIPPED: You can install uv manually later:" -ForegroundColor DarkGray
        Write-Host "     powershell -c `"irm https://astral.sh/uv/install.ps1 | iex`""
        Write-Host "     Then re-run this install script."
        Set-Content -Path $RuntimeConfig -Value "python_runtime=none"
        return
    }

    # Auto-install uv
    Write-Host "  Installing uv..." -ForegroundColor Cyan
    try {
        irm https://astral.sh/uv/install.ps1 | iex
        # Verify installation
        $hasUvNow = Get-Command uv -ErrorAction SilentlyContinue
        if ($hasUvNow) {
            Set-Content -Path $RuntimeConfig -Value "python_runtime=uv"
            Write-Host "  OK: uv installed successfully" -ForegroundColor Green
        } else {
            # Installed but not in PATH yet — check common locations
            $uvPaths = @(
                (Join-Path $env:USERPROFILE ".local\bin\uv.exe"),
                (Join-Path $env:USERPROFILE ".cargo\bin\uv.exe"),
                "C:\Users\Administrator\AppData\Local\Microsoft\WinGet\Links\uv.exe"
            )
            $found = $false
            foreach ($uvPath in $uvPaths) {
                if (Test-Path $uvPath) {
                    Set-Content -Path $RuntimeConfig -Value "python_runtime=uv"
                    Write-Host "  OK: uv installed (at $uvPath)" -ForegroundColor Green
                    Write-Host "     You may need to restart your terminal for 'uv' to be in PATH." -ForegroundColor Yellow
                    $found = $true
                    break
                }
            }
            if (-not $found) {
                Write-Host "  WARNING: uv was installed but not found in PATH." -ForegroundColor Yellow
                Write-Host "     Please restart your terminal and re-run this install script."
                Set-Content -Path $RuntimeConfig -Value "python_runtime=none"
            }
        }
    } catch {
        Write-Host "  FAIL: uv installation failed: $_" -ForegroundColor Red
        Write-Host "     You can install manually: https://docs.astral.sh/uv/getting-started/installation/" -ForegroundColor Yellow
        Set-Content -Path $RuntimeConfig -Value "python_runtime=none"
    }
}

Detect-PythonRuntime

# 5. Verify
Write-Host ""
Write-Host "=== Verification ===" -ForegroundColor Cyan

$allInstalled = $true

# Check main skill
$mainSkillFile = Join-Path $SkillsDir "dev-workflow\SKILL.md"
if (Test-Path $mainSkillFile) {
    Write-Host "  OK: dev-workflow" -ForegroundColor Green
} else {
    Write-Host "  FAIL: dev-workflow not found" -ForegroundColor Red
    $allInstalled = $false
}

# Check bundled sub-skills
$bundledSkills = @("brainstorming", "writing-plans", "executing-plans", "using-git-worktrees", "finishing-a-development-branch", "frontend-design", "ui-ux-pro-max")
foreach ($skill in $bundledSkills) {
    $skillFile = Join-Path $SkillsDir "dev-workflow\bundled-skills\$skill\SKILL.md"
    if (Test-Path $skillFile) {
        Write-Host "  OK: bundled-skills\$skill" -ForegroundColor Green
    } else {
        Write-Host "  FAIL: bundled-skills\$skill not found" -ForegroundColor Red
        $allInstalled = $false
    }
}

# Check runtime config
if (Test-Path $RuntimeConfig) {
    $runtimeValue = Get-Content $RuntimeConfig -Raw
    Write-Host "  OK: .runtime-config ($runtimeValue)" -ForegroundColor Green
} else {
    Write-Host "  WARN: .runtime-config not found (ui-ux-pro-max may not work until runtime is detected)" -ForegroundColor Yellow
}

Write-Host ""
if ($allInstalled) {
    Write-Host "Installation complete! The dev-workflow skill is ready." -ForegroundColor Green
    Write-Host ""
    Write-Host "To use: just make any development request in Claude Code."
    Write-Host "The skill will automatically classify and route your request."
    Write-Host ""
    Write-Host "NOTE: Sub-skills are bundled and isolated - they do NOT appear"
    Write-Host "as separate global skills and will NOT conflict with any existing"
    Write-Host "skills you may have installed."
} else {
    Write-Host "WARNING: Some components are missing. Please check the errors above." -ForegroundColor Red
    exit 1
}
