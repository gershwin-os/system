# Removing the following line will break Ctrl-A and Ctrl-E
bindkey -e

PROMPT='%n@%m %1~ %# '
autoload -U colors
colors
PS1='%F{blue}%n%f@%F{green}%m%f %F{yellow}%1~%f %# '
alias ls='ls -G'
alias ll='ls -l'
alias la='ls -la'
export EDITOR=nano

# Add /opt/bin to the PATH
export PATH="/opt/bin:$PATH"

# Source GNUstep.sh
source /System/Makefiles/GNUstep.sh
