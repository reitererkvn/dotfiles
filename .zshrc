# history
# Wo soll die History gespeichert werden?
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt correct

# plugins
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
	ZSH_AUTOSUGGEST_STRATEGY=(history completion)
	ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh
eval "$(zoxide init zsh)"
# customization
PROMPT='%F{blue}%n%f%F{green}@%f%F{blue}%m%f %F{green}%~%f %# '
# Zsh Tastatur-Fix
bindkey  "^[[H"   beginning-of-line       # Pos1
bindkey  "^[[F"   end-of-line             # Ende
bindkey  "^[[3~"  delete-char             # Entf
bindkey  "^[[1;5C" forward-word           # Strg + Pfeil Rechts
bindkey  "^[[1;5D" backward-word          # Strg + Pfeil Links
# alias
alias sudo='sudo -E' # root verwendet envs von user
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias vim='nvim'
alias snapnow='sudo snapper -c root create --description "manuell erstellt" && sudo snapper -c home create --description "manuell erstellt" && echo -e "📸 \n\e[1;32mSnapshots erstellt am $(date +%H:%M:%S):\e[0m\n\e[1;34m@(root):\e[0m $(sudo snapper list | tail -n 1)\n\e[1;34m@home:\e[0m   $(sudo snapper -c home list | tail -n 1)"'
alias n8nup='docker start c00b75e9f2b0'
alias n8ndn='docker stop c00b75e9f2b0'
alias sysupdate='/usr/local/bin/system-update.sh'
alias note='~/=.local/bin/note'
alias gitsync='/home/kevin/.dotfiles/.local/bin/git-push.sh'

