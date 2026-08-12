# AI-Guided Machine Bootstrap

Use this document with an AI coding agent after cloning this repository onto a
new Mac or Linux machine. The workflow is intentionally interactive: inspect the
machine first, present choices, and make only the changes the user approves.

## Prompt to use

From the cloned dotfiles repository, tell the agent:

> Read `AI-BOOTSTRAP.md` and guide me through setting up this machine. Inspect
> first, show me the proposed component plan, and ask before installing software,
> replacing files, creating symlinks, or changing system settings.

## Instructions for the agent

You are setting up a personal development machine from this dotfiles repository.
Do not assume the new machine should exactly reproduce another machine. Discover
its environment, ask what the user wants, and apply only approved components.

### Safety rules

- Inspect before changing anything.
- Do not stage, commit, push, switch branches, or rewrite Git history unless the
  user explicitly requests it.
- Never read, copy, print, or commit secrets. This includes `.env` files, SSH
  private keys, cloud credentials, keychains, authentication databases, tokens,
  and machine-local settings.
- Never copy `~/.claude/settings.local.json`, OpenCode authentication data,
  session history, caches, package/runtime directories, or generated files.
- Before replacing a regular file or directory, show the conflict and ask whether
  to skip, back it up, merge it, copy the repository version, or create a symlink.
- Do not install packages, alter the login shell, enable services, or change system
  settings without explicit approval.
- Verify current official installation instructions before proposing a package or
  remote installation command. Do not blindly run stale commands from this repo.
- Prefer the smallest reversible change. Preserve existing working configuration.

### Step 1: Inventory the machine

Collect only non-sensitive facts:

- OS, version, architecture, hostname, username, home directory, and shell
- Current dotfiles branch and working-tree status
- Whether each destination below is missing, a regular file, or a symlink
- Availability and versions of relevant tools such as Git, Zsh, Homebrew or the
  platform package manager, OpenCode, Claude Code, tmux, Neovim, oh-my-posh,
  Conda, fnm, Node.js, and common terminal utilities
- Machine-specific setup documents that may apply, including `MEMS-SETUP.md` and
  `HARI-LINUX-PC-SETUP.md`

Do not inspect credential contents while gathering this inventory.

### Step 2: Present an interactive component plan

Show a concise table with these columns:

| Component | Repository source | Current destination state | Recommendation | Action |
|---|---|---|---|---|

For each component, ask the user to choose `skip`, `copy`, `symlink`, or
`review/merge`. Do not treat one answer as approval for unrelated components.

#### AI tooling

| Component | Repository source | Destination |
|---|---|---|
| OpenCode config | `opencode/opencode.json` | `~/.config/opencode/opencode.json` |
| OpenCode instructions | `opencode/AGENTS.md` | `~/.config/opencode/AGENTS.md` |
| OpenCode agents | `opencode/agents/` | `~/.config/opencode/agents/` |
| OpenCode skills | `opencode/skills/` | `~/.config/opencode/skills/` |
| Claude instructions | `claude/CLAUDE.md` | `~/.claude/CLAUDE.md` |
| Claude settings | `claude/settings.json` | `~/.claude/settings.json` |
| Claude statusline | `claude/statusline-command.sh` | `~/.claude/statusline-command.sh` |
| Claude skills | `claude/skills/` | `~/.claude/skills/` |

OpenCode and Claude skills with the same name may have different frontmatter.
Deploy each platform's own variant rather than deduplicating them blindly.

#### Shell and development tools

| Component | Repository source | Destination |
|---|---|---|
| Zsh config | `zsh/.zshrc` | `~/.zshrc` |
| Zsh profile | `zsh/.zprofile` | `~/.zprofile` |
| Git config | `git/.gitconfig` | `~/.gitconfig` |
| Global Git ignore | `git/ignore` | `~/.config/git/ignore` |
| tmux | `tmux/.tmux.conf` | `~/.tmux.conf` |
| SSH client config | `ssh/config` | `~/.ssh/config` |
| Neovim | `nvim/` | `~/.config/nvim` |
| oh-my-posh | `ohmyposh/` | `~/.config/ohmyposh` |
| btop | `btop/` | `~/.config/btop` |
| htop | `htop/htoprc` | `~/.config/htop/htoprc` |
| neofetch | `neofetch/config.conf` | `~/.config/neofetch/config.conf` |

Treat terminal themes under `iterm2/` as optional manual imports. Account for
macOS/Linux differences before using SSH, Homebrew, terminal, or shell settings.

### Step 3: Resolve machine-specific values

Before deploying an approved component, identify hardcoded paths, usernames,
package-manager locations, tool versions, and OS-specific options. Show the user
any required adaptation.

- Prefer `$HOME` or `~` in portable files when the target application supports it.
- Do not silently rewrite the tracked repository snapshot.
- If adaptation is required, prefer a machine-local override when one exists.
- Ask before creating a target-specific copy that will differ from the repository.
- Do not expose or transfer machine-specific credentials.

### Step 4: Apply approved choices

For each approved component:

1. Reconfirm any destructive replacement or package installation.
2. Create missing parent directories safely.
3. Back up an existing destination only after approval, using a timestamped name.
4. Perform the selected copy, symlink, or reviewed merge.
5. Preserve appropriate file modes.
6. Do not modify unrelated files.

When installing OpenCode or another tool, separate the software-install decision
from the config-deployment decision. A user may want one without the other.

### Step 5: Validate

Run only checks relevant to the components actually changed. Examples:

- Parse JSON configuration files.
- Run `opencode debug config` after deploying OpenCode configuration.
- Run `bash -n` on shell scripts.
- Confirm symlink targets and destination paths.
- Confirm expected tools start or report versions.
- Show `git status` for this repository without staging anything.

If an application loads configuration only at startup, tell the user to restart it.

### Step 6: Report

Summarize:

- Components installed or configured
- Components skipped
- Backups created
- Machine-specific adaptations
- Validation performed and results
- Remaining manual steps
- Repository changes, if any

Do not claim the machine is fully configured if checks were skipped or failed.
