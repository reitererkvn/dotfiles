#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias snapnow='sudo snapper -c root create --description "manuell erstellt" && sudo snapper -c home create --description "manuell erstellt" && echo -e "📸 \n\e[1;32mSnapshots erstellt am $(date +%H:%M:%S):\e[0m\n\e[1;34m@(root):\e[0m $(sudo snapper list | tail -n 1)\n\e[1;34m@home:\e[0m   $(sudo snapper -c home list | tail -n 1)"'
alias n8nup='docker start c00b75e9f2b0'
alias n8ndn='docker stop c00b75e9f2b0'
alias sysupdate='/usr/local/bin/system-update.sh'

PS1='[\u@\h \W]\$ '

export TERMINAL=kitty

export LIBVA_DRIVER_NAME=nvidia
. "$HOME/.cargo/env"
