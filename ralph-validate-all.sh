#!/bin/bash
# Ralph Holistic Validation Script
# Runs ALL test suites and health checks before allowing completion
# Exit code 0 = all passed, Exit code 1 = something failed

echo "═══════════════════════════════════════"
echo "  RALPH HOLISTIC VALIDATION"
echo "═══════════════════════════════════════"

FAILED=0
RESULTS=""

# Find project root (current directory)
PROJECT_ROOT="$(pwd)"

# 1. Backend tests
if [ -d "$PROJECT_ROOT/backend" ]; then
    echo ""
    echo "🧪 [1/4] Backend tests..."
    if (cd "$PROJECT_ROOT/backend" && poetry run pytest --tb=line -q 2>&1); then
        RESULTS+="✅ Backend tests passed\n"
    else
        RESULTS+="❌ Backend tests FAILED\n"
        FAILED=1
    fi
else
    RESULTS+="⏭️  Backend: not found\n"
fi

# 2. Mobile tests
if [ -d "$PROJECT_ROOT/mobile" ]; then
    echo ""
    echo "📱 [2/4] Mobile tests..."
    if (cd "$PROJECT_ROOT/mobile" && npm test -- --passWithNoTests --silent 2>&1); then
        RESULTS+="✅ Mobile tests passed\n"
    else
        RESULTS+="❌ Mobile tests FAILED\n"
        FAILED=1
    fi
else
    RESULTS+="⏭️  Mobile: not found\n"
fi

# 3. Web tests
if [ -d "$PROJECT_ROOT/web" ]; then
    echo ""
    echo "🌐 [3/4] Web tests..."
    if (cd "$PROJECT_ROOT/web" && npm test -- --passWithNoTests --run 2>&1); then
        RESULTS+="✅ Web tests passed\n"
    else
        RESULTS+="❌ Web tests FAILED\n"
        FAILED=1
    fi
else
    RESULTS+="⏭️  Web: not found\n"
fi

# 4. Health check (optional - only if server running)
echo ""
echo "🏥 [4/4] Health check..."
if curl -sf http://localhost:8000/health > /dev/null 2>&1; then
    RESULTS+="✅ Health check passed\n"
else
    RESULTS+="⚠️  Health check: server not running (OK if testing only)\n"
fi

# Summary
echo ""
echo "═══════════════════════════════════════"
echo "  RESULTS"
echo "═══════════════════════════════════════"
echo -e "$RESULTS"

if [ $FAILED -eq 0 ]; then
    echo "✅ ALL VALIDATIONS PASSED - safe to complete"
    exit 0
else
    echo "❌ VALIDATION FAILED - fix issues before completing"
    exit 1
fi
