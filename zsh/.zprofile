# zsh runs this for login shells; ~/.zshrc also sources it so non-login shells
# (some terminals, tmux panes) still get brew and ~/.local/bin. Guard the body
# so the double-source doesn't add each PATH entry twice.
if [[ -z "${ZPROFILE_SOURCED:-}" ]]; then
  export ZPROFILE_SOURCED=1

  [[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
  export PATH="$HOME/.local/bin:$PATH"
fi
