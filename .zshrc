export ZSH="$HOME/.oh-my-zsh"

### Settings
ZSH_CUSTOM="$HOME/.config/ohmyzsh"

DISABLE_UPDATE_PROMPT="true"
UPDATE_ZSH_DAYS=7

### Plugins
plugins=(
  docker
  docker-compose
  ssh-agent
  tmux
  zsh_reload
  zsh-vi-mode

  # must be the last sourced plugin
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

### Load custom configurations
for configuration in "$ZSH_CUSTOM/"*.zsh; do
  source "${configuration}"
done
unset configuration

eval "$(starship init zsh)"
