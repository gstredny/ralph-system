---
description: Interview me about a project, then create Ralph-ready PRD with tasks
argument-hint: [rough-idea-file]
model: claude-opus-4-5-20251101
---

Read $1 which contains a rough project idea.

## Phase 1: Interview

Interview me using AskUserQuestion about:
- Technical implementation details
- UI/UX decisions
- Concerns and tradeoffs
- Edge cases
- Dependencies and constraints
- Target platforms
- Business model (if applicable)

Ask non-obvious questions only. One question at a time. Go deep.
Continue until I say "done" or you've exhausted meaningful questions.

## Phase 2: Write PRD

After interview complete, write a comprehensive PRD with these sections:

1. **Overview** - What we're building
2. **Problem** - What pain point it solves
3. **Core Features** - Detailed feature descriptions
4. **Tech Stack** - Chosen technologies with rationale
5. **Data Model** - Key entities and relationships
6. **Open Questions** - Anything unresolved

## Phase 3: Generate Tasks

At the end of the PRD, add:
```markdown
---

## Implementation Tasks

### Phase 1: Foundation
- [ ] Task: Specific, completable-in-one-iteration description

### Phase 2: Core Features
- [ ] Task: ...

(continue for all phases)
```

Rules for tasks:
- Each task completable in ~30-60 min
- Specific and testable
- Include setup, features, tests, deployment phases
- Aim for 30-50 tasks total
- Order by dependency (foundational first)

## Task Type Prefixes

Mark each task with a type:
- [impl] - Implementation: Claude decides and proceeds (most tasks)
- [design] - Design decision: Claude logs reasoning, surfaces alternatives
- [review] - Review checkpoint: Run tests, audit code

## Story Format with Acceptance Criteria

Each task should include testable acceptance criteria:

Example:
- [ ] [impl] Create firebase.ts - Firebase client init
  - AC1: Exports initialized Firebase app
  - AC2: Uses environment variables for config
  - AC3: No hardcoded credentials
- [ ] [design] Define auth error handling - toast vs inline vs redirect
  - AC1: Document chosen approach with rationale
  - AC2: Handle network, validation, and auth errors
- [ ] [impl] Create LoginPage.tsx
  - AC1: Renders email/password fields
  - AC2: Shows validation errors on invalid input
  - AC3: Calls auth API on submit
  - AC4: Redirects to dashboard on success
  - AC5: All tests pass
- [ ] [review] Code review: Phase 1 security audit
  - AC1: No credentials in code
  - AC2: Input validation present
  - AC3: Error messages don't leak internals

Keep ACs specific and testable - they define "done".

Use [design] for tasks involving:
- User-facing behavior choices
- Error handling strategies
- Data model decisions
- API contract design
- State management approach

Use [impl] for:
- Creating files from clear specs
- Adding dependencies
- Writing tests for defined behavior
- Connecting existing pieces

## Required Task Patterns

Every PRD must include these task types:

### Per-phase code review
After each phase, add:
- [ ] Task: Code review: Phase X security and integration audit

### Final validation phase (always last)
- [ ] Task: Integration tests - test complete user flows E2E
- [ ] Task: Full code review - security, performance, edge cases
- [ ] Task: Docker/deployment validation - containers start, health checks pass
- [ ] Task: Manual QA checklist - verify all features work

### Example structure:
```
Phase 1: Foundation
- [ ] task...
- [ ] task...
- [ ] Code review: Phase 1 security and integration audit

Phase 2: Core Features
- [ ] task...
- [ ] task...
- [ ] Code review: Phase 2 security and integration audit

...

Phase N: Validation (always last)
- [ ] Integration tests
- [ ] Full code review
- [ ] Docker/deployment validation
- [ ] Manual QA checklist
```

## Output

Ask me where to save the PRD (default: prd.md in current directory).
Write the complete PRD with all sections including tasks.
