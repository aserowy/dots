with import <nixpkgs> { };
mkShell rec {
  name = "nix";
  buildInputs = [
    pkgs.nixpkgs-fmt
    pkgs.nodePackages.prettier
  ];
  shellHook = ''
    alias hms="home-manager switch"
    alias nerb="nix-env --rollback"

    # format
    alias fmt="prettier --write README.md && nixpkgs-fmt ."

    # format and build -> fab :)
    alias fab="prettier --write README.md && nixpkgs-fmt . && home-manager build"
  '';
}

