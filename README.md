# Dotfiles

## structure

TODO: short introduction into the repository

## git

| keys | effect                                 |
| ---- | -------------------------------------- |
| g    | git                                    |
| ga   | git add                                |
| gaa  | git add --all                          |
| gb   | git branch                             |
| gba  | git branch -a                          |
| gc   | git commit -v                          |
| gcsm | git commit -s -m                       |
| gcl  | git clone --recurse-submodules -j8     |
| gco  | git checkout                           |
| gcob | git checkout -b                        |
| gcp  | git cherry-pick                        |
| gd   | git diff                               |
| gf   | git fetch                              |
| gpla | git pull --rebase --autostash          |
| gp   | git push                               |
| gpdr | git push --dry-run                     |
| gpod | git push origin --delete               |
| gpt  | git push --tags                        |
| grsh | git reset --hard                       |
| gst  | git status                             |
| gsur | git submodule update --remote --rebase |
| gt   | git tag                                |
| gta  | git tag -a                             |

## tmux

> cheatsheet for tmux <https://gist.github.com/MohamedAlaa/2961058>

The prefix changed to <kbd>ctrl + t</kbd> to overwrite the terminal key inside
neovim while using tmux.

### bindings

| keys                             | effect                                                  |
| -------------------------------- | ------------------------------------------------------- |
| <kbd>ctrl + t</kbd> <kbd>v</kbd> | split window vertically                                 |
| <kbd>ctrl + t</kbd> <kbd>x</kbd> | split window horizontally                               |
| <kbd>ctrl + t</kbd> <kbd>w</kbd> | trigger tmux-easy-motion (bd-w)                         |
| <kbd>ctrl + h</kbd>              | moves to left pane                                      |
| <kbd>ctrl + j</kbd>              | moves to lower pane                                     |
| <kbd>ctrl + k</kbd>              | moves to upper pane                                     |
| <kbd>ctrl + l</kbd>              | moves to right pane                                     |
| <kbd>alt + h</kbd>               | (not working in vim) in/decrease size by 5 to the left  |
| <kbd>alt + j</kbd>               | (not working in vim) in/decrease size by 5 down         |
| <kbd>alt + k</kbd>               | (not working in vim) in/decrease size by 5 up           |
| <kbd>alt + l</kbd>               | (not working in vim) in/decrease size by 5 to the right |

### aliases

| keys | effect               |
| ---- | -------------------- |
| t    | tmux                 |
| tl   | tmux ls              |
| ts   | tmux new -s          |
| ta   | tmux attach -t       |
| tad  | tmux attach -d -t    |
| tksv | tmux kill-server     |
| tkss | tmux kill-session -t |
| trss | tmux rename-session  |
| tlb  | tmux list-buffers    |
| tcb  | tmux choose-buffer   |

## misc

| keys              | effect                             |
| ----------------- | ---------------------------------- |
|                   |                                    |
| **ls**            |                                    |
| ll                | ls -l                              |
| la                | ls -a                              |
| lla               | ls -la                             |
|                   |                                    |
| **misc**          |                                    |
| src               | -- sources zsh configuration again |
|                   |                                    |
| **mstsc**         |                                    |
| m [ip (optional)] | mstsc.exe & or mstsc.exe /v:ip &   |

## install

### fonts

To get usefull icons in shell and nvim, install your favorite nerd font from
<https://www.nerdfonts.com/font-downloads>. My most beloved font is `FiraCode
Nerd Font`. It is important to install all available font faces given.

Set the installed font as default in your terminal.

### on debian

Install the specified dependencies in your distribution.

```sh
sudo apt-get update
sudo apt-get install -y curl openssh-server xz-utils
```

After these packages are installed run the install script with the following command.

> For others to use: fork and change targets in flake.nix (user@system) accordingly.

```sh
curl -L https://raw.githubusercontent.com/aserowy/dots/main/install.sh | sh
```

At the end, copy your ssh keys into `~/.ssh` and set the permissions to 600 for
all keys and pubs.

```sh
sudo chmod 600 [file]
```

### on windows for wsl 2

Fix author and principal in <./assets/wsl\_init.xml> accordingly. Open the Task
Scheduler and import the updated task definition.
