source ~/.config/fish/alias.fish

# ssh
eval (ssh-agent -c)

# starship
if test -d c:/tools/cygwin/$HOME/.config/
    set -x STARSHIP_CONFIG c:/tools/cygwin/$HOME/.config/starship.toml
end

starship init fish | source
