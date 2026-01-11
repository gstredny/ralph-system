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

## E2E Testing Requirements
For frontend tasks:
- If Playwright is set up, run `npx playwright test` after changes
- All E2E tests must pass before marking task complete
- If creating a new user-facing feature, create E2E test in tests/e2e/

## Decision Logging
When you make a design choice (not just implementation), log it in progress.txt:
- Format: "DECISION: [what you chose] REASON: [why]"
- Design choices include: data structure, API shape, error handling strategy, UI behavior, state management approach
- Implementation details (don't log): syntax choice, variable names, import order, formatting

## Ambiguity Handling
If a PRD task is ambiguous about product behavior:
- Do NOT guess and continue
- Add to progress.txt: "BLOCKED: [task name] - QUESTION: [specific question needing human input]"
- Skip this task, move to next unchecked task
- Human reviews blocked items before next Ralph run

## Task Types
- [impl] tasks: Make decisions and proceed
- [design] tasks: Log your reasoning, surface alternatives considered
- [review] tasks: Run full test suite, check for issues

## Learning Capture (CRITICAL)
After completing each task, update CLAUDE.md in the project root:

1. **Patterns discovered:** Add to "## Patterns" section
   - "This codebase uses X for Y"
   - "Component Z follows this structure..."

2. **Gotchas found:** Add to "## Gotchas" section
   - "Don't forget to update X when changing Y"
   - "This API requires Z header"

3. **Useful context:** Add to "## Context" section
   - "Settings panel is in src/components/settings/"
   - "Auth flow goes through middleware X"

Create CLAUDE.md if it doesn't exist. Claude Code auto-reads this file - learnings persist automatically.

## Rules
- ONE task per iteration
- Do NOT skip testing or validation
- Leave codebase in WORKING state - app must start
- If blocked, document in progress.txt and move to next task

## Completion
If all tasks in prd.md are checked [x], output:
<promise>COMPLETE</promise>