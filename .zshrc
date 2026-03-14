# history
# Wo soll die History gespeichert werden?
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt correct
#
# plugins
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
	ZSH_AUTOSUGGEST_STRATEGY=(history completion)
	ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh
eval "$(zoxide init zsh)"
#
# customization
PROMPT='%F{blue}%n%f%F{green}@%f%F{blue}%m%f %F{green}%~%f %# '
#
# Zsh Tastatur-Fix
bindkey  "^[[H"   beginning-of-line       # Pos1
bindkey  "^[[F"   end-of-line             # Ende
bindkey  "^[[3~"  delete-char             # Entf
bindkey  "^[[1;5C" forward-word           # Strg + Pfeil Rechts
bindkey  "^[[1;5D" backward-word          # Strg + Pfeil Links
#
# alias
source "$HOME/.alias"
