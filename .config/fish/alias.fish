# choco
if test -d c:/tools/cygwin/$HOME/.config/
    abbr -a ci  choco install -y
    abbr -a cu  choco uninstall -y
end

# git
abbr -a gf      git fetch

abbr -a gco     git checkout
abbr -a gcb     git checkout -b

abbr -a gupa    git pull --rebase --autostash

abbr -a ga      git add
abbr -a gaa     git add --all
abbr -a gc      git commit -v
abbr -a gcsm    git commit -s -m

abbr -a gp      git push
abbr -a gpd     git push --dry-run

abbr -a gst     git status
abbr -a gd      git diff

# ls
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'

# misc
alias rl='exec fish'
