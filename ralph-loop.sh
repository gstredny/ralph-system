#!/bin/bash
# Ralph Wiggum - Long-running AI agent loop
# Based on https://github.com/snarktank/ralph
# Usage: ./ralph-loop.sh [max_iterations]

set -e

MAX_ITERATIONS=${1:-10}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(pwd)"
PRD_FILE="$PROJECT_DIR/prd.json"
PROGRESS_FILE="$PROJECT_DIR/progress.txt"
ARCHIVE_DIR="$PROJECT_DIR/archive"
LAST_BRANCH_FILE="$PROJECT_DIR/.last-branch"
PROMPT_FILE="$SCRIPT_DIR/templates/PROMPT.md"

# Check jq is installed
if ! command -v jq &> /dev/null; then
    echo "❌ jq required. Install with: sudo apt-get install -y jq"
    exit 1
fi

# Check prd.json exists
if [ ! -f "$PRD_FILE" ]; then
    echo "❌ prd.json not found in $PROJECT_DIR"
    echo "Run: ~/ralph-system/ralph-init.sh or /interview to create one"
    exit 1
fi

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
    OUTPUT=$(claude --dangerously-skip-permissions -p "@prd.json @progress.txt $PROMPT" 2>&1 | tee /dev/stderr) || true

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
