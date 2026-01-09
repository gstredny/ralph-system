#!/bin/bash
set -e

PROJECT_NAME=${1:-$(basename $(pwd))}

echo "Initializing Ralph project: $PROJECT_NAME"

# Create PRD from template
if [ ! -f "prd.md" ]; then
    cp ~/ralph-system/templates/prd-template.md prd.md
    sed -i "s/PROJECT_NAME/$PROJECT_NAME/g" prd.md 2>/dev/null || sed -i '' "s/PROJECT_NAME/$PROJECT_NAME/g" prd.md
    echo "Created prd.md"
else
    echo "prd.md already exists, skipping"
fi

# Create progress.txt
if [ ! -f "progress.txt" ]; then
    cat > progress.txt << EOF
=== Progress Log for $PROJECT_NAME ===
Initialized: $(date)
---
EOF
    echo "Created progress.txt"
fi

# Init git if needed
if [ ! -d ".git" ]; then
    git init
    echo "Initialized git"
fi

# Init beads if available
if command -v bd &> /dev/null; then
    if [ ! -d ".beads" ]; then
        bd init --quiet
        echo "Initialized beads"
    fi
fi

echo ""
echo "Next steps:"
echo "  1. Edit prd.md with your tasks (or run /interview @prd.md)"
echo "  2. Run: ~/ralph-system/ralph-loop.sh 20"
echo ""
echo "  Or for single iteration:"
echo "  claude --dangerously-skip-permissions -p '@prd.md @progress.txt \$(cat ~/ralph-system/templates/PROMPT.md)'"
