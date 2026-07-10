[[ -r ~/.zprofile ]] && source ~/.zprofile

if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
    . "$HOME/miniconda3/etc/profile.d/conda.sh"
else
    export PATH="$HOME/miniconda3/bin:$PATH"
fi

command -v oh-my-posh >/dev/null 2>&1 && eval "$(oh-my-posh init zsh --config ~/.config/ohmyposh/default.json)"

command -v fzf >/dev/null 2>&1 && source <(fzf --zsh)

# fnm (node version manager) — macOS via brew, Linux via ~/.local/bin
FNM_PATH="/opt/homebrew/opt/fnm/bin"
[[ -d "$FNM_PATH" ]] && export PATH="$FNM_PATH:$PATH"
command -v fnm >/dev/null 2>&1 && eval "$(fnm env --use-on-cd --shell zsh)"

# zsh-autosuggestions — brew (macOS) or system/user paths (Linux)
for _zsh_autosuggest in \
  "${HOMEBREW_PREFIX:-/opt/homebrew}/share/zsh-autosuggestions/zsh-autosuggestions.zsh" \
  /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"; do
  [[ -r "$_zsh_autosuggest" ]] && source "$_zsh_autosuggest" && break
done
unset _zsh_autosuggest

# Linux disk display (per-partition — commented; enable on Linux via ~/.zshrc.local)
# _print_disk() {
#   local mount=$1 label=$2
#   local dim='\033[2m' nc='\033[0m'
#   df -B1 "$mount" | awk -v label="$label" -v dim="$dim" -v nc="$nc" 'NR==2 {
#     used=$3/1073741824; total=$2/1073741824; pct=int($3/$2*100)
#     filled=int(pct/10); empty=10-filled
#     bar=""; for(i=0;i<filled;i++) bar=bar"█"; for(i=0;i<empty;i++) bar=bar"░"
#     printf "  %s󰋊 %-6s %5.1fG / %5.1fG  (%3d%%)  [%s]%s\n", dim, label, used, total, pct, bar, nc
#   }'
# }
# _print_disk /     "/"
# _print_disk /home "/home"

# Backup dashboard widget (macOS only — guarded so a missing file doesn't error)
if [[ -r "$HOME/Dev/backup-framework/terminal-dashboard.zsh" ]]; then
  source "$HOME/Dev/backup-framework/terminal-dashboard.zsh"
  terminal_dashboard_startup
fi


export STM32_PRG_PATH=/Applications/STMicroelectronics/STM32Cube/STM32CubeProgrammer/STM32CubeProgrammer.app/Contents/MacOs/bin

mactopb() {
  if [[ -t 2 ]]; then
    printf "\n⚠️  Using build-from-source mactop\n" >&2
    sleep 1.5
  fi
  /Users/hareee234/Dev/projects/public/mactop/mactop/mactop "$@"
}

mactop_build_if_needed() {
  local repo="/Users/hareee234/Dev/projects/public/mactop/mactop"
  local bin="$repo/mactop"
  local newest_source=""
  local src
  local -a build_inputs

  build_inputs=(
    "$repo"/**/*.go(N)
    "$repo"/go.mod(N)
    "$repo"/go.sum(N)
    "$repo"/Makefile(N)
  )

  if [[ ! -x "$bin" ]]; then
    if [[ -t 2 ]]; then
      printf "Binary missing; building mactop from source...\n" >&2
    fi
  else
    for src in "${build_inputs[@]}"; do
      if [[ -z "$newest_source" || "$src" -nt "$newest_source" ]]; then
        newest_source="$src"
      fi
    done

    if [[ -n "$newest_source" && ! "$bin" -nt "$newest_source" ]]; then
      if [[ -t 2 ]]; then
        printf "Source changes detected; rebuilding mactop...\n" >&2
      fi
    else
      if [[ -t 2 ]]; then
        printf "Build is up to date; skipping rebuild.\n" >&2
      fi
      return 0
    fi
  fi

  (
    cd "$repo" || exit 1
    /opt/homebrew/bin/go build -o mactop main.go
  )
}

mactopbr() {
  if [[ -t 2 ]]; then
    printf "\n⚠️  Using smart rebuild for source mactop\n" >&2
    sleep 1.5
  fi
  mactop_build_if_needed || return 1
  /Users/hareee234/Dev/projects/public/mactop/mactop/mactop "$@"
}

# mac-health: low-noise system health check (throttled to once per 3h, skips tmux)
if [[ -o interactive && -z "${TMUX:-}" ]] && command -v mac-health >/dev/null 2>&1; then
  MAC_HEALTH_LAST="/tmp/.mac_health_last_run_${USER}"
  MAC_HEALTH_NOW="$(date +%s)"
  MAC_HEALTH_INTERVAL=$((3 * 60 * 60))

  if [[ ! -f "$MAC_HEALTH_LAST" ]] || (( MAC_HEALTH_NOW - $(cat "$MAC_HEALTH_LAST" 2>/dev/null || echo 0) > MAC_HEALTH_INTERVAL )); then
    echo "$MAC_HEALTH_NOW" > "$MAC_HEALTH_LAST"
    mac-health
  fi
fi

# Per-machine overrides (not tracked in dotfiles) — Linux paths, work-box tweaks, etc.
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
