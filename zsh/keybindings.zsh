# zsh/keybindings.zsh
bindkey '^K' backward-kill-line
bindkey '^[begin' beginning-of-line
bindkey '^[end' end-of-line

_fix_cursor() {
   echo -ne '\e[5 q'
}
precmd_functions+=(_fix_cursor)