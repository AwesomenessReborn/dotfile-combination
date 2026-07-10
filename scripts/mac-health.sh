#!/usr/bin/env bash
# mac-health — macOS system health check
# Usage: mac-health          quiet mode — prints nothing if healthy
#        mac-health --full   full readable report with context
#        mac-health --debug  raw source lines + parsed values

MODE="quiet"
[[ "${1:-}" == "--full"  ]] && MODE="full"
[[ "${1:-}" == "--debug" ]] && MODE="debug"

# ── 1. Uptime ──────────────────────────────────────────────────────────────────
# kern.boottime: "{ sec = 1748465400, usec = 0 } ..."
BOOT_SEC=$(sysctl -n kern.boottime | awk '{print $4}' | tr -d ',')
NOW_SEC=$(date +%s)
UPTIME_DAYS=$(( (NOW_SEC - BOOT_SEC) / 86400 ))

# ── 2. Physical memory ─────────────────────────────────────────────────────────
PHYS_BYTES=$(sysctl -n hw.memsize 2>/dev/null || echo 0)
PHYS_GB=$(awk "BEGIN { printf \"%.0f\", $PHYS_BYTES / (1024*1024*1024) }")

# ── 3. Swap ────────────────────────────────────────────────────────────────────
# "vm.swapusage: total = 24576.00M  used = 23462.75M  free = 1113.25M"
SWAP_RAW=$(sysctl vm.swapusage 2>/dev/null || true)
SWAP_TOTAL=$(printf '%s' "$SWAP_RAW" | grep -oE 'total = [0-9]+\.[0-9]+' | grep -oE '[0-9.]+$')
SWAP_USED=$(printf '%s'  "$SWAP_RAW" | grep -oE 'used = [0-9]+\.[0-9]+'  | grep -oE '[0-9.]+$')
SWAP_FREE=$(printf '%s'  "$SWAP_RAW" | grep -oE 'free = [0-9]+\.[0-9]+'  | grep -oE '[0-9.]+$')
SWAP_TOTAL=${SWAP_TOTAL:-0}
SWAP_USED=${SWAP_USED:-0}
SWAP_FREE=${SWAP_FREE:-0}
SWAP_PCT=$(awk "BEGIN { t=$SWAP_TOTAL; print (t>0) ? int($SWAP_USED/t*100) : 0 }")
SWAP_FREE_GB=$(awk  "BEGIN { printf \"%.1f\", $SWAP_FREE  / 1024 }")
SWAP_USED_GB=$(awk  "BEGIN { printf \"%.1f\", $SWAP_USED  / 1024 }")
SWAP_TOTAL_GB=$(awk "BEGIN { printf \"%.1f\", $SWAP_TOTAL / 1024 }")

# ── 4. Memory pressure ─────────────────────────────────────────────────────────
MEM_RAW=$(memory_pressure 2>/dev/null || true)
MEM_FREE_LINE=$(printf '%s' "$MEM_RAW" | grep -i 'memory free percentage' || true)
MEM_FREE_PCT=$(printf '%s' "$MEM_FREE_LINE" | grep -oE '[0-9]+' | head -1)
MEM_LABEL=$(printf '%s' "$MEM_RAW" | awk '/[Ss]ystem memory pressure/{print $NF}')
MEM_FREE_PCT=${MEM_FREE_PCT:-""}
MEM_LABEL=${MEM_LABEL:-""}

# ── 5. vm_stat (compressor + wired) ───────────────────────────────────────────
VM_RAW=$(vm_stat 2>/dev/null || true)
PAGE_SIZE=$(printf '%s' "$VM_RAW" | grep -oE 'page size of [0-9]+' | grep -oE '[0-9]+$')
PAGE_SIZE=${PAGE_SIZE:-16384}

# Pages stored in compressor  = logical/uncompressed payload macOS has compressed
#                               (how much data is represented, NOT how much RAM is used)
# Pages occupied by compressor = actual RAM the compressor holds
#                               (what Activity Monitor shows as "Compressed Memory")
VM_STORED_LINE=$(printf '%s'   "$VM_RAW" | grep '^Pages stored in compressor:')
VM_OCCUPIED_LINE=$(printf '%s' "$VM_RAW" | grep '^Pages occupied by compressor:')
VM_WIRED_LINE=$(printf '%s'    "$VM_RAW" | grep '^Pages wired down:')

PAGES_STORED=$(printf '%s'   "$VM_STORED_LINE"   | awk '{gsub(/\./,"",$NF); print $NF+0}')
PAGES_OCCUPIED=$(printf '%s' "$VM_OCCUPIED_LINE" | awk '{gsub(/\./,"",$NF); print $NF+0}')
PAGES_WIRED=$(printf '%s'    "$VM_WIRED_LINE"    | awk '{gsub(/\./,"",$NF); print $NF+0}')
PAGES_STORED=${PAGES_STORED:-0}
PAGES_OCCUPIED=${PAGES_OCCUPIED:-0}
PAGES_WIRED=${PAGES_WIRED:-0}

