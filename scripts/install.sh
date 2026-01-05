#!/bin/bash

# Directory structure
# dotfiles/
# ├── zsh/
# │   ├── .zshrc                  # Main zsh configuration
# │   ├── aliases.zsh             # Your custom aliases
# │   ├── functions.zsh           # Your custom functions (killport, etc.)
# │   ├── keybindings.zsh         # Your custom key bindings
# │   ├── p10k.zsh               # Powerlevel10k configuration
# │   └── plugins/                # Custom plugin configurations
# │       ├── zsh-syntax-highlighting/
# │       ├── zsh-autosuggestions/
# │       └── zsh-shift-select/
# ├── git/
# │   ├── .gitconfig             
# │   └── git-aliases.zsh        
# ├── scripts/
# │   ├── install.sh             
# │   └── clear_photos.sh        
# └── README.md                  

set -e

DOTFILES="$HOME/.dotfiles"
CONFIG_DIR="$HOME/.config"
ZSH_DIR="$HOME/.oh-my-zsh"
P10K_THEME_DIR="$ZSH_DIR/custom/themes/powerlevel10k"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Print colored messages
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running in zsh (for Oh My Zsh installation)
check_shell() {
    if [ -z "$ZSH_VERSION" ]; then
        print_warn "This script should ideally be run from zsh, but continuing anyway..."
    fi
}

# Install Oh My Zsh if not installed
install_oh_my_zsh() {
    if [ ! -d "$ZSH_DIR" ]; then
        print_info "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        print_info "Oh My Zsh installed successfully"
    else
        print_info "Oh My Zsh is already installed"
    fi
}

# Install Powerlevel10k theme
install_powerlevel10k() {
    if [ ! -d "$P10K_THEME_DIR" ]; then
        print_info "Installing Powerlevel10k theme..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_THEME_DIR" || {
            print_error "Failed to install Powerlevel10k"
            return 1
        }
        print_info "Powerlevel10k installed successfully"
    else
        print_info "Powerlevel10k is already installed"
    fi
}

# Create necessary directories
create_directories() {
    print_info "Creating necessary directories..."
    mkdir -p "$CONFIG_DIR/.zsh"
    mkdir -p "$CONFIG_DIR/scripts"
    print_info "Directories created"
}

# Create symbolic links
create_symlinks() {
    print_info "Creating symbolic links..."
    
    # Backup existing files
    [ -f ~/.zshrc ] && [ ! -L ~/.zshrc ] && mv ~/.zshrc ~/.zshrc.backup && print_info "Backed up existing ~/.zshrc"
    [ -f ~/.p10k.zsh ] && [ ! -L ~/.p10k.zsh ] && mv ~/.p10k.zsh ~/.p10k.zsh.backup && print_info "Backed up existing ~/.p10k.zsh"
    [ -f ~/.gitconfig ] && [ ! -L ~/.gitconfig ] && mv ~/.gitconfig ~/.gitconfig.backup && print_info "Backed up existing ~/.gitconfig"
    
    # Create symbolic links
    ln -sf "$DOTFILES/zsh/.zshrc" "$HOME/.zshrc" && print_info "Linked ~/.zshrc"
    ln -sf "$DOTFILES/zsh/p10k.zsh" "$HOME/.p10k.zsh" && print_info "Linked ~/.p10k.zsh"
    
    # Link git config if it exists
    if [ -f "$DOTFILES/git/.gitconfig" ]; then
        ln -sf "$DOTFILES/git/.gitconfig" "$HOME/.gitconfig" && print_info "Linked ~/.gitconfig"
    fi
    
    # Link scripts
    if [ -f "$DOTFILES/scripts/clear_photos.sh" ]; then
        ln -sf "$DOTFILES/scripts/clear_photos.sh" "$CONFIG_DIR/scripts/clear_photos.sh" && print_info "Linked clear_photos.sh"
    fi
    
    # Link Cursor settings
    CURSOR_USER_DIR="$HOME/Library/Application Support/Cursor/User"
    if [ -d "$CURSOR_USER_DIR" ]; then
        [ -f "$CURSOR_USER_DIR/keybindings.json" ] && [ ! -L "$CURSOR_USER_DIR/keybindings.json" ] && mv "$CURSOR_USER_DIR/keybindings.json" "$CURSOR_USER_DIR/keybindings.json.backup" && print_info "Backed up existing Cursor keybindings.json"
        [ -f "$CURSOR_USER_DIR/settings.json" ] && [ ! -L "$CURSOR_USER_DIR/settings.json" ] && mv "$CURSOR_USER_DIR/settings.json" "$CURSOR_USER_DIR/settings.json.backup" && print_info "Backed up existing Cursor settings.json"
        
        ln -sf "$DOTFILES/cursor/keybindings.json" "$CURSOR_USER_DIR/keybindings.json" && print_info "Linked Cursor keybindings.json"
        ln -sf "$DOTFILES/cursor/settings.json" "$CURSOR_USER_DIR/settings.json" && print_info "Linked Cursor settings.json"
    else
        print_warn "Cursor User directory not found. Skipping Cursor settings symlink."
    fi
    
    print_info "Symbolic links created successfully"
}

# Fix Powerlevel10k path in .zshrc if needed
fix_p10k_path() {
    print_info "Checking Powerlevel10k path in .zshrc..."
    
    # Check if powerlevel10k is installed as Oh My Zsh theme
    if [ -f "$P10K_THEME_DIR/powerlevel10k.zsh-theme" ]; then
        P10K_PATH="$P10K_THEME_DIR/powerlevel10k.zsh-theme"
    # Check if installed via Homebrew
    elif [ -f "/opt/homebrew/opt/powerlevel10k/powerlevel10k.zsh-theme" ]; then
        P10K_PATH="/opt/homebrew/opt/powerlevel10k/powerlevel10k.zsh-theme"
    elif [ -f "/opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme" ]; then
        P10K_PATH="/opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme"
    else
        print_warn "Could not find Powerlevel10k installation. You may need to install it manually."
        return 0
    fi
    
    # Update .zshrc if the path is different
    if [ -f "$DOTFILES/zsh/.zshrc" ]; then
        if grep -q "source.*powerlevel10k" "$DOTFILES/zsh/.zshrc"; then
            # Use sed to replace the powerlevel10k path
            if [[ "$OSTYPE" == "darwin"* ]]; then
                # macOS sed
                sed -i '' "s|source.*powerlevel10k.*|source $P10K_PATH|" "$DOTFILES/zsh/.zshrc"
            else
                # Linux sed
                sed -i "s|source.*powerlevel10k.*|source $P10K_PATH|" "$DOTFILES/zsh/.zshrc"
            fi
            print_info "Updated Powerlevel10k path in .zshrc to: $P10K_PATH"
        fi
    fi
}

# Main installation function
main() {
    print_info "Starting dotfiles installation..."
    
    check_shell
    install_oh_my_zsh
    install_powerlevel10k
    create_directories
    create_symlinks
    fix_p10k_path
    
    print_info "Installation completed successfully!"
    print_info "Please restart your terminal or run: source ~/.zshrc"
}

# Run main function
main
