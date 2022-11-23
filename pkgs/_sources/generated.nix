# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub }:
{
  picom = {
    pname = "picom";
    version = "c4107bb6cc17773fdc6c48bb2e475ef957513c7a";
    src = fetchFromGitHub ({
      owner = "ibhagwan";
      repo = "picom";
      rev = "c4107bb6cc17773fdc6c48bb2e475ef957513c7a";
      fetchSubmodules = false;
      sha256 = "sha256-1hVFBGo4Ieke2T9PqMur1w4D0bz/L3FAvfujY9Zergw=";
    });
  };
  spicetify-cli = {
    pname = "spicetify-cli";
    version = "v2.14.3";
    src = fetchFromGitHub ({
      owner = "khanhas";
      repo = "spicetify-cli";
      rev = "v2.14.3";
      fetchSubmodules = false;
      sha256 = "sha256-7bCl8VfkMhoTBnr+O+oBYQeSV2sRwlP/qUkNkYerZdU=";
    });
  };
  spicetify-themes = {
    pname = "spicetify-themes";
    version = "0c6961c39a277387dc79fdf3811e6eb75c4906a7";
    src = fetchFromGitHub ({
      owner = "morpheusthewhite";
      repo = "spicetify-themes";
      rev = "0c6961c39a277387dc79fdf3811e6eb75c4906a7";
      fetchSubmodules = false;
      sha256 = "sha256-MjniQirtSG/Q6Xwmp76hFiLq3g+Q6C9waj0ZK92+eOI=";
    });
  };
  tmux-continuum = {
    pname = "tmux-continuum";
    version = "3e4bc35da41f956c873aea716c97555bf1afce5d";
    src = fetchFromGitHub ({
      owner = "tmux-plugins";
      repo = "tmux-continuum";
      rev = "3e4bc35da41f956c873aea716c97555bf1afce5d";
      fetchSubmodules = false;
      sha256 = "sha256-Z10DPP5svAL6E8ZETcosmj25RkA1DTBhn3AkJ7TDyN8=";
    });
  };
  tmux-easy-motion = {
    pname = "tmux-easy-motion";
    version = "69b15746dcee17e7a857311636d29c09f73346f3";
    src = fetchFromGitHub ({
      owner = "IngoMeyer441";
      repo = "tmux-easy-motion";
      rev = "69b15746dcee17e7a857311636d29c09f73346f3";
      fetchSubmodules = false;
      sha256 = "sha256-YedReOqQzmcSn4Cv/kFPUQ3FaaA9EsTllAABlEznyys=";
    });
  };
  tmux-resurrect = {
    pname = "tmux-resurrect";
    version = "a2ddfb96b94bb64a7a2e3f5fa2a7c57dce8ad579";
    src = fetchFromGitHub ({
      owner = "tmux-plugins";
      repo = "tmux-resurrect";
      rev = "a2ddfb96b94bb64a7a2e3f5fa2a7c57dce8ad579";
      fetchSubmodules = false;
      sha256 = "sha256-DFDdTMwRQXk9g3OlP/3JAw5iPaeK4Cks06QFZVP6iL0=";
    });
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
    version = "1.0.5776";
    src = fetchurl {
      url = "https://MS-vsliveshare.gallery.vsassets.io/_apis/public/gallery/publisher/MS-vsliveshare/extension/vsliveshare/1.0.5776/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "vsliveshare-1.0.5776.zip";
      sha256 = "sha256-BamhVT1fmgpDKhoBTYdwIvuWUbHzF363WnKLz2ql3Lo=";
    };
    name = "vsliveshare";
    publisher = "MS-vsliveshare";
  };
  vscode-extensions-material-theme = {
    pname = "vscode-extensions-material-theme";
    version = "3.15.6";
    src = fetchurl {
      url = "https://zhuangtongfa.gallery.vsassets.io/_apis/public/gallery/publisher/zhuangtongfa/extension/material-theme/3.15.6/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "material-theme-3.15.6.zip";
      sha256 = "sha256-LViiHGDJjtQwz5O6ZZrAApi2F1rISZvcggCl8Y3nzTA=";
    };
    name = "material-theme";
    publisher = "zhuangtongfa";
  };
  vscode-extensions-remote-containers = {
    pname = "vscode-extensions-remote-containers";
    version = "0.264.0";
    src = fetchurl {
      url = "https://ms-vscode-remote.gallery.vsassets.io/_apis/public/gallery/publisher/ms-vscode-remote/extension/remote-containers/0.264.0/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "remote-containers-0.264.0.zip";
      sha256 = "sha256-sLzeoe7MPF3Nu9Qxavp8cI4b6A0GbvNXOJ8voTEsKy4=";
    };
    name = "remote-containers";
    publisher = "ms-vscode-remote";
  };
  vscode-extensions-remote-wsl = {
    pname = "vscode-extensions-remote-wsl";
    version = "0.72.0";
    src = fetchurl {
      url = "https://ms-vscode-remote.gallery.vsassets.io/_apis/public/gallery/publisher/ms-vscode-remote/extension/remote-wsl/0.72.0/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "remote-wsl-0.72.0.zip";
      sha256 = "sha256-wVsEhVpO614KzrRUvh0yRoSkswUFLlvbphmbR4BFabA=";
    };
    name = "remote-wsl";
    publisher = "ms-vscode-remote";
  };
  vscode-extensions-todo-tree = {
    pname = "vscode-extensions-todo-tree";
    version = "0.0.220";
    src = fetchurl {
      url = "https://gruntfuggly.gallery.vsassets.io/_apis/public/gallery/publisher/gruntfuggly/extension/todo-tree/0.0.220/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "todo-tree-0.0.220.zip";
      sha256 = "sha256-U7aY2/ESz9f8foBjydy1G/bWd7CLNyIjDWE3pytZfxo=";
    };
    name = "todo-tree";
    publisher = "gruntfuggly";
  };
  vscode-extensions-vscode-icons = {
    pname = "vscode-extensions-vscode-icons";
    version = "12.0.1";
    src = fetchurl {
      url = "https://vscode-icons-team.gallery.vsassets.io/_apis/public/gallery/publisher/vscode-icons-team/extension/vscode-icons/12.0.1/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "vscode-icons-12.0.1.zip";
      sha256 = "sha256-zxKD+8PfuaBaNoxTP1IHwG+25v0hDkYBj4RPn7mSzzU=";
    };
    name = "vscode-icons";
    publisher = "vscode-icons-team";
  };
  vscode-extensions-vscode-neovim = {
    pname = "vscode-extensions-vscode-neovim";
    version = "0.0.94";
    src = fetchurl {
      url = "https://asvetliakov.gallery.vsassets.io/_apis/public/gallery/publisher/asvetliakov/extension/vscode-neovim/0.0.94/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "vscode-neovim-0.0.94.zip";
      sha256 = "sha256-G/3trfDcWP0z+mqVldZRsFmlvqPF66m0QF5sq3C6hIo=";
    };
    name = "vscode-neovim";
    publisher = "asvetliakov";
  };
}
