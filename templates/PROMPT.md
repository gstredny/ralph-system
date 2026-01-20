# Ralph Autonomous Development Loop

Read prd.json and progress.txt to understand the project and what's been done.

## Your workflow:

### 1. SELECT
- Parse prd.json
- **FIRST:** Check for any story with `"status": "in_progress"` - resume these before starting new work
- If resuming: Read `lastAttempt` field for context on what was tried and what to do next
- Otherwise: Find the lowest priority story where `"passes": false` and `"status"` is not `"blocked"`
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

### 5. UPDATE prd.json (success)
- Set `"passes": true` for the completed story
- Set `"status": "complete"`
- Add any learnings to `"notes"` field
- Clear `"lastAttempt"` if present

### 5b. EXPLORATION MODE (for uncertain tasks)

Before implementing a story you're unsure about:

1. **Research first:**
   - Read relevant existing code
   - Check how similar features are implemented
   - List dependencies and integration points

2. **Log exploration in progress.txt:**
   ```
   [TIMESTAMP] EXPLORING: US-005 Router handler
   - Found: simple_router.py handles intents at line 142
   - Found: existing pattern uses match/case
   - Decision: Will follow existing pattern
   ```

3. **Then implement with confidence**

### 6. IF INCOMPLETE
If you cannot complete this story this iteration:

1. **Update prd.json** with partial progress:
   - Set `"status": "in_progress"`
   - Add/update `"lastAttempt"` object with:
     - `"timestamp"`: ISO date
     - `"attempts"`: Increment by 1 (start at 1)
     - `"learned"`: What you discovered
     - `"completed"`: Array of what's done so far
     - `"blockers"`: Why it didn't complete
     - `"nextSteps"`: Array of what the next iteration should do

2. **Check attempt count:**
   - If `attempts >= 3` and still not complete:
     - Set `"status": "blocked"`
     - Add clear explanation to `"notes"`
     - Move to next story

3. **Append to progress.txt**:
   ```
   ## US-XXX: [title] ⏳ IN PROGRESS
   Attempted: [timestamp]
   Attempt #: [number]
   Learned: [key insights]
   Completed so far: [list]
   Blocked by: [reason]
   Next steps: [what to do next]
   ```

4. **DO NOT** set `"passes": true` - task remains incomplete

5. **Update CLAUDE.md with discoveries:**
   - Add blocking issue to "## Gotchas"
   - Add any patterns discovered to "## Patterns"
   - Even failed attempts teach us something

6. Commit with message: `"WIP: US-XXX [title] - [brief status]"`

### 7. UPDATE CLAUDE.md
After completing each story, update CLAUDE.md:
- **Patterns discovered:** Add to "## Patterns" section
- **Gotchas found:** Add to "## Gotchas" section
- **Useful context:** Add to "## Context" section
Create CLAUDE.md if it doesn't exist. This is CRITICAL for future iterations.

### 8. COMMIT
- Append summary to progress.txt
- Git commit: "Complete: US-XXX [story title]"

## PRD Schema Reference

Stories support these fields:
```json
{
  "id": "US-001",
  "title": "Story title",
  "criteria": "Acceptance criteria",
  "priority": 1,
  "passes": false,
  "status": "not_started",
  "notes": "",
  "lastAttempt": {
    "timestamp": "2026-01-20T10:30:00Z",
    "attempts": 1,
    "learned": "What was discovered",
    "completed": ["Item 1", "Item 2"],
    "blockers": "Why incomplete",
    "nextSteps": ["Next action 1", "Next action 2"]
  }
}
```

**Status values:** `"not_started"` | `"in_progress"` | `"blocked"` | `"complete"`

## Rules
- ONE story per iteration
- **Resume in_progress tasks before starting new ones**
- Do NOT skip acceptance criteria verification
- ALWAYS update CLAUDE.md with learnings
- Leave codebase in WORKING state
- After 3 failed attempts, mark as blocked and move to next story

## Completion
When ALL stories have `"passes": true`, output exactly:
<promise>COMPLETE</promise>
