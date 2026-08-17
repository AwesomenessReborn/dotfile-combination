# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

Personal dotfiles repository that **tracks and transfers** development environment configurations between macOS and Ubuntu/Linux machines. This is not a symlink manager — configs are stored here as a reference and manually copied to new systems as needed.

An optional legacy script exists in `archive/install.sh` that can automate dependency installation and symlinking, but the primary workflow is manual transfer.

## File Mapping

Where each config in the repo belongs on the system:

| Repo path | System destination |
|---|---|
| `zsh/.zshrc` | `~/.zshrc` |
| `zsh/.zprofile` | `~/.zprofile` |
| `git/.gitconfig` | `~/.gitconfig` |
| `git/ignore` | `~/.config/git/ignore` |
| `tmux/.tmux.conf` | `~/.tmux.conf` |
| `ssh/config` | `~/.ssh/config` |
| `nvim/` | `~/.config/nvim` |
| `alacritty/` | `~/.config/alacritty` — **platform-selective**, see below |
| `ohmyposh/` | `~/.config/ohmyposh` |
| `btop/` | `~/.config/btop` |
| `neofetch/config.conf` | `~/.config/neofetch/config.conf` |
| `htop/htoprc` | `~/.config/htop/htoprc` |
| `claude/CLAUDE.md` | `~/.claude/CLAUDE.md` |
| `claude/settings.json` | `~/.claude/settings.json` |
| `claude/statusline-command.sh` | `~/.claude/statusline-command.sh` |
| `claude/skills/` | `~/.claude/skills/` |
| `opencode/opencode.json` | `~/.config/opencode/opencode.json` |
| `opencode/AGENTS.md` | `~/.config/opencode/AGENTS.md` |
| `opencode/agents/` | `~/.config/opencode/agents/` |
| `opencode/skills/` | `~/.config/opencode/skills/` |

## Architecture

### Shell (`zsh/`)
- `.zprofile`: Homebrew init (macOS only)
- `.zshrc`: Sources `.zprofile`, initializes conda, oh-my-posh, fzf, fnm, zsh-autosuggestions, and neofetch on login. Contains a custom `_show_backup_status()` widget that reads `~/Dev/backup-framework/last-backup-status`.

### Neovim (`nvim/`)
Based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim). All config is in `init.lua` (lazy.nvim bootstrap + plugin declarations) with modular plugin files under `lua/kickstart/plugins/`. User-added plugins go in `lua/custom/plugins/init.lua`.

Key plugins: telescope, nvim-lspconfig + mason, blink.cmp, conform.nvim, treesitter, neo-tree, gitsigns, which-key. LSP servers configured: `pyright`, `lua_ls`, `clangd`, `jsonls`.

Colorscheme: TokyoNight. Leader key: `<Space>`.

### Alacritty (`alacritty/`)
Unlike every other directory here, this one is **not** a straight copy — copy
`alacritty.toml`, `common.toml`, `colors-*.toml`, plus **exactly one** of
`linux.toml` / `macos.toml`. Copying both will apply macOS-only values
(`decorations = "Buttonless"`, `option_as_alt`) on Linux, which is invalid.

`alacritty.toml` is import-only by design: Alacritty lets the importing file
override its imports, so any key set there would be unoverridable by the platform
files. Later imports win, hence the order common → colors → platform. Missing
imports are skipped at INFO level, which is what lets one entry point import both
platform files. Full explanation in `alacritty/README.md`.

Font: JetBrainsMono Nerd Font **Mono** variant (single-cell icons — required for
Alacritty's fixed grid). Palette shared with `iterm2/`.

### Tmux (`tmux/`)
Mouse enabled, status bar at top, true color, Catppuccin Mocha theme via tpm. Vim-style pane navigation (`h/j/k/l`).

### Git (`git/`)
- `.gitconfig`: Uses `gh auth git-credential` for GitHub auth (Homebrew path on macOS)
- `ignore`: Global gitignore — currently ignores `.claude/settings.local.json`

### AI tooling (`claude/`, `opencode/`)
- Track shareable instructions, settings, statusline scripts, custom agents, and skills.
- Keep Claude and OpenCode skill variants separate when their frontmatter differs.
- Do not track local settings, authentication files, caches, package/runtime files, or session history.

### Platform differences

**Most of this repo is a macOS snapshot.** These files contain hardcoded macOS
paths or Mac-only values and must be **adapted, not copied**, on Linux:

| File | Mac-specific content |
|---|---|
| `zsh/.zshrc`, `zsh/.zprofile` | Homebrew at `/opt/homebrew`, miniconda at `/Users/...` |
| `git/.gitconfig` | Credential helper at `/opt/homebrew/bin/gh` |
| `ssh/config` | `UseKeychain yes` (macOS-only directive) |
| `claude/CLAUDE.md` | `/Users/...` conda paths, Google Drive CloudStorage mount, Homebrew fnm |
| `opencode/AGENTS.md` | `/Users/hareee234/miniconda3/envs/torch-default/...` |
| `opencode/opencode.json` | `github-copilot` provider + `openai/gpt-5.6-*` models; auth and model availability are per-machine |
| `scripts/mac-health.sh` | macOS-only entirely |
| `alacritty/macos.toml` | Copy `linux.toml` instead — see the Alacritty section above |

Safe to copy verbatim on either platform: `nvim/`, `tmux/`, `btop/`, `htop/`,
`neofetch/`, `ohmyposh/`, `claude/statusline-command.sh` (branches on `uname`),
`claude/skills/`, `opencode/agents/`, `opencode/skills/`.

Linux shell overrides should go in `~/.zshrc.local` — **except** on `hari-linux-pc`,
where `~/.zshrc` is maintained directly. See `HARI-LINUX-PC-SETUP.md`.

Deployed Linux adaptations live only on their machine, not in this repo. After a
`git pull`, re-adapt rather than re-copy. `AI-BOOTSTRAP.md` Step 3 covers the process.

### Claude Code settings.json
`claude/settings.json` cannot be deployed by an agent — Claude Code's permission
classifier blocks writes to its own settings file (it governs permission modes).
Apply that one by hand or via `/config`.

## Secrets & `.gitignore`

SSH private keys (`ssh/id_*`), `.env` files, `*.pem`/`*.key` certificates, and `*.bak`/`*.backup` files are all excluded. Never commit secrets.
