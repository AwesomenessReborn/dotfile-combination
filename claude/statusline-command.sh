#!/usr/bin/env bash
# Claude Code status line script
# ~/.claude/statusline-command.sh

input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
model=$(echo "$input" | jq -r '.model.display_name')
ctx_used=$(echo "$input" | jq -r '(.context_window.used_percentage // empty) | floor' 2>/dev/null)
five_hr=$(echo "$input" | jq -r '(.rate_limits.five_hour.used_percentage // empty) | floor' 2>/dev/null)
seven_day=$(echo "$input" | jq -r '(.rate_limits.seven_day.used_percentage // empty) | floor' 2>/dev/null)
cost_raw=$(echo "$input" | jq -r '.cost.total_cost_usd // empty' 2>/dev/null)

# --- Rate limit reset times ---
five_hr_reset_raw=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
seven_day_reset_raw=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

# 5-hour window: show time only (HH:MM) — it always resets within hours
five_hr_reset=""
if [ -n "$five_hr_reset_raw" ]; then
  if [[ "$(uname)" == "Darwin" ]]; then
    five_hr_reset=$(date -r "$five_hr_reset_raw" "+%H:%M" 2>/dev/null)
  else
    five_hr_reset=$(date -d "@$five_hr_reset_raw" "+%H:%M" 2>/dev/null)
  fi
fi

# 7-day window: show day + time (Mon HH:MM)
seven_day_reset=""
if [ -n "$seven_day_reset_raw" ]; then
  if [[ "$(uname)" == "Darwin" ]]; then
    seven_day_reset=$(date -r "$seven_day_reset_raw" "+%a %H:%M" 2>/dev/null)
  else
    seven_day_reset=$(date -d "@$seven_day_reset_raw" "+%a %H:%M" 2>/dev/null)
  fi
fi
time=$(date +"%a %m/%d %H:%M")
dir=$(basename "$cwd")
os_label=$([ "$(uname)" = "Darwin" ] && echo "macOS" || echo "Linux")

