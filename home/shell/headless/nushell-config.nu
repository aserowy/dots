let-env config = {
  show_banner: false

  hooks: {
    pre_prompt: [{
      code: "
        let direnv = (direnv export json | from json)
        let direnv = if ($direnv | length) == 1 { $direnv } else { {} }
        $direnv | load-env
      "
    }]
  }
}

ssh-agent -c | lines | first 2 | parse "setenv {name} {value};" | transpose -i -r -d | load-env

source ~/.cache/starship/init.nu
source ~/.cache/zoxide/init.nu
