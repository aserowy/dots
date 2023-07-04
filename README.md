# Dotfiles

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

## install nixpkgs

### fonts

To get usefull icons in shell and nvim, install your favorite nerd font from
<https://www.nerdfonts.com/font-downloads>. My most beloved font is
`FiraCode Nerd Font`. It is important to install all available font faces given.

Set the installed font as default in your terminal.

### on debian

Install the specified dependencies in your distribution.

```sh
sudo apt-get update
sudo apt-get install -y curl openssh-server xz-utils
```

After these packages are installed run the install script with the following
command.

> For others to use: fork and change targets in flake.nix (user@system)
> accordingly.

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

## install nixos

### filesystem

```sh
export ROOT_DISK=/dev/sda

# create partitions
sudo parted -a opt --script "${ROOT_DISK}" \
    mklabel gpt \
    mkpart primary fat32 0% 512MiB \
    set 1 esp on \
    name 1 boot \
    mkpart primary 512MiB 100% \
    set 2 lvm on \
    name 2 root

sudo fdisk ${ROOT_DISK} -l

# setup virtuals
sudo vgcreate vg ${ROOT_DISK}2

sudo lvcreate -L 8G -n swap vg
sudo lvcreate -l '100%FREE' -n root vg

sudo lvdisplay

# format partitions
sudo mkfs.fat -F 32 -n boot /dev/disk/by-partlabel/boot
sudo mkfs.ext4 -L root /dev/vg/root
sudo mkswap -L swap /dev/vg/swap

swapon -s
```

### install with flake

```sh
# mount for install
sudo mount /dev/disk/by-label/root /mnt
sudo mkdir -p /mnt/boot
sudo mount /dev/disk/by-label/boot /mnt/boot
sudo swapon /dev/vg/swap

# install
nix-shell -p git nixFlakes

sudo git clone --recurse-submodules -j8 https://github.com/aserowy/nixos.git /mnt/etc/dots

# add a new profile with hardware configuration
sudo nixos-install --root /mnt --flake /mnt/etc/dots#<new profile>

reboot
```

### switch channel to unstable for direnv

```sh
sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos
sudo nix-channel --update
```
