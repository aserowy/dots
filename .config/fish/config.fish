# fish_greeting
set -e fish_greeting
set greeting ''

## cygwin
if test -d c:/tools/cygwin/$HOME/.config/
    ps -ef | grep -v grep | grep 'cygserver' >/dev/null
    if test $status -ne 0
        set greeting 'cygserver not started: this may result in slow executions! run cygserver-config and cygrunsrv -S cygserver in an elevated console. '$greeting
    end
end

if test -n '$greeting'
    set -U fish_greeting $greeting
end

# sources
source ~/.config/fish/alias.fish
source ~/.config/fish/paths.fish

# vi mode
fish_vi_key_bindings

# https://github.com/fish-shell/fish-shell/issues/3481
function fish_mode_prompt; end
set -g fish_cursor_unknown block

# ssh
ps -ef | grep -v grep | grep 'ssh-agent' >/dev/null
if test $status -ne 0
    eval (ssh-agent -c) &>/dev/null
end

starship init fish | source
