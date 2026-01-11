#!/bin/bash
# Manually archive current Ralph run

PROJECT_DIR="$(pwd)"
PRD_FILE="$PROJECT_DIR/prd.json"
PROGRESS_FILE="$PROJECT_DIR/progress.txt"
ARCHIVE_DIR="$PROJECT_DIR/archive"

if [ ! -f "$PRD_FILE" ]; then
    echo "❌ No prd.json to archive"
    exit 1
fi

DATE=$(date +%Y-%m-%d)
BRANCH=$(jq -r '.branchName // "unknown"' "$PRD_FILE" | sed 's|^ralph/||')
ARCHIVE_FOLDER="$ARCHIVE_DIR/$DATE-$BRANCH"

echo "📦 Archiving current run..."
mkdir -p "$ARCHIVE_FOLDER"

[ -f "$PRD_FILE" ] && cp "$PRD_FILE" "$ARCHIVE_FOLDER/"
[ -f "$PROGRESS_FILE" ] && cp "$PROGRESS_FILE" "$ARCHIVE_FOLDER/"
[ -f "$PROJECT_DIR/CODE_REVIEW.md" ] && cp "$PROJECT_DIR/CODE_REVIEW.md" "$ARCHIVE_FOLDER/"

echo "✅ Archived to: $ARCHIVE_FOLDER"

# Clean up for next run
rm -f "$PROJECT_DIR/.last-branch"
echo ""
echo "Ready for new prd.json"
