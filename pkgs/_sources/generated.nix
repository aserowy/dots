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
    version = "97.0.1072.21";
    src = fetchurl {
      url = "https://packages.microsoft.com/repos/edge/pool/main/m/microsoft-edge-beta/microsoft-edge-beta_97.0.1072.21-1_amd64.deb";
      sha256 = "1jhhrz1jn8ivv105vjw7lwkv3k4kpwzhh0k8zf1lg3m1xibvlvas";
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
    version = "0bbdb305f9a6fb1d983c45223c8296b75aa250ad";
    src = fetchgit {
      url = "https://github.com/morpheusthewhite/spicetify-themes";
      rev = "0bbdb305f9a6fb1d983c45223c8296b75aa250ad";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "09lli5zj5zihp9k3zlblgiy75nks71cvpkr6nx9p1mygdm0nxikz";
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
    version = "3.13.6";
    src = fetchurl {
      url = "https://zhuangtongfa.gallery.vsassets.io/_apis/public/gallery/publisher/zhuangtongfa/extension/material-theme/3.13.6/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      sha256 = "1rlfgl7gzph6xyhl9nrbrzqc26x99incdfd90f93q2pybn5km86z";
    };
    name = "material-theme";
    publisher = "zhuangtongfa";
  };
  vscode-extensions-remote-containers = {
    pname = "vscode-extensions-remote-containers";
    version = "0.209.1";
    src = fetchurl {
      url = "https://ms-vscode-remote.gallery.vsassets.io/_apis/public/gallery/publisher/ms-vscode-remote/extension/remote-containers/0.209.1/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      sha256 = "03ad8jrvl291lmhpw87np49791fnrnnqlwkjy4gv1pd16dcia4xz";
    };
    name = "remote-containers";
    publisher = "ms-vscode-remote";
  };
  vscode-extensions-remote-wsl = {
    pname = "vscode-extensions-remote-wsl";
    version = "0.63.4";
    src = fetchurl {
      url = "https://ms-vscode-remote.gallery.vsassets.io/_apis/public/gallery/publisher/ms-vscode-remote/extension/remote-wsl/0.63.4/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      sha256 = "1f3jwfy6kalcawl08v2dh5pkm7xllyf9fjdszlggmsa64hg8kjkl";
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
    version = "11.8.0";
    src = fetchurl {
      url = "https://vscode-icons-team.gallery.vsassets.io/_apis/public/gallery/publisher/vscode-icons-team/extension/vscode-icons/11.8.0/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      sha256 = "147d5cba3jdfgjp22a5vvvp83z79mmmkd36hgplv7cgklfmnbdis";
    };
    name = "vscode-icons";
    publisher = "vscode-icons-team";
  };
  vscode-extensions-vscode-neovim = {
    pname = "vscode-extensions-vscode-neovim";
    version = "0.0.83";
    src = fetchurl {
      url = "https://asvetliakov.gallery.vsassets.io/_apis/public/gallery/publisher/asvetliakov/extension/vscode-neovim/0.0.83/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      sha256 = "1giybf12p0h0fm950w9bwvzdk77771zfkylrqs9h0lhbdzr92qbl";
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
