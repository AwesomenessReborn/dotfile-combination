# OpenCode configuration

Portable snapshot of the live OpenCode configuration under `~/.config/opencode/`.

## File mapping

| Repository path | Live destination |
|---|---|
| `opencode/opencode.json` | `~/.config/opencode/opencode.json` |
| `opencode/AGENTS.md` | `~/.config/opencode/AGENTS.md` |
| `opencode/agents/` | `~/.config/opencode/agents/` |
| `opencode/skills/` | `~/.config/opencode/skills/` |

This directory intentionally excludes `node_modules/`, package manifests, lockfiles,
authentication data, caches, and other runtime state.

The OpenCode and Claude smart-commit skills are tracked as separate variants because
their platform-specific frontmatter differs.
