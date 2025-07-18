# single character aliases
alias g=git;
alias j=just;
alias _=sudo;
alias t=task;
alias z=zellij;
alias y=yazi;

alias c="cd $HOME/.config";
alias cfg="fzd $HOME/.config";

alias lgc="lazygit -g ~/.cfg -w ~"

alias ij=daily; # interstitial journal

alias tx="exec tmx default"

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

alias zz=zellij;
alias gg=git;

if [[ $OSTYPE = 'linux-gnu' ]]; then
  alias open=xdg-open
fi

alias hxr="hx ~/.reminders";

# util / override
alias scr="grimshot save area";
alias ct="bat --style snip --style changes --style header";
alias mkdir="mkdir -p";

# cd
alias ".."="cd ..";
alias "..."="cd ../..";
alias "...."="cd ../../..";

# list files
alias vdir="vdir --color=auto";
alias dir="dir --color=auto";
alias l="eza -lh";
alias ll="eza -lh --grid --group-directories-first";
alias la="eza -lah --grid --group-directories-first";
alias ld="eza -lhD";
alias lt="eza --tree";

# grep
alias egrep="grep -E --color=auto";
alias fgrep="grep -F --color=auto";
alias grep="grep --color=auto";

# editors
alias v=nvim;
alias vi=nvim;
alias vim=nvim;
alias zed=zeditor;

# TUI shortcuts
alias yz=yazi;
alias lg=lazygit;
alias ip=ip -color;

# nix
alias drs="cd ~/flakes && sudo darwin-rebuild switch --flake '.#fusillade' ";
alias nrs="sudo zsh -c 'nixos-rebuild --log-format internal-json -v switch |& nom --json' ";
alias ngc="nix-collect-garbage --delete-old && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";
alias -g om=' --log-format internal-json -v |& nom --json';
alias lgc='lazygit -g ~/.cfg -w ~/';
alias ns="nix-search-tv print | fzf --preview 'nix-search-tv preview {}' --scheme history"

# hyprland
alias waybar-reload='pkill waybar --signal SIGUSR2'

# Taskwarrior
alias tw='taskwarrior-tui'
alias tn='clear;task next +READY'
alias ta='task add'
alias ti="task add +in"
alias in="task add +in"
alias tm='task modify'
alias tl='task log'
alias tc='task context';
alias tin='task in'

alias taskserver='taskchampion-sync-server --listen localhost:10222';

# harsh
alias h=harsh;
alias hc="$VISUAL ~/.config/harsh/habits";
alias hl="$VISUAL ~/.config/harsh/log";

# misc
alias cl="clock-rs -Bbt --fmt '%Y-%m-%d'";
alias arch="distrobox enter archlinux";
