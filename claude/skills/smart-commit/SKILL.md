---
name: smart-commit
description: Review all git diffs, write a concise commit message summarizing the changes, stage and commit them. Never add Co-Authored-By lines — the user is the sole author.
disable-model-invocation: true
allowed-tools: Bash(git *)
---

You are performing a smart personal git commit. Follow these steps exactly:

## 1. Assess the repo state

Run these in parallel:
- `git status` — see tracked/untracked changes
- `git diff` — unstaged changes
- `git diff --cached` — already staged changes
- `git log --oneline -5` — recent commit style to match

## 2. Analyze all changes

Read the full diff carefully. Understand:
- What files changed and why
- The nature of the change (feat, fix, refactor, chore, docs, etc.)
- Any sensitive files (`.env`, credentials, secrets) — **warn the user and skip those**

## 3. Stage changes

Stage relevant files by name (never use `git add -A` or `git add .` blindly). Skip:
- Build artifacts (`node_modules/`, `dist/`, `__pycache__/`, `.venv/`)
- Secrets or credentials
- Anything in `.gitignore`

## 4. Write a commit message

Draft a clear, concise commit message:
- First line: imperative mood, under 72 chars (e.g. `feat: add user auth flow`)
- Optional body: bullet points explaining *why*, not just *what*
- Match the style of recent commits in `git log`
- **Do NOT include any `Co-Authored-By` lines — the user is the sole author**

## 5. Commit

```
git commit -m "$(cat <<'EOF'
<your message here>
EOF
)"
```

Verify with `git status` after committing.

**Never force-push. Never amend. Never use --no-verify.**
