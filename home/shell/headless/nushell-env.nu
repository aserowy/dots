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
    $"($env.HOME)/.config/nushell/scripts"
]

# Directories to search for plugin binaries when calling register
# let-env NU_PLUGIN_DIRS = [
#     ($nu.config-path | path dirname | path join 'plugins')
# ]

mkdir ~/.cache/starship
# BUG: https://github.com/starship/starship/issues/5063
starship init nu
| str replace --string 'PROMPT_COMMAND = {' 'PROMPT_COMMAND = { ||'
| str replace --string 'PROMPT_COMMAND_RIGHT = {' 'PROMPT_COMMAND_RIGHT = { ||'
| save ~/.cache/starship/init.nu --force

mkdir ~/.cache/zoxide
zoxide init nushell | save -f ~/.cache/zoxide/init.nu --force
