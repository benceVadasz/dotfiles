# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"
export DOTFILES="$HOME/.dotfiles"

# Load Oh My Zsh with plugins
plugins=(git copyfile)
source $ZSH/oh-my-zsh.sh

# Load Powerlevel10k
# Try Oh My Zsh custom themes first, then Homebrew installation
if [ -f "$ZSH/custom/themes/powerlevel10k/powerlevel10k.zsh-theme" ]; then
    source /Users/bencevadasz/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme
elif [ -f "/opt/homebrew/opt/powerlevel10k/powerlevel10k.zsh-theme" ]; then
    source /Users/bencevadasz/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme
elif [ -f "/opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme" ]; then
    source /Users/bencevadasz/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme
fi

source $DOTFILES/git/git-aliases.zsh

# Load all .zsh files
for config_file ($DOTFILES/zsh/*.zsh); do
    source $config_file
done

# Load DevOps configurations
if [ -d "$DOTFILES/zsh/devops" ]; then
    for devops_config ($DOTFILES/zsh/devops/*.zsh); do
        source $devops_config
    done
fi

# Load tool completions
if [ -f "$DOTFILES/configs/kubectl/completion.zsh" ]; then
    source $DOTFILES/configs/kubectl/completion.zsh
fi

# Load custom plugins
source $DOTFILES/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $DOTFILES/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source $DOTFILES/zsh/plugins/zsh-shift-select/zsh-shift-select.plugin.zsh

# Source p10k config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Path configurations
export PATH=~/.npm-global/bin:$PATH
export PATH="$PATH:/Users/$USER/.local/bin"

# Load Google Cloud SDK if available
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then
    source "$HOME/google-cloud-sdk/path.zsh.inc"
fi
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then
    source "$HOME/google-cloud-sdk/completion.zsh.inc"
fi

# NVM configuration
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Added by Windsurf
export PATH="/Users/bencevadasz/.codeium/windsurf/bin:$PATH"
export PATH=$PATH:/Applications/Docker.app/Contents/Resources/bin

# Added by Yarn Switch
source "/Users/bencevadasz/.yarn/switch/env"

# bun completions
[ -s "/Users/bencevadasz/.bun/_bun" ] && source "/Users/bencevadasz/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
