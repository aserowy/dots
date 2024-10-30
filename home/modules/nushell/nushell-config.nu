$env.config = {
    show_banner: false
    edit_mode: vi

    # hook for direnv
    hooks: {
        pre_prompt: [
            {||
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
                    let command = $command.0
                    if $command == 'z' {
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

                        (zellij action rename-tab $after)
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

source ~/.cache/carapace/init.nu
source ~/.cache/starship/init.nu
source ~/.cache/zoxide/init.nu
