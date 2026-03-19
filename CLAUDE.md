# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

Personal dotfiles repository that manages development environment configurations for macOS and Ubuntu/Linux. All configs live in `~/.dotfiles/` and are symlinked to their standard locations via `install.sh`.

## Installation

```bash
# Bootstrap everything (idempotent — safe to run multiple times)
bash install.sh
```

The script auto-detects the OS (macOS vs Ubuntu/Debian), installs dependencies, creates symlinks, and sets zsh as the default shell. Existing configs are backed up with a `.bak` suffix before symlinking.

### Post-install steps (manual)
1. Restart shell: `exec zsh`
2. Install tmux plugins: open tmux, press `prefix + I`
3. Open `nvim` — lazy.nvim auto-installs plugins on first launch
4. Install a Nerd Font for icon support in the prompt and nvim
5. Linux only: review `~/.zshrc.local` and source it from `~/.zshrc`

## Symlink Mapping

| Source (in repo) | Destination |
|---|---|
| `zsh/.zshrc` | `~/.zshrc` |
| `zsh/.zprofile` | `~/.zprofile` |
| `git/.gitconfig` | `~/.gitconfig` |
| `git/ignore` | `~/.config/git/ignore` |
| `tmux/.tmux.conf` | `~/.tmux.conf` |
| `ssh/config` | `~/.ssh/config` |
| `nvim/` | `~/.config/nvim` |
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

### Tmux (`tmux/`)
Mouse enabled, status bar at top, true color, Catppuccin Mocha theme via tpm. Vim-style pane navigation (`h/j/k/l`).

### Git (`git/`)
- `.gitconfig`: Uses `gh auth git-credential` for GitHub auth (Homebrew path on macOS)
- `ignore`: Global gitignore — currently ignores `.claude/settings.local.json`

### Platform differences
macOS paths are hardcoded in `.zshrc` and `.gitconfig` (Homebrew at `/opt/homebrew`). Linux overrides should go in `~/.zshrc.local`, which the install script creates automatically.

## Secrets & `.gitignore`

SSH private keys (`ssh/id_*`), `.env` files, `*.pem`/`*.key` certificates, and `*.bak`/`*.backup` files are all excluded. Never commit secrets.
