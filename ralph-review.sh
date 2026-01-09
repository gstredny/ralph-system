#!/bin/bash
set -e

echo "═══════════════════════════════════════"
echo "  Ralph Code Review Agent"
echo "═══════════════════════════════════════"

REVIEW_PROMPT='You are a senior code reviewer. Review recent changes in this repo.

## Your task:
1. Run `git diff HEAD~5` to see recent changes
2. Run `git log --oneline -10` to understand what was built

## Review for:
- Security issues (SQL injection, auth bypasses, secrets in code)
- Error handling gaps
- Missing input validation
- Broken imports or dependencies
- Tests that dont actually test anything
- Docker/config issues preventing startup
- Race conditions or async issues
- Code that contradicts other code

## Output:
Create CODE_REVIEW.md with:

### Critical (must fix)
- Issue: ... File: ... Line: ...

### Warnings (should fix)
- Issue: ... File: ...

### Suggestions (nice to have)
- ...

### Summary
X critical, Y warnings, Z suggestions

If critical issues found, list exact fix commands.'

claude --dangerously-skip-permissions -p "$REVIEW_PROMPT"

echo ""
echo "✅ Review complete. Check CODE_REVIEW.md"
