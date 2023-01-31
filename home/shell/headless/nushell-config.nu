let-env config = {
  show_banner: false

  edit_mode: vi

  # hook for direnv
  hooks: {
    pre_prompt: [{
      code: "
        let direnv = (direnv export json | from json)
        let direnv = if ($direnv | length) == 1 { $direnv } else { {} }
        $direnv | load-env
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
use cat-aliases.nu

# git
use git-completions.nu *
source git-aliases.nu

# ls
source ls-aliases.nu

# loading ssh-agent into env
ssh-agent -c | lines | first 2 | parse "setenv {name} {value};" | transpose -i -r -d | load-env

source ~/.cache/starship/init.nu
source ~/.cache/zoxide/init.nu
