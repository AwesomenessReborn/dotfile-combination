# Alacritty

Cross-platform terminal emulator config, shared between macOS and Ubuntu.

The design goal is one config that behaves identically on both machines, with
platform differences isolated to two small files. Alacritty is treated as a dumb
renderer — `tmux` is the actual workspace layer, so there are no tabs/panes/session
features configured here on purpose.

## Files

| File | Purpose |
|---|---|
| `alacritty.toml` | Entry point. **Imports only — no settings.** |
| `common.toml` | Shared base: window, font, scrolling, cursor, selection, keybindings |
| `colors-iterm2-dark.toml` | Active palette — iTerm2 "Default" dark, same as `../iterm2/` |
| `colors-catppuccin-mocha.toml` | Alternate palette, not active |
| `linux.toml` | Ubuntu only — `zsh` path, `Full` decorations, `xdg-open` URL hints |
| `macos.toml` | macOS only — `option_as_alt`, `Buttonless` decorations, Command bindings, `open` URL hints |

## How the layering works

Two Alacritty behaviors drive the whole structure. Both were verified against
0.18.0-dev rather than assumed:

1. **The importing file overrides its imports.** A key set in `alacritty.toml`
   could not be overridden by `linux.toml`/`macos.toml`. This is why
   `alacritty.toml` contains nothing but the import list.
2. **Later imports override earlier ones.** Hence the order
   common → colors → platform.

A third behavior makes the platform split work: **a missing import is logged at
INFO and skipped, not treated as an error.** So `alacritty.toml` imports *both*
`linux.toml` and `macos.toml`, and only the relevant one is ever copied onto a
given machine. The other import quietly no-ops.

```
alacritty.toml  (imports only)
  ├── common.toml                 both machines
  ├── colors-iterm2-dark.toml     both machines
  ├── linux.toml                  Ubuntu only  ─┐ exactly one of
  └── macos.toml                  macOS only   ─┘ these two exists
```

## Install — Ubuntu

```bash
mkdir -p ~/.config/alacritty
cd ~/.dotfiles/alacritty
cp alacritty.toml common.toml colors-*.toml linux.toml ~/.config/alacritty/
# macos.toml must NOT be copied here
```

## Install — macOS

```bash
mkdir -p ~/.config/alacritty
cd ~/.dotfiles/alacritty
cp alacritty.toml common.toml colors-*.toml macos.toml ~/.config/alacritty/
# linux.toml must NOT be copied here
```

`live_config_reload` is on, so edits apply to open windows without a restart.

## Font

**JetBrainsMono Nerd Font**, size 12 (13 on macOS).

The `Mono` variant is required, not optional: its icon glyphs are constrained to a
single cell, which is what Alacritty's fixed grid needs. The plain
`JetBrainsMono Nerd Font` variant has double-width icons that get clipped.
The exact family string is `JetBrainsMono Nerd Font Mono`.

```bash
mkdir -p ~/.local/share/fonts/JetBrainsMonoNerdFont
cd /tmp
curl -fLO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip -o -j JetBrainsMono.zip 'JetBrainsMonoNerdFontMono-*.ttf' \
  -d ~/.local/share/fonts/JetBrainsMonoNerdFont
fc-cache -f ~/.local/share/fonts
fc-match "JetBrainsMono Nerd Font Mono:style=Regular"   # should NOT report a fallback
```

On macOS, `brew install --cask font-jetbrains-mono-nerd-font`.

> This supersedes the RobotoMono Nerd Font noted in `../iterm2/README.md`, which
> describes the older iTerm2 profile. The *palette* there is still the source of
> truth; only the font changed.

**Alacritty does not render ligatures**, so JetBrains Mono's `->` `!=` `===` show
as separate glyphs. That is a known Alacritty limitation, not a broken install.

## Building Alacritty from source (Ubuntu)

There is no official apt package; `cargo install alacritty` does not install the
desktop integration. Built from `~/Dev/tools/alacritty`:

```bash
cargo build --release
sudo install -Dm755 target/release/alacritty /usr/local/bin/alacritty
sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
sudo desktop-file-install extra/linux/Alacritty.desktop
sudo update-desktop-database

# completions
sudo install -Dm644 extra/completions/_alacritty     /usr/local/share/zsh/site-functions/_alacritty
sudo install -Dm644 extra/completions/alacritty.bash /usr/share/bash-completion/completions/alacritty

# man pages (needs scdoc)
sudo apt install -y scdoc
scdoc < extra/man/alacritty.1.scd | gzip -c | sudo tee /usr/local/share/man/man1/alacritty.1.gz >/dev/null
scdoc < extra/man/alacritty.5.scd | gzip -c | sudo tee /usr/local/share/man/man5/alacritty.5.gz >/dev/null

# default terminal
sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator \
  /usr/local/bin/alacritty 50
```

Terminfo (`alacritty`, `alacritty-direct`) already ships in Ubuntu's
`ncurses-term`, so `extra/alacritty.info` does not need installing — check with
`infocmp alacritty` before bothering.

## Verifying a config change

Alacritty has no `--check` flag, but it logs config errors on startup and exits
cleanly with `-e`:

```bash
alacritty --print-events -e /bin/true 2>&1 | grep -iE 'error|Configuration files' -A6
```

That prints every file in the resolved import chain, which is the fastest way to
confirm layering is doing what you think.

## Gotchas hit while setting this up

- Regexes in `[[hints.enabled]]` must use TOML **literal** strings (`'''…'''`).
  A basic `"…"` string mangles the backslash escapes and fails to parse.
- `decorations = "Buttonless"` / `"Transparent"` are macOS-only values and are
  invalid on Linux — another reason the platform files must not cross over.
