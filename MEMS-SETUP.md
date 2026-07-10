# MEMS Machine Setup Progress

Machine: **MEMS** — Ubuntu 24.04.4 LTS work box (ST), shared machine (other local users present). Accessed over SSH.

Last updated: 2026-07-10

---

## Done

| Config / Tool | Status | Notes |
|---|---|---|
| zsh | ✅ | `/usr/bin/zsh` (apt), set as login shell via `chsh` |
| oh-my-posh | ✅ | `~/.local/bin/oh-my-posh`, config at `~/.config/ohmyposh/default.json` |
| tmux | ✅ | `/usr/bin/tmux`, `.tmux.conf` + tpm plugins (catppuccin) installed |
| fastfetch | ✅ | Replaces neofetch (archived upstream, unmaintained). Installed via `.deb` from GitHub releases (not in apt/snap). Config at `~/.config/fastfetch/config.jsonc`, mirrors the neofetch field selection |
| htop | ✅ | `/usr/bin/htop`, config from dotfiles (old config backed up to `htoprc.bak-*`) |
| btop | ✅ | `/usr/bin/btop` (already installed), config from dotfiles (old config backed up to `btop.conf.bak-*`) |
| git | ✅ | `~/.gitconfig` — name, email, `gh auth git-credential` helper (already portable, no Homebrew path to fix) |
| ssh config | ✅ | `~/.ssh/config` — `UseKeychain` (macOS-only) stripped; Tailscale alias to hari-linux-pc kept |
| nvim | ✅ | `/snap/bin/nvim`, config copied to `~/.config/nvim/` (kickstart.nvim + lazy.nvim) |
| fnm | ✅ | `~/.local/share/fnm/fnm`, Node v24.18.0 LTS installed and set default, shell integration in `.zshrc.local` |
| fzf | ✅ | apt version (0.44.1) predates `--zsh` flag — replaced with static binary v0.74.0 in `~/.local/bin` |
| fd | ✅ | apt ships it as `fdfind` — aliased to `fd` in `.zshrc.local` |
| zsh-autosuggestions | ✅ | apt package, sourced via existing guard in `.zshrc` |
| Claude Code statusline | ✅ | `~/.claude/settings.json` and `~/.claude/statusline-command.sh` **symlinked** into `~/.dotfiles/claude/` (repo is source of truth — edit there, not in `~/.claude/`) |
| Claude CLAUDE.md | ✅ | **Not symlinked** — `~/.claude/CLAUDE.md` is a Linux-adapted copy (no conda on this box, fnm paths differ, no Google Drive storage convention). See file for details |

---

## Pending

| Config / Tool | Notes |
|---|---|
| `gh auth login` | gh CLI installed but not authenticated — interactive/browser step, do manually |
| Nerd Font | Not needed on the box itself (SSH-accessed, no local terminal here) — install a Nerd Font in whatever terminal app you SSH in from, so oh-my-posh/nvim icons render correctly client-side |
| kitty / GUI terminal | Skipped — this box is accessed over SSH, no local terminal use case |

---

## Notes

### Why fastfetch instead of neofetch
neofetch's maintainer archived the repo in 2024; it receives no updates. fastfetch is the actively maintained, faster (C, not bash) successor recommended by the community. It's not in Ubuntu 24.04's apt repos or as a snap, so it's installed from the GitHub release `.deb` directly.

### Why fzf is a standalone binary here, not the apt package
Ubuntu 24.04's `fzf` package is 0.44.1, which predates the `--zsh` flag used by the shared `.zshrc` (`source <(fzf --zsh)`). Rather than patch the shared `.zshrc`, a current static binary was placed in `~/.local/bin/fzf`, which resolves first on PATH.

### Claude Code config split: symlink vs copy
- `settings.json` and `statusline-command.sh` are **symlinked** from the repo — they're already portable/cross-platform, so the repo is the single source of truth. Edit in `~/.dotfiles/claude/`, then `git commit`.
- `CLAUDE.md` is **copied and adapted**, not symlinked — its content (conda paths, storage strategy) is genuinely machine-specific and would give Claude wrong assumptions if shared verbatim with macOS.

### This is a shared machine
Other local users (e.g. `sahaswap`) have active sessions on this box. All setup here is scoped to the `hareee234` account only — no system-wide changes beyond `chsh` (per-user) and `apt install` for the handful of packages needed (zsh, fzf, zsh-autosuggestions, jq, fastfetch's `.deb`).
