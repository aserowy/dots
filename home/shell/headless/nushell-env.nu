# path conversion for windows environments
let-env ENV_CONVERSIONS = {
  "PATH": {
    from_string: { |s| $s | split row (char esep) | path expand -n }
    to_string: { |v| $v | path expand -n | str join (char esep) }
  }
  "Path": {
    from_string: { |s| $s | split row (char esep) | path expand -n }
    to_string: { |v| $v | path expand -n | str join (char esep) }
  }
}

# adding nix bin to path for wsl
if "PATH" in $env {
    let-env PATH = ($env.PATH | split row (char esep) | append $"($env.HOME)/.nix-profile/bin")
}

# Directories to search for scripts when calling source or use
let-env NU_LIB_DIRS = [
    ($nu.default-config-dir | path join 'scripts')
]

mkdir ~/.cache/carapace
carapace _carapace nushell | save --force ~/.cache/carapace/init.nu

mkdir ~/.cache/starship
starship init nu | save --force ~/.cache/starship/init.nu

mkdir ~/.cache/zoxide
zoxide init nushell | save --force ~/.cache/zoxide/init.nu
