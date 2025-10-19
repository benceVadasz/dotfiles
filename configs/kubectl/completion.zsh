# Kubectl completion for ZSH
# Source this file in your .zshrc

if command -v kubectl &> /dev/null; then
    source <(kubectl completion zsh)

    # Alias completion for Zsh
    compdef _kubectl k
    compdef _kubectl kube
fi
