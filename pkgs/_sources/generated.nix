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
    version = "99.0.1150.11";
    src = fetchurl {
      url = "https://packages.microsoft.com/repos/edge/pool/main/m/microsoft-edge-beta/microsoft-edge-beta_99.0.1150.11-1_amd64.deb";
      sha256 = "0wdw3ibqcsqd0is56zjdhy6jcas6fwx5gz67pq6smfl8rdr0wfvl";
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
    version = "v2.9.0";
    src = fetchgit {
      url = "https://github.com/khanhas/spicetify-cli";
      rev = "v2.9.0";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "1nqizr86gq3wnmhnw73i6crszxf805ad82ppg7m569bznfnacwiw";
    };
  };
  spicetify-themes = {
    pname = "spicetify-themes";
    version = "cab870eba282a509a34f2f107185c52188891c7f";
    src = fetchgit {
      url = "https://github.com/morpheusthewhite/spicetify-themes";
      rev = "cab870eba282a509a34f2f107185c52188891c7f";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "0zbmagqbzj8i97xd68z118s5h71wbabm9ym1g5df00fsbav6c8az";
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
    version = "027960ad25895701a8fbc0a1eb4a8cb477452d20";
    src = fetchgit {
      url = "https://github.com/tmux-plugins/tmux-resurrect";
      rev = "027960ad25895701a8fbc0a1eb4a8cb477452d20";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "07sc0a7l3f2j01ynrm2sxsn6pz05im1bfzmff29sh1qqrrp1w2zb";
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
    version = "3.13.19";
    src = fetchurl {
      url = "https://zhuangtongfa.gallery.vsassets.io/_apis/public/gallery/publisher/zhuangtongfa/extension/material-theme/3.13.19/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      sha256 = "1j99x7axa4h9250qx05r2d3yv6biiiw6275zg5b0xvkv4l8s1ff3";
    };
    name = "material-theme";
    publisher = "zhuangtongfa";
  };
  vscode-extensions-remote-containers = {
    pname = "vscode-extensions-remote-containers";
    version = "0.222.0";
    src = fetchurl {
      url = "https://ms-vscode-remote.gallery.vsassets.io/_apis/public/gallery/publisher/ms-vscode-remote/extension/remote-containers/0.222.0/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      sha256 = "0q81cpc2l14v6d5nk1j9lzd290ni15lvdfbqzv8fnmrrwsskray2";
    };
    name = "remote-containers";
    publisher = "ms-vscode-remote";
  };
  vscode-extensions-remote-wsl = {
    pname = "vscode-extensions-remote-wsl";
    version = "0.64.2";
    src = fetchurl {
      url = "https://ms-vscode-remote.gallery.vsassets.io/_apis/public/gallery/publisher/ms-vscode-remote/extension/remote-wsl/0.64.2/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      sha256 = "07glfvspv2p2x9gz9l37w30algq89r16dn3h755wykfj881900p7";
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
    version = "11.9.0";
    src = fetchurl {
      url = "https://vscode-icons-team.gallery.vsassets.io/_apis/public/gallery/publisher/vscode-icons-team/extension/vscode-icons/11.9.0/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      sha256 = "1z9rmy7j3qla8y7xbdfl9wyiz4c9p9pklgm5dfa67p49nkdvcfil";
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
