source ~/.config/fish/alias.fish

# ssh
eval (ssh-agent -c)

# neovim
if test -d c:/tools/cygwin/$HOME/.config/
    set -x XDG_CONFIG_HOME c:/tools/cygwin/$HOME/.config/
end

# starship
if test -d c:/tools/cygwin/$HOME/.config/
    set -x STARSHIP_CONFIG c:/tools/cygwin/$HOME/.config/starship.toml
end

starship init fish | source
