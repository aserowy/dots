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

# adding nix bin to path for wsl
if "PATH" in $env {
    $env.PATH = ($env.PATH | split row (char esep) | append $"($env.HOME)/.nix-profile/bin")
}

# Directories to search for scripts when calling source or use
$env.NU_LIB_DIRS = [
    ($nu.default-config-dir | path join 'scripts')
]

mkdir ~/.cache/carapace
carapace _carapace nushell
| str replace 'carapace $spans.0 nushell $spans | from json' "# if the current command is an alias, get it's expansion\n  let expanded_alias = (scope aliases | where name == $spans.0 | get -i 0 | get -i expansion)\n\n  # overwrite\n  let spans = (if $expanded_alias != null  {\n    # put the first word of the expanded alias first in the span\n    $spans | skip 1 | prepend ($expanded_alias | split words)\n  } else {\n    $spans\n  })\n\n  carapace $spans.0 nushell $spans | from json"
| save --force ~/.cache/carapace/init.nu

mkdir ~/.cache/starship
starship init nu | save --force ~/.cache/starship/init.nu

mkdir ~/.cache/zoxide
zoxide init nushell | save --force ~/.cache/zoxide/init.nu
