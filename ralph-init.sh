#!/bin/bash
# Initialize a new Ralph project

PROJECT_NAME=${1:-$(basename $(pwd))}
BRANCH_NAME="ralph/$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"

echo "🚀 Initializing Ralph project: $PROJECT_NAME"

# Create prd.json template
if [ ! -f "prd.json" ]; then
    cat > prd.json << EOF
{
  "project": "$PROJECT_NAME",
  "branchName": "$BRANCH_NAME",
  "description": "TODO: Describe what you're building",
  "userStories": [
    {
      "id": "US-001",
      "title": "TODO: First task",
      "description": "As a user, I need X so that Y",
      "acceptanceCriteria": [
        "TODO: Specific testable outcome",
        "Tests pass"
      ],
      "priority": 1,
      "passes": false,
      "notes": ""
    }
  ]
}
EOF
    echo "✅ Created prd.json"
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

# Create CLAUDE.md if missing
if [ ! -f "CLAUDE.md" ]; then
    cat > CLAUDE.md << EOF
# $PROJECT_NAME

## Patterns
<!-- Add patterns discovered during development -->

## Gotchas
<!-- Add gotchas and things to watch out for -->

## Context
<!-- Add useful context about the codebase -->
EOF
    echo "✅ Created CLAUDE.md"
fi

# Init git if needed
if [ ! -d ".git" ]; then
    git init
    echo "✅ Initialized git"
fi

echo ""
echo "📋 Next steps:"
echo "  1. Edit prd.json with your user stories"
echo "     OR run /interview to generate it"
echo "  2. Run: ~/ralph-system/ralph-loop.sh 20"
echo "  3. Monitor: ~/ralph-system/ralph-status.sh"
