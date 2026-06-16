#!/usr/bin/env bash
# install.sh — Install dev-workflow skill + bundled sub-skills for Claude Code
# Usage: bash install.sh

set -euo pipefail

SKILLS_DIR="$HOME/.claude/skills"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

# 3. Install main skill
echo ""
echo "[3/4] Installing dev-workflow skill..."

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
        echo "  ✅ Overwritten"
    fi
else
    cp -r "$SCRIPT_DIR" "$SKILLS_DIR/dev-workflow"
    echo "  ✅ Installed to $SKILLS_DIR/dev-workflow"
fi

# 4. Install bundled sub-skills
echo ""
echo "[4/4] Installing bundled sub-skills..."

BUNDLED_DIR="$SCRIPT_DIR/bundled-skills"
SKILLS_TO_INSTALL=("brainstorming" "writing-plans" "executing-plans" "using-git-worktrees" "finishing-a-development-branch")
# ui-ux-pro-max has no dual-mode logic, handle separately
OPTIONAL_SKILLS=("ui-ux-pro-max")

for skill in "${SKILLS_TO_INSTALL[@]}"; do
    if [ -d "$SKILLS_DIR/$skill" ]; then
        # Check if existing version has dual-mode support
        if grep -q "Merged\|Sequential" "$SKILLS_DIR/$skill/SKILL.md" 2>/dev/null; then
            echo "  ⏭️  $skill — already has dual-mode support, skipping"
            continue
        else
            echo "  ⚠️  $skill — existing version lacks dual-mode support"
            read -p "  Replace with bundled version? [y/N] " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                echo "  ⏭️  Skipped. The workflow may not work correctly with the original version."
                continue
            fi
            rm -rf "$SKILLS_DIR/$skill"
        fi
    fi

    cp -r "$BUNDLED_DIR/$skill" "$SKILLS_DIR/$skill"
    echo "  ✅ $skill installed"
done

# 4b. Install optional frontend skill (ui-ux-pro-max)
for skill in "${OPTIONAL_SKILLS[@]}"; do
    if [ -d "$SKILLS_DIR/$skill" ]; then
        echo "  ⏭️  $skill — already installed, skipping"
        continue
    fi
    cp -r "$BUNDLED_DIR/$skill" "$SKILLS_DIR/$skill"
    echo "  ✅ $skill installed (frontend design support)"
done

# 5. Verify
echo ""
echo "=== Verification ==="

INSTALLED=true

if [ ! -f "$SKILLS_DIR/dev-workflow/SKILL.md" ]; then
    echo "  ❌ dev-workflow not found"
    INSTALLED=false
else
    echo "  ✅ dev-workflow"
fi

for skill in "${SKILLS_TO_INSTALL[@]}"; do
    if [ ! -f "$SKILLS_DIR/$skill/SKILL.md" ]; then
        echo "  ❌ $skill not found"
        INSTALLED=false
    else
        echo "  ✅ $skill"
    fi
done

echo ""
if $INSTALLED; then
    echo "🎉 Installation complete! The dev-workflow skill is ready."
    echo ""
    echo "To use: just make any development request in Claude Code."
    echo "The skill will automatically classify and route your request."
else
    echo "⚠️  Some skills are missing. Please check the errors above."
    exit 1
fi
