# manage dotfiles with bare repo:
gc() { git --work-tree=$HOME --git-dir=$HOME/.cfg $* }

prv() { git --work-tree=$HOME --git-dir=$HOME/.private $* }

om() { $* --log-format internal-json -v |& nom --json }

# periodic org files

wk() {
  date +"$ORG_DIR/%Y/wk/%Ywk%U.md"
}

day() {
  date +"$ORG_DIR/%Y/dd/%F.md"
}

mo() {
  date +"$ORG_DIR/%Y/mo/%m.md"
}

ewk() {
  $VISUAL $(wk) -w $ORG_DIR
}

eday() {
  $VISUAL $(day) -w $ORG_DIR
}

#
# FZF
# 
# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" --exclude "result" . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" --exclude "result" . "$1"
}
