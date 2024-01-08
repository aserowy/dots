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

# FIX: remove replace after https://github.com/rsteube/carapace-bin/pull/2102 gets merged
mkdir ~/.cache/carapace
carapace _carapace nushell
| str replace 'carapace $spans.0 nushell $spans | from json' "# if the current command is an alias, get it's expansion\n  let expanded_alias = (scope aliases | where name == $spans.0 | get -i 0 | get -i expansion)\n\n  # overwrite\n  let spans = (if $expanded_alias != null  {\n    # put the first word of the expanded alias first in the span\n    $spans | skip 1 | prepend ($expanded_alias | split row \" \" | take 1)\n  } else {\n    $spans\n  })\n\n  carapace $spans.0 nushell $spans\n  | from json"
| save --force ~/.cache/carapace/init.nu

mkdir ~/.cache/starship
starship init nu | save --force ~/.cache/starship/init.nu

# FIX: remove after zoxide nu fix gets released
mkdir ~/.cache/zoxide
zoxide init nushell
| str replace "def-env" "def --env" --all
| save --force ~/.cache/zoxide/init.nu
