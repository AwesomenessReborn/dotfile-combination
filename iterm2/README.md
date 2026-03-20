# iTerm2 Color Scheme & Profile

Exported from iTerm2 "Default" profile on macOS (2026-03-19).
Supports both **dark** and **light** mode variants.

## Files

| File | Purpose |
|---|---|
| `Default-dark.itermcolors` | Importable iTerm2 color scheme — dark mode |
| `Default-light.itermcolors` | Importable iTerm2 color scheme — light mode |
| `alacritty-colors.toml` | Same palette for [Alacritty](https://alacritty.org/) on Linux |
| `kitty-colors.conf` | Same palette for [Kitty](https://sw.kovidgoyal.net/kitty/) on Linux |

## Color palette (dark mode)

| Role | Hex |
|---|---|
| Background | `#15191f` |
| Foreground | `#dcdcdc` |
| Cursor | `#ffffff` |
| Selection bg | `#b3d7ff` |
| Link | `#328eee` |

| ANSI | Normal | Bright |
|---|---|---|
| Black (0/8) | `#14191e` | `#686868` |
| Red (1/9) | `#b43c2a` | `#dd7975` |
| Green (2/10) | `#00c200` | `#58e790` |
| Yellow (3/11) | `#c7c400` | `#ece100` |
| Blue (4/12) | `#2744c7` | `#a7abf2` |
| Magenta (5/13) | `#c040be` | `#e17ee1` |
| Cyan (6/14) | `#00c5c7` | `#60fdff` |
| White (7/15) | `#c7c7c7` | `#ffffff` |

## Font

`RobotoMonoNFM-Rg` at size 12 (Roboto Mono Nerd Font).
Install on Linux: download from [nerdfonts.com](https://www.nerdfonts.com/font-downloads) → "RobotoMono Nerd Font"

```bash
mkdir -p ~/.local/share/fonts
unzip RobotoMonoNerdFont.zip -d ~/.local/share/fonts/
fc-cache -fv
```

## Other profile settings

| Setting | Value |
|---|---|
| Terminal type | `xterm-256color` |
| Transparency | 5% (0.05) |
| Blinking cursor | yes |
| Bold / italic | enabled |
| Scrollback lines | 1000 |
| Default columns × rows | 120 × 45 |
| Horizontal spacing | 1.1 |
| Vertical spacing | 1.0 |

## Using on macOS (iTerm2)

1. Open iTerm2 → Preferences → Profiles → Colors → **Color Presets…** → Import
2. Select `Default-dark.itermcolors` or `Default-light.itermcolors`
3. Apply the preset

## Using on Linux — Alacritty

```bash
mkdir -p ~/.config/alacritty
cp alacritty-colors.toml ~/.config/alacritty/alacritty.toml
# Or add to existing config:
# import = ["~/.config/alacritty/iterm2-colors.toml"]
```

## Using on Linux — Kitty

```bash
mkdir -p ~/.config/kitty
cp kitty-colors.conf ~/.config/kitty/kitty.conf
# Or add to existing kitty.conf:
# include iterm2-colors.conf
```

## Linux terminal recommendation

iTerm2 is macOS-only. Best Linux equivalents that support Nerd Fonts well:

- **Kitty** — GPU-accelerated, feature-rich, great config system
- **Alacritty** — minimal, fast, TOML config
- **WezTerm** — cross-platform, Lua config, closest to iTerm2 feature set
