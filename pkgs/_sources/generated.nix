# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  git-credential-manager = {
    pname = "git-credential-manager";
    version = "v2.1.2";
    src = fetchFromGitHub {
      owner = "GitCredentialManager";
      repo = "git-credential-manager";
      rev = "v2.1.2";
      fetchSubmodules = false;
      sha256 = "sha256-PeQ9atSCgSvduAcqY2CnNJH3ucvoInduA5i8dPUJiHo=";
    };
  };
  spicetify-cli = {
    pname = "spicetify-cli";
    version = "v2.20.0";
    src = fetchFromGitHub {
      owner = "spicetify";
      repo = "spicetify-cli";
      rev = "v2.20.0";
      fetchSubmodules = false;
      sha256 = "sha256-6pOFDQqzxA1eHI66BHL9Yst1PtGyJzhmFveCErBA2pU=";
    };
  };
  spicetify-themes = {
    pname = "spicetify-themes";
    version = "96d6cc6e6caba407a4c2acc2e0c1fb4a2acad583";
    src = fetchFromGitHub {
      owner = "spicetify";
      repo = "spicetify-themes";
      rev = "96d6cc6e6caba407a4c2acc2e0c1fb4a2acad583";
      fetchSubmodules = false;
      sha256 = "sha256-ZsQthQGQvhpWWMzUCHdpDcCFmCi2pAzvCQp1uCFau/0=";
    };
    date = "2023-06-05";
  };
  tmux-continuum = {
    pname = "tmux-continuum";
    version = "3e4bc35da41f956c873aea716c97555bf1afce5d";
    src = fetchFromGitHub {
      owner = "tmux-plugins";
      repo = "tmux-continuum";
      rev = "3e4bc35da41f956c873aea716c97555bf1afce5d";
      fetchSubmodules = false;
      sha256 = "sha256-Z10DPP5svAL6E8ZETcosmj25RkA1DTBhn3AkJ7TDyN8=";
    };
    date = "2022-07-19";
  };
  tmux-easy-motion = {
    pname = "tmux-easy-motion";
    version = "69b15746dcee17e7a857311636d29c09f73346f3";
    src = fetchFromGitHub {
      owner = "IngoMeyer441";
      repo = "tmux-easy-motion";
      rev = "69b15746dcee17e7a857311636d29c09f73346f3";
      fetchSubmodules = false;
      sha256 = "sha256-YedReOqQzmcSn4Cv/kFPUQ3FaaA9EsTllAABlEznyys=";
    };
    date = "2022-07-08";
  };
  tmux-resurrect = {
    pname = "tmux-resurrect";
    version = "cff343cf9e81983d3da0c8562b01616f12e8d548";
    src = fetchFromGitHub {
      owner = "tmux-plugins";
      repo = "tmux-resurrect";
      rev = "cff343cf9e81983d3da0c8562b01616f12e8d548";
      fetchSubmodules = false;
      sha256 = "sha256-FcSjYyWjXM1B+WmiK2bqUNJYtH7sJBUsY2IjSur5TjY=";
    };
    date = "2023-03-06";
  };
  vscode-extensions-crates = {
    pname = "vscode-extensions-crates";
    version = "0.5.11";
    src = fetchurl {
      url = "https://serayuzgur.gallery.vsassets.io/_apis/public/gallery/publisher/serayuzgur/extension/crates/0.5.11/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "crates-0.5.11.zip";
      sha256 = "sha256-CuUc68SRJWbnChLJjHqZwPbzptxG85qHJ53IrAZc2zc=";
    };
    name = "crates";
    publisher = "serayuzgur";
  };
  vscode-extensions-errorlens = {
    pname = "vscode-extensions-errorlens";
    version = "3.11.1";
    src = fetchurl {
      url = "https://usernamehw.gallery.vsassets.io/_apis/public/gallery/publisher/usernamehw/extension/errorlens/3.11.1/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "errorlens-3.11.1.zip";
      sha256 = "sha256-yCX+imIaSww3LJ/v3ofs3qBVAXVkTT2Njha8oaqrAX8=";
    };
    name = "errorlens";
    publisher = "usernamehw";
  };
  vscode-extensions-even-better-toml = {
    pname = "vscode-extensions-even-better-toml";
    version = "0.19.0";
    src = fetchurl {
      url = "https://tamasfe.gallery.vsassets.io/_apis/public/gallery/publisher/tamasfe/extension/even-better-toml/0.19.0/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "even-better-toml-0.19.0.zip";
      sha256 = "sha256-MqSQarNThbEf1wHDTf1yA46JMhWJN46b08c7tV6+1nU=";
    };
    name = "even-better-toml";
    publisher = "tamasfe";
  };
  vscode-extensions-keyboard-quickfix = {
    pname = "vscode-extensions-keyboard-quickfix";
    version = "0.0.6";
    src = fetchurl {
      url = "https://pascalsenn.gallery.vsassets.io/_apis/public/gallery/publisher/pascalsenn/extension/keyboard-quickfix/0.0.6/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "keyboard-quickfix-0.0.6.zip";
      sha256 = "sha256-BK7ND6gtRVEitxaokJHmQ5rvSOgssVz+s9dktGQnY6M=";
    };
    name = "keyboard-quickfix";
    publisher = "pascalsenn";
  };
  vscode-extensions-live-share = {
    pname = "vscode-extensions-live-share";
    version = "1.0.5873";
    src = fetchurl {
      url = "https://MS-vsliveshare.gallery.vsassets.io/_apis/public/gallery/publisher/MS-vsliveshare/extension/vsliveshare/1.0.5873/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "vsliveshare-1.0.5873.zip";
      sha256 = "sha256-pwbabpGORQP8feMUgD3MU7frc0vp5y/epEbtY8THq7A=";
    };
    name = "vsliveshare";
    publisher = "MS-vsliveshare";
  };
  vscode-extensions-material-theme = {
    pname = "vscode-extensions-material-theme";
    version = "3.15.17";
    src = fetchurl {
      url = "https://zhuangtongfa.gallery.vsassets.io/_apis/public/gallery/publisher/zhuangtongfa/extension/material-theme/3.15.17/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "material-theme-3.15.17.zip";
      sha256 = "sha256-k09gJaxFVtdo11SSSDm2EKa4DIPl0w0MZNiRCOwaJPE=";
    };
    name = "material-theme";
    publisher = "zhuangtongfa";
  };
  vscode-extensions-remote-containers = {
    pname = "vscode-extensions-remote-containers";
    version = "0.296.0";
    src = fetchurl {
      url = "https://ms-vscode-remote.gallery.vsassets.io/_apis/public/gallery/publisher/ms-vscode-remote/extension/remote-containers/0.296.0/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "remote-containers-0.296.0.zip";
      sha256 = "sha256-VQkygGcE6dyyz5XsTRSN08vFF0Onx537Nnh7MawRdbo=";
    };
    name = "remote-containers";
    publisher = "ms-vscode-remote";
  };
  vscode-extensions-remote-wsl = {
    pname = "vscode-extensions-remote-wsl";
    version = "0.79.5";
    src = fetchurl {
      url = "https://ms-vscode-remote.gallery.vsassets.io/_apis/public/gallery/publisher/ms-vscode-remote/extension/remote-wsl/0.79.5/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "remote-wsl-0.79.5.zip";
      sha256 = "sha256-+dlWjDei8k+DLqSvsj/1LKNib3ejUmPULp0Aj8KU3YM=";
    };
    name = "remote-wsl";
    publisher = "ms-vscode-remote";
  };
  vscode-extensions-todo-tree = {
    pname = "vscode-extensions-todo-tree";
    version = "0.0.226";
    src = fetchurl {
      url = "https://gruntfuggly.gallery.vsassets.io/_apis/public/gallery/publisher/gruntfuggly/extension/todo-tree/0.0.226/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "todo-tree-0.0.226.zip";
      sha256 = "sha256-Fj9cw+VJ2jkTGUclB1TLvURhzQsaryFQs/+f2RZOLHs=";
    };
    name = "todo-tree";
    publisher = "gruntfuggly";
  };
  vscode-extensions-vscode-direnv = {
    pname = "vscode-extensions-vscode-direnv";
    version = "1.0.0";
    src = fetchurl {
      url = "https://cab404.gallery.vsassets.io/_apis/public/gallery/publisher/cab404/extension/vscode-direnv/1.0.0/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "vscode-direnv-1.0.0.zip";
      sha256 = "sha256-+nLH+T9v6TQCqKZw6HPN/ZevQ65FVm2SAo2V9RecM3Y=";
    };
    name = "vscode-direnv";
    publisher = "cab404";
  };
  vscode-extensions-vscode-icons = {
    pname = "vscode-extensions-vscode-icons";
    version = "12.4.0";
    src = fetchurl {
      url = "https://vscode-icons-team.gallery.vsassets.io/_apis/public/gallery/publisher/vscode-icons-team/extension/vscode-icons/12.4.0/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "vscode-icons-12.4.0.zip";
      sha256 = "sha256-A72aE2CwjK9IVyKF05X+tYy793NKIuu7dbDO3eO4Cyg=";
    };
    name = "vscode-icons";
    publisher = "vscode-icons-team";
  };
  vscode-extensions-vscode-lldb = {
    pname = "vscode-extensions-vscode-lldb";
    version = "1.9.2";
    src = fetchurl {
      url = "https://vadimcn.gallery.vsassets.io/_apis/public/gallery/publisher/vadimcn/extension/vscode-lldb/1.9.2/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "vscode-lldb-1.9.2.zip";
      sha256 = "sha256-TxHILZ0862gnWPrh9ut3dqCcGHrWMgUfYCkOjygMcVk=";
    };
    name = "vscode-lldb";
    publisher = "vadimcn";
  };
  vscode-extensions-vscode-neovim = {
    pname = "vscode-extensions-vscode-neovim";
    version = "0.0.97";
    src = fetchurl {
      url = "https://asvetliakov.gallery.vsassets.io/_apis/public/gallery/publisher/asvetliakov/extension/vscode-neovim/0.0.97/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "vscode-neovim-0.0.97.zip";
      sha256 = "sha256-rNGW8WB3jBSjThiB0j4/ORKMRAaxFiMiBfaa+dbGu/w=";
    };
    name = "vscode-neovim";
    publisher = "asvetliakov";
  };
}
