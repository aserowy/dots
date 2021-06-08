# cargo
if [ -d "$HOME/.cargo/bin" ]; then
    path+=("$HOME/.cargo/bin")
fi

# snap
if [ -d "/snap/bin" ]; then
    path+=("/snap/bin")
fi

export PATH
