#!/usr/bin/env bash
# Boot a throwaway copy of the config with emacs -nw in a pty, from a login shell.
set -u
P=/tmp/nw-probe
rm -rf "$P"; mkdir -p "$P/home/.config"
cp -a "$HOME/.config/emacs" "$P/home/.config/emacs"
# Optional overlay of unpushed host changes, laid out relative to the config root.
if [ -d /tmp/nw-overlay ]; then
  cp -r /tmp/nw-overlay/. "$P/home/.config/emacs/"
  find /tmp/nw-overlay -name '*.el' -printf '%P\n' | sed 's/\.el$/.elc/' | (cd "$P/home/.config/emacs" && xargs rm -f)
fi
for d in notes dev; do ln -s "$HOME/$d" "$P/home/$d"; done
cp /tmp/nw-dump.el "$P/nw-dump.el"
cat > "$P/run.sh" <<RUN
unset XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME XDG_STATE_HOME
export HOME=$P/home TERM=xterm-256color
stty rows 50 cols 160
exec timeout 150 emacs -nw --debug-init --init-directory=$P/home/.config/emacs -l $P/nw-dump.el
RUN
timeout 170 script -qec "bash -lc 'source $P/run.sh'" "$P/typescript" </dev/null >/dev/null 2>&1
echo "exit=$?"
if [ -f "$P/report.txt" ]; then cat "$P/report.txt"; else
  echo "NO REPORT: last screen text:"; sed 's/\x1b\[[0-9;?]*[a-zA-Z]//g' "$P/typescript" | tr -d '\r' | tail -c 1500; fi
