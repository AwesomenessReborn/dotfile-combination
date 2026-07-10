# Linux Machine Setup Progress

Machine: **hari-linux-pc** — Ubuntu Linux, NVIDIA GeForce RTX 5070 Ti (16GB), Driver 580.126.09 / CUDA 13.0

Last updated: 2026-03-22

---

## Done

| Config / Tool | Status | Notes |
|---|---|---|
| zsh | ✅ | `/usr/bin/zsh`, default shell |
| oh-my-posh | ✅ | `~/.local/bin/oh-my-posh`, config at `~/.config/ohmyposh/default.json` |
| tmux | ✅ | `/usr/bin/tmux`, `.tmux.conf` with tpm plugins |
| kitty terminal | ✅ | `~/.local/bin/kitty`, `kitty.conf` sets MesloLGS Nerd Font |
| MesloLGS Nerd Font | ✅ | Installed system-wide |
| neofetch | ✅ | `/usr/bin/neofetch`, config at `~/.config/neofetch/config.conf` |
| htop | ✅ | `/usr/bin/htop` |
| git | ✅ | `~/.gitconfig` — name, email, `defaultBranch = main` |
| Claude CLAUDE.md | ✅ | `~/.claude/CLAUDE.md` |
| Claude statusline | ✅ | `~/.claude/settings.json` — time, dir, git branch, model, token usage |
| Claude memory | ✅ | Active and working |
| Tailscale | ✅ | Connected — `100.106.106.24`, hostname `hari-linux-pc` |
| OpenSSH server | ✅ | Installed, `systemctl enable --now ssh` |
| nvim | ✅ | `/usr/bin/nvim` v0.9.5, config at `~/.config/nvim/` (kickstart.nvim + lazy.nvim) |
| fnm | ✅ | `~/.local/share/fnm`, shell integration in `.zshrc`, LTS Node installed |
| fzf | ✅ | `~/Dev/tools/fzf` (git install), v0.70.0, shell integration via `~/.fzf.zsh` |
| zsh-autosuggestions | ✅ | apt package, sourced in `.zshrc` |
| login display | ✅ | neofetch + git status tree (`~/Dev/tools/show-git-status.zsh`) on shell start |

---

## Pending

| Config / Tool | Notes |
|---|---|
| btop | Not installed — config in `btop/btop.conf`, deploy to `~/.config/btop/` |
| `~/.ssh/config` | Doesn't exist — copy from `ssh/config`, remove `UseKeychain yes` (macOS-only) |
| git credential helper | `gh auth login` then update `~/.gitconfig` — replace `/opt/homebrew/bin/gh` with `gh` |
| nvtop | Low priority — apt version crashes, build from source (see [TODO-nvtop.md](TODO-nvtop.md)) |
| rclone backup status | Low priority — port `_show_backup_status()` from Mac once rclone is set up |

---

## Notes

### `.zshrc` on Linux
The Linux `.zshrc` is maintained directly (not via `.zshrc.local`). It includes: oh-my-posh, fnm, fzf, zsh-autosuggestions, neofetch, and git status tree. The repo `zsh/.zshrc` remains macOS-specific.

### git on Linux
The repo `git/.gitconfig` uses `/opt/homebrew/bin/gh` as the credential helper. On Linux:
```
gh auth login
```
Then update `~/.gitconfig` credential helper lines to use plain `gh` instead of the Homebrew path.

### SSH config
The repo `ssh/config` includes `UseKeychain yes` which is macOS-only. Remove that line when copying to Linux.

### nvtop
The packaged `nvtop` crashes due to an AMD GPU backend assertion bug, even on NVIDIA-only machines. The RTX 5070 Ti is also too new for the packaged version. Build from source — see [TODO-nvtop.md](TODO-nvtop.md).
