# Dotfiles...

## git

| keys | effect                                 |
| ---- | -------------------------------------- |
| ga   | git add                                |
| gaa  | git add --all                          |
| gco  | git checkout                           |
| gcob | git checkout -b                        |
| gc   | git commit -v                          |
| gcsm | git commit -s -m                       |
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

| keys                  | effect                    |
| --------------------- | ------------------------- |
| <kbd>ctrl + t</kbd> v | split window vertically   |
| <kbd>ctrl + t</kbd> x | split window horizontally |
| <kbd>ctrl + h</kbd>   | moves to left pane        |
| <kbd>ctrl + j</kbd>   | moves to lower pane       |
| <kbd>ctrl + k</kbd>   | moves to upper pane       |
| <kbd>ctrl + l</kbd>   | moves to right pane       |

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

### on windows

Follow the instructions on <https://chocolatey.org/install> and install choco.

```sh
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
```

Install the following packages with choco and make sure you do not have git for windows or llvm installed. Uninstall them at first otherwise.

```sh
cinst -y cygwin
cinst -y cyg-get
cinst -y neovim --pre
cinst -y starship

RefreshEnv.cmd
```

Make sure to install neovim nightly with the `--pre` suffix. Now install with cyg-get all missing packages into your cygwin environment.

```sh
cyg-get.bat clang curl zsh git openssh tmux dos2unix
```

Install ohmyzsh within your cygwin shell.

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### on ubuntu

> My workflow uses `tmux` as terminal multiplexer. It is installed on ubuntu by default! Make sure you have it in your disposal as well :).

Install zsh on your distribution.

```sh
sudo apt-get update
sudo apt-get install -y zsh
```

Now install starship (<https://starship.rs/>), ohmyzsh (<https://github.com/ohmyzsh/ohmyzsh/>), and set zsh as your default shell.

```sh
sh -c "$(curl -fsSL https://starship.rs/install.sh)"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

    ```sh

chsh -s $(which zsh)
```

### clone the repo

    Remove all files given and clone the repo into your home directory. If you don't want to remove all files, clone it into a temp folder and move all files into your home afterwards.

    ```sh
    git clone --recurse-submodules -j8 git@github.com:aserowy/dots.git .
    ```
