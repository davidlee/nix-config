#!/usr/bin/env bash
# Waybar module: SATAN inbox unread count.
# Reads my/satan-inbox-unread-count via emacsclient. Hidden when zero or
# when emacs server isn't running.

n=$(emacsclient --eval '(my/satan-inbox-unread-count)' 2>/dev/null | tr -d '\n"')

case "$n" in
    ""|0|nil)
        printf '{"text":"","class":"empty","tooltip":"SATAN inbox: 0 unread"}\n'
        ;;
    *[!0-9]*)
        printf '{"text":"","class":"empty","tooltip":"SATAN inbox: unavailable"}\n'
        ;;
    *)
        printf '{"text":"📥 %s","class":"unread","tooltip":"SATAN inbox: %s unread"}\n' "$n" "$n"
        ;;
esac
