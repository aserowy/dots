curl -L https://nixos.org/nix/install | sh

sudo chmod +x ~/.nix-profile/etc/profile.d/nix.sh
. ~/.nix-profile/etc/profile.d/nix.sh

nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update

nix-shell '<home-manager>' -A install
nix-env -iA nixpkgs.git

rm -rf ~/nix
git clone --branch cr-move-to-nix https://github.com/aserowy/dots.git ~/nix

cd ~/.config
rm -rf nixpkgs
ln -s ~/nix nixpkgs

home-manager switch
