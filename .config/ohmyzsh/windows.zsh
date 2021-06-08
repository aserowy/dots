if [ -d "/cygdrive/c/tools/cygwin$HOME/.config/" ]; then
    # neovim
    alias nvim="nvim -u C:/tools/cygwin$HOME/.config/nvim/init.lua"

    # starship
    export STARSHIP_CONFIG="$HOME/.config/starship.toml"
fi

