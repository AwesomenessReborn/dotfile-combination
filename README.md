# dotfiles

Personal dotfiles for macOS and Ubuntu, tracked for transfer between machines.

## Structure

```
dotfile-combination/
├── nvim/           Neovim config (kickstart.nvim + lazy.nvim, LSP, Telescope)
├── alacritty/      Alacritty terminal config (shared macOS + Ubuntu, layered imports)
├── tmux/           tmux config (catppuccin theme, tpm plugins)
├── zsh/            Zsh config (.zshrc, .zprofile)
├── git/            Git config (.gitconfig, global ignore)
├── ssh/            SSH client config (no private keys)
├── ohmyposh/       oh-my-posh prompt theme (default.json)
├── btop/           btop resource monitor config
├── neofetch/       neofetch display config
├── htop/           htop process monitor config
├── iterm2/         iTerm2 color scheme (.itermcolors) + Linux equivalents (Alacritty, Kitty)
├── claude/         Claude Code instructions, settings, statusline, and skills
├── opencode/       OpenCode config, instructions, agents, and skills
└── README.md       This file
```

## Usage

Clone the repo and manually copy configs to their standard locations on the target machine. See the config details below for where each file belongs.

> **Legacy script:** `archive/install.sh` exists as an optional convenience script that can auto-install dependencies and create symlinks, but the primary workflow is manual copy/transfer.

### AI-guided setup on a new machine

For an interactive setup instead of applying every preference automatically, open
an AI coding agent in this repository and use:

> Read `AI-BOOTSTRAP.md` and guide me through setting up this machine. Inspect
> first, show me the proposed component plan, and ask before installing software,
> replacing files, creating symlinks, or changing system settings.

The bootstrap workflow inventories the machine, offers each OpenCode, Claude,
shell, editor, prompt, and terminal component separately, handles platform-specific
differences, and validates only the choices you approve.

## Config details

### `nvim/`
Kickstart.nvim-based config with lazy.nvim. Plugins auto-install on first `nvim` launch.
LSPs configured: pyright, lua_ls, clangd, jsonls (via mason).
Key plugins: Telescope, blink.cmp, conform.nvim, nvim-treesitter, tokyonight colorscheme.

### `alacritty/`
Cross-platform terminal emulator config — the same setup on macOS and Ubuntu.
See `alacritty/README.md` for the full layering explanation and install steps.

- `alacritty.toml` is an **import-only** entry point; settings live in `common.toml`
- Platform differences isolated to `linux.toml` / `macos.toml` — copy only the one
  matching the machine, the other import is skipped harmlessly
- Palette: iTerm2 "Default" dark (shared with `iterm2/`); Catppuccin Mocha included
  as an alternate
- Font: **JetBrainsMono Nerd Font Mono** 12pt (13 on macOS)

> Alacritty is intentionally kept minimal — `tmux` is the workspace layer, so no
> tabs/panes/sessions are configured at the emulator level.

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
Custom oh-my-posh prompt theme — see `ohmyposh/README.md` for full segment docs and install instructions.
- 4-line prompt: time+shell → exit code+exec time+git+python+node → full path → `❯`
- Works on macOS and Linux (zsh/bash)
- Requires a Nerd Font (RobotoMono Nerd Font recommended — matches `iterm2/` config)
- Install on Linux: `curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin`

### `btop/`
btop++ resource monitor config. Catppuccin-themed.

### `neofetch/`
Custom neofetch display config showing OS, CPU, GPU, memory, shell, and terminal info.

### `htop/`
htop process monitor preferences — column layout, sort order, color scheme.

### `iterm2/`
- `Default-dark.itermcolors` / `Default-light.itermcolors` — importable iTerm2 color presets
- `alacritty-colors.toml` — same palette for Alacritty on Linux
- `kitty-colors.conf` — same palette for Kitty on Linux
- Font: **RobotoMono Nerd Font** at 12pt (install from [nerdfonts.com](https://www.nerdfonts.com/font-downloads))
- 5% transparency, blinking cursor, bold+italic enabled, 120×45 default window

> **Linux:** iTerm2 is macOS-only. **Resolved:** standardized on Alacritty for both
> platforms — see `alacritty/`, which is now the maintained config. The palette here
> is still the source of truth; `alacritty/colors-iterm2-dark.toml` is the port of it.
> The RobotoMono font note below is superseded by JetBrainsMono Nerd Font.

### `claude/`
Claude Code global config reference (macOS paths — adjust for Linux):
- `CLAUDE.md` — global instructions
- `settings.json` — global settings (`settings.local.json` is intentionally excluded)
- `statusline-command.sh` — custom statusline
- `skills/` — locally maintained Claude skill variants

### `opencode/`
OpenCode global config snapshot:
- `opencode.json` — providers, agents, permissions, and MCP configuration
- `AGENTS.md` — global working instructions
- `agents/` — custom agents such as `auto-explore`
- `skills/` — locally maintained OpenCode skill variants

Runtime files such as `node_modules`, package manifests, lockfiles, caches, and
authentication data are intentionally excluded. OpenCode and Claude skills with the
same name remain separate when their platform-specific frontmatter differs.

## Manual steps post-install

1. **SSH key** — generate and add: `ssh-keygen -t ed25519 -C "you@email.com"` then add public key to GitHub
2. **gh CLI auth** — `gh auth login`
3. **Nerd Font** — install **JetBrainsMono Nerd Font** (the `Mono` variant) for icons in nvim + oh-my-posh. Exact commands in `alacritty/README.md`.
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
