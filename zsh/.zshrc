[[ -r ~/.zprofile ]] && source ~/.zprofile

if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
    . "$HOME/miniconda3/etc/profile.d/conda.sh"
else
    export PATH="$HOME/miniconda3/bin:$PATH"
fi

eval "$(oh-my-posh init zsh --config ~/.config/ohmyposh/default.json)"

source <(fzf --zsh)

# fnm
FNM_PATH="/opt/homebrew/opt/fnm/bin"
if [ -d "$FNM_PATH" ]; then
  eval "`fnm env`"
fi

eval "$(fnm env --use-on-cd --shell zsh)"

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

neofetch

# Dev backup sync status
_show_backup_status() {
  local status_file="$HOME/Dev/backup-framework/last-backup-status"
  local green='\033[0;32m'
  local red='\033[0;31m'
  local yellow='\033[1;33m'
  local cyan='\033[0;36m'
  local dim='\033[2m'
  local nc='\033[0m'

  if [ ! -f "$status_file" ]; then
    echo -e "  ${yellow}󰕒 Backup${nc}  never run  —  run backup-to-gdrive.sh to start"
    return
  fi

  local backup_status backup_time backup_files backup_size
  backup_status=$(grep 'status=' "$status_file" | cut -d= -f2)
  backup_time=$(grep 'time=' "$status_file" | cut -d= -f2)
  backup_files=$(grep 'files=' "$status_file" | cut -d= -f2)
  backup_size=$(grep 'size=' "$status_file" | cut -d= -f2)

  # Relative time (e.g. "3h ago", "2d ago")
  local time_ago=""
  if [ -n "$backup_time" ]; then
    local now backup_epoch diff
    now=$(date +%s)
    backup_epoch=$(date -j -f "%Y-%m-%d %H:%M" "$backup_time" +%s 2>/dev/null)
    diff=$(( (now - backup_epoch) / 60 ))
    if   [ $diff -lt 60 ];   then time_ago="${diff}m ago"
    elif [ $diff -lt 1440 ]; then time_ago="$(( diff / 60 ))h ago"
    else                          time_ago="$(( diff / 1440 ))d ago"
    fi
  fi

  # SSD usage
  local ssd_info
  ssd_info=$(df -k /System/Volumes/Data | awk 'NR==2 {printf "%.2f GB used / %.2f GB total (%s)", $3/1048576, $2/1048576, $5}')

  if pgrep -x rclone > /dev/null 2>&1; then
    echo -e "  ${cyan}󰕒 Backup${nc}  syncing now..."
    echo -e "  ${dim}SSD: $ssd_info${nc}"
  elif [ "$backup_status" = "success" ]; then
    echo -e "  ${green}󰕒 Backup${nc}  ✓ $time_ago"
    echo -e "  ${dim}$backup_files files backed up, totalling $backup_size transferred to Google Drive.${nc}"
    echo -e "  ${dim}SSD: $ssd_info${nc}"
  else
    echo -e "  ${red}󰕒 Backup${nc}  ✗ FAILED $time_ago"
    echo -e "  ${dim}check backup.log${nc}"
    echo -e "  ${dim}SSD: $ssd_info${nc}"
  fi
}
_show_backup_status

# Git dirty check — tree view (runs as separate script to avoid DEBUG trap interference)
zsh "$HOME/Dev/backup-framework/show-git-status.zsh"
echo

