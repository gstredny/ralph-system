#!/bin/bash
# Usage: ./ralph-status.sh [prd-file.json]
# If no file specified, finds all prd-*.json or falls back to prd.json

echo "═══════════════════════════════════════"
echo "  Ralph Status"
echo "═══════════════════════════════════════"

# Find PRD file
if [ -n "$1" ] && [ -f "$1" ]; then
    PRD_FILE="$1"
elif ls prd-*.json 1>/dev/null 2>&1; then
    # List all named PRD files
    PRD_FILES=(prd-*.json)
    if [ ${#PRD_FILES[@]} -eq 1 ]; then
        PRD_FILE="${PRD_FILES[0]}"
    else
        echo "📂 Multiple PRD files found:"
        for f in "${PRD_FILES[@]}"; do
            passes=$(jq '[.userStories[] | select(.passes==true)] | length' "$f" 2>/dev/null || echo "?")
            total=$(jq '.userStories | length' "$f" 2>/dev/null || echo "?")
            echo "   $f ($passes/$total)"
        done
        echo ""
        echo "Specify one: ./ralph-status.sh prd-feature.json"
        exit 0
    fi
elif [ -f "prd.json" ]; then
    PRD_FILE="prd.json"
else
    echo "  No prd.json or prd-*.json found"
    exit 1
fi

# Extract progress file name from PRD name
PRD_BASENAME=$(basename "$PRD_FILE" .json)
if [[ "$PRD_BASENAME" == "prd" ]]; then
    PROGRESS_FILE="progress.txt"
else
    FEATURE_NAME=${PRD_BASENAME#prd-}
    PROGRESS_FILE="progress-$FEATURE_NAME.txt"
fi

echo "📄 PRD: $PRD_FILE"
cat "$PRD_FILE" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    project = data.get('project', 'Unknown')
    branch = data.get('branchName', 'N/A')
    stories = data.get('userStories', [])
    passing = [s for s in stories if s.get('passes')]
    failing = [s for s in stories if not s.get('passes')]
    print(f'   Project: {project}')
    print(f'   Branch: {branch}')
    print(f'   Progress: {len(passing)} / {len(stories)} stories')
    if failing:
        print(f'   Next: {failing[0][\"id\"]}: {failing[0][\"title\"][:45]}...')
    else:
        print('   ✅ All stories complete!')
except Exception as e:
    print(f'   Error: {e}')
"

echo ""
echo "📝 Recent progress ($PROGRESS_FILE):"
if [ -f "$PROGRESS_FILE" ]; then
    tail -10 "$PROGRESS_FILE"
else
    echo "  No progress file yet"
fi

echo ""
echo "🧠 CLAUDE.md (learnings):"
if [ -f "CLAUDE.md" ]; then
    echo "  Found: ./CLAUDE.md"
    grep -E "^## (Patterns|Gotchas|Context)" CLAUDE.md 2>/dev/null | head -3 || echo "  (no sections yet)"
else
    echo "  None yet - will be created on first learning"
fi

echo ""
echo "⚠️  Blocked items:"
if [ -f "$PROGRESS_FILE" ]; then
    blocked=$(grep -i "BLOCKED:" "$PROGRESS_FILE" 2>/dev/null)
    if [ -n "$blocked" ]; then
        echo "$blocked"
    else
        echo "  None"
    fi
else
    echo "  No progress file"
fi

echo "═══════════════════════════════════════"
