# Directory structure
dotfiles/
├── zsh/
│   ├── .zshrc                  # Main zsh configuration
│   ├── aliases.zsh             # Your custom aliases
│   ├── functions.zsh           # Your custom functions (killport, etc.)
│   ├── keybindings.zsh         # Your custom key bindings
│   ├── p10k.zsh               # Powerlevel10k configuration
│   └── plugins/                # Custom plugin configurations
│       ├── zsh-syntax-highlighting/
│       ├── zsh-autosuggestions/
│       └── zsh-shift-select/
├── git/
│   ├── .gitconfig             
│   └── git-aliases.zsh        
├── scripts/
│   ├── install.sh             
│   └── clear_photos.sh        
└── README.md                  

#!/bin/bash

DOTFILES="$HOME/.dotfiles"
CONFIG_DIR="$HOME/.config"

# Create necessary directories
mkdir -p "$CONFIG_DIR/.zsh"

# Create symbolic links
create_symlinks() {
    echo "Creating symbolic links..."
    
    # Backup existing files
    [ -f ~/.zshrc ] && mv ~/.zshrc ~/.zshrc.backup
    [ -f ~/.p10k.zsh ] && mv ~/.p10k.zsh ~/.p10k.zsh.backup
    
    # Create symbolic links
    ln -sf "$DOTFILES/zsh/.zshrc" "$HOME/.zshrc"
    ln -sf "$DOTFILES/zsh/p10k.zsh" "$HOME/.p10k.zsh"
    ln -sf "$DOTFILES/git/.gitconfig" "$HOME/.gitconfig"
    
    # Link custom plugins
    ln -sf "$DOTFILES/zsh/plugins/zsh-syntax-highlighting" "$CONFIG_DIR/.zsh/"
    ln -sf "$DOTFILES/zsh/plugins/zsh-autosuggestions" "$CONFIG_DIR/.zsh/"
    ln -sf "$DOTFILES/zsh/plugins/zsh-shift-select" "$CONFIG_DIR/.zsh/"
}

# Main .zshrc content
# zsh/.zshrc
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
export DOTFILES="$HOME/.dotfiles"

# Theme configuration
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme

# Load Oh My Zsh
plugins=(git copyfile)
source $ZSH/oh-my-zsh.sh

# Load custom configurations
for config_file ($DOTFILES/zsh/*.zsh); do
    source $config_file
done

# Load custom plugins
source ~/.config/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.config/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.config/.zsh/zsh-shift-select/zsh-shift-select.plugin.zsh

# Your functions.zsh
killport() {
  if [[ -z $1 ]]; then
    echo "Usage: killport <port>"
    return 1
  fi

  local port=$1
  local pids=$(lsof -t -i:$port)

  if [[ -z $pids ]]; then
    echo "No processes found on port $port."
    return 1
  fi

  echo "Killing processes on port $port: $pids"
  kill -9 $pids
}

# Your keybindings.zsh
bindkey '^K' backward-kill-line
bindkey '^[begin' beginning-of-line
bindkey '^[end' end-of-line

_fix_cursor() {
   echo -ne '\e[5 q'
}
precmd_functions+=(_fix_cursor)

# Your aliases.zsh
alias dev="cd ~/Desktop/Dev"
alias play="cd ~/Desktop/Dev/playground"
alias pjob="pbpaste > ~/Desktop/Dev/projects/jobs-api/content.txt"
alias particle="pbpaste > ~/Desktop/Dev/projects/AICommands/article/content.txt"
alias article='node ~/Desktop/Dev/projects/AICommands/article/index.js'
alias seed='yarn b docker:exec seed'
alias migration-run='yarn b docker:exec migration:run'
alias clear-photos="~/.config/scripts/clear_photos.sh"
alias myip="ifconfig | grep 'inet ' | grep -v '127.0.0.1' | awk '{print \$2}'"
alias config="code ~/.zshrc"

# Environment setup
export PATH=~/.npm-global/bin:$PATH
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Source p10k configuration
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh