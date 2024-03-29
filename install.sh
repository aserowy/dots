# install nix pkgs
curl -L https://nixos.org/nix/install | sh

sudo chmod +x ~/.nix-profile/etc/profile.d/nix.sh
. ~/.nix-profile/etc/profile.d/nix.sh

# activate flake support
nix-env -iA nixpkgs.nixUnstable

mkdir -p ~/.config/nix/
echo 'experimental-features = nix-command flakes' | tee ~/.config/nix/nix.conf

# add home manager channel
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update

# clone dotfiles
rm -rf ~/src/dots/
nix-shell -p git --run "git clone --recurse-submodules -j8 https://github.com/aserowy/dots.git ~/src/dots/"
if [ $? -ne 0 ]; then
    exit 1
fi

# install home manager and install from dotfiles
cd ~/src/dots/
nix-shell '<home-manager>' -A install
rm -rf ~/.config/nixpkgs/

home-manager switch --flake ./
if [ $? -ne 0 ]; then
    exit 1
fi

# set ssh origin for dotfiles
git remote set-url origin git@github.com:aserowy/dots.git

# set standard shell for current user
if ! grep -q "~/.nix-profile/bin/nu" "/etc/shells"; then
    echo "~/.nix-profile/bin/nu" | sudo tee -a /etc/shells
fi
sudo chsh -s ~/.nix-profile/bin/nu $(whoami)

# setup ssh daemon
sudo systemctl enable ssh
sudo sed -i -e "s/#Port 22/Port 2222/" /etc/ssh/sshd_config 

sudo tee -a /etc/wsl-init > /dev/null <<EOT
#!/bin/sh
echo initializing services
service ssh start
EOT

sudo chmod +x /etc/wsl-init

exit 0
