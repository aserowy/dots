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

# broot --print-shell-function nushell | save --force ~/.cache/nushell/broot.nu
carapace _carapace nushell | save --force ~/.cache/nushell/carapace.nu
starship init nu | save --force ~/.cache/nushell/starship.nu
zoxide init nushell | save --force ~/.cache/nushell/zoxide.nu

let tab_names = ['nvim' 'ssh']
let command_expansion = [[short extended]; ['e.g. y' 'yeet']]

$env.config = {
    show_banner: false
    edit_mode: vi

    hooks: {
        pre_prompt: [
            {||
                # hook for direnv
                try {
                    let direnv = (direnv export json | from json | default {})
                    if ($direnv | is-empty) {
                        return
                    }
                    $direnv
                        | items {|key, value| {
                            key: $key
                            value: (if $key in $env.ENV_CONVERSIONS {
                                do ($env.ENV_CONVERSIONS | get $key | get from_string) $value
                            } else {
                                $value
                            })
                        }}
                        | transpose -ird
                        | load-env
                } catch {
                    'direnv missing'
                }
            }
        ]
        pre_execution: [
            {||
                try {
                    if ($env.ZELLIJ? | is-empty) {
                        return
                    }

                    let command = (commandline | split row ' ')
                    if ($command | is-empty) {
                        return
                    }

                    let expansion = ($command_expansion
                        | find --regex $command.0
                        | get extended)

                    let command = if ($expansion | is-not-empty) {
                        $expansion.0
                    } else {
                        $command.0
                    }

                    if ($tab_names | all {|it| $it != $command}) {
                        return
                    }

                    (zellij action rename-tab $command)
                } catch {
                    (zellij action rename-tab 'unnamed')
                }
            }
        ]
        env_change: {
            PWD: [
                {|_, $after|
                    try {
                        if ($env.ZELLIJ? | is-empty) {
                            return
                        }

                        let new_tab_name = ($after | split row "/" | last | default '')
                        (zellij action rename-tab $"($new_tab_name)/")
                    } catch {
                        (zellij action rename-tab 'unnamed')
                    }
                }
            ]
        }
    }

    ls: {
        clickable_links: true
        use_ls_colors: true
    }

    table: {
        header_on_separator: true
        mode: rounded
        trim: {
            methodology: wrapping
            wrapping_try_keep_words: true
        }
    }
}

# loading ssh-agent into env
try {
    let sshAgentFilePath = $"/tmp/ssh-agent-($env.USER).nuon"

    if ($sshAgentFilePath | path exists) and ($"/proc/((open $sshAgentFilePath).SSH_AGENT_PID)" | path exists) {
        load-env (open $sshAgentFilePath)
    } else {
        ^ssh-agent -c
            | lines
            | first 2
            | parse "setenv {name} {value};"
            | transpose -r
            | into record
            | save --force $sshAgentFilePath

        load-env (open $sshAgentFilePath)
    }
}

# source ~/.cache/nushell/broot.nu
source ~/.cache/nushell/carapace.nu
source ~/.cache/nushell/starship.nu
source ~/.cache/nushell/zoxide.nu

$env.PROMPT_INDICATOR = ""
$env.TRANSIENT_PROMPT_INDICATOR = ""
$env.PROMPT_INDICATOR_VI_INSERT = ""
$env.TRANSIENT_PROMPT_INDICATOR_VI_INSERT = ""
$env.PROMPT_INDICATOR_VI_NORMAL = ""
$env.TRANSIENT_PROMPT_INDICATOR_VI_NORMAL = ""
