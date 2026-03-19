# dotfiles

Personal dotfiles for macOS and Ubuntu, tracked for transfer between machines.

## Structure

```
dotfile-combination/
├── nvim/           Neovim config (kickstart.nvim + lazy.nvim, LSP, Telescope)
├── tmux/           tmux config (catppuccin theme, tpm plugins)
├── zsh/            Zsh config (.zshrc, .zprofile)
├── git/            Git config (.gitconfig, global ignore)
├── ssh/            SSH client config (no private keys)
├── ohmyposh/       oh-my-posh prompt theme (default.json)
├── btop/           btop resource monitor config
├── neofetch/       neofetch display config
├── htop/           htop process monitor config
├── claude/         Claude Code global instructions + settings
└── README.md       This file
```

## Usage

Clone the repo and manually copy configs to their standard locations on the target machine. See the config details below for where each file belongs.

> **Legacy script:** `archive/install.sh` exists as an optional convenience script that can auto-install dependencies and create symlinks, but the primary workflow is manual copy/transfer.

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

> **macOS-specific paths in `.zshrc`:** Homebrew at `/opt/homebrew`, miniconda at `~/miniconda3`, fnm via brew. On Ubuntu, create a `~/.zshrc.local` with Linux-compatible overrides and source it from `.zshrc`.

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

### `neofetch/`
Custom neofetch display config showing OS, CPU, GPU, memory, shell, and terminal info.

### `htop/`
htop process monitor preferences — column layout, sort order, color scheme.

### `claude/`
Claude Code global config reference (macOS paths — adjust for Linux). Not required for machine setup.

## Manual steps post-install

1. **SSH key** — generate and add: `ssh-keygen -t ed25519 -C "you@email.com"` then add public key to GitHub
2. **gh CLI auth** — `gh auth login`
3. **Nerd Font** — install a Nerd Font in your terminal (e.g. JetBrainsMono Nerd Font) for icons in nvim + oh-my-posh
4. **conda/miniconda** — install separately: https://docs.conda.io/en/latest/miniconda.html
5. **Ubuntu: `.zshrc.local`** — create `~/.zshrc.local` with Linux overrides and add `source ~/.zshrc.local` to the bottom of `~/.zshrc`
6. **Tailscale** — `curl -fsSL https://tailscale.com/install.sh | sh` then `sudo tailscale up` to join your tailnet
7. **OpenSSH server** — `sudo apt install -y openssh-server && sudo systemctl enable --now ssh` for remote access over Tailscale or LAN

## Adding new dotfiles

Copy the config into the repo under a descriptive directory:

```bash
cp ~/.config/foo/config.toml dotfile-combination/foo/config.toml
```

## Secrets / sensitive files

- SSH private keys are **not** tracked (`ssh/id_*` is in `.gitignore`)
- API keys / tokens → use a `.env` file + add to `.gitignore`
- Machine-specific settings → use `~/.zshrc.local` (not tracked)
- **rclone** (`~/.config/rclone/rclone.conf`) contains OAuth tokens — **not tracked**. Set up manually: `rclone config` and authenticate with Google Drive
