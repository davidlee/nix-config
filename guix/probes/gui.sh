#!/usr/bin/env bash
# Boots the config in a real pgtk frame under headless sway; screenshots it.
P=/tmp/emacs-probe; H=$P/home
FRESH=${FRESH:-1}
if [ "$FRESH" = 1 ]; then
  rm -rf "$H"; mkdir -p "$H/.config"
  cp -a "${SRC:-/workspace/emacs-config}" "$H/.config/emacs"
  cp -a ~/notes "$H/notes"
fi
rm -f $P/gui-done $P/gui-state.txt $P/shot.png
unset XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME XDG_STATE_HOME
export HOME=$H
source $P/profile/etc/profile
export PATH=$P/profile/bin:$PATH
export WLR_BACKENDS=headless WLR_LIBINPUT_NO_DEVICES=1 WLR_RENDERER=pixman
export XDG_RUNTIME_DIR=$P/run; mkdir -p -m700 $XDG_RUNTIME_DIR
cd "$H"
printf 'output HEADLESS-1 mode 1600x1000\nexec_always true\n' > $P/sway.conf
$P/wm/bin/sway -c $P/sway.conf > $P/sway.log 2>&1 &
SWAY=$!
sleep 3
export WAYLAND_DISPLAY=$(ls $XDG_RUNTIME_DIR | grep -E '^wayland-[0-9]+$' | head -1)
export GDK_BACKEND=wayland
unset DISPLAY
timeout 240 emacs ${EMACS_ARGS:---init-directory=$H/.config/emacs -l $P/dump.el} > $P/gui.log 2>&1 &
EM=$!
for i in $(seq 1 200); do [ -f $P/gui-done ] && { echo "dump after ${i}s"; break; }; kill -0 $EM 2>/dev/null || { echo "emacs exited at ${i}s"; break; }; sleep 1; done
PATH=$P/wm/bin:$PATH grim $P/shot.png 2>&1 | head -3
kill $EM $SWAY 2>/dev/null; wait 2>/dev/null
tail -15 $P/gui.log | cut -c1-200
