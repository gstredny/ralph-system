# Ralph System

Autonomous development loop for Claude Code.

## Scripts

| Script | Purpose |
|--------|---------|
| `ralph-loop.sh <n>` | Run n iterations |
| `ralph-review.sh` | Code review agent |
| `ralph-validate.sh` | Runtime validation |
| `ralph-validate-all.sh` | Comprehensive test suite |
| `ralph-decisions.sh` | Review decisions & blocked items |
| `ralph-init.sh` | Initialize new project |

## Workflow

1. Create project, write rough idea.md
2. `/interview @idea.md` - flesh out PRD with tasks
3. `ralph-loop.sh 20` - run autonomous loop
4. `ralph-decisions` - review decisions made
5. `ralph-validate.sh` - verify everything works
6. Repeat until complete

## Task Types

PRD tasks use type prefixes:

- `[impl]` - Implementation: Claude decides and proceeds
- `[design]` - Design choice: Claude logs reasoning, surfaces alternatives
- `[review]` - Checkpoint: Run tests and audit

Example:
```markdown
- [ ] [impl] Create firebase.ts - Firebase client init
- [ ] [design] Define auth error handling - toast vs inline vs redirect
- [ ] [review] Code review: Phase 1 security audit
```

## Decision Logging

When Claude makes design choices, it logs to progress.txt:
```
DECISION: [what was chosen] REASON: [why]
```

## Ambiguity Handling

If a task is ambiguous about product behavior:
```
BLOCKED: [task name] - QUESTION: [specific question]
```

Claude skips blocked tasks. Human reviews before next run.

## Files in Your Project

| File | Purpose |
|------|---------|
| `prd.md` | Tasks with `- [ ]` checkboxes |
| `progress.txt` | Session log, decisions, blocked items |
| `CODE_REVIEW.md` | Output from ralph-review.sh |

## Quick Start

```bash
# Initialize
mkdir my-project && cd my-project
~/ralph-system/ralph-init.sh my-project

# Create PRD (interactive)
/interview @idea.md

# Run loop
~/ralph-system/ralph-loop.sh 20

# Check decisions
ralph-decisions

# Validate
~/ralph-system/ralph-validate.sh
```

## Exit Conditions

- All tasks checked `[x]` (outputs `<promise>COMPLETE</promise>`)
- Max iterations reached
- All remaining tasks blocked
