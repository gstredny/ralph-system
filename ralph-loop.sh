#!/bin/bash
# Ralph Wiggum - Long-running AI agent loop
# Based on https://github.com/snarktank/ralph
# Usage: ./ralph-loop.sh [prd-file.json] [max_iterations]
# Examples:
#   ./ralph-loop.sh 20                        # Uses prd.json, 20 iterations
#   ./ralph-loop.sh prd-budget-validation.json 20  # Uses named PRD

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(pwd)"

# Parse arguments - supports both orders:
#   ./ralph-loop.sh 20
#   ./ralph-loop.sh 20 prd-feature.json
#   ./ralph-loop.sh prd-feature.json 20
if [[ "$1" =~ ^[0-9]+$ ]]; then
    MAX_ITERATIONS=$1
    if [[ -n "$2" && "$2" == *.json ]]; then
        PRD_FILE="$PROJECT_DIR/$2"
    else
        PRD_FILE="$PROJECT_DIR/prd.json"
    fi
elif [[ -n "$1" && "$1" == *.json ]]; then
    PRD_FILE="$PROJECT_DIR/$1"
    MAX_ITERATIONS=${2:-10}
else
    MAX_ITERATIONS=${1:-10}
    PRD_FILE="$PROJECT_DIR/prd.json"
fi

# Extract feature name from PRD filename for progress file
PRD_BASENAME=$(basename "$PRD_FILE" .json)
if [[ "$PRD_BASENAME" == "prd" ]]; then
    PROGRESS_FILE="$PROJECT_DIR/progress.txt"
