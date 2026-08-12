#!/usr/bin/env bash
# Claude Code status line script
# ~/.claude/statusline-command.sh
#
# Styled to match the oh-my-posh prompt theme
# (source of truth: ~/.dotfiles/ohmyposh/default.json)
# Segments: [time] user@host  os-icon  model   path  git-branch(status)  python  node  ctx%
# Rendered on a single line (Claude Code statuslines are single-line).

input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
model=$(echo "$input" | jq -r '.model.display_name')
ctx_used=$(echo "$input" | jq -r '(.context_window.used_percentage // empty) | floor' 2>/dev/null)
fivehr_used=$(echo "$input" | jq -r '(.rate_limits.five_hour.used_percentage // empty) | floor' 2>/dev/null)
sevenday_used=$(echo "$input" | jq -r '(.rate_limits.seven_day.used_percentage // empty) | floor' 2>/dev/null)
fivehr_reset=$(echo "$input" | jq -r '(.rate_limits.five_hour.resets_at // empty)' 2>/dev/null)
sevenday_reset=$(echo "$input" | jq -r '(.rate_limits.seven_day.resets_at // empty)' 2>/dev/null)

# Format a Unix epoch as a dim "(…)" reset hint. macOS: date -r <epoch>; GNU: date -d @<epoch>
reset_hint() {
  local epoch=$1 fmt=$2 out
  [ -z "$epoch" ] && return
  out=$(date -r "$epoch" +"$fmt" 2>/dev/null) || out=$(date -d "@$epoch" +"$fmt" 2>/dev/null)
  [ -n "$out" ] && printf " \033[2;38;2;171;178;191m(%s)\033[0m" "$out"
}

# Progress bar: make_bar <pct> <width> [color] -> colored █/░ bar.
# If [color] (an ANSI SGR sequence) is given it is used for the whole bar;
# otherwise it falls back to usage thresholds (green<50, amber<80, red>=80).
make_bar() {
  local pct=$1 width=${2:-8} override=$3 filled empty i out c
  [ -z "$pct" ] && pct=0
  filled=$(( (pct * width + 50) / 100 ))
  [ "$filled" -gt "$width" ] && filled=$width
  [ "$filled" -lt 0 ] && filled=0
  empty=$(( width - filled ))
  if   [ -n "$override" ];    then c="$override"
  elif [ "$pct" -ge 80 ]; then c="\033[38;2;224;108;117m"   # red   #E06C75
  elif [ "$pct" -ge 50 ]; then c="\033[38;2;229;192;123m"   # amber #E5C07B
  else                         c="\033[38;2;152;195;121m"; fi # green #98C379
  out="$c"
  for ((i=0;i<filled;i++)); do out="${out}\xe2\x96\x88"; done   # █
  out="${out}\033[2;38;2;171;178;191m"
  for ((i=0;i<empty;i++));  do out="${out}\xe2\x96\x91"; done   # ░
  out="${out} ${c}${pct}%\033[0m"
  printf "%b" "$out"
}

time_str=$(date +"%H:%M")
user=$(whoami)
host=$(hostname -s)

# Path, home-shortened (mirrors the omp "path" segment)
display_path="${cwd/#$HOME/~}"

