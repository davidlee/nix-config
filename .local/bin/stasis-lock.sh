#!/usr/bin/env bash
# Tell logind we are locking (Stasis listens for this)
loginctl lock-session
# Run your locker in the background (daemonize/fork it)
swaylock -f -c ~/.config/swaylock/config
