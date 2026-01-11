#!/bin/bash
echo "═══════════════════════════════════════"
echo "  Ralph Status"
echo "═══════════════════════════════════════"

if [ -f "prd.json" ]; then
    echo "📊 From prd.json:"
    cat prd.json | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    stories = data.get('userStories', [])
    passing = [s for s in stories if s.get('passes')]
    failing = [s for s in stories if not s.get('passes')]
    print(f'  Passing: {len(passing)} / {len(stories)}')
    if failing:
        print(f'  Next up: {failing[0][\"title\"][:50]}...')
    else:
        print('  All done!')
except Exception as e:
    print(f'  Error parsing JSON: {e}')
"
elif [ -f "prd.md" ]; then
    echo "📊 From prd.md:"
    done=$(grep -c '\- \[x\]' prd.md 2>/dev/null || echo 0)
    total=$(grep -c '\- \[.\]' prd.md 2>/dev/null || echo 0)
    echo "  Done: $done / $total"
    next=$(grep -m1 '\- \[ \]' prd.md | head -c 60)
    if [ -n "$next" ]; then
        echo "  Next up: $next..."
    fi
else
    echo "  No prd.md or prd.json found"
fi

echo ""
echo "📝 Recent progress:"
if [ -f "progress.txt" ]; then
    tail -10 progress.txt
else
    echo "  No progress.txt"
fi

echo ""
echo "🧠 AGENTS.md files (learnings):"
agents_files=$(find . -name "AGENTS.md" -type f 2>/dev/null | head -5)
if [ -n "$agents_files" ]; then
    echo "$agents_files"
else
    echo "  None yet"
fi

echo ""
echo "⚠️  Blocked items:"
if [ -f "progress.txt" ]; then
    blocked=$(grep -i "BLOCKED:" progress.txt 2>/dev/null)
    if [ -n "$blocked" ]; then
        echo "$blocked"
    else
        echo "  None"
    fi
else
    echo "  No progress.txt"
fi

echo "═══════════════════════════════════════"
