# undef oh-my-zsh lib/directories.zsh function for
# directory management so i can use it for doctrine
(( $+functions[d] )) && unfunction d

# the zsh builtin `log` (watch) hides ~/.local/bin/log
disable log

alias _=sudo;

alias s=z
alias si=zi

alias zn=zmx-new

alias et="emacsclient --tty";
alias er="emacsclient --reuse-frame";
alias ec="emacsclient --create-frame";
alias en="emacsclient --no-wait";
alias ee="emacsclient --eval";
alias ent="emacsclient --tty --no-wait";

alias nw="emacs -nw" # non-client: NEW emacs

alias phones="pactl set-default-sink bluez_output.80_99_E7_ED_2D_2D.1"

# alias ea="distrobox enter --root archlinux"

alias clock="clock-rs -Bbt --fmt '%d %b' -c blue"

alias warn="sleipnir-doctor warn"

# single character aliases
alias g=git;
alias d=doctrine;
alias j=just;
alias jc="just --choose" # !!

alias sdr="spec-driver"
alias dr="sleipnir-doctor"

alias c="cd $HOME/.config";
alias cfg="cd-pick ~/.config";

# bookmarks
alias dev="cd ~/dev";
alias fl="cd ~/flakes";
alias notes="cd ~/notes";

# editors
alias vi=nvim;
alias vim=nvim;
alias zed=zeditor;

# TUI shortcuts
alias st="git status";
alias zf=zi;
# alias ip=ip -color;

# alias -g G="| grep -E --color=auto";
alias -g C="| wl-copy -rp"
alias -g E='| grep -E'
alias -g G='| grep'
alias -g H='| head'
alias -g I='| grep -iE'
alias -g J='| jq .'
alias -g L='| less'
alias -g T="| tr -d '\n' "
alias -g W='| wc -l'

[[ $OSTYPE = linux* ]] && alias open=xdg-open

# util / override
alias scr="grimshot save area";
alias ct="bat --style snip --style changes --style header";
alias mkdir="mkdir -p";

# cd
alias ".."="cd ..";
alias "..."="cd ../..";
alias "...."="cd ../../..";

alias -g "..."="../.."
alias -g "...."="../../.."

# list files
alias vdir="vdir --color=auto";
alias dir="dir --color=auto";
# ls, la, ll, lla, lt: home-manager eza integration (defined after this file)
alias ld="eza -lhD";
alias l='eza --git-ignore'
alias lh='eza -lh'
alias llm='eza --all --header --long --sort=modified'
alias lx='eza -lbhHigUmuSa@'
alias tree='eza --tree'
alias tgi='eza --tree --git-ignore'

# grep
alias egrep="grep -E --color=auto";
alias fgrep="grep -F --color=auto";
alias grep="grep --color=auto";
alias pg='pgrep --list-full'; # process_name

# nix
# alias -g nomjson=' --log-format internal-json -v |& nom --json';
alias drs="cd ~/flakes && just darwin-switch";
# nrs: ~/.local/bin/nrs
alias nrb="sudo zsh -c 'nixos-rebuild --no-reexec -v --log-format internal-json --flake /home/david/flakes/\#$HOST |& nom --json --show-trace' ";
alias ngc="nix-collect-garbage --delete-old && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";

#
alias ns="nix-search-tv print | fzf --preview 'nix-search-tv preview {}' --scheme history"

# misc

alias cl="clock-rs -Bbt --fmt '%Y-%m-%d'";

alias supabase-kill="docker ps -q --filter "name=supabase_" | xargs -r docker stop"
