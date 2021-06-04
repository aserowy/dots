# Dotfiles...

## tmux

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

### abbraviations

| keys | effect              |
| ---- | ------------------- |
| tl   | tmux ls             |
| tn   | tmux new -s         |
| ta   | tmux attach -t      |
| trs  | tmux rename-session |
| tks  | tmux kill-session   |

## aliases & abbraviations

| keys     | effect                                 |
| -------- | -------------------------------------- |
|          |                                        |
| **git**  |                                        |
| gf       | git fetch                              |
| gco      | git checkout                           |
| gcob     | git checkout -b                        |
| gpla     | git pull --rebase --autostash          |
| gsur     | git submodule update --remote --rebase |
| ga       | git add                                |
| gaa      | git add --all                          |
| gc       | git commit -v                          |
| gcsm     | git commit -s -m                       |
| gt       | git tag                                |
| gta      | git tag -a                             |
| grsh     | git reset --hard                       |
| gp       | git push                               |
| gpdr     | git push --dry-run                     |
| gpod     | git push origin --delete               |
| gpt      | git push --tags                        |
| gst      | git status                             |
| gd       | git diff                               |
|          |                                        |
| **ls**   |                                        |
| l        | ls -l                                  |
| la       | ls -a                                  |
| lla      | ls -la                                 |
|          |                                        |
| **misc** |                                        |
| rl       | exec fish                              |

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
cyg-get clang curl fish git openssh tmux
```

Set fish in your terminal of choice. I am using windows terminal. You can find my configuration for copy & paste actions [here](./.config/terminal/settings.json).

To prevent slow responses through authentication, add cygserver for caching purposes. The shell must run with elevated privileges!

> <https://superuser.com/questions/877051/cygwin-from-windows-is-very-slow-laggy>

```sh
cygserver-config
```

### on ubuntu

> My workflow uses `tmux` as terminal multiplexer. It is installed on ubuntu by default! Make sure you have it in your disposal as well :).

Install fish shell on your distribution described on <https://fishshell.com/>. For ubuntu (2021-05-21) you need to add the given repository.

```sh
sudo apt-add-repository ppa:fish-shell/release-3
sudo apt-get update
sudo apt-get install fish
```

Now install starship <https://starship.rs/> and set fish as your default shell.

```sh
sh -c "$(curl -fsSL https://starship.rs/install.sh)"
```

```sh
chsh -s `which fish`
```

### clone the repo

Remove all files given and clone the repo into your home directory. If you don't want to remove all files, clone it into a temp folder and move all files into your home afterwards.

```sh
git clone git@github.com:aserowy/dots.git .
```

The neovim configuration is used as a submodule of the repository of [NeoCode](https://github.com/aserowy/NeoCode/). To enable it, you have to initialze all submodules. Before running the git commands, make sure you have set up your github access (e.g. ssh) accordingly.

```sh
git submodule init
git submodule update --remote --rebase
```
