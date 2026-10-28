#!/usr/bin/env -S zsh -f
# Behaviour of e, ez, ne and cd-pick from ~/.config/zsh/functions.zsh, in a
# throwaway $HOME with emacsclient, fzf and zoxide stubbed.
emulate -L zsh
local tmp=$(mktemp -d) fails=0 src=~/.config/zsh/functions.zsh
export HOME=$tmp
mkdir -p $tmp/bin $tmp/notes $tmp/repo/src $tmp/zdir/sub
print '#!/bin/sh\necho "emacsclient $*"' > $tmp/bin/emacsclient
print '#!/bin/sh\necho '$tmp'/zdir' > $tmp/bin/zoxide
# fzf stand-in: the first line holding the --query value
print '#!/bin/sh\nfor a; do case $a in --query=*) q=${a#--query=};; esac; done\ngrep -m1 -F -- "$q"' > $tmp/bin/fzf
chmod +x $tmp/bin/*
path=($tmp/bin $path)
compdef() {}
source $src

check() { # name, expected output, output
  [[ $3 == $2 ]] && print "ok   $1" || { print "FAIL $1\n     want: ${(q)2}\n     got:  ${(q)3}"; (( fails++ )) }
}

check "e reuses the GUI frame"   "emacsclient -r -n f" "$(WAYLAND_DISPLAY=w e f)"
check "e uses the tty w/o display" "emacsclient -t f"  "$(WAYLAND_DISPLAY= e f)"
check "e options replace the mode" "emacsclient -c f"  "$(WAYLAND_DISPLAY=w e -c f)"

touch $tmp/notes/20260611--cordage.org $tmp/notes/cordage.png $tmp/notes/inbox.org
check "ne edits the matching note" "emacsclient -t $tmp/notes/20260611--cordage.org" \
  "$(WAYLAND_DISPLAY= ne cord)"
check "ne passes options to e"    "emacsclient -c $tmp/notes/20260611--cordage.org" \
  "$(ne -c cord)"
check "ne skips attachments"      "" "$(ne png)"

touch $tmp/zdir/sub/z.txt
check "ez picks under zoxide's dir" "emacsclient -t $tmp/zdir/sub/z.txt" \
  "$(WAYLAND_DISPLAY= ez q)"
git -C $tmp/repo init -q && touch $tmp/repo/src/r.txt
check "ez picks under the git root" "emacsclient -c $tmp/repo/src/r.txt" \
  "$(cd $tmp/repo/src && ez -c)"

check "cd-pick cds to the subdir" "$tmp/zdir/sub" "$(cd-pick $tmp/zdir && pwd)"
rm -rf $tmp
exit $fails
