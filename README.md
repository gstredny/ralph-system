# Ralph System

Autonomous development loop for Claude Code.

## Philosophy

Ralph is a **workflow**, not just a script. It enforces:
1. **Interview first** - Understand before building
2. **Structured tasks** - JSON PRD with testable criteria
3. **Incremental progress** - One story at a time
4. **Learning capture** - CLAUDE.md grows with each run

## Correct Workflow

```
1. INTERVIEW    →  /interview idea.md
                   Claude asks questions, understands scope

2. PRD CREATED  →  prd.json with userStories
                   Each story has acceptance criteria

3. USER REVIEW  →  Verify stories look right
                   Adjust if needed

4. RALPH RUNS   →  ~/ralph-system/ralph-loop.sh 20
                   Executes one story per iteration
                   Updates passes: true when done

5. COMPLETE     →  <promise>COMPLETE</promise>
                   All stories pass, auto-validates
```

## ⚠️ NEVER run ralph-loop.sh without prd.json!

The loop will refuse to start without structured tasks.

## Commands

| Command | Purpose |
|---------|---------|
| `ralph-init.sh [name]` | Initialize new project |
| `ralph-loop.sh [n]` | Run n iterations |
| `ralph-status.sh` | Check progress |
| `ralph-review.sh` | Code review agent |
| `ralph-validate.sh` | Runtime validation |
| `ralph-validate-all.sh` | Comprehensive test suite |
| `ralph-archive.sh` | Manual archive |
| `ralph-decisions.sh` | Review decisions |

## Files Per Project

| File | Purpose |
|------|---------|
| `prd.json` | User stories with passes status |
| `progress.txt` | Log of completed work |
| `CLAUDE.md` | Patterns/gotchas for this project |
| `archive/` | Previous runs (auto-created) |
| `.last-branch` | Branch tracking (auto-created) |

## prd.json Format

```json
{
  "project": "MyApp",
  "branchName": "ralph/feature-name",
  "description": "What we're building",
  "userStories": [
    {
      "id": "US-001",
      "title": "Task title",
      "description": "As a user, I need X so that Y",
      "acceptanceCriteria": [
        "Testable outcome 1",
        "Testable outcome 2",
        "Tests pass"
      ],
      "priority": 1,
      "passes": false,
      "notes": ""
    }
  ]
}
```

## Task Types

PRD tasks use type prefixes:

- `[impl]` - Implementation: Claude decides and proceeds
- `[design]` - Design choice: Claude logs reasoning, surfaces alternatives
- `[review]` - Checkpoint: Run tests and audit

## Features

- **JSON-first**: Structured, queryable tasks
- **Auto-archive**: Previous runs saved on branch change
- **Branch tracking**: Auto-creates feature branches
- **CLAUDE.md updates**: Learnings persist across sessions
- **Validation**: Won't run without proper PRD

## Installation

```bash
git clone https://github.com/gstredny/ralph-system.git ~/ralph-system
chmod +x ~/ralph-system/*.sh
```

Requires: `jq` for JSON parsing
```bash
sudo apt-get install -y jq  # Linux
brew install jq             # Mac
```

## Quick Start

```bash
cd ~/my-project
~/ralph-system/ralph-init.sh my-feature

# In Claude Code:
/interview idea.md

# After prd.json created:
~/ralph-system/ralph-loop.sh 20
~/ralph-system/ralph-status.sh
```

## Exit Conditions

- All tasks checked `passes: true` (outputs `<promise>COMPLETE</promise>`)
- Max iterations reached
- All remaining tasks blocked
