export ZSH="$HOME/.oh-my-zsh"

### Settings
ZSH_CUSTOM="$HOME/.config/ohmyzsh"

export EDITOR=nvim

DISABLE_UPDATE_PROMPT="true"
UPDATE_ZSH_DAYS=7

### Plugins
plugins=(
  docker
  docker-compose
  ssh-agent
  zsh-autosuggestions
  zsh-completions
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

### Load completions
for configuration in "$ZSH_CUSTOM/completions/"*.zsh; do
  source "${configuration}"
done
unset configuration

# TODO: https://github.com/starship/starship/issues/2449
if [ -d "/cygdrive/c/tools/cygwin$HOME/.config/" ]; then
    source <(starship init zsh --print-full-init | dos2unix)
else
    eval "$(starship init zsh)"
fi