# --- Git (skip optional locks, mirrors omp "git" segment) ---
git_seg=""
if git -C "$cwd" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)
  changed=$(git -C "$cwd" --no-optional-locks diff --numstat 2>/dev/null | wc -l | tr -d ' ')
  staged=$(git -C "$cwd" --no-optional-locks diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')

  git_color="\033[38;5;221m"  # clean: 221 #FFD75F
  if [ "$changed" != "0" ] || [ "$staged" != "0" ]; then
    git_color="\033[38;5;215m"  # dirty: 215 #FFAF5F
  fi

  git_seg="${git_color}\xee\x82\xa0 ${branch}"
  [ "$changed" != "0" ] && git_seg="${git_seg} \xef\x81\x84 ${changed}"
  [ "$staged"  != "0" ] && git_seg="${git_seg} \xef\x81\x86 ${staged}"
  git_seg="${git_seg}\033[0m"
fi

# --- Python / Conda (contextual, mirrors omp "python" segment) ---
py_seg=""
if [ -n "$CONDA_DEFAULT_ENV" ]; then
  conda_python="$HOME/miniconda3/envs/${CONDA_DEFAULT_ENV}/bin/python"
  [ "$CONDA_DEFAULT_ENV" = "base" ] && conda_python="$HOME/miniconda3/bin/python"
  py_ver=""
  [ -x "$conda_python" ] && py_ver=$("$conda_python" --version 2>&1 | awk '{print $2}')
  py_seg=" \033[38;5;190m\xee\x88\xb5 ${CONDA_DEFAULT_ENV}${py_ver:+ ($py_ver)}\033[0m"
elif [ -n "$VIRTUAL_ENV" ]; then
  venv_python="$VIRTUAL_ENV/bin/python"
  py_ver=""
  [ -x "$venv_python" ] && py_ver=$("$venv_python" --version 2>&1 | awk '{print $2}')
  py_seg=" \033[38;5;190m\xee\x88\xb5 $(basename "$VIRTUAL_ENV")${py_ver:+ ($py_ver)}\033[0m"
elif [ -f "$cwd/pyproject.toml" ] || [ -f "$cwd/requirements.txt" ] || ls "$cwd"/*.py >/dev/null 2>&1; then
  conda_python="$HOME/miniconda3/envs/torch-default/bin/python"
  py_ver=""
  [ -x "$conda_python" ] && py_ver=$("$conda_python" --version 2>&1 | awk '{print $2}')
  py_seg=" \033[38;5;190m\xee\x88\xb5 torch-default${py_ver:+ ($py_ver)}\033[0m"
fi

# --- Node.js (contextual, mirrors omp "node" segment) ---
node_seg=""
if [ -f "$cwd/package.json" ]; then
  node_ver_file=""
  if [ -f "$cwd/.node-version" ]; then
    node_ver_file=$(tr -d '[:space:]v' < "$cwd/.node-version" 2>/dev/null)
  elif [ -f "$cwd/.nvmrc" ]; then
    node_ver_file=$(tr -d '[:space:]v' < "$cwd/.nvmrc" 2>/dev/null)
  fi

  node_bin="$HOME/.local/share/fnm/node-versions/v24.11.0/installation/bin/node"
  if [ -n "$node_ver_file" ] && [ -x "$HOME/.local/share/fnm/node-versions/v${node_ver_file}/installation/bin/node" ]; then
    node_bin="$HOME/.local/share/fnm/node-versions/v${node_ver_file}/installation/bin/node"
  fi

  node_ver=""
  [ -x "$node_bin" ] && node_ver=$("$node_bin" --version 2>/dev/null | tr -d 'v')
  [ -n "$node_ver" ] && node_seg=" \033[38;5;71m\xee\x9c\x98 v${node_ver}\033[0m"
fi

# --- Session cost (dollar amount, green like money) ---
cost=$(echo "$input" | jq -r '(.cost.total_cost_usd // empty)' 2>/dev/null)
cost_seg=""
if [ -n "$cost" ]; then
  cost_fmt=$(printf "%.2f" "$cost" 2>/dev/null)
  cost_seg=" \033[38;5;156m\$${cost_fmt}\033[0m"  # 156 #AFFF87
fi

# --- Reasoning effort (live .effort.level, else persisted settings.json) ---
effort=$(echo "$input" | jq -r '(.effort.level // empty)' 2>/dev/null)
[ -z "$effort" ] && effort=$(jq -r '(.effortLevel // empty)' "$HOME/.claude/settings.json" 2>/dev/null)
effort_seg=""
if [ -n "$effort" ]; then
  case "$effort" in
    high)   effort_color="\033[38;2;152;195;121m" ;;  # #98C379 green
    medium) effort_color="\033[38;2;229;192;123m" ;;  # #E5C07B amber
    low)    effort_color="\033[38;2;224;108;117m" ;;  # #E06C75 red
    *)      effort_color="\033[38;2;171;178;191m" ;;  # #ABB2BF grey
  esac
  effort_seg=" ${effort_color}effort:${effort}\033[0m"
fi

# --- Render (3-line dashboard) ---
# Line 1: status — time, host, os, model, git, py, node
printf "\033[38;5;179m[%s]\033[0m" "$time_str"                                # time  179 #D7AF5F
printf " \033[38;5;245m%s@%s\033[0m" "$user" "$host"                          # user@host (OS-label grey)  245 #8A8A8A
printf " \033[38;5;245m\xef\x85\xb9\033[0m"                                    # apple icon  245 #8A8A8A
printf " \033[90m\xee\x9e\x95 %s\033[0m" "$model"                              # model  theme-grey (documented \033[90m)
[ -n "$git_seg" ]    && printf " %b" "$git_seg"
[ -n "$py_seg" ]     && printf "%b" "$py_seg"
[ -n "$node_seg" ]   && printf "%b" "$node_seg"
echo

# Line 2: usage dashboard — ctx / 5h / 7d progress bars, then cost + effort
# Fixed per-bar colors (One Dark palette): ctx=blue, 5h=yellow, 7d=purple
c_ctx="\033[38;5;75m"    # blue    75  #5FAFFF
c_5h="\033[38;5;215m"    # orange  215 #FFAF5F
c_7d="\033[38;5;177m"    # purple  177 #D787FF

printf "\033[90mctx\033[0m ";  make_bar "${ctx_used:-0}" 8 "$c_ctx"
[ -n "$fivehr_used" ]   && { printf "  \033[90m5h\033[0m ";  make_bar "$fivehr_used" 8 "$c_5h";   reset_hint "$fivehr_reset" "%H:%M"; }
[ -n "$sevenday_used" ] && { printf "  \033[90m7d\033[0m ";  make_bar "$sevenday_used" 8 "$c_7d"; reset_hint "$sevenday_reset" "%a %H:%M"; }
[ -n "$cost_seg" ]   && printf " %b" "$cost_seg"
[ -n "$effort_seg" ] && printf "%b" "$effort_seg"
echo

# Line 3: path on its own line, closest to the prompt (mirrors omp path segment)
printf "\033[38;5;75m\xee\xaa\x83 %s\033[0m\n" "$display_path"                 # path (dir)  75 #5FAFFF
