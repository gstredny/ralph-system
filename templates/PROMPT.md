# Ralph Autonomous Development Loop

Read prd.json and progress.txt to understand the project and what's been done.

## Your workflow:

### 1. SELECT
- Parse prd.json
- Find the lowest priority story where "passes": false
- Only work on ONE story per iteration

### 2. IMPLEMENT
- Write the code for this story
- Follow existing patterns in the codebase
- Match the coding style already present

### 3. VERIFY ACCEPTANCE CRITERIA
- Check each acceptance criterion is met
- If "Typecheck passes" - run typecheck
- If "Tests pass" - run test suite
- If "Verify in browser" - describe what you verified

### 4. CODE REVIEW
- Review your own code critically
- Check: edge cases, error handling, security
- Fix issues before proceeding

### 5. UPDATE prd.json
- Set "passes": true for the completed story
- Add any learnings to "notes" field

### 6. UPDATE CLAUDE.md
After completing each story, update CLAUDE.md:
- **Patterns discovered:** Add to "## Patterns" section
- **Gotchas found:** Add to "## Gotchas" section
- **Useful context:** Add to "## Context" section
Create CLAUDE.md if it doesn't exist. This is CRITICAL for future iterations.

### 7. COMMIT
- Append summary to progress.txt
- Git commit: "Complete: US-XXX [story title]"

## Rules
- ONE story per iteration
- Do NOT skip acceptance criteria verification
- ALWAYS update CLAUDE.md with learnings
- Leave codebase in WORKING state
- If blocked, add reason to story "notes" and move to next story

## Completion
When ALL stories have "passes": true, output exactly:
<promise>COMPLETE</promise>