# --- Git ---
branch=$(git -C "$cwd" -c core.useBuiltinFSMonitor=false rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
if [ -n "$branch" ]; then
  git -C "$cwd" -c core.useBuiltinFSMonitor=false diff --quiet 2>/dev/null \
    && git -C "$cwd" -c core.useBuiltinFSMonitor=false diff --cached --quiet 2>/dev/null \
    && changed="clean" || changed="dirty"
fi

# --- Python / Conda (contextual) ---
# Show when: conda env is active OR python-related files exist in cwd
py_env=""
py_version=""
has_python_files=false
if [ -f "$cwd/pyproject.toml" ] || [ -f "$cwd/requirements.txt" ] || ls "$cwd"/*.py 2>/dev/null | head -1 | grep -q .; then
  has_python_files=true
fi

if [ -n "$CONDA_DEFAULT_ENV" ]; then
  py_env="$CONDA_DEFAULT_ENV"
  # Get python version from the conda env
  conda_python="$HOME/miniconda3/envs/${CONDA_DEFAULT_ENV}/bin/python"
  if [ "$CONDA_DEFAULT_ENV" = "base" ]; then
    conda_python="$HOME/miniconda3/bin/python"
  fi
  if [ -x "$conda_python" ]; then
    py_version=$("$conda_python" --version 2>&1 | awk '{print $2}')
  fi
elif [ -n "$VIRTUAL_ENV" ]; then
  py_env=$(basename "$VIRTUAL_ENV")
  venv_python="$VIRTUAL_ENV/bin/python"
  if [ -x "$venv_python" ]; then
    py_version=$("$venv_python" --version 2>&1 | awk '{print $2}')
  fi
elif [ "$has_python_files" = true ]; then
  # No active env but python files present — show default conda env
  py_env="torch-default"
  conda_python="$HOME/miniconda3/envs/torch-default/bin/python"
  if [ -x "$conda_python" ]; then
    py_version=$("$conda_python" --version 2>&1 | awk '{print $2}')
  fi
fi

# Only display python segment if env is active OR python files are present
show_python=false
if [ -n "$CONDA_DEFAULT_ENV" ] || [ -n "$VIRTUAL_ENV" ] || [ "$has_python_files" = true ]; then
  show_python=true
fi

# --- Node.js (contextual) ---
# Show only when package.json exists in cwd
node_version=""
if [ -f "$cwd/package.json" ]; then
  # Try to get version from .node-version or .nvmrc first
  node_ver_file=""
  if [ -f "$cwd/.node-version" ]; then
    node_ver_file=$(cat "$cwd/.node-version" 2>/dev/null | tr -d '[:space:]')
  elif [ -f "$cwd/.nvmrc" ]; then
    node_ver_file=$(cat "$cwd/.nvmrc" 2>/dev/null | tr -d '[:space:]v')
  fi

  if [ -n "$node_ver_file" ]; then
    node_bin="$HOME/.local/share/fnm/node-versions/v${node_ver_file}/installation/bin/node"
    if [ ! -x "$node_bin" ]; then
      # Try with v prefix stripped already
      node_bin="$HOME/.local/share/fnm/node-versions/${node_ver_file}/installation/bin/node"
    fi
  else
    node_bin="$HOME/.local/share/fnm/node-versions/v24.11.0/installation/bin/node"
  fi

  if [ -x "$node_bin" ]; then
    node_version=$("$node_bin" --version 2>/dev/null | tr -d 'v')
  fi
fi

# --- Derived values ---
cost_fmt=""
if [ -n "$cost_raw" ]; then
  cost_fmt=$(printf "\$%.2f" "$cost_raw")
fi

# --- Progress bar helper ---
make_bar() {
  local pct=${1:-0}
  local width=15
  (( pct < 0   )) && pct=0
  (( pct > 100 )) && pct=100
  local filled=$(( pct * width / 100 ))
  local empty=$(( width - filled ))
  local bar=""
  for ((i=0; i<filled; i++)); do bar="${bar}█"; done
  for ((i=0; i<empty;  i++)); do bar="${bar}░"; done
  printf "%s" "$bar"
}

# --- Render ---
printf "\033[38;5;179m[%s]\033[0m " "$time"
printf "\033[38;5;245m%s\033[0m " "$os_label"
printf "\033[38;5;75m%s\033[0m" "$dir"

if [ -n "$branch" ]; then
  if [ "$changed" = "dirty" ]; then
    printf " \033[38;5;215m%s\033[0m" "$branch"
  else
    printf " \033[38;5;221m%s\033[0m" "$branch"
  fi
fi

if [ "$show_python" = true ] && [ -n "$py_env" ]; then
  if [ -n "$py_version" ]; then
    printf " \033[38;5;190m\xf0\x9f\x90\x8d %s (%s)\033[0m" "$py_env" "$py_version"
  else
    printf " \033[38;5;190m\xf0\x9f\x90\x8d %s\033[0m" "$py_env"
  fi
fi

if [ -n "$node_version" ]; then
  printf " \033[38;5;71m\xe2\xac\xa1 v%s\033[0m" "$node_version"
fi

printf " \033[90m%s\033[0m" "$model"
[ -n "$cost_fmt" ] && printf "  \033[38;5;156m%s\033[0m" "$cost_fmt"

echo

# --- Second line: progress bars ---
show_bars=false
[ -n "$ctx_used" ]  && show_bars=true
[ -n "$five_hr" ]   && show_bars=true
[ -n "$seven_day" ] && show_bars=true

if [ "$show_bars" = true ]; then
  if [ -n "$ctx_used" ]; then
    printf "\033[90mCtx \033[38;5;75m%s\033[0m \033[38;5;75m%3s%%\033[0m" \
      "$(make_bar "$ctx_used")" "$ctx_used"
  fi
  if [ -n "$five_hr" ]; then
    printf "   \033[90m5h \033[38;5;215m%s\033[0m \033[38;5;215m%3s%%\033[0m" \
      "$(make_bar "$five_hr")" "$five_hr"
    [ -n "$five_hr_reset" ] && printf " \033[38;5;215m(%s)\033[0m" "$five_hr_reset"
  fi
  if [ -n "$seven_day" ]; then
    printf "   \033[90m7d \033[38;5;177m%s\033[0m \033[38;5;177m%3s%%\033[0m" \
      "$(make_bar "$seven_day")" "$seven_day"
    [ -n "$seven_day_reset" ] && printf " \033[38;5;177m(%s)\033[0m" "$seven_day_reset"
  fi
  printf "\n"
fi
