# Ralph Autonomous Development Loop

Read @prd.md and @progress.txt to understand the project and what's been done.

## Your workflow (Kanban flow):

### 1. SELECT (WIP)
- Find the highest-priority unchecked task in prd.md
- Only work on ONE task

### 2. IMPLEMENT
- Write the code for this task
- Follow existing patterns in the codebase

### 3. CODE REVIEW
- Review your own code critically
- Check for: edge cases, error handling, code style, security
- Fix any issues before proceeding

### 4. TESTING
- Run ALL tests (not just new ones): `pytest` or equivalent
- All tests must pass before proceeding
- If tests fail, fix them before moving on

### 5. VALIDATION
- If Docker/containers involved: `docker-compose up -d` must work
- Health endpoints must respond
- No import errors, no crashes on startup
- App must be in working state

### 6. COMMIT
- Mark task complete in prd.md: [ ] → [x]
- Append summary to progress.txt
- Git commit: "Complete: [task name]"

## Rules
- ONE task per iteration
- Do NOT skip testing or validation
- Leave codebase in WORKING state - app must start
- If blocked, document in progress.txt and move to next task

## Completion
If all tasks in prd.md are checked [x], output:
<promise>COMPLETE</promise>