# Dotfiles

## install nixpkgs

### fonts

To get usefull icons in shell and nvim, install your favorite nerd font from
<https://www.nerdfonts.com/font-downloads>. My most beloved font is
`FiraCode Nerd Font`. It is important to install all available font faces given.

Set the installed font as default in your terminal.

### on windows for wsl 2

Fix author and principal in <./assets/wsl\_init.xml> accordingly. Open the Task
Scheduler and import the updated task definition.

## install nixos

### filesystem

<!-- TODO: use disko -->

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
