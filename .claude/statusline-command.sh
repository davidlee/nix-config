#!/usr/bin/env bash
# Claude Code status line: context bar | model | git changes

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "unknown"')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')

# Colour thresholds for token count (and percentage)
# 0-40k: default, 40-100k: green, 100-120k: orange, 120-160k: dark orange, 160-200k: red, 200k+: magenta
ctx_color() {
  local tokens=$1
  if [ "$tokens" -ge 200000 ]; then
    printf '\033[35m' # magenta
  elif [ "$tokens" -ge 160000 ]; then
    printf '\033[31m' # red
  elif [ "$tokens" -ge 120000 ]; then
    printf '\033[38;5;202m' # dark orange
  elif [ "$tokens" -ge 100000 ]; then
    printf '\033[33m' # orange (yellow)
  elif [ "$tokens" -ge 40000 ]; then
    printf '\033[32m' # green
  else
    printf '' # default
  fi
}

if [ -n "$used" ] && [ -n "$total_input" ]; then
  used_int=$(printf "%.0f" "$used")
  tokens_int=$(printf "%.0f" "$total_input")
  # Format token count as Nk
  tokens_k=$((tokens_int / 1000))
  color=$(ctx_color "$tokens_int")
  reset='\033[0m'
  if [ -n "$color" ]; then
    ctx_display=$(printf "[${color}%dk${reset} \302\267 ${color}%d%%${reset}]" "$tokens_k" "$used_int")
  else
    ctx_display=$(printf "[%dk \302\267 %d%%]" "$tokens_k" "$used_int")
  fi
else
  ctx_display="[ 0% ]"
fi

# Abbreviate long context-window suffix: "Opus 4.8 (1M context)" -> "Opus 4.8 [1M]"
model=$(echo "$model" | sed -E 's/ ?\(1M context\)/ [1M]/')

# Colour model name: green Opus, red Sonnet, magenta Haiku
model_lower=$(echo "$model" | tr '[:upper:]' '[:lower:]')
if echo "$model_lower" | grep -q "opus"; then
  model_display="\033[32m${model}\033[0m"
elif echo "$model_lower" | grep -q "sonnet"; then
  model_display="\033[31m${model}\033[0m"
elif echo "$model_lower" | grep -q "haiku"; then
  model_display="\033[35m${model}\033[0m"
else
  model_display="${model}"
fi

# Git: unstaged changes + untracked files (skip optional locks; run in cwd from input)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // ""')
git_count=""
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
  unstaged=$(git -C "$cwd" diff --name-only 2>/dev/null | wc -l | tr -d ' ')
  untracked=$(git -C "$cwd" ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')
  # changed (tracked, modified) green ✏; new (untracked) red ✚. Each member hidden at 0.
  seg=""
  [ "$unstaged" -gt 0 ] && seg=$(printf '\033[32m\342\234\217 %d\033[0m' "$unstaged")
  if [ "$untracked" -gt 0 ]; then
    new=$(printf '\033[31m\342\234\232 %d\033[0m' "$untracked")
    if [ -n "$seg" ]; then seg="$seg $new"; else seg="$new"; fi
  fi
  [ -n "$seg" ] && git_count=$(printf ' \302\267 %s' "$seg")
fi

# Last-completion clock: wall-clock time (HH:MM:SS AM/PM) at which the last
# agent turn ended, vs the 5-minute prompt cache TTL. record-turn-end.sh writes
# two per-session files:
#   last-prompt-{key}  on UserPromptSubmit (turn start)
#   last-stop-{key}    on Stop             (turn end)
# A fixed timestamp instead of a count-up timer: the status line only re-renders
# on activity, so a live counter looks frozen. The stamp is stable; only its
# colour reflects staleness, recomputed against `now` at each render.
# Key derivation: session_id first; fall back to transcript_path basename.
# Must match the derivation in record-turn-end.sh exactly.
# Colours: default = fresh, orange = <60s until expiry, red = stale.
# session_key=$(echo "$input" | jq -r '.session_id // ""')
# if [ -z "$session_key" ]; then
#   _tp=$(echo "$input" | jq -r '.transcript_path // ""')
#   [ -n "$_tp" ] && session_key=$(basename "$_tp" .jsonl)
# fi
# clock_display=""
# if [ -n "$session_key" ]; then
#   prompt_file="/home/david/.claude/last-prompt-${session_key}"
#   stop_file="/home/david/.claude/last-stop-${session_key}"
#   prompt_ts=$([ -f "$prompt_file" ] && cat "$prompt_file" 2>/dev/null)
#   stop_ts=$([ -f "$stop_file" ] && cat "$stop_file" 2>/dev/null)
#   : "${prompt_ts:=0}" "${stop_ts:=0}"
#   if [ "$stop_ts" -gt 0 ]; then
#     clock=$(date -d "@${stop_ts}" '+%-I:%M:%S %p' 2>/dev/null)
#     if [ "$prompt_ts" -ge "$stop_ts" ]; then
#       # Turn underway (prompt newer than last turn-end) — cache is warm, show plain.
#       clock_display=$(printf ' \302\267 %s' "$clock")
#     else
#       now=$(date +%s)
#       elapsed=$((now - stop_ts))
#       [ "$elapsed" -lt 0 ] && elapsed=0
#       if [ "$elapsed" -ge 300 ]; then
#         clock_display=$(printf ' \302\267 \033[31m%s\033[0m' "$clock") # red — stale
#       elif [ "$elapsed" -ge 240 ]; then
#         clock_display=$(printf ' \302\267 \033[33m%s\033[0m' "$clock") # orange — <60s to expiry
#       else
#         clock_display=$(printf ' \302\267 %s' "$clock") # default — fresh
#       fi
#     fi
#   fi
# fi

# Prompt cache token stats: read (served from cache, ~10% rate) vs creation (write,
# full rate). Ratio = read / (read + creation) = cache hit rate; higher is better.
cw=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // empty')
cr=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // empty')
cache_stats=""
if [ -n "$cw" ] || [ -n "$cr" ]; then
  : "${cw:=0}" "${cr:=0}"
  cw=$(printf '%.0f' "$cw")
  cr=$(printf '%.0f' "$cr")
  cw_k=$((cw / 1000))
  cr_k=$((cr / 1000))
  denom=$((cr + cw))
  if [ "$denom" -gt 0 ]; then ratio=$((cr * 100 / denom)); else ratio=0; fi
  # ratio colour: green >=80, orange >=50, red below
  if [ "$ratio" -ge 80 ]; then rc='\033[32m'; elif [ "$ratio" -ge 50 ]; then rc='\033[33m'; else rc='\033[31m'; fi
  # bolt glyph, then read/write in k, then coloured hit-rate %.
  cache_stats=$(printf ' \302\267 \342\232\241 %dk/%dk %b%d%%\033[0m' "$cr_k" "$cw_k" "$rc" "$ratio")
fi

# Order: ctx · cache · model git · cwd.
# %b only for model_display — it still holds literal \033 escapes to expand.
# ctx_display/cache_stats/git_count are already printf-expanded (raw ESC bytes) → %s.
# cache_stats and git_count carry their own leading ' \302\267 ' dot; only model and cwd
# need an explicit separator, so no dot precedes the self-prefixed segments (no doubling).
printf '%s%s \302\267 %b%s \302\267 %s' "$ctx_display" "$cache_stats" "$model_display" "$git_count" "${cwd:-$(pwd)}"
