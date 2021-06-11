export ZSH="$HOME/.oh-my-zsh"

### settings
ZSH_CUSTOM="$HOME/.config/ohmyzsh"

export EDITOR=nvim

DISABLE_UPDATE_PROMPT="true"
UPDATE_ZSH_DAYS=7

### plugins
plugins=(
    docker
    docker-compose
    git-auto-fetch
    ssh-agent
    zsh-autosuggestions
    zsh-completions
    zsh_reload
    zsh-vi-mode

  # must be the last sourced plugin
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

### load custom configurations
for configuration in "$ZSH_CUSTOM/"*.zsh; do
    source "${configuration}"
done
unset configuration

### load completions
for configuration in "$ZSH_CUSTOM/completions/"*.zsh; do
    source "${configuration}"
done
unset configuration

eval "$(starship init zsh)"
