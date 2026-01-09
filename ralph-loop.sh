#!/bin/bash
set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <iterations>"
    exit 1
fi

if [ ! -f "prd.md" ]; then
    echo "❌ prd.md not found."
    exit 1
fi

if [ ! -f "progress.txt" ]; then
    echo "=== Progress Log ===" > progress.txt
    echo "Started: $(date)" >> progress.txt
    echo "---" >> progress.txt
fi

PROMPT=$(cat ~/ralph-system/templates/PROMPT.md)

for ((i=1; i<=$1; i++)); do
    echo ""
    echo "═══════════════════════════════════════"
    echo "  Ralph Iteration $i of $1"
    echo "═══════════════════════════════════════"

    result=$(claude --dangerously-skip-permissions -p "@prd.md @progress.txt $PROMPT")

    echo "$result"

    # Code review every 10 iterations
    if (( i % 10 == 0 )); then
        echo ""
        echo "🔍 Running code review checkpoint..."
        ~/ralph-system/ralph-review.sh || true
    fi

    if [[ "$result" == *"<promise>COMPLETE</promise>"* ]]; then
        echo ""
        echo "✅ All tasks complete!"
        ~/ralph-system/ralph-validate.sh
        notify-send "Ralph Complete! 🎉" "All tasks finished" 2>/dev/null || true
        echo -e "\a"
        exit 0
    fi

    echo ""
    echo "⏳ Pausing 3s..."
    sleep 3
done

echo "⏱️ Reached max iterations ($1)"
~/ralph-system/ralph-validate.sh
notify-send "Ralph paused" "Reached $1 iterations" 2>/dev/null || true
echo -e "\a"
