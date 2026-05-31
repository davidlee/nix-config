
alias v="vice";
alias vm="vice -W meta";
alias vin="vice -W inlight";
alias x="vice -i";

alias em="emacsclient";
alias emt="emacsclient --tty";
alias emn="emacsclient --tty --no-wait";

alias phones="pactl set-default-sink bluez_output.80_99_E7_ED_2D_2D.1"
alias ea="distrobox enter --root archlinux"
# alias gcal="gcalcli agenda --calendar $WORK_EMAIL"

# single character aliases
alias g=git;
alias j=just;
alias jc="just --choose"
alias _=sudo;
alias s='uv run spec-driver';

alias dr="sleipnir-doctor"

alias nw="emacs -nw"

alias c="cd $HOME/.config";
alias cfg="fzd $HOME/.config";

alias tx="exec tmx default"
alias gg=git;
alias yy=yazi;

# editors
alias vi=nvim;
alias vim=nvim;
alias zed=zeditor;

# TUI shortcuts
alias yz=yazi;
alias lg=lazygit;
alias ip=ip -color;

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

if [[ $OSTYPE = 'linux-gnu' ]]; then
  alias open=xdg-open
fi

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
alias l="eza -lh";
alias ll="eza -lh --grid --group-directories-first";
alias la="eza -lah --grid --group-directories-first";
alias ld="eza -lhD";
alias lt="eza --tree";
alias ls='eza $eza_params'
alias l='eza --git-ignore $eza_params'
alias ll='eza --all --header --long $eza_params'
alias llm='eza --all --header --long --sort=modified $eza_params'
alias la='eza -lbhHigUmuSa'
alias lx='eza -lbhHigUmuSa@'
alias lt='eza --tree $eza_params'
alias tree='eza --tree $eza_params'

# grep
alias egrep="grep -E --color=auto";
alias fgrep="grep -F --color=auto";
alias grep="grep --color=auto";

# nix
# alias -g nomjson=' --log-format internal-json -v |& nom --json';
alias drs="cd ~/flakes && sudo darwin-rebuild switch --flake '.#fusillade' ";
alias nrs="sudo zsh -c 'nixos-rebuild --log-format internal-json -v switch --flake /home/david/flakes/\#Sleipnir |& nom --json' ";
alias nrb="sudo zsh -c 'nixos-rebuild --no-reexec -v --log-format internal-json --flake /home/david/flakes/\#Sleipnir |& nom --json --show-trace' ";
alias ngc="nix-collect-garbage --delete-old && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";
alias ns="nix-search-tv print | fzf --preview 'nix-search-tv preview {}' --scheme history"

alias waybar-reload='pkill waybar --signal SIGUSR2'

# misc

alias cl="clock-rs -Bbt --fmt '%Y-%m-%d'";
alias arch="distrobox enter archlinux";
alias supabase-kill="docker ps -q --filter "name=supabase_" | xargs -r docker stop"
