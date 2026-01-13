# Project Workflow

This project uses the Ralph autonomous development system from ~/ralph-system/

## When user requests new features or changes:

### Step 1: Interview (REQUIRED)
- Run /interview or manually ask clarifying questions
- Understand the full scope before writing ANY code
- Ask about: technical details, edge cases, testing needs, dependencies

### Step 2: Create prd.json (REQUIRED)
After interview, create prd.json with userStories array.
Each story needs: id, title, description, acceptanceCriteria, priority, passes, notes

### Step 3: Review with User
- Show total story count
- List first 5 stories
- Ask: "Ready to run Ralph, or want to modify stories?"

### Step 4: User Runs Ralph
Tell user to run:
```bash
~/ralph-system/ralph-loop.sh 20
~/ralph-system/ralph-status.sh  # to monitor
```

## Story Requirements

Every story MUST have:
- Testable acceptance criteria (not vague outcomes)
- "Tests pass" or "Typecheck passes" where applicable
- Clear definition of done

## CRITICAL RULES

### NEVER:
- Write feature code without prd.json existing
- Skip the interview step for complex features
- Run ralph-loop.sh without userStories
- Mark stories as passes:true without meeting ALL acceptance criteria

### ALWAYS:
- Update CLAUDE.md with patterns/gotchas discovered
- Create small stories (30-60 min each)
- Include testing criteria in every story

## Ralph System Commands

```bash
~/ralph-system/ralph-init.sh [name]     # Initialize new project
~/ralph-system/ralph-loop.sh [n]        # Run n iterations
~/ralph-system/ralph-status.sh          # Check progress
~/ralph-system/ralph-review.sh          # Code review
~/ralph-system/ralph-validate.sh        # Runtime validation
~/ralph-system/ralph-archive.sh         # Manual archive
```

## Patterns
<!-- Add patterns discovered during development -->

## Gotchas
<!-- Add gotchas and things to watch out for -->

## Context
<!-- Add useful context about the codebase -->
