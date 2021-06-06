# cargo
if [ -d "$HOME/.cargo/bin" ]; then
    path+=("$HOME/.cargo/bin")
fi

# neovim
if [ -d "/cygdrive/c/tools/cygwin$HOME/.config/" ]; then
    export XDG_CONFIG_HOME="/cygdrive/c/tools/cygwin$HOME/.config/"
fi

# snap
if [ -d "/snap/bin" ]; then
    path+=("/snap/bin")
fi

# starship
if [ -d "/cygdrive/c/tools/cygwin$HOME/.config/" ]; then
    export STARSHIP_CONFIG="/cygdrive/c/tools/cygwin$HOME/.config/starship.toml"
fi

export PATH
