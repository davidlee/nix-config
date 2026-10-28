# undef oh-my-zsh lib/directories.zsh function for
# directory management so i can use it for doctrine
(( $+functions[d] )) && unfunction d

# the zsh builtin `log` (watch) hides ~/.local/bin/log
disable log

alias s=z
alias si=zi

# alias v="vice";
# alias vm="vice -W meta";
# alias vin="vice -W inlight";
# alias x="vice -i";

alias et="emacsclient -t";
alias ea="emacsclient -a";
alias ec="emacsclient -c";
alias emt="emacsclient --tty";
alias en="emacsclient --no-wait";
alias ee="emacsclient --eval";
alias er="emacsclient --reuse-frame";
alias ent="emacsclient --tty --no-wait";

alias nw="emacs -nw"

alias phones="pactl set-default-sink bluez_output.80_99_E7_ED_2D_2D.1"
# alias ea="distrobox enter --root archlinux"
# alias gcal="gcalcli agenda --calendar $WORK_EMAIL"

alias clock="clock-rs -Bbt --fmt '%d %b' -c blue"

alias warn="sleipnir-doctor warn"

# single character aliases
alias g=git;
alias d=doctrine;
alias j=just;
alias jc="just --choose" # !!
alias _=sudo;

alias dr="sleipnir-doctor"


alias c="cd $HOME/.config";
alias cfg="cd-pick ~/.config";

# alias tx="exec tmx default"
# y, lg: home-manager functions in .zshrc (cd on exit); no aliases here.

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
alias llm='eza --all --header --long --sort=modified'
alias lx='eza -lbhHigUmuSa@'
alias tree='eza --tree'

# grep
alias egrep="grep -E --color=auto";
alias fgrep="grep -F --color=auto";
alias grep="grep --color=auto";

# nix
# alias -g nomjson=' --log-format internal-json -v |& nom --json';
alias drs="cd ~/flakes && just darwin-switch";
# nrs: ~/.local/bin/nrs
alias nrb="sudo zsh -c 'nixos-rebuild --no-reexec -v --log-format internal-json --flake /home/david/flakes/\#$HOST |& nom --json --show-trace' ";
alias ngc="nix-collect-garbage --delete-old && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";

alias ns="nix-search-tv print | fzf --preview 'nix-search-tv preview {}' --scheme history"

# alias waybar-reload='pkill waybar --signal SIGUSR2'

# misc

alias cl="clock-rs -Bbt --fmt '%Y-%m-%d'";
# alias arch="distrobox enter archlinux";
alias supabase-kill="docker ps -q --filter "name=supabase_" | xargs -r docker stop"
