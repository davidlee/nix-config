#!/usr/bin/env bash
# Boots the config from a copy under a throwaway HOME.
set -u
P=/tmp/emacs-probe; H=$P/home
rm -rf "$H"; mkdir -p "$H/.config"
cp -a "${SRC:-/workspace/emacs-config}" "$H/.config/emacs"
cp -a ~/notes "$H/notes"
export HOME=$H
set +u; source $P/profile/etc/profile; set -u
export PATH=$P/profile/bin:$PATH
cd "$H"
echo "=== PASS1 real daemon start"
timeout 200 emacs --fg-daemon=probe > $P/daemon.log 2>&1 &
for i in $(seq 1 170); do
  sleep 1
  emacsclient -s probe -e t >/dev/null 2>&1 && { echo "server up after ${i}s"; break; }
done
emacsclient -s probe -e '(with-current-buffer "*Messages*" (buffer-string))' 2>&1 | sed 's/\\n/\n/g' | tail -40 | cut -c1-220
emacsclient -s probe -e '(if (get-buffer "*Warnings*") (with-current-buffer "*Warnings*" (buffer-string)) "no warnings")' 2>&1 | sed 's/\\n/\n/g' | cut -c1-220 | head -40
emacsclient -s probe -e '(list :init-time (emacs-init-time) :features (length features) :packages-vc (length package-alist))' 2>&1
emacsclient -s probe -e '(kill-emacs)' >/dev/null 2>&1
wait
echo "--- daemon.log tail"; tail -30 $P/daemon.log | cut -c1-220
echo "=== PASS2 sweep"
timeout 280 emacs --batch --init-directory="$H/.config/emacs" -l /tmp/emacs-probe/sweep.el > $P/sweep.log 2>&1
echo "sweep exit $?"
