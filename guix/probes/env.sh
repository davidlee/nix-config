unset XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME XDG_STATE_HOME
export HOME=/tmp/emacs-probe/home
set +u; source /tmp/emacs-probe/profile/etc/profile; set -u
export PATH=/tmp/emacs-probe/profile/bin:$PATH
