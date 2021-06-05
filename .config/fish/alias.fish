# choco
if test -d c:/tools/cygwin/$HOME/.config/
    abbr -a ci  choco install -y
    abbr -a cu  choco uninstall -y
end

# git
abbr -a gf      git fetch

abbr -a gco     git checkout
abbr -a gcob    git checkout -b

abbr -a gpla    git pull --autostash --rebase
abbr -a gsur    git submodule update --remote --rebase

abbr -a ga      git add
abbr -a gaa     git add --all
abbr -a gc      git commit -v
abbr -a gcsm    git commit -s -m

abbr -a gt      git tag
abbr -a gta     git tag -a

abbr -a grsh    git reset --hard

abbr -a gp      git push
abbr -a gpdr    git push --dry-run 
abbr -a gpod    git push origin --delete
abbr -a gpsu    git push --set-upstream origin
abbr -a gpt     git push --tags

abbr -a gst     git status
abbr -a gd      git diff

# tmux
abbr -a tl      tmux ls
abbr -a tn      tmux new -s
abbr -a ta      tmux attach -t
abbr -a trs     tmux rename-session
abbr -a tks     tmux kill-server
abbr -a tkss    tmux kill-session

# ls
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'

# misc
alias rl='exec fish'
