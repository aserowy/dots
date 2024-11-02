# path conversion for windows environments
$env.ENV_CONVERSIONS = {
  "PATH": {
    from_string: { |s| $s | split row (char esep) | path expand -n }
    to_string: { |v| $v | path expand -n | str join (char esep) }
  }
  "Path": {
    from_string: { |s| $s | split row (char esep) | path expand -n }
    to_string: { |v| $v | path expand -n | str join (char esep) }
  }
}

# adding nix bin to path for wsl and macos
if "PATH" in $env {
    $env.PATH = ($env.PATH | split row (char esep) | prepend $"($env.HOME)/.nix-profile/bin")
}

# Directories to search for scripts when calling source or use
$env.NU_LIB_DIRS = [
    ($nu.default-config-dir | path join 'scripts')
]


mkdir ~/.cache/nushell

broot --print-shell-function nushell| save --force ~/.cache/nushell/broot.nu
carapace _carapace nushell | save --force ~/.cache/nushell/carapace.nu
starship init nu | save --force ~/.cache/nushell/starship.nu
zoxide init nushell | save --force ~/.cache/nushell/zoxide.nu
