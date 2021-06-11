# string operations
alias trim="sed -e 's/^[[:space:]]*//g' -e 's/[[:space:]]*\$//g'"

# git
alias g="git"

alias gf="git fetch"

alias gcl="git clone --recurse-submodules"

alias gco="git checkout"
alias gcob="git checkout -b"

alias gpla="git pull --autostash --rebase"
alias gsur="git submodule update --remote --rebase"

alias ga="git add"
alias gaa="git add --all"
alias gc="git commit -v"
alias gcsm="git commit -s -m"

alias gt="git tag"
alias gta="git tag -a"

alias grsh="git reset --hard"

alias gp="git push"
alias gpdr="git push --dry-run"
alias gpod="git push origin --delete"
alias gpsu="git push --set-upstream origin"
alias gpt="git push --tags"

alias gst="git status"
alias gd="git diff"

# ls
alias ll="ls -l"
alias la="ls -a"
alias lla="ls -la"

# mstsc
m() {
    param=$(echo "$1" | trim)
    echo "$param"
    if [ -z "$param" ]; then
        mstsc.exe &
    else
        mstsc.exe /v:"$param" &
    fi
}

# nvim
alias vim="nvim"
alias vimdiff="nvim -d"

# tmux
alias t="tmux"

alias tl="tmux ls"
alias ts="tmux new -s"
alias ta="tmux attach -t"
alias tad="tmux attach -d -t"
alias tksv="tmux kill-server"
alias tkss="tmux kill-session -t"
alias trss="tmux rename-session"
