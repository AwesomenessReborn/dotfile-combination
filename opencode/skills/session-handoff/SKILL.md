---
name: session-handoff
description: >
  Generates a structured markdown session-handoff document summarizing everything accomplished
  in the current Claude Code session — goals, decisions, progress, file changes, blockers,
  and exact next steps — so the user can clear context and resume seamlessly in a new chat.

  USE THIS SKILL whenever the user says things like: "summarize the session", "save my progress",
  "I'm going to clear context", "create a handoff", "context summary", "wrap up", "save session",
  "what did we do", "generate a summary so I can start fresh", "handoff", or anything that signals
  they want to capture the current session state before ending or clearing it. Err on the side of
  triggering this skill — a false positive is far less costly than losing session context.
---

You are generating a session handoff document. Follow every step below exactly.

---

## Step 1 — Gather Ground Truth from Git

Run these commands in parallel to get authoritative data on what changed this session.
Do NOT skip this step — do not rely on memory alone for file changes.

- `git status` — current working tree state
- `git diff --name-only HEAD` — files changed but not yet committed
- `git diff --cached --name-only` — staged files
- `git log --oneline -10` — recent commits (to identify commits made this session)
- `git diff HEAD~5..HEAD --name-only 2>/dev/null || true` — files touched in recent commits

If `git` is unavailable or the directory is not a repo, note that and rely on context alone.

---

## Step 2 — Collect the Working Directory

Run: `pwd`

You will embed this path in the resume prompt so the next session knows exactly where to look.

---

## Step 3 — Write the Handoff File

Write the complete document to `./SESSION_HANDOFF.md`. Overwrite if it exists.

Use the structure below. **Do not skip any section.** If a section has nothing to report, write `N/A`.

---

```markdown
# Session Handoff — <ISO 8601 timestamp, e.g. 2026-04-05T14:32:00>

## Original Goal
<One paragraph. What was the user trying to accomplish when this session started?
Infer from the earliest messages in conversation if not stated explicitly.>

## Session Status
**Status**: <In Progress | Blocked | Complete>
**Confidence**: <High | Medium | Low> — <one sentence rationale for confidence level>

---

## Accomplished
<!-- Bullet list of concrete, completed outcomes. Be specific. No vague items. -->
- <e.g. "Created /Dev/projects/foo/src/parser.py with a CAN frame parser">
- <...>

---

## Key Decisions
| Decision | Rationale | Alternatives Rejected |
|---|---|---|
| <decision> | <why> | <what else was considered> |

---

## Current State

### Files Changed
<!-- Use git output from Step 1 as the authoritative source. -->
- `path/to/file` — <what changed and why>

### What Works
- <...>

### What Doesn't Work / Is Incomplete
- <...>

### Known Issues
- <...>

---

## Blockers & Open Questions
- <blocker or question> — <context needed to resolve it>

---

## Next Steps
<!-- Most critical section. Must be specific enough that a fresh Claude session
      can execute step 1 without asking the user for clarification. -->
1. <Specific, actionable step — include file paths, function names, commands>
2. <...>
3. <...>

---

## Resume Prompt

Paste this into your next Claude Code session to restore context instantly:

---
I'm resuming work from a previous session. The working directory is `<pwd output from Step 2>`.

Read `SESSION_HANDOFF.md` in that directory to get full context, then:
1. Confirm you understand the current state in 2-3 sentences.
2. Show me the next step and ask me to confirm before proceeding.
---
```

---

## Step 4 — Behavior Guidelines

- **Git output is ground truth for file changes.** Cross-reference with conversation context, but
  prefer git data over memory when they conflict.
- **Write for a stateless reader.** Assume zero shared memory. If something was decided in
  conversation, write it down explicitly with the reasoning.
- **Capture HEAD state, not intentions.** Only document what actually happened. Plans that weren't
  executed belong in Next Steps, not Accomplished.
- **Be specific over generic.** File paths, function names, error messages, exact commands —
  include them. Vague summaries are useless for resumption.
- **Don't pad.** If a section is genuinely empty, write N/A. Don't invent content.

---

## Step 5 — Report to the User

After writing the file, tell the user:

1. "Written to `SESSION_HANDOFF.md`" with the full path.
2. The **Status** and **Confidence** level with the rationale.
3. The **top 3 next steps** in plain text (so they can see them without opening the file).
4. A reminder to paste the resume prompt at the start of their next session.

Keep this report concise — the detail lives in the file.
