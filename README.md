# dotfiles

Personal dotfiles for macOS and Ubuntu, managed via symlinks.

## Structure

```
~/.dotfiles/
├── nvim/           Neovim config (kickstart.nvim + lazy.nvim, LSP, Telescope)
├── tmux/           tmux config (catppuccin theme, tpm plugins)
├── zsh/            Zsh config (.zshrc, .zprofile)
├── git/            Git config (.gitconfig, global ignore)
├── ssh/            SSH client config (no private keys)
├── ohmyposh/       oh-my-posh prompt theme (default.json)
├── btop/           btop resource monitor config
├── install.sh      Bootstrap script — run on any new machine
└── README.md       This file
```

## Quick start on a new machine

```bash
# 1. Clone
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/.dotfiles

# 2. Run installer
cd ~/.dotfiles
chmod +x install.sh
./install.sh
```

`install.sh` is idempotent — safe to run multiple times.

## What install.sh does

1. Detects OS (macOS or Ubuntu/Debian)
2. Installs dependencies:
   - **macOS**: via Homebrew (`neovim`, `tmux`, `zsh`, `fzf`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, `ripgrep`, `fd`, `oh-my-posh`, `btop`, `neofetch`, `fnm`)
   - **Ubuntu**: via apt + manual installs for oh-my-posh, fnm, and zsh plugins
3. Creates symlinks from `~/.dotfiles/*` → original config locations
4. Installs [tpm](https://github.com/tmux-plugins/tpm) (tmux plugin manager)
5. Sets zsh as the default shell

## Config details

### `nvim/`
Kickstart.nvim-based config with lazy.nvim. Plugins auto-install on first `nvim` launch.
LSPs configured: pyright, lua_ls, clangd, jsonls (via mason).
Key plugins: Telescope, blink.cmp, conform.nvim, nvim-treesitter, tokyonight colorscheme.

### `tmux/`
- Mouse support, status bar at top
- Theme: catppuccin mocha (via tpm)
- After install: open tmux → press `prefix + I` to install plugins

### `zsh/`
- `.zprofile` — Homebrew env (macOS)
- `.zshrc` — conda, oh-my-posh, fzf, fnm, zsh-autosuggestions, backup status widget

> **macOS-specific paths in `.zshrc`:** Homebrew at `/opt/homebrew`, miniconda at `~/miniconda3`, fnm via brew. On Ubuntu, `install.sh` creates `~/.zshrc.local` with Linux-compatible overrides.

### `git/`
- `.gitconfig` — name, email, default branch `main`, gh credential helper
- `ignore` — global gitignore (`**/.claude/settings.local.json`)

> **macOS-specific:** credential helper uses `/opt/homebrew/bin/gh`. On Ubuntu, change to `gh` (if in PATH) or remove that section.

### `ssh/`
- `config` — `AddKeysToAgent yes`, `UseKeychain yes` (macOS keychain), `IdentityFile ~/.ssh/id_ed25519`

> **macOS-specific:** `UseKeychain yes` is a macOS-only directive. Remove it on Linux.

### `ohmyposh/`
Custom oh-my-posh prompt theme showing: time, shell, exit code, execution time, git status, Python venv, Node version, full path. Requires a [Nerd Font](https://www.nerdfonts.com/).

### `btop/`
btop++ resource monitor config. Catppuccin-themed.

## Manual steps post-install

1. **SSH key** — generate and add: `ssh-keygen -t ed25519 -C "you@email.com"` then add public key to GitHub
2. **gh CLI auth** — `gh auth login`
3. **Nerd Font** — install a Nerd Font in your terminal (e.g. JetBrainsMono Nerd Font) for icons in nvim + oh-my-posh
4. **conda/miniconda** — install separately: https://docs.conda.io/en/latest/miniconda.html
5. **Ubuntu: `.zshrc.local`** — add `source ~/.zshrc.local` at the bottom of `~/.dotfiles/zsh/.zshrc` after first install

## Adding new dotfiles

```bash
cp ~/.config/foo/config.toml ~/.dotfiles/foo/config.toml
ln -s ~/.dotfiles/foo/config.toml ~/.config/foo/config.toml
# then add link_file line to install.sh
```

## Secrets / sensitive files

- SSH private keys are **not** tracked (`ssh/id_*` is in `.gitignore`)
- API keys / tokens → use a `.env` file + add to `.gitignore`
- Machine-specific settings → use `~/.zshrc.local` (not tracked)
