# Ralph System

Simple autonomous development loop for Claude Code.

## Structure

```
~/ralph-system/
├── ralph-init.sh           # Initialize any project
├── ralph-loop.sh           # Main loop runner
├── templates/
│   ├── prd-template.md     # PRD template (markdown tasks)
│   └── PROMPT.md           # Iteration prompt
└── README.md
```

## Quick Start

```bash
# 1. Create and enter project directory
mkdir my-project && cd my-project

# 2. Initialize Ralph
~/ralph-system/ralph-init.sh my-project

# 3. Edit prd.md with your tasks
# (or run: /interview @prd.md)

# 4. Run the loop
~/ralph-system/ralph-loop.sh 20
```

## Workflow

Each iteration follows Kanban flow:

1. **SELECT** - Pick highest-priority unchecked task
2. **IMPLEMENT** - Write the code
3. **CODE REVIEW** - Self-review for edge cases, errors, security
4. **TESTING** - Write/run tests
5. **VALIDATION** - Verify feature works
6. **COMMIT** - Mark task `[x]`, update progress.txt, git commit

## Files in Your Project

| File | Purpose |
|------|---------|
| `prd.md` | Your tasks with `- [ ]` checkboxes |
| `progress.txt` | Session handoff log, context for next run |

## Usage

```bash
# Run 20 iterations
~/ralph-system/ralph-loop.sh 20

# Single iteration (manual)
claude --dangerously-skip-permissions -p '@prd.md @progress.txt $(cat ~/ralph-system/templates/PROMPT.md)'
```

## Exit Conditions

- Loop exits when all tasks are `[x]` checked (outputs `<promise>COMPLETE</promise>`)
- Or when max iterations reached

## PRD Format

```markdown
# Project: my-project

## Overview
What we're building.

## Tech Stack
- Python 3.11
- FastAPI

## Features / Tasks

### Phase 1: Foundation
- [ ] Task 1: Set up project structure
- [ ] Task 2: Create database models

### Phase 2: Core
- [x] Task 3: (completed)
- [ ] Task 4: Implement API endpoints

## Notes
- Any context for the AI
```
