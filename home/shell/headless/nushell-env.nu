mkdir ~/.cache/starship
starship init nu | save ~/.cache/starship/init.nu --force

mkdir ~/.cache/zoxide
zoxide init nushell | save -f ~/.cache/zoxide/init.nu --force
