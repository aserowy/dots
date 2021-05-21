# Dotfiles...

## install

### fonts

To get usefull icons in shell and nvim, install your favorite nerd font from <https://www.nerdfonts.com/font-downloads>. My most beloved font is `FiraCode Nerd Font`. It is important to install all available font faces given.

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
cyg-get clang curl fish git openssh
```

Set fish in your terminal of choice. I am using windows terminal. You can find my configuration for copy & paste actions [here](./.config/terminal/settings.json).

### on ubuntu

chsh -s `which fish`

### clone the repo

Remove all files given and clone the repo into your home directory. If you don't want to remove all files, clone it into a temp folder and move all files into your home afterwards.

```sh
git clone https://github.com/aserowy/dots.git .
```

The neovim configuration is used as a submodule of the repository of [NeoCode](https://github.com/aserowy/NeoCode/). To enable it, you have to initialze all submodules. Before running the git commands, make sure you have set up your github access (e.g. ssh) accordingly.

```sh
git submodule init
git submodule update --remote --merge
```
