#!/usr/bin/env bash
# ~/.dotfiles/install.sh
# Idempotent bootstrap — safe to run multiple times.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ─── Detect OS ──────────────────────────────────────────────────────────────
OS="unknown"
if [[ "$(uname)" == "Darwin" ]]; then
  OS="mac"
elif [[ -f /etc/os-release ]]; then
  . /etc/os-release
  case "$ID" in ubuntu|debian) OS="ubuntu" ;; esac
fi

echo "Detected OS: $OS"

# ─── Install dependencies ────────────────────────────────────────────────────
install_deps() {
  if [[ "$OS" == "mac" ]]; then
    if ! command -v brew &>/dev/null; then
      echo "Installing Homebrew..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    echo "Installing brew packages..."
    brew install neovim tmux zsh fzf zsh-autosuggestions zsh-syntax-highlighting \
                 ripgrep fd oh-my-posh btop neofetch fnm

  elif [[ "$OS" == "ubuntu" ]]; then
    echo "Updating apt..."
    sudo apt-get update -qq

    # Neovim — use official PPA for latest stable
    if ! command -v nvim &>/dev/null; then
      sudo apt-get install -y software-properties-common
      sudo add-apt-repository -y ppa:neovim-ppa/stable
      sudo apt-get update -qq
    fi

    sudo apt-get install -y \
      neovim tmux zsh fzf ripgrep fd-find curl git btop neofetch

    # zsh-autosuggestions + zsh-syntax-highlighting (no brew on Linux)
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.zsh}"
    mkdir -p "$ZSH_CUSTOM"

    if [[ ! -d "$ZSH_CUSTOM/zsh-autosuggestions" ]]; then
      git clone https://github.com/zsh-users/zsh-autosuggestions \
        "$ZSH_CUSTOM/zsh-autosuggestions"
    fi
    if [[ ! -d "$ZSH_CUSTOM/zsh-syntax-highlighting" ]]; then
      git clone https://github.com/zsh-users/zsh-syntax-highlighting \
        "$ZSH_CUSTOM/zsh-syntax-highlighting"
    fi

    # oh-my-posh
    if ! command -v oh-my-posh &>/dev/null; then
      echo "Installing oh-my-posh..."
      curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin
    fi

    # fnm (node version manager)
    if ! command -v fnm &>/dev/null; then
      curl -fsSL https://fnm.vercel.app/install | bash
    fi

  else
    echo "WARNING: Unknown OS — skipping package installation. Install manually:"
    echo "  neovim tmux zsh fzf ripgrep fd oh-my-posh btop neofetch fnm"
    echo "  zsh-autosuggestions zsh-syntax-highlighting"
  fi
}

# ─── Create a symlink (idempotent) ───────────────────────────────────────────
# Usage: link_file <dotfiles-source> <destination>
link_file() {
  local src="$1"
  local dest="$2"

  # Already correct symlink — nothing to do
  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    echo "  ok (already linked): $dest"
    return
  fi

  # Stale symlink or real file — back it up
  if [[ -e "$dest" || -L "$dest" ]]; then
    echo "  backing up: $dest -> ${dest}.bak"
    mv "$dest" "${dest}.bak"
  fi

  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  echo "  linked: $dest -> $src"
}

# ─── Create symlinks ─────────────────────────────────────────────────────────
create_symlinks() {
  echo "Creating symlinks..."

  link_file "$DOTFILES/zsh/.zshrc"        "$HOME/.zshrc"
  link_file "$DOTFILES/zsh/.zprofile"     "$HOME/.zprofile"
  link_file "$DOTFILES/git/.gitconfig"    "$HOME/.gitconfig"
  link_file "$DOTFILES/git/ignore"        "$HOME/.config/git/ignore"
  link_file "$DOTFILES/tmux/.tmux.conf"   "$HOME/.tmux.conf"
  link_file "$DOTFILES/ssh/config"        "$HOME/.ssh/config"
  link_file "$DOTFILES/nvim"              "$HOME/.config/nvim"
  link_file "$DOTFILES/ohmyposh"          "$HOME/.config/ohmyposh"
  link_file "$DOTFILES/btop"              "$HOME/.config/btop"
}

# ─── tmux plugin manager (tpm) ───────────────────────────────────────────────
install_tpm() {
  local TPM_DIR="$HOME/.tmux/plugins/tpm"
  if [[ ! -d "$TPM_DIR" ]]; then
    echo "Installing tpm (tmux plugin manager)..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    echo "  Run: tmux source ~/.tmux.conf  then press prefix+I to install plugins"
  else
    echo "  ok: tpm already installed"
  fi
}

# ─── Set zsh as default shell ────────────────────────────────────────────────
set_zsh_default() {
  local zsh_path
  zsh_path="$(command -v zsh 2>/dev/null || true)"

  if [[ -z "$zsh_path" ]]; then
    echo "WARNING: zsh not found in PATH — skipping default shell change"
    return
  fi

  if [[ "$SHELL" == "$zsh_path" ]]; then
    echo "  ok: zsh already default shell"
    return
  fi

  # Ensure zsh is in /etc/shells
  if ! grep -qxF "$zsh_path" /etc/shells; then
    echo "$zsh_path" | sudo tee -a /etc/shells
  fi

  echo "Setting zsh as default shell..."
  chsh -s "$zsh_path"
}

# ─── Linux-specific: patch .zshrc for apt paths ─────────────────────────────
# NOTE: The committed .zshrc is tuned for macOS (Homebrew, /opt/homebrew).
# On Ubuntu you'll want to source from ~/.zsh/ instead. A simple override file
# is created at ~/.zshrc.local — source it at the bottom of .zshrc to add
# Linux-specific overrides without editing the shared file.
create_linux_overrides() {
  if [[ "$OS" != "ubuntu" ]]; then return; fi

  local override="$HOME/.zshrc.local"
  if [[ -f "$override" ]]; then
    echo "  ok: $override already exists — not overwriting"
    return
  fi

  cat > "$override" << 'EOF'
# ~/.zshrc.local — Linux overrides (not tracked in dotfiles)
# Sourced from ~/.zshrc when present.

# zsh plugins (cloned by install.sh)
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.zsh}"
source "$ZSH_CUSTOM/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$ZSH_CUSTOM/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# fnm
export PATH="$HOME/.local/share/fnm:$PATH"
eval "$(fnm env --use-on-cd --shell zsh)"

# oh-my-posh
export PATH="$HOME/.local/bin:$PATH"
eval "$(oh-my-posh init zsh --config ~/.config/ohmyposh/default.json)"
EOF

  echo "  created: $override (Linux overrides)"
  echo "  ACTION NEEDED: Add 'source ~/.zshrc.local' to the bottom of ~/.dotfiles/zsh/.zshrc"
}

# ─── Main ────────────────────────────────────────────────────────────────────
echo ""
echo "=== dotfiles install.sh ==="
echo ""

install_deps
create_symlinks
install_tpm
set_zsh_default
create_linux_overrides

echo ""
echo "=== Done! ==="
echo ""
echo "Next steps:"
echo "  1. Restart your terminal (or: exec zsh)"
echo "  2. Open tmux, press prefix+I to install plugins"
echo "  3. Open nvim — lazy.nvim will auto-install plugins on first launch"
if [[ "$OS" == "ubuntu" ]]; then
  echo "  4. Review ~/.zshrc.local and add 'source ~/.zshrc.local' to ~/.dotfiles/zsh/.zshrc"
fi
