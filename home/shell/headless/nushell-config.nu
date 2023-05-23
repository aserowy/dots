let-env PATH = ($env.PATH | prepend "/home/serowy/.config/carapace/bin")

let carapace_completer = {|spans|
  carapace $spans.0 nushell $spans | from json
}

let-env config = {
  show_banner: false

  edit_mode: vi

  completions: {
    external: {
      enable: true
      completer: $carapace_completer
    }
  }

  # hook for direnv
  hooks: {
    pre_prompt: [{
      code: "
        try {
            let direnv = (direnv export json | from json)
            let direnv = if ($direnv | length) == 1 { $direnv } else { {} }
            $direnv | load-env
        }
      "
    }]
  }

  ls: {
    clickable_links: true
    use_ls_colors: true
  }

  table: {
    mode: rounded
    trim: {
      methodology: wrapping
      wrapping_try_keep_words: true
    }
  }
}

# cat
source cat-aliases.nu

# git
source git-aliases.nu

# ls
source ls-aliases.nu

# loading ssh-agent into env
try {
    ssh-agent -c | lines | first 2 | parse "setenv {name} {value};" | transpose -i -r -d | load-env
}

source ~/.cache/starship/init.nu
source ~/.cache/zoxide/init.nu
