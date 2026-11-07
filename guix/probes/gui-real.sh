#!/usr/bin/env bash
# First boot of the installed config in a real frame under headless sway.
P=/tmp/emacs-probe
rm -f $P/gui-done $P/gui-state.txt $P/shot.png
export WLR_BACKENDS=headless WLR_LIBINPUT_NO_DEVICES=1 WLR_RENDERER=pixman
export XDG_RUNTIME_DIR=$P/run; mkdir -p -m700 $XDG_RUNTIME_DIR
cd ~
$P/wm/bin/sway -c $P/sway.conf > $P/sway.log 2>&1 &
SWAY=$!
sleep 3
export WAYLAND_DISPLAY=$(ls $XDG_RUNTIME_DIR | grep -E '^wayland-[0-9]+$' | head -1)
export GDK_BACKEND=wayland
unset DISPLAY
timeout 280 emacs -l $P/dump.el > $P/gui.log 2>&1 &
EM=$!
for i in $(seq 1 260); do [ -f $P/gui-done ] && { echo "dump after ${i}s"; break; }; kill -0 $EM 2>/dev/null || { echo "emacs exited at ${i}s"; break; }; sleep 1; done
$P/wm/bin/grim $P/shot.png
kill $EM $SWAY 2>/dev/null; wait 2>/dev/null
