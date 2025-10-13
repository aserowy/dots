# NOTE: init files for carapace etc. here, because generating and sourcing files in one script is forbidden
mkdir ~/.cache/nushell

# broot --print-shell-function nushell | save --force ~/.cache/nushell/broot.nu
carapace _carapace nushell | save --force ~/.cache/nushell/carapace.nu
starship init nu | save --force ~/.cache/nushell/starship.nu
zoxide init nushell | save --force ~/.cache/nushell/zoxide.nu
