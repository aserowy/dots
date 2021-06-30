curl -L https://nixos.org/nix/install | sh

sudo chmod +x ~/.nix-profile/etc/profile.d/nix.sh
. ~/.nix-profile/etc/profile.d/nix.sh

nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update

nix-shell '<home-manager>' -A install
nix-env -iA nixpkgs.git

rm -rf ~/nix
git clone --recurse-submodules -j8 https://github.com/aserowy/dots.git ~/nix
if [ $? -ne 0 ]; then
    exit 1
fi

nix-env --rollback

cd ~/.config
rm -rf nixpkgs
ln -s ~/nix nixpkgs

cd ~/nix
home-manager switch
if [ $? -ne 0 ]; then
    exit 1
fi

git remote set-url origin git@github.com:aserowy/dots.git

if ! grep -q "~/.nix-profile/bin/zsh" "/etc/shells"; then
    echo "~/.nix-profile/bin/zsh" | sudo tee -a /etc/shells
fi
sudo chsh -s ~/.nix-profile/bin/zsh $(whoami)

exit 0
