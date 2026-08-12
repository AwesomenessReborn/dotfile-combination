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

### Platform differences
macOS paths are hardcoded in `.zshrc` and `.gitconfig` (Homebrew at `/opt/homebrew`). Linux overrides should go in `~/.zshrc.local`.

## Secrets & `.gitignore`

SSH private keys (`ssh/id_*`), `.env` files, `*.pem`/`*.key` certificates, and `*.bak`/`*.backup` files are all excluded. Never commit secrets.
