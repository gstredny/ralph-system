#!/bin/bash
# Initialize a new Ralph project

PROJECT_NAME=${1:-$(basename $(pwd))}
BRANCH_NAME="ralph/$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Initializing Ralph project: $PROJECT_NAME"

# Create prd.json template
if [ ! -f "prd.json" ]; then
    cat > prd.json << EOF
{
  "project": "$PROJECT_NAME",
  "branchName": "$BRANCH_NAME",
  "description": "TODO: Describe what you're building",
  "userStories": []
}
EOF
    echo "✅ Created prd.json (empty - run /interview to populate)"
else
    echo "ℹ️  prd.json already exists"
fi

# Create progress.txt
if [ ! -f "progress.txt" ]; then
    cat > progress.txt << EOF
# Ralph Progress Log
Project: $PROJECT_NAME
Branch: $BRANCH_NAME
Started: $(date)
---
EOF
    echo "✅ Created progress.txt"
fi

# Copy CLAUDE.md from template (don't overwrite if exists)
if [ ! -f "CLAUDE.md" ]; then
    if [ -f "$SCRIPT_DIR/templates/CLAUDE.md" ]; then
        cp "$SCRIPT_DIR/templates/CLAUDE.md" CLAUDE.md
        # Replace placeholder with project name (macOS + Linux compatible)
        sed -i "s/# Project Workflow/# $PROJECT_NAME Workflow/" CLAUDE.md 2>/dev/null || \
        sed -i '' "s/# Project Workflow/# $PROJECT_NAME Workflow/" CLAUDE.md
        echo "✅ Created CLAUDE.md with Ralph workflow"
    else
        echo "⚠️  No CLAUDE.md template found at $SCRIPT_DIR/templates/CLAUDE.md"
    fi
else
    echo "ℹ️  CLAUDE.md already exists"
fi

# Init git if needed
if [ ! -d ".git" ]; then
    git init
    echo "✅ Initialized git"
fi

echo ""
echo "📋 Next steps:"
echo "  1. Run /interview to create user stories in prd.json"
echo "  2. Review prd.json"
echo "  3. Run: ~/ralph-system/ralph-loop.sh 20"
echo ""
echo "⚠️  Do NOT run ralph-loop.sh until prd.json has userStories!"
