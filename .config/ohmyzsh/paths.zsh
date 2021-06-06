# cargo
if [ -d "$HOME/.cargo/bin" ]; then
    path+=("$HOME/.cargo/bin")
fi

# neovim
if [ -d "c:/tools/cygwin/$HOME/.config/" ]; then
    export XDG_CONFIG_HOME=$("c:/tools/cygwin$HOME/.config/")
fi

# snap
if [ -d "/snap/bin" ]; then
    path+=("/snap/bin")
fi

# starship
if [ -d "c:/tools/cygwin/$HOME/.config/" ]; then
    export STARSHIP_CONFIG=$("c:/tools/cygwin$HOME/.config/starship.toml")
fi

export PATH
