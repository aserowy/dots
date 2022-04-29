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
    version = "101.0.1210.31";
    src = fetchurl {
      url = "https://packages.microsoft.com/repos/edge/pool/main/m/microsoft-edge-beta/microsoft-edge-beta_101.0.1210.31-1_amd64.deb";
      sha256 = "0f477hk0d4v3fwp4yzcsbbvc0slw2pc986ssjd2283q5skgv3a49";
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
    version = "v2.9.8";
    src = fetchgit {
      url = "https://github.com/khanhas/spicetify-cli";
      rev = "v2.9.8";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "09dma2702096qzzijknnj1vdpv78r3agvsc6h8jwk3bwhfx91slf";
    };
  };
  spicetify-themes = {
    pname = "spicetify-themes";
    version = "95fd6ed8e98e456bed015cbe8a76253cd17064d2";
    src = fetchgit {
      url = "https://github.com/morpheusthewhite/spicetify-themes";
      rev = "95fd6ed8e98e456bed015cbe8a76253cd17064d2";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "1jbh8d9f23ls65jm1jmjhvjjp615w526sn0zfwq958lwys5gh5d3";
    };
  };
  tmux-continuum = {
    pname = "tmux-continuum";
    version = "fc2f31d79537a5b349f55b74c8ca69abaac1ddbb";
    src = fetchgit {
      url = "https://github.com/tmux-plugins/tmux-continuum";
      rev = "fc2f31d79537a5b349f55b74c8ca69abaac1ddbb";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "06i1jp83iybw76raaxciqz9a7ypgpkvbyjn6jjap8jpqfmj2wmjb";
    };
  };
  tmux-easy-motion = {
    pname = "tmux-easy-motion";
    version = "21fd252c3c916dd421b02c9e5bf3f141a9dff2d6";
    src = fetchgit {
      url = "https://github.com/IngoMeyer441/tmux-easy-motion";
      rev = "21fd252c3c916dd421b02c9e5bf3f141a9dff2d6";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "0zh89abbyqhc5fkrwcabflrq3iql2nkdinw1ihh1pqvkdhzrjpz2";
    };
  };
  tmux-resurrect = {
    pname = "tmux-resurrect";
    version = "6050d2d8d8a9052c6a30e88fa27e6d5e3844e52a";
    src = fetchgit {
      url = "https://github.com/tmux-plugins/tmux-resurrect";
      rev = "6050d2d8d8a9052c6a30e88fa27e6d5e3844e52a";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "0xbdlyn4xrfw9l1v8iw63azp1hmvl98z0idr11207hv8y319q5zj";
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
    version = "3.13.24";
    src = fetchurl {
      url = "https://zhuangtongfa.gallery.vsassets.io/_apis/public/gallery/publisher/zhuangtongfa/extension/material-theme/3.13.24/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      sha256 = "14iksqwljw7xmnk56agpcrb3mvpvzx585v7lwhqjq4km5h34dv8l";
    };
    name = "material-theme";
    publisher = "zhuangtongfa";
  };
  vscode-extensions-remote-containers = {
    pname = "vscode-extensions-remote-containers";
    version = "0.233.0";
    src = fetchurl {
      url = "https://ms-vscode-remote.gallery.vsassets.io/_apis/public/gallery/publisher/ms-vscode-remote/extension/remote-containers/0.233.0/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      sha256 = "1xlczc788avyy1wnxlhgm2fbkxmw2dbbdlqalwpipn33w07gzpg0";
    };
    name = "remote-containers";
    publisher = "ms-vscode-remote";
  };
  vscode-extensions-remote-wsl = {
    pname = "vscode-extensions-remote-wsl";
    version = "0.66.2";
    src = fetchurl {
      url = "https://ms-vscode-remote.gallery.vsassets.io/_apis/public/gallery/publisher/ms-vscode-remote/extension/remote-wsl/0.66.2/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      sha256 = "04km6bkifxg5yf84817z4cnn92lm8m56y9cjbix5y94nhsncx5ny";
    };
    name = "remote-wsl";
    publisher = "ms-vscode-remote";
  };
  vscode-extensions-todo-tree = {
    pname = "vscode-extensions-todo-tree";
    version = "0.0.215";
    src = fetchurl {
      url = "https://gruntfuggly.gallery.vsassets.io/_apis/public/gallery/publisher/gruntfuggly/extension/todo-tree/0.0.215/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      sha256 = "0lyaijsvi1gqidpn8mnnfc0qsnd7an8qg5p2m7l24c767gllkbsq";
    };
    name = "todo-tree";
    publisher = "gruntfuggly";
  };
  vscode-extensions-vscode-icons = {
    pname = "vscode-extensions-vscode-icons";
    version = "11.11.0";
    src = fetchurl {
      url = "https://vscode-icons-team.gallery.vsassets.io/_apis/public/gallery/publisher/vscode-icons-team/extension/vscode-icons/11.11.0/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      sha256 = "0qd9y0rb1j70iha8gqkxv2xvds6n4db8p0h8arlqcsfayljkn5v6";
    };
    name = "vscode-icons";
    publisher = "vscode-icons-team";
  };
  vscode-extensions-vscode-neovim = {
    pname = "vscode-extensions-vscode-neovim";
    version = "0.0.84";
    src = fetchurl {
      url = "https://asvetliakov.gallery.vsassets.io/_apis/public/gallery/publisher/asvetliakov/extension/vscode-neovim/0.0.84/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      sha256 = "042z6qi5y6n8znnf23w1r0rn1i8pc8s253vc3jh3i8nqfjkx02x5";
    };
    name = "vscode-neovim";
    publisher = "asvetliakov";
  };
  widevine-cdm = {
    pname = "widevine-cdm";
    version = "4.10.2449.0";
    src = fetchurl {
      url = "https://dl.google.com/widevine-cdm/4.10.2449.0-linux-x64.zip";
      sha256 = "045dik5bi8smldmfnzkw5lj34kpxwgjk0vjv8gdaczj2fcmrg6sx";
    };
  };
}
