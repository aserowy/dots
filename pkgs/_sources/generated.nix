# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl }:
{
  eww = {
    pname = "eww";
    version = "v0.2.0";
    src = fetchgit {
      url = "https://github.com/elkowar/eww";
      rev = "v0.2.0";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "050zc3w1z9f2vg6sz86mdxf345gd3s3jf09gf4y8y1mqkzs86b8x";
    };
    cargoLock = {
      lockFile = ./eww-v0.2.0/Cargo.lock;
      outputHashes = {
        
      };
    };
  };
  microsoft-edge-beta = {
    pname = "microsoft-edge-beta";
    version = "96.0.1054.34";
    src = fetchurl {
      url = "https://packages.microsoft.com/repos/edge/pool/main/m/microsoft-edge-beta/microsoft-edge-beta_96.0.1054.34-1_amd64.deb";
      sha256 = "1gdjwrikr7r78z03l4i70im4ydb006ggfbappwcarxhcdkwziah3";
    };
  };
  picom = {
    pname = "picom";
    version = "c4107bb6cc17773fdc6c48bb2e475ef957513c7a";
    src = fetchgit {
      url = "https://github.com/ibhagwan/picom";
      rev = "c4107bb6cc17773fdc6c48bb2e475ef957513c7a";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "035fbvb678zvpm072bzzpk8h63npmg5shkrzv4gfj89qd824a5fn";
    };
  };
  spicetify-cli = {
    pname = "spicetify-cli";
    version = "v2.8.3";
    src = fetchgit {
      url = "https://github.com/khanhas/spicetify-cli";
      rev = "v2.8.3";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "0a6vhv843vq1ilyfi2icazibgyf4p4m15lsiy505g7qg58689pqy";
    };
  };
  spicetify-themes = {
    pname = "spicetify-themes";
    version = "7b7283aa7d4058e7850e4654083d1511713fee09";
    src = fetchgit {
      url = "https://github.com/morpheusthewhite/spicetify-themes";
      rev = "7b7283aa7d4058e7850e4654083d1511713fee09";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "0a3nq4nzwm88j8ayad7k9fjcrfhis6sb7i6yda57m0v37azp8h8q";
    };
  };
  vscode-extensions-keyboard-quickfix = {
    pname = "vscode-extensions-keyboard-quickfix";
    version = "0.0.6";
    src = fetchurl {
      url = "https://pascalsenn.gallery.vsassets.io/_apis/public/gallery/publisher/pascalsenn/extension/keyboard-quickfix/0.0.6/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      sha256 = "18v34xjb8r6pngz5rc9cx14fz6j3ws8r1a0nnwi52i9dm07wvbh4";
    };
    name = "keyboard-quickfix";
    publisher = "pascalsenn";
  };
  vscode-extensions-material-theme = {
    pname = "vscode-extensions-material-theme";
    version = "3.13.4";
    src = fetchurl {
      url = "https://zhuangtongfa.gallery.vsassets.io/_apis/public/gallery/publisher/zhuangtongfa/extension/material-theme/3.13.4/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      sha256 = "1k38k0wza360wqs5h8cm2k96zmyz1hkkm7y5pc9v4bb63naigfv1";
    };
    name = "material-theme";
    publisher = "zhuangtongfa";
  };
  vscode-extensions-remote-containers = {
    pname = "vscode-extensions-remote-containers";
    version = "0.206.0";
    src = fetchurl {
      url = "https://ms-vscode-remote.gallery.vsassets.io/_apis/public/gallery/publisher/ms-vscode-remote/extension/remote-containers/0.206.0/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      sha256 = "0mijw3sjyfbphz3194vdpafb53mvhnnpcl0v7h0699zf2xqvzj97";
    };
    name = "remote-containers";
    publisher = "ms-vscode-remote";
  };
  vscode-extensions-remote-wsl = {
    pname = "vscode-extensions-remote-wsl";
    version = "0.63.2";
    src = fetchurl {
      url = "https://ms-vscode-remote.gallery.vsassets.io/_apis/public/gallery/publisher/ms-vscode-remote/extension/remote-wsl/0.63.2/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      sha256 = "14gxj3vxlhp6gp4w9jkzkp5r9k9n3a9aiiy5m84nzs68qmdlpbbd";
    };
    name = "remote-wsl";
    publisher = "ms-vscode-remote";
  };
  vscode-extensions-todo-tree = {
    pname = "vscode-extensions-todo-tree";
    version = "0.0.214";
    src = fetchurl {
      url = "https://gruntfuggly.gallery.vsassets.io/_apis/public/gallery/publisher/gruntfuggly/extension/todo-tree/0.0.214/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      sha256 = "0rwxjnrl44rnhx3183037k6435xs4772p58a37azl5cahsyav1hk";
    };
    name = "todo-tree";
    publisher = "gruntfuggly";
  };
  vscode-extensions-vscode-icons = {
    pname = "vscode-extensions-vscode-icons";
    version = "11.7.0";
    src = fetchurl {
      url = "https://vscode-icons-team.gallery.vsassets.io/_apis/public/gallery/publisher/vscode-icons-team/extension/vscode-icons/11.7.0/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      sha256 = "06a0br8szsf3i72hhq233p08b5zp7wdb8nn29h1gblhgzmv1p830";
    };
    name = "vscode-icons";
    publisher = "vscode-icons-team";
  };
  vscode-extensions-vscode-neovim = {
    pname = "vscode-extensions-vscode-neovim";
    version = "0.0.82";
    src = fetchurl {
      url = "https://asvetliakov.gallery.vsassets.io/_apis/public/gallery/publisher/asvetliakov/extension/vscode-neovim/0.0.82/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      sha256 = "17f0jzg9vdbqdjnnc5i1q28ij2kckvvxi7fw9szmyy754f074jb1";
    };
    name = "vscode-neovim";
    publisher = "asvetliakov";
  };
  widevine-cdm = {
    pname = "widevine-cdm";
    version = "4.10.2391.0";
    src = fetchurl {
      url = "https://dl.google.com/widevine-cdm/4.10.2391.0-linux-x64.zip";
      sha256 = "1ni18sfdbh9scfz3axwm47xfvgqx202svf6psgn6zvmsq39zq0gf";
    };
  };
}