STORED_GB=$(awk   "BEGIN { printf \"%.1f\", ($PAGES_STORED   * $PAGE_SIZE) / (1024*1024*1024) }")
OCCUPIED_GB=$(awk "BEGIN { printf \"%.1f\", ($PAGES_OCCUPIED * $PAGE_SIZE) / (1024*1024*1024) }")
WIRED_GB=$(awk    "BEGIN { printf \"%.1f\", ($PAGES_WIRED    * $PAGE_SIZE) / (1024*1024*1024) }")

# ── 6. Zombie processes ────────────────────────────────────────────────────────
ZOMBIE_COUNT=$(ps -Ao state= 2>/dev/null | awk '/^Z/{n++} END{print n+0}')

# ── 7. Top RSS processes (BSD ps, rss in KB) ───────────────────────────────────
PROC_LIST=$(ps -ax -o rss=,comm= 2>/dev/null | sort -rn | head -10)
MAX_RSS_KB=$(printf '%s' "$PROC_LIST" | awk 'NR==1{print $1+0}')
MAX_PROC=$(printf '%s' "$PROC_LIST" | awk 'NR==1{$1=""; sub(/^ +/,""); print}')
MAX_RSS_GB=$(awk "BEGIN { printf \"%.1f\", ${MAX_RSS_KB:-0} / (1024*1024) }")

# ── 8. Disk usage ──────────────────────────────────────────────────────────────
DISK_PCT=$(df / 2>/dev/null | awk 'NR==2{gsub(/%/,"",$5); print $5+0}')
DISK_PCT=${DISK_PCT:-0}

# ── 9. Backup status ───────────────────────────────────────────────────────────
BACKUP_FILE="$HOME/Dev/backup-framework/last-backup-status"
BACKUP_STATUS=""
BACKUP_TIME=""
if [[ -f "$BACKUP_FILE" ]]; then
  BACKUP_STATUS=$(awk -F= '/^status/{print $2}' "$BACKUP_FILE")
  BACKUP_TIME=$(awk -F= '/^time/{print $2}' "$BACKUP_FILE")
fi

# ── 10. Dotfile sanity ─────────────────────────────────────────────────────────
FNM_COUNT=$(grep -c 'fnm env' "$HOME/.zshrc" 2>/dev/null || echo 0)
ZSHRC_SYMLINK="no"
[[ -L "$HOME/.zshrc" ]] && ZSHRC_SYMLINK="yes"

# ── Classify ───────────────────────────────────────────────────────────────────
CRITICALS=()
WARNINGS=()
INFOS=()
RECOMMENDATION=""

# Flags used for recommendation logic
SWAP_IS_CRITICAL=false
MEM_PRESSURE_LOW=false

# 1. Uptime — informational only; restart is opportunistic, never urgent
if [[ "$UPTIME_DAYS" -gt 21 ]]; then
  INFOS+=("Uptime: ${UPTIME_DAYS}d. Restart opportunistically when convenient.")
fi

# 2. Swap
# Helper: true when memory_pressure reports active pressure (WARN or CRITICAL)
_swap_pressure_active() {
  [[ "$MEM_LABEL" == "CRITICAL" || "$MEM_LABEL" == "WARN" ]] || \
  [[ -n "$MEM_FREE_PCT" && "$MEM_FREE_PCT" -lt 10 ]]
}

if awk "BEGIN { exit !($SWAP_TOTAL > 0) }"; then
  if [[ "$SWAP_PCT" -ge 90 ]]; then
    if _swap_pressure_active; then
      CRITICALS+=("Swap nearly full: ${SWAP_USED_GB}GB / ${SWAP_TOTAL_GB}GB used (${SWAP_PCT}%) and memory under active pressure.")
      SWAP_IS_CRITICAL=true
    else
      WARNINGS+=("Swap high: ${SWAP_USED_GB}GB / ${SWAP_TOTAL_GB}GB used (${SWAP_PCT}%). Likely cold inactive state — watch for sluggishness.")
    fi
  elif awk "BEGIN { exit ($SWAP_FREE_GB >= 2.0) }"; then
    # exit(0) when free < 2GB (the condition >= 2.0 is false → exit 0)
    # Note: macOS swap is dynamic — "free" reflects current swap file headroom,
    # not a hard cap. Only escalate to CRIT if pressure signals confirm active need.
    if _swap_pressure_active; then
      CRITICALS+=("Swap free very low: ${SWAP_FREE_GB}GB remaining with active memory pressure.")
      SWAP_IS_CRITICAL=true
    else
      WARNINGS+=("Swap headroom low: ${SWAP_FREE_GB}GB free in current swap files (macOS will expand if needed).")
    fi
  elif [[ "$SWAP_PCT" -ge 80 ]]; then
    WARNINGS+=("Swap high: ${SWAP_USED_GB}GB / ${SWAP_TOTAL_GB}GB used (${SWAP_PCT}%). Watch for sluggishness; consider closing stale apps.")
  fi
