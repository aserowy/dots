$env.config = {
  show_banner: false

  edit_mode: vi

  # hook for direnv
  hooks: {
    pre_prompt: [{ ||
      try {
        let direnv = (direnv export json | from json)
        let direnv = if ($direnv | length) == 1 { $direnv } else { {} }
        $direnv | load-env
      }
    }]
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

# cat
source cat-aliases.nu

# git
source git-aliases.nu

# ls
source ls-aliases.nu

# loading ssh-agent into env
try {
    ssh-agent -c
    | lines
    | first 2
    | parse "setenv {name} {value};"
    | transpose -r
    | into record
    | load-env
}

source ~/.cache/carapace/init.nu
source ~/.cache/starship/init.nu
source ~/.cache/zoxide/init.nu
