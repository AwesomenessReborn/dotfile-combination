# oh-my-posh prompt theme

Custom prompt theme for [oh-my-posh](https://ohmyposh.dev/) — works on macOS (zsh) and Linux (zsh/bash).

## File

| File | Purpose |
|---|---|
| `default.json` | oh-my-posh theme — copy to `~/.config/ohmyposh/default.json` |

## Prompt layout

The prompt renders across multiple lines:

```
[15:04]  zsh
 x0  123ms   main  ✎ 1 | ✔ 2    3.12.1   v24.11.0
 ~/Dev/projects/my-repo
❯
```

| Line | What it shows |
|---|---|
| 1 | Time (`HH:MM`) + shell name |
| 2 | Exit code · execution time · git status · Python venv+version · Node version |
| 3 | Full current path |
| 4 | Prompt character (`❯`, red `!` if root) |

## Segment breakdown

### Line 1
| Segment | Color | Notes |
|---|---|---|
| Time | `#E5C07B` (gold) | `HH:MM` format |
| Shell | `#E06C75` (red) | Shows `zsh`, `bash`, etc. |

### Line 2
| Segment | Color | Notes |
|---|---|---|
| Exit code | `#b8ff75` green / `#E06C75` red | Green = success, red = error with code reason |
| Execution time | same color-coded | Duration of last command (roundrock diamond style) |
| Git | `#F3C267` gold | Branch, ahead/behind, working/staged changes, stash count |
| Git (dirty) | `#FF9248` orange | When working tree or staging has changes |
| Git (diverged/ahead/behind) | `#B388FF` purple | Upstream sync status |
| Python | `#c8ff00` lime | venv name + Python version (always shown) |
| Node | `#cfee1b` yellow | Node version (always shown) |

### Line 3
| Segment | Color | Notes |
|---|---|---|
| Path | `#61AFEF` blue | Full path style |

### Line 4
| Segment | Color | Notes |
|---|---|---|
| Root indicator | `#E06C75` red | `!` shown only when running as root |
| Prompt char | `#E06C75` red | `❯` |

## Installation

### macOS

```bash
# Install oh-my-posh
brew install oh-my-posh

# Copy config
mkdir -p ~/.config/ohmyposh
cp default.json ~/.config/ohmyposh/default.json

# Add to ~/.zshrc
echo 'eval "$(oh-my-posh init zsh --config ~/.config/ohmyposh/default.json)"' >> ~/.zshrc
```

### Linux (Ubuntu/Debian)

```bash
# Install oh-my-posh
curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin

# Copy config
mkdir -p ~/.config/ohmyposh
cp default.json ~/.config/ohmyposh/default.json

# Add to ~/.zshrc (or ~/.bashrc if using bash)
echo 'eval "$(oh-my-posh init zsh --config ~/.config/ohmyposh/default.json)"' >> ~/.zshrc
```

> Make sure `~/.local/bin` is in your PATH on Linux: `export PATH="$HOME/.local/bin:$PATH"`

## Requirements

- **Nerd Font** — the theme uses Nerd Font icons (e.g. git branch icon, Python snake, Node logo).
  Install **RobotoMono Nerd Font** to match the iTerm2/terminal setup: [nerdfonts.com](https://www.nerdfonts.com/font-downloads)
- **oh-my-posh** v3+ (config uses `"version": 3`)

## Upgrade behavior

Auto-upgrade is disabled (`"auto": false`, `"notice": false`). Update manually:

```bash
# macOS
brew upgrade oh-my-posh

# Linux
curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin
```

## Colors used (quick reference)

| Color | Hex | Role |
|---|---|---|
| Gold | `#E5C07B` | Time |
| Red | `#E06C75` | Shell, exit code (error), prompt char |
| Green | `#b8ff75` | Exit code (success), execution time (success) |
| Orange | `#FF9248` | Git dirty |
| Purple | `#B388FF` | Git ahead/behind |
| Gold | `#F3C267` | Git clean |
| Lime | `#c8ff00` | Python |
| Yellow | `#cfee1b` | Node |
| Blue | `#61AFEF` | Path |