fi

# 3. Memory pressure — use MEM_LABEL (NORMAL/WARN/CRITICAL) as primary signal,
#    MEM_FREE_PCT as secondary. MEM_LABEL comes from `memory_pressure` output.
if [[ "$MEM_LABEL" == "CRITICAL" ]]; then
  CRITICALS+=("Memory pressure CRITICAL (${MEM_FREE_PCT:+${MEM_FREE_PCT}% free}).")
  MEM_PRESSURE_LOW=true
elif [[ "$MEM_LABEL" == "WARN" ]]; then
  WARNINGS+=("Memory pressure WARN (${MEM_FREE_PCT:+${MEM_FREE_PCT}% free}).")
  MEM_PRESSURE_LOW=true
elif [[ -n "$MEM_FREE_PCT" ]]; then
  # Fallback if MEM_LABEL is unavailable
  if [[ "$MEM_FREE_PCT" -lt 10 ]]; then
    CRITICALS+=("Memory pressure critical: ${MEM_FREE_PCT}% system memory free.")
    MEM_PRESSURE_LOW=true
  elif [[ "$MEM_FREE_PCT" -lt 20 ]]; then
    WARNINGS+=("Memory pressure: ${MEM_FREE_PCT}% system memory free.")
    MEM_PRESSURE_LOW=true
  fi
fi

# 4. Compressor — warn only on actual occupied RAM, not logical payload
#    OCCUPIED_GB is what Activity Monitor calls "Compressed Memory" (real RAM cost)
#    STORED_GB is the uncompressed logical size — not a RAM usage figure
if awk "BEGIN { exit !($OCCUPIED_GB >= 10.0) }"; then
  WARNINGS+=("High compressed RAM: ${OCCUPIED_GB}GB occupied by compressor. macOS is compressing heavily.")
elif awk "BEGIN { exit !($STORED_GB >= 10.0) }"; then
  # Notable compression — show as info alongside other issues, not a standalone warning
  INFOS+=("Compression active: ${STORED_GB}GB logical → ${OCCUPIED_GB}GB actual RAM.")
fi

# 5. Wired memory
if awk "BEGIN { exit !($WIRED_GB >= 4.0) }"; then
  WARNINGS+=("High wired memory: ${WIRED_GB}GB.")
fi

# 6. Zombies
[[ "$ZOMBIE_COUNT" -gt 5 ]] && WARNINGS+=("${ZOMBIE_COUNT} zombie processes.")

# 7. Large RSS
if awk "BEGIN { exit !($MAX_RSS_GB >= 3.0) }"; then
  WARNINGS+=("Large process: $MAX_PROC using ${MAX_RSS_GB}GB RSS.")
fi

# 8. Disk
if [[ "$DISK_PCT" -ge 95 ]]; then
  CRITICALS+=("Disk / at ${DISK_PCT}% — critically full. Free space now.")
elif [[ "$DISK_PCT" -ge 85 ]]; then
  WARNINGS+=("Disk / at ${DISK_PCT}%.")
fi

# 9. Backup — separate from memory health
if [[ "$BACKUP_STATUS" == "failed" ]]; then
  WARNINGS+=("Backup: last run failed (${BACKUP_TIME}). Check ~/Dev/backup-framework/backup.log")
fi

# ── Recommendation ─────────────────────────────────────────────────────────────
if $SWAP_IS_CRITICAL; then
  if $MEM_PRESSURE_LOW; then
    RECOMMENDATION="Save work. Close major apps or restart now to avoid OOM conditions."
  else
    RECOMMENDATION="Close or restart heavy apps first. Reboot only if sluggishness persists."
  fi
fi

# ── Output helpers ─────────────────────────────────────────────────────────────

_issues() {
  local c w i
  for c in "${CRITICALS[@]+"${CRITICALS[@]}"}";  do printf "  [CRIT] %s\n" "$c"; done
  for w in "${WARNINGS[@]+"${WARNINGS[@]}"}";    do printf "  [WARN] %s\n" "$w"; done
  for i in "${INFOS[@]+"${INFOS[@]}"}";          do printf "  [INFO] %s\n" "$i"; done
  [[ -n "$RECOMMENDATION" ]] && printf "  =>     %s\n" "$RECOMMENDATION"
}

