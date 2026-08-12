---
name: handoff
description: >
  Generates a structured handoff document so a fresh AI agent or terminal session can
  continue immediately without re-explaining context.

  AUTO-DETECTS mode:
  - If inside a git repo → repo mode: grounds truth in git output, writes HANDOFF.md with
    branch, changed files, decisions, and next action.
  - If no git repo detected → conversation mode: synthesizes from conversation context only,
    writes HANDOFF.md with goal, status, decisions, and next step.

  USE THIS SKILL for: mid-session wrap-ups, context transfers, end-of-session saves,
  planning handoffs, repo state transfers, or any time you want to continue in a fresh session.

  Trigger phrases: "handoff", "wrap up", "save session", "save my progress",
  "create a handoff", "transfer this session", "context summary", "save repo state".

  allowed-tools: Bash(git *), Write
---

You are generating a handoff document. Follow every step below exactly.

---

## Step 1 — Detect Mode

Run: `git rev-parse --show-toplevel`

- **If it succeeds** → you are in a git repo. Use **Repo Mode** in Step 2.
- **If it fails** → no repo. Use **Conversation Mode** in Step 2.

Do not tell the user you are detecting the mode. Just proceed.

---

## Step 2 — Gather Context

### Repo Mode
Run these commands:
- `git status --short --branch`
- `git log --oneline -5`
- `git diff --stat`

Then run `git diff <file>` on the 1–3 most significant changed files (skip lock files, binaries, build artifacts).

Collect any test/build/lint output already visible in this session. Do NOT re-run tests or builds.

### Conversation Mode
Do NOT run terminal commands. Synthesize from the conversation only:
- What was the user trying to accomplish?
- What was decided, confirmed, or ruled out?
- What constraints or preferences did the user state?
- What is still unresolved?
- What is the very next step?

Clearly distinguish **confirmed facts** from **assumptions**. Label anything inferred as "(assumed)" or "(not confirmed)".

Exception: if a branch name or file path was central to the discussion, you may note it from conversation context — but do not run commands to verify it.

---

## Step 3 — Write HANDOFF.md

Write the complete document to `./HANDOFF.md`. Overwrite if it exists.

Use this structure exactly. If a section has nothing to report, write `N/A` — never omit a section.

```markdown
# Handoff — <ISO 8601 timestamp>

## Mode
<!-- Either "Repo (git-grounded)" or "Conversation (synthesized)" -->

## Goal
<One paragraph. What was the user trying to accomplish?>

## Current Status
<One paragraph. What's resolved, what's still open, where things stand right now.>

## Repo State
<!-- Repo mode: fill this in. Conversation mode: write N/A -->
- **Directory:** <repo root>
- **Branch:** <branch name>
- **Git status:** <paste --short output, or "clean">
- **Recent commits:** <paste git log --oneline -5>
- **Changed files:** <list with brief description of what changed in each>
- **Tests / build / lint:** <results if run this session, otherwise "not checked">

## Key Decisions
| Decision | Rationale | Alternatives Rejected |
|---|---|---|
| <decision> | <why> | <what else was considered> |

## Constraints and Preferences
- <e.g. "No external dependencies">
- <e.g. "Target Python 3.12">

## Do Not Do
- <Explicit things the next agent must NOT attempt or suggest>

## Open Questions / Risks
- <question or risk> — <context needed to resolve it>
- <mark inferred items as "(assumed)">

## Next Action
<The single most important next step. Specific enough that a fresh agent can execute it immediately — include file path, function name, or command if known.>
```

---

## Step 4 — Report to the User

After writing the file, tell the user:

1. Written to `./HANDOFF.md` — confirm the full path.
2. Which mode was used (repo or conversation) and one-sentence current status.
3. The **Next Action** in plain text.
4. Reminder: paste the contents of `HANDOFF.md` at the start of the next session.

Keep this to 4–5 lines. The detail lives in the file.

---

## Behavior Rules

- **Never fix code, refactor, or continue implementing.** Inspect and document only.
- **Repo output is ground truth in repo mode.** Prefer git facts over conversation memory when they conflict.
- **Never claim tests pass unless they were actually run this session.** Say "not checked" otherwise.
- **Never include secrets, tokens, credentials, or private keys** in any output.
- **Never tell the next agent to commit, push, delete, or overwrite files** unless the user explicitly requested that this session.
- **Do not over-dump the conversation.** Extract signal, not transcript.
- **Say "not checked", "unknown", or "not discussed"** where appropriate — do not fill gaps with guesses.
- **Avoid generic motivational language.** Be direct and factual.