else
    # prd-budget-validation.json -> progress-budget-validation.txt
    FEATURE_NAME=${PRD_BASENAME#prd-}
    PROGRESS_FILE="$PROJECT_DIR/progress-$FEATURE_NAME.txt"
fi
ARCHIVE_DIR="$PROJECT_DIR/archive"
LAST_BRANCH_FILE="$PROJECT_DIR/.last-branch"
PROMPT_FILE="$SCRIPT_DIR/templates/PROMPT.md"

# Check jq is installed
if ! command -v jq &> /dev/null; then
    echo "❌ jq required. Install with: sudo apt-get install -y jq"
    exit 1
fi

# Check PRD file exists
if [ ! -f "$PRD_FILE" ]; then
    echo "❌ PRD file not found: $PRD_FILE"
    echo ""
    echo "📋 Ralph Loop requires a structured PRD with user stories."
    echo ""
    echo "To create one:"
    echo "  1. Create idea.md with your rough requirements"
    echo "  2. Run: /interview idea.md  (creates prd-{feature}.json)"
    echo "  3. Review the generated PRD"
    echo "  4. Then run: ~/ralph-system/ralph-loop.sh"
    echo ""
    echo "Or use: ~/ralph-system/ralph-init.sh for blank template"
    exit 1
fi

# Validate PRD has userStories
STORY_COUNT=$(jq '.userStories | length // 0' "$PRD_FILE" 2>/dev/null || echo "0")
if [ "$STORY_COUNT" -eq 0 ]; then
    echo "❌ PRD has no userStories: $PRD_FILE"
    echo ""
    echo "📋 Ralph Loop requires at least 1 user story with:"
    echo "   - id: unique identifier"
    echo "   - title: what to build"
    echo "   - criteria: acceptance criteria"
    echo "   - passes: false (until implemented)"
    echo ""
    echo "Example userStory:"
    echo '  {"id": "US-001", "title": "Add login", "criteria": "User can log in", "passes": false}'
    echo ""
    echo "Generate stories with: /interview idea.md"
    exit 1
fi

echo "📄 Using PRD: $(basename $PRD_FILE) ($STORY_COUNT stories)"

# Archive previous run if branch changed
if [ -f "$LAST_BRANCH_FILE" ]; then
    CURRENT_BRANCH=$(jq -r '.branchName // empty' "$PRD_FILE" 2>/dev/null || echo "")
    LAST_BRANCH=$(cat "$LAST_BRANCH_FILE" 2>/dev/null || echo "")

    if [ -n "$CURRENT_BRANCH" ] && [ -n "$LAST_BRANCH" ] && [ "$CURRENT_BRANCH" != "$LAST_BRANCH" ]; then
        DATE=$(date +%Y-%m-%d)
        FOLDER_NAME=$(echo "$LAST_BRANCH" | sed 's|^ralph/||')
        ARCHIVE_FOLDER="$ARCHIVE_DIR/$DATE-$FOLDER_NAME"

        echo "📦 Archiving previous run: $LAST_BRANCH"
        mkdir -p "$ARCHIVE_FOLDER"
        [ -f "$PRD_FILE" ] && cp "$PRD_FILE" "$ARCHIVE_FOLDER/"
        [ -f "$PROGRESS_FILE" ] && cp "$PROGRESS_FILE" "$ARCHIVE_FOLDER/"
        [ -f "$PROJECT_DIR/CODE_REVIEW.md" ] && cp "$PROJECT_DIR/CODE_REVIEW.md" "$ARCHIVE_FOLDER/"
        echo "   Archived to: $ARCHIVE_FOLDER"

        # Reset progress file for new run
        echo "# Ralph Progress Log" > "$PROGRESS_FILE"
        echo "Started: $(date)" >> "$PROGRESS_FILE"
        echo "Branch: $CURRENT_BRANCH" >> "$PROGRESS_FILE"
        echo "---" >> "$PROGRESS_FILE"
    fi
fi

# Track current branch
CURRENT_BRANCH=$(jq -r '.branchName // empty' "$PRD_FILE" 2>/dev/null || echo "")
if [ -n "$CURRENT_BRANCH" ]; then
    echo "$CURRENT_BRANCH" > "$LAST_BRANCH_FILE"

    # Create git branch if not on it
    if [ "$(git branch --show-current 2>/dev/null)" != "$CURRENT_BRANCH" ]; then
        echo "🌿 Switching to branch: $CURRENT_BRANCH"
        git checkout -b "$CURRENT_BRANCH" 2>/dev/null || git checkout "$CURRENT_BRANCH"
    fi
fi

# Initialize progress file if it doesn't exist
if [ ! -f "$PROGRESS_FILE" ]; then
    echo "# Ralph Progress Log" > "$PROGRESS_FILE"
    echo "Started: $(date)" >> "$PROGRESS_FILE"
    echo "Project: $(jq -r '.project' "$PRD_FILE")" >> "$PROGRESS_FILE"
    echo "Branch: $CURRENT_BRANCH" >> "$PROGRESS_FILE"
    echo "---" >> "$PROGRESS_FILE"
fi

# Show initial status
PROJECT_NAME=$(jq -r '.project' "$PRD_FILE")
TOTAL_STORIES=$(jq '.userStories | length' "$PRD_FILE")
DONE_STORIES=$(jq '[.userStories[] | select(.passes==true)] | length' "$PRD_FILE")

echo "🚀 Starting Ralph - $PROJECT_NAME"
echo "   Stories: $DONE_STORIES / $TOTAL_STORIES complete"
echo "   Max iterations: $MAX_ITERATIONS"
echo ""

for i in $(seq 1 $MAX_ITERATIONS); do
    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo "  Ralph Iteration $i of $MAX_ITERATIONS"
    echo "═══════════════════════════════════════════════════════"

    # Show current progress
    DONE=$(jq '[.userStories[] | select(.passes==true)] | length' "$PRD_FILE")
    TOTAL=$(jq '.userStories | length' "$PRD_FILE")
    NEXT_STORY=$(jq -r '.userStories[] | select(.passes==false) | "\(.id): \(.title)"' "$PRD_FILE" | head -1)
    echo "  Progress: $DONE / $TOTAL stories"
    echo "  Next: $NEXT_STORY"
    echo ""

    # Run Claude with the prompt
    PROMPT=$(cat "$PROMPT_FILE")
    PRD_BASENAME=$(basename "$PRD_FILE")
    PROGRESS_BASENAME=$(basename "$PROGRESS_FILE")
    OUTPUT=$(claude --dangerously-skip-permissions -p "@$PRD_BASENAME @$PROGRESS_BASENAME $PROMPT" 2>&1 | tee /dev/stderr) || true

    # Warn if CLAUDE.md not updated
    if ! git diff --name-only 2>/dev/null | grep -q "CLAUDE.md"; then
        echo ""
        echo "⚠️  CLAUDE.md not updated - consider adding learnings"
    fi

    # Check for completion signal
    if echo "$OUTPUT" | grep -q "<promise>COMPLETE</promise>"; then
        echo ""
        echo "✅ Ralph completed all tasks!"
        echo "   Completed at iteration $i of $MAX_ITERATIONS"
        ~/ralph-system/ralph-validate.sh 2>/dev/null || true
        notify-send "Ralph Complete! 🎉" "All stories finished" 2>/dev/null || true
        echo -e "\a"
        exit 0
    fi

    echo ""
    echo "⏳ Iteration $i complete. Pausing 3s..."
    sleep 3
done

echo ""
echo "⏱️ Ralph reached max iterations ($MAX_ITERATIONS) without completing all tasks."
echo "   Check progress: ~/ralph-system/ralph-status.sh"
echo "   Continue with: ~/ralph-system/ralph-loop.sh $MAX_ITERATIONS"
~/ralph-system/ralph-validate.sh 2>/dev/null || true
notify-send "Ralph paused" "Reached $MAX_ITERATIONS iterations" 2>/dev/null || true
echo -e "\a"
exit 1
