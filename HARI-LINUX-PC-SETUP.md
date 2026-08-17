# Linux Machine Setup Progress

Machine: **hari-linux-pc** — Ubuntu 24.04.4 LTS, NVIDIA GeForce RTX 5070 Ti (16GB), Driver 580.126.09 / CUDA 13.0

Last updated: 2026-08-16

---

## Done

| Config / Tool | Status | Notes |
|---|---|---|
| zsh | ✅ | `/usr/bin/zsh`, default shell |
| oh-my-posh | ✅ | `~/.local/bin/oh-my-posh`, config at `~/.config/ohmyposh/default.json` |
| tmux | ✅ | `/usr/bin/tmux`, `.tmux.conf` with tpm plugins |
| kitty terminal | ✅ | `~/.local/bin/kitty`, `kitty.conf` sets MesloLGS Nerd Font — **superseded by Alacritty, migration pending** |
| MesloLGS Nerd Font | ✅ | Installed system-wide |
| neofetch | ✅ | `/usr/bin/neofetch`, config at `~/.config/neofetch/config.conf` |
| htop | ✅ | `/usr/bin/htop` |
| btop | ✅ | `/usr/bin/btop` v1.3.0, config at `~/.config/btop/` |
| nvtop | ✅ | `/usr/local/bin/nvtop` — built from source, see [TODO-nvtop.md](TODO-nvtop.md) |
| git | ✅ | `~/.gitconfig` — name, email, `defaultBranch = main` |
| Claude CLAUDE.md | ✅ | `~/.claude/CLAUDE.md` — **Linux-adapted**, see note below |
| Claude statusline | ✅ | `~/.claude/statusline-command.sh` — deployed from repo 2026-08-16 |
| Claude skills | ✅ | `~/.claude/skills/` — `handoff`, `smart-commit` |
| Claude memory | ✅ | Active and working |
| OpenCode | ✅ | via fnm Node; config, `AGENTS.md`, `agents/`, `skills/` deployed 2026-08-16 |
| Tailscale | ✅ | Connected — `100.87.163.44`, hostname `hari-linux-pc` |
| OpenSSH server | ✅ | Installed, `systemctl enable --now ssh` |
| nvim | ✅ | `~/.local/bin/nvim` v0.11.6, config at `~/.config/nvim/` (kickstart.nvim + lazy.nvim) |
| fnm | ✅ | `~/.local/share/fnm`, shell integration in `.zshrc`, Node v24.14.0 / npm 11.9.0 |
| miniconda | ✅ | `~/miniconda3` — default env `torch5070` (py3.12.13, torch 2.11.0+cu130) |
| fzf | ✅ | `~/Dev/tools/fzf` (git install), v0.70.0, shell integration via `~/.fzf.zsh` |
| zsh-autosuggestions | ✅ | apt package, sourced in `.zshrc` |
| login display | ✅ | neofetch + git status tree (`~/Dev/tools/show-git-status.zsh`) on shell start |

---

## Pending

| Config / Tool | Notes |
|---|---|
| **gh auth** | ⚠️ Token in `~/.config/gh/hosts.yml` is **invalid** — run `gh auth login -h github.com`. HTTPS GitHub operations will fail until fixed (SSH remotes are unaffected). |
| `~/.claude/settings.json` | Still the minimal 4-key version. Repo adds plugins, `effortLevel`, `autoCompactEnabled: false`, `skipAutoPermissionPrompt`. Must be edited by hand — Claude Code's permission classifier blocks agents from writing its own settings file. |
| Alacritty migration | Not installed. Repo standardizes on it for both platforms; requires JetBrainsMono Nerd Font **Mono** variant. Decide what happens to kitty. |
| `~/.ssh/config` | Doesn't exist — copy from `ssh/config`, remove `UseKeychain yes` (macOS-only) |
| git credential helper | `~/.gitconfig` has **no** credential helper section at all on this machine. Add one using plain `gh` (not the Homebrew path) after `gh auth login`. |
| rclone / cloud data | Not configured. No Google Drive mount on Linux (macOS-only app). Blocks porting `_show_backup_status()`. |

---

## Notes

### Repo configs that are macOS snapshots — do NOT copy verbatim
These files in the repo are Mac-specific and will regress this machine if copied as-is:

| Repo file | Problem on Linux |
|---|---|
| `claude/CLAUDE.md` | `/Users/hareee234/...` conda + Google Drive CloudStorage paths, Homebrew fnm |
| `opencode/AGENTS.md` | `/Users/hareee234/miniconda3/envs/torch-default/...` |
| `opencode/opencode.json` | `github-copilot` provider + `openai/gpt-5.6-sol` — neither is available here; this machine authenticates `opencode-go` only |
| `zsh/.zshrc`, `zsh/.zprofile` | Homebrew paths |
| `git/.gitconfig` | `/opt/homebrew/bin/gh` credential helper |
| `ssh/config` | `UseKeychain yes` |
| `scripts/mac-health.sh` | macOS-only entirely |

The deployed Linux versions live only on this machine, not in the repo. Re-adapt
rather than re-copy after a `git pull`. See `AI-BOOTSTRAP.md` Step 3.

### OpenCode models on this machine
Only the `opencode` / `opencode-go` providers are authenticated (`opencode auth list`).
Deployed agent→model mapping:

| Agent | Model |
|---|---|
| plan, review | `opencode-go/qwen3.6-plus` |
| build, auto | `opencode-go/minimax-m2.7` |
| explore | `opencode-go/deepseek-v4-flash` |

`default_agent` is `auto`, which depends on `agents/auto-explore.md` being deployed.

### `.zshrc` on Linux
The Linux `.zshrc` is maintained directly (not via `.zshrc.local`). It includes: oh-my-posh, fnm, fzf, zsh-autosuggestions, neofetch, and git status tree. The repo `zsh/.zshrc` remains macOS-specific.

### SSH config
The repo `ssh/config` includes `UseKeychain yes` which is macOS-only. Remove that line when copying to Linux.

### nvtop
The packaged `nvtop` crashed due to an AMD GPU backend assertion bug, and the RTX 5070 Ti was too new for the packaged version. Resolved by building from source — now at `/usr/local/bin/nvtop`. See [TODO-nvtop.md](TODO-nvtop.md).
