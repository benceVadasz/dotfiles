# Dotfiles

My personal dotfiles for setting up a new machine with my preferred development environment.

## What's Inside

- Zsh configuration with Oh My Zsh
- Powerlevel10k theme
- Custom aliases and functions
- Git configuration
- Various plugin configurations

### Directory Structure

```plaintext
dotfiles/
├── .gitignore # Git ignore file
├── zsh/
│ ├── .zshrc # Main zsh configuration
│ ├── aliases.zsh # Custom aliases
│ ├── functions.zsh # Custom functions
│ ├── keybindings.zsh # Custom key bindings
│ ├── p10k.zsh # Powerlevel10k configuration
│ └── plugins/ # Custom plugin configurations
│ ├── zsh-syntax-highlighting/
│ ├── zsh-autosuggestions/
│ └── zsh-shift-select/
├── git/
│ ├── .gitconfig # Git configuration
│ └── git-aliases.zsh # Git aliases
├── scripts/
│ ├── install.sh # Installation script
│ └── clear_photos.sh # Photo clearing script
└── README.md
```

## Prerequisites

- Zsh
- [Oh My Zsh](https://ohmyz.sh/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- Git

## Installation

1. Clone the repository (with submodules):

```bash
git clone --recursive https://github.com/yourusername/dotfiles.git ~/.dotfiles
```

2. Run the installation script:

```bash
cd ~/.dotfiles
chmod +x scripts/install.sh
./scripts/install.sh
```

## Features

### Custom Functions

- **killport**: Kill process running on specified port
- **migration-gen**: Generate database migrations
- **job**: Run job script with parameters
- **checkout_branch**: Git branch checkout with message

### Custom Aliases

- Development shortcuts (dev, play)
- Docker commands (seed, migration-run, dock)
- Database proxy connections
- Git workflow shortcuts

### Plugins

- zsh-syntax-highlighting
- zsh-autosuggestions
- zsh-shift-select

## Updating

### Update dotfiles

```bash
cd ~/.dotfiles
git pull
```

### Update plugins

```bash
git submodule update --remote
```

## Customization

### Adding new aliases

Add them to `zsh/aliases.zsh`

### Adding new functions

Add them to `zsh/functions.zsh`

### Adding new key bindings

Add them to `zsh/keybindings.zsh`

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Oh My Zsh
- Powerlevel10k
- All plugin authors
