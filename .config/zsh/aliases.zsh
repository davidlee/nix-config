# single character aliases 
alias g=git;

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
alias zed=zeditor;

# TUI shortcuts
alias yz=yazi;
alias lg=lazygit;
alias ip=ip -color;

# nix
alias ngc="nix-collect-garbage --delete-old && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";
alias opts="man home-configuration.nix";
alias nrs="sudo nixos-rebuild switch --log-format internal-json -v |& nom --json";

# taskwarrior
alias t=task;
alias ta=task add;
alias tc='task context';

alias h=harsh;
alias hc="$VISUAL ~/.config/harsh/habits";
alias hl="$VISUAL ~/.config/harsh/log";

# misc
alias cl="clock-rs -Bbt --fmt '%Y-%m-%d'";
