function fish_greeting
end

source ~/.config/fish/alias.fish

# vi mode
fish_vi_key_bindings

# https://github.com/fish-shell/fish-shell/issues/3481
function fish_mode_prompt; end
set -g fish_cursor_unknown block

# ssh
ps -ef | grep -v grep | grep "ssh-agent" >/dev/null
if test $status -ne 0
    eval (ssh-agent -c) &>/dev/null
end

# neovim
if test -d c:/tools/cygwin/$HOME/.config/
    set -x XDG_CONFIG_HOME c:/tools/cygwin/$HOME/.config/
end

# starship
if test -d c:/tools/cygwin/$HOME/.config/
    set -x STARSHIP_CONFIG c:/tools/cygwin/$HOME/.config/starship.toml
end

starship init fish | source
