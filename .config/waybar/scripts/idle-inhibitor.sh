#!/usr/bin/env bash
# Idle inhibitor toggle with flag file for snooze timer integration.
# Flag presence at FLAG means inhibitor is active.
FLAG="/tmp/idle-inhibitor-active"
PID_FILE="/tmp/idle-inhibitor.pid"

activate() {
  wlinhibit &
  echo $! > "$PID_FILE"
  touch "$FLAG"
}

deactivate() {
  if [ -f "$PID_FILE" ]; then
    kill "$(cat "$PID_FILE")" 2>/dev/null
    rm -f "$PID_FILE"
  fi
  rm -f "$FLAG"
}

toggle() {
  if [ -f "$FLAG" ]; then
    deactivate
  else
    activate
  fi
  pkill -RTMIN+8 waybar
}

status() {
  if [ -f "$FLAG" ]; then
    echo '{"text":"","class":"activated","tooltip":"Idle inhibitor: active"}'
  else
    echo '{"text":"","class":"deactivated","tooltip":"Idle inhibitor: inactive"}'
  fi
}

case "${1:-status}" in
  toggle) toggle ;;
  *) status ;;
esac
