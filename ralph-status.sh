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
    in_progress = [s for s in stories if s.get('status') == 'in_progress']
    blocked = [s for s in stories if s.get('status') == 'blocked']
    remaining = [s for s in stories if not s.get('passes') and s.get('status') not in ('blocked', 'in_progress')]

    print(f'   Project: {project}')
    print(f'   Branch: {branch}')
    print(f'   Progress: {len(passing)} / {len(stories)} stories')

    if in_progress:
        story = in_progress[0]
        print(f'   ⏳ In Progress: {story[\"id\"]}: {story[\"title\"][:40]}...')
        if story.get('lastAttempt'):
            la = story['lastAttempt']
            print(f'      Attempt #{la.get(\"attempts\", 1)}')
            if la.get('blockers'):
                print(f'      Blocker: {la[\"blockers\"][:50]}...')
            if la.get('nextSteps'):
                steps = la['nextSteps']
                if isinstance(steps, list) and steps:
                    print(f'      Next: {steps[0][:50]}...')
    elif remaining:
        story = sorted(remaining, key=lambda x: x.get('priority', 999))[0]
        print(f'   Next: {story[\"id\"]}: {story[\"title\"][:45]}...')
    else:
        print('   ✅ All stories complete!')

    if blocked:
        print(f'   🚫 Blocked: {len(blocked)} stories')
except Exception as e:
    print(f'   Error: {e}')
"

echo ""
echo "⏳ In-Progress Details:"
cat "$PRD_FILE" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    stories = data.get('userStories', [])
    in_progress = [s for s in stories if s.get('status') == 'in_progress']

    if not in_progress:
        print('  None')
    else:
        for story in in_progress:
            print(f'  {story[\"id\"]}: {story[\"title\"]}')
            la = story.get('lastAttempt', {})
            if la:
                print(f'    Timestamp: {la.get(\"timestamp\", \"N/A\")}')
                print(f'    Attempts: {la.get(\"attempts\", 1)}')
                if la.get('learned'):
                    print(f'    Learned: {la[\"learned\"][:80]}...' if len(la.get('learned',''))>80 else f'    Learned: {la.get(\"learned\",\"N/A\")}')
                if la.get('completed'):
                    completed = la['completed']
                    if isinstance(completed, list):
                        for item in completed[:3]:
                            print(f'      ✓ {item}')
                        if len(completed) > 3:
                            print(f'      ... and {len(completed)-3} more')
                if la.get('blockers'):
                    print(f'    Blocker: {la[\"blockers\"]}')
                if la.get('nextSteps'):
                    steps = la['nextSteps']
                    if isinstance(steps, list):
                        print('    Next steps:')
                        for step in steps[:3]:
                            print(f'      → {step}')
except Exception as e:
    print(f'  Error: {e}')
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
echo "🚫 Blocked stories:"
cat "$PRD_FILE" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    stories = data.get('userStories', [])
    blocked = [s for s in stories if s.get('status') == 'blocked']

    if not blocked:
        print('  None')
    else:
        for story in blocked:
            print(f'  {story[\"id\"]}: {story[\"title\"]}')
            if story.get('notes'):
                print(f'    Reason: {story[\"notes\"][:60]}...' if len(story.get('notes',''))>60 else f'    Reason: {story.get(\"notes\")}')
except Exception as e:
    print(f'  Error: {e}')
"

echo "═══════════════════════════════════════"
