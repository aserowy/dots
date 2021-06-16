# Dotfiles...

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

The prefix changed to <kbd>ctrl + t</kbd> to overwrite the terminal key inside neovim while using tmux.

### bindings

| keys                  | effect                             |
| --------------------- | ---------------------------------- |
| <kbd>ctrl + t</kbd> v | split window vertically            |
| <kbd>ctrl + t</kbd> x | split window horizontally          |
| <kbd>ctrl + h</kbd>   | moves to left pane                 |
| <kbd>ctrl + j</kbd>   | moves to lower pane                |
| <kbd>ctrl + k</kbd>   | moves to upper pane                |
| <kbd>ctrl + l</kbd>   | moves to right pane                |
| <kbd>alt + h</kbd>    | in/decrease size by 5 to the left  |
| <kbd>alt + j</kbd>    | in/decrease size by 5 down         |
| <kbd>alt + k</kbd>    | in/decrease size by 5 up           |
| <kbd>alt + l</kbd>    | in/decrease size by 5 to the right |

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

To get usefull icons in shell and nvim, install your favorite nerd font from <https://www.nerdfonts.com/font-downloads>. My most beloved font is `FiraCode Nerd Font`. It is important to install all available font faces given.

Set Fira as default font in your terminal.

### on ubuntu

Install all dependencies in your distribution.

```sh
sudo apt-get update
sudo apt-get install -y acpi curl git tmux zsh
```

Now install starship (<https://starship.rs/>), ohmyzsh (<https://github.com/ohmyzsh/ohmyzsh/>),

```sh
sh -c "$(curl -fsSL https://starship.rs/install.sh)"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

 and set zsh as your default shell.

```sh
chsh -s $(which zsh)
```

To get tmux thumbs running, you need to install cargo on your system as well.

```sh
curl https://sh.rustup.rs -sSf | sh
```

### clone the repo

Remove all files given and clone the repo into your home directory. If you don't want to remove all files, clone it into a temp folder and move all files into your home afterwards.

```sh
git clone --recurse-submodules -j8 git@github.com:aserowy/dots.git .
```

### last but not least

Install all plugins in tmux `<kbd>ctrl + t</kbd> I`.
