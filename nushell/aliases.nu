# zoxide
export alias c = z
export alias ci = zi

export alias j = just
export alias d = doctrine

# pushd / popd
export alias g = dirs goto
export alias n = dirs next
export alias p = dirs prev

# emacsclient
export alias e  = emacsclient
export alias ec = emacsclient
export alias et = emacsclient -tty
export alias ee = emacsclient --eval
export alias er = emacsclient --reuse-frame
export alias ec = emacsclient --create-frame
export alias en = emacsclient --no-wait

# bookmarks
export alias dev = cd ~/dev
export alias cfg = cd ~/.config
export alias fl = cd ~/flakes
export alias nuc = vi ~/nushell/custom.nu
export alias notes = cd ~/notes

# other cli faves
export alias zed = zeditor
export alias lg = lazygit
export alias st = git status

# an ls by any other name
export alias la = eza -a
export alias ll = eza -l
export alias lla = eza -la
export alias lls = ls
export alias lt = eza --tree
export alias tree = eza --tree

export alias ch = cd (gum choose ~/dev/doctrine ~/dev/.emacs.d ~/dev/notes ~/flakes ~/nushell ~/Downloads ~/.local/src/ ~/.local/bin)

export alias arch = distrobox enter archlinux;

# nushell specials
export alias fg = job unfreeze
alias o = start
