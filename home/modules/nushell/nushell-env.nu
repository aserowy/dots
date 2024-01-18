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

mkdir ~/.cache/carapace
carapace _carapace nushell | save --force ~/.cache/carapace/init.nu

mkdir ~/.cache/starship
starship init nu | save --force ~/.cache/starship/init.nu

# FIX: remove after zoxide nu fix gets released
mkdir ~/.cache/zoxide
zoxide init nushell
| str replace "def-env" "def --env" --all
| str replace "-- $rest" "-- ...$rest" --all
| save --force ~/.cache/zoxide/init.nu