_has_issues() {
  [[ ${#CRITICALS[@]} -gt 0 || ${#WARNINGS[@]} -gt 0 || ${#INFOS[@]} -gt 0 ]]
}

# ── Debug mode ─────────────────────────────────────────────────────────────────
if [[ "$MODE" == "debug" ]]; then
  echo "  --- raw source lines ---"
  printf "  swap_raw         = %s\n"  "${SWAP_RAW:-n/a}"
  printf "  vm_stored_line   = %s\n"  "${VM_STORED_LINE:-n/a}"
  printf "  vm_occupied_line = %s\n"  "${VM_OCCUPIED_LINE:-n/a}"
  printf "  vm_wired_line    = %s\n"  "${VM_WIRED_LINE:-n/a}"
  printf "  mem_free_line    = %s\n"  "${MEM_FREE_LINE:-n/a}"
  if [[ -f "$BACKUP_FILE" ]]; then
    printf "  backup_file      = %s\n"  "$(tr '\n' '|' < "$BACKUP_FILE")"
  else
    printf "  backup_file      = not found\n"
  fi
  echo "  --- parsed values ---"
  printf "  uptime_days      = %s\n"   "$UPTIME_DAYS"
  printf "  phys_gb          = %s\n"   "$PHYS_GB"
  printf "  swap_total_gb    = %s\n"   "$SWAP_TOTAL_GB"
  printf "  swap_used_gb     = %s\n"   "$SWAP_USED_GB"
  printf "  swap_free_gb     = %s\n"   "$SWAP_FREE_GB"
  printf "  swap_pct         = %s%%\n" "$SWAP_PCT"
  printf "  mem_free_pct     = %s%%\n" "${MEM_FREE_PCT:-n/a}"
  printf "  mem_label        = %s\n"   "${MEM_LABEL:-n/a}"
  printf "  page_size        = %s\n"   "$PAGE_SIZE"
  printf "  stored_gb        = %s  (logical payload, NOT RAM usage)\n"  "$STORED_GB"
  printf "  occupied_gb      = %s  (actual RAM used by compressor)\n"   "$OCCUPIED_GB"
  printf "  wired_gb         = %s\n"   "$WIRED_GB"
  printf "  zombies          = %s\n"   "$ZOMBIE_COUNT"
  printf "  max_proc         = %s\n"   "${MAX_PROC:-n/a}"
  printf "  max_rss_gb       = %s\n"   "$MAX_RSS_GB"
  printf "  disk_pct         = %s%%\n" "$DISK_PCT"
  printf "  backup_status    = %s\n"   "${BACKUP_STATUS:-n/a}"
  printf "  backup_time      = %s\n"   "${BACKUP_TIME:-n/a}"
  printf "  fnm_calls        = %s\n"   "$FNM_COUNT"
  printf "  zshrc_symlink    = %s\n"   "$ZSHRC_SYMLINK"
  echo ""
  if _has_issues; then
    _issues
    echo ""
  fi
  exit 0
fi

# ── Full mode ──────────────────────────────────────────────────────────────────
if [[ "$MODE" == "full" ]]; then
  echo ""
  echo "  mac-health ─────────────────────────────────────────"
  printf "  Uptime              %dd\n"               "$UPTIME_DAYS"
  printf "  Physical RAM        %dGB\n"              "$PHYS_GB"
  printf "  Swap                %s / %s GB (%d%%)\n" "$SWAP_USED_GB" "$SWAP_TOTAL_GB" "$SWAP_PCT"
  printf "  Memory free         %s%%\n"              "${MEM_FREE_PCT:-n/a}"
  [[ -n "$MEM_LABEL" ]] && printf "  Memory status       %s\n" "$MEM_LABEL"
  printf "  Wired               %s GB\n"             "$WIRED_GB"
  printf "  Compressor payload  %s GB logical\n"     "$STORED_GB"
  printf "  Compressor RAM      %s GB occupied\n"    "$OCCUPIED_GB"
  printf "  Zombies             %d\n"                "$ZOMBIE_COUNT"
  printf "  Disk /              %d%%\n"              "$DISK_PCT"
  printf "  Backup              %s (%s)\n"           "${BACKUP_STATUS:-never}" "${BACKUP_TIME:--}"
  echo ""
  echo "  Top processes by RSS:"
  while IFS= read -r line; do
    rss_mb=$(echo "$line" | awk '{printf "%d", $1/1024}')
    proc_name=$(echo "$line" | awk '{$1=""; sub(/^ +/,""); print}')
    printf "    %6d MB  %s\n" "$rss_mb" "$proc_name"
  done <<< "$PROC_LIST"
  echo ""
  echo "  Dotfile checks:"
  printf "    .zshrc symlinked   %s\n"  "$ZSHRC_SYMLINK"
  printf "    fnm env calls      %s\n"  "$FNM_COUNT"
  echo "  ─────────────────────────────────────────────────────"
fi

# ── Issues block (quiet + full) ────────────────────────────────────────────────
if _has_issues; then
  _issues
  echo ""
fi

exit 0
