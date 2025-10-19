# Kubectl completion for ZSH
# Source this file in your .zshrc

if command -v kubectl &> /dev/null; then
    source <(kubectl completion zsh)

    # Alias completion
    complete -F __start_kubectl k
    complete -F __start_kubectl kube
fi
