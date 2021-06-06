export ZSH="$HOME/.oh-my-zsh"

### Settings
ZSH_CUSTOM="$HOME/.config/ohmyzsh"

DISABLE_UPDATE_PROMPT="true"
UPDATE_ZSH_DAYS=7

plugins=(
  docker
  docker-compose
  git
  ssh-agent
  tmux
  zsh_reload
  zsh-vi-mode
)

source $ZSH/oh-my-zsh.sh

eval "$(starship init zsh)"
