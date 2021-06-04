# cargo
if test -d $HOME/.cargo/bin
    fish_add_path $HOME/.cargo/bin
end

# neovim
if test -d c:/tools/cygwin/$HOME/.config/
    set -x XDG_CONFIG_HOME c:/tools/cygwin/$HOME/.config/
else
    set -x XDG_CONFIG_HOME ~/.config/
end

# snap
if test -d /snap/bin
    fish_add_path /snap/bin
end

# starship
if test -d c:/tools/cygwin/$HOME/.config/
    set -x STARSHIP_CONFIG c:/tools/cygwin/$HOME/.config/starship.toml
end

