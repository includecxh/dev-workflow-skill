#!/usr/bin/env bash
# install.sh — Install dev-workflow skill for Claude Code
# Usage: bash install.sh
#
# All sub-skills are bundled within the dev-workflow directory (bundled-skills/).
# They are NOT installed as separate global skills — this ensures zero pollution
# of the user's existing skill setup.

set -euo pipefail

SKILLS_DIR="$HOME/.claude/skills"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNTIME_CONFIG="$SCRIPT_DIR/.runtime-config"

echo "=== dev-workflow installer ==="
echo ""

# 1. Check prerequisites
echo "[1/4] Checking prerequisites..."

if ! command -v claude &>/dev/null; then
    echo "  ⚠️  'claude' CLI not found. Install Claude Code first: https://claude.com/claude-code"
    echo "  Continuing anyway — the skill will work once Claude Code is installed."
fi

if ! command -v git &>/dev/null; then
    echo "  ❌ 'git' is required but not found. Please install git first."
    exit 1
fi

echo "  ✅ Prerequisites met"

# 2. Create skills directory
echo ""
echo "[2/4] Creating skills directory..."
mkdir -p "$SKILLS_DIR"
echo "  ✅ $SKILLS_DIR ready"

# 3. Install dev-workflow skill (includes all bundled sub-skills)
echo ""
echo "[3/4] Installing dev-workflow skill (includes all bundled sub-skills)..."

# Check for existing installation
if [ -d "$SKILLS_DIR/dev-workflow" ]; then
    echo "  ⚠️  Existing dev-workflow found at $SKILLS_DIR/dev-workflow"
    read -p "  Overwrite? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "  Skipped. To install alongside, rename the existing directory first."
    else
        rm -rf "$SKILLS_DIR/dev-workflow"
        cp -r "$SCRIPT_DIR" "$SKILLS_DIR/dev-workflow"
        # Remove install scripts from the installed copy
        rm -f "$SKILLS_DIR/dev-workflow/install.sh" "$SKILLS_DIR/dev-workflow/install.ps1"
        echo "  ✅ Overwritten"
    fi
else
    cp -r "$SCRIPT_DIR" "$SKILLS_DIR/dev-workflow"
    # Remove install scripts from the installed copy
    rm -f "$SKILLS_DIR/dev-workflow/install.sh" "$SKILLS_DIR/dev-workflow/install.ps1"
    echo "  ✅ Installed to $SKILLS_DIR/dev-workflow"
fi

# Update RUNTIME_CONFIG path after installation
RUNTIME_CONFIG="$SKILLS_DIR/dev-workflow/.runtime-config"

# 4. Detect Python runtime for ui-ux-pro-max
echo ""
echo "[4/4] Detecting Python runtime for ui-ux-pro-max..."

# Detect Python runtime for ui-ux-pro-max
# Priority: uv > python3 > auto-install uv > none
detect_python_runtime() {
    # 1. Check uv (preferred — auto-manages Python versions)
    if command -v uv &>/dev/null; then
        echo "python_runtime=uv" > "$RUNTIME_CONFIG"
        echo "  ✅ uv found — will use 'uv run' for ui-ux-pro-max"
        return 0
    fi

    # 2. Check python3 (fallback — must be real, not Windows Store stub)
    if command -v python3 &>/dev/null; then
        # Verify it's a real Python, not a Windows Store placeholder
        if python3 --version &>/dev/null 2>&1; then
            echo "python_runtime=python3" > "$RUNTIME_CONFIG"
            echo "  ✅ python3 found — will use 'python3' for ui-ux-pro-max"
            return 0
        else
            echo "  ⚠️  python3 found but appears to be a Windows Store stub (not real Python)"
        fi
    fi

    # 3. Neither available — offer to install uv
    echo "  ⚠️  ui-ux-pro-max requires a Python runtime but neither uv nor python3 was found."
    echo "     uv is a lightweight Python runner (~10MB, installs in seconds)."
    read -p "     Install uv now? [Y/n] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        echo "  ⏭️  Skipped. You can install uv manually later:"
        echo "     curl -LsSf https://astral.sh/uv/install.sh | sh"
        echo "     Then re-run this install script."
        echo "python_runtime=none" > "$RUNTIME_CONFIG"
        return 0
    fi

    # Auto-install uv
    echo "  📦 Installing uv..."
    if curl -LsSf https://astral.sh/uv/install.sh | sh 2>/dev/null; then
        # Verify installation — uv may need PATH refresh
        if command -v uv &>/dev/null; then
            echo "python_runtime=uv" > "$RUNTIME_CONFIG"
            echo "  ✅ uv installed successfully"
            return 0
        else
            # Installed but not in PATH yet (common on first install)
            # Check common install locations
            local uv_paths=("$HOME/.local/bin/uv" "$HOME/.cargo/bin/uv")
            for uv_path in "${uv_paths[@]}"; do
                if [ -x "$uv_path" ]; then
                    echo "python_runtime=uv" > "$RUNTIME_CONFIG"
                    echo "  ✅ uv installed successfully (at $uv_path)"
                    echo "     You may need to restart your terminal for 'uv' to be in PATH."
                    return 0
                fi
            done
            echo "  ⚠️  uv was installed but not found in PATH."
            echo "     Please restart your terminal and re-run this install script."
            echo "python_runtime=none" > "$RUNTIME_CONFIG"
            return 0
        fi
    else
        echo "  ❌ uv installation failed."
        echo "     You can install manually: https://docs.astral.sh/uv/getting-started/installation/"
        echo "python_runtime=none" > "$RUNTIME_CONFIG"
        return 0
    fi
}

detect_python_runtime

# 5. Verify
echo ""
echo "=== Verification ==="

INSTALLED=true

# Check main skill
if [ ! -f "$SKILLS_DIR/dev-workflow/SKILL.md" ]; then
    echo "  ❌ dev-workflow not found"
    INSTALLED=false
else
    echo "  ✅ dev-workflow"
fi

# Check bundled sub-skills
BUNDLED_SKILLS=("brainstorming" "writing-plans" "executing-plans" "using-git-worktrees" "finishing-a-development-branch" "frontend-design" "ui-ux-pro-max")
for skill in "${BUNDLED_SKILLS[@]}"; do
    if [ ! -f "$SKILLS_DIR/dev-workflow/bundled-skills/$skill/SKILL.md" ]; then
        echo "  ❌ bundled-skills/$skill not found"
        INSTALLED=false
    else
        echo "  ✅ bundled-skills/$skill"
    fi
done

# Check runtime config
if [ -f "$RUNTIME_CONFIG" ]; then
    echo "  ✅ .runtime-config ($(grep python_runtime "$RUNTIME_CONFIG"))"
else
    echo "  ⚠️  .runtime-config not found (ui-ux-pro-max may not work until runtime is detected)"
fi

echo ""
if $INSTALLED; then
    echo "🎉 Installation complete! The dev-workflow skill is ready."
    echo ""
    echo "To use: just make any development request in Claude Code."
    echo "The skill will automatically classify and route your request."
    echo ""
    echo "NOTE: Sub-skills are bundled and isolated — they do NOT appear"
    echo "as separate global skills and will NOT conflict with any existing"
    echo "skills you may have installed."
else
    echo "⚠️  Some components are missing. Please check the errors above."
    exit 1
fi
