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
    version = "v2.14.0";
    src = fetchFromGitHub ({
      owner = "khanhas";
      repo = "spicetify-cli";
      rev = "v2.14.0";
      fetchSubmodules = false;
      sha256 = "sha256-iaaf5ZHaHSEkQdxqZtsc6K/3+x6gAfvgQoWWYWcFeV4=";
    });
  };
  spicetify-themes = {
    pname = "spicetify-themes";
    version = "eb6b818368d9c01ef92522623b37aa29200d0bc0";
    src = fetchFromGitHub ({
      owner = "morpheusthewhite";
      repo = "spicetify-themes";
      rev = "eb6b818368d9c01ef92522623b37aa29200d0bc0";
      fetchSubmodules = false;
      sha256 = "sha256-Q/LBS+bjt2WP/s43LE8hDjYHxPVorT/RA71esPraLOM=";
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
    version = "88297b4c3abcd3a15c874a85cf3586aa7f536e1a";
    src = fetchFromGitHub ({
      owner = "tmux-plugins";
      repo = "tmux-resurrect";
      rev = "88297b4c3abcd3a15c874a85cf3586aa7f536e1a";
      fetchSubmodules = false;
      sha256 = "sha256-jLDncwNDX166yeJF++SZsWoW9AthjUxZiXtFN8YaB2g=";
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
    version = "1.0.5733";
    src = fetchurl {
      url = "https://MS-vsliveshare.gallery.vsassets.io/_apis/public/gallery/publisher/MS-vsliveshare/extension/vsliveshare/1.0.5733/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "vsliveshare-1.0.5733.zip";
      sha256 = "sha256-KbD77j+ZRedMo3iX/dAu17vOSZBZaVpjzOw6rgBZ85w=";
    };
    name = "vsliveshare";
    publisher = "MS-vsliveshare";
  };
  vscode-extensions-material-theme = {
    pname = "vscode-extensions-material-theme";
    version = "3.15.5";
    src = fetchurl {
      url = "https://zhuangtongfa.gallery.vsassets.io/_apis/public/gallery/publisher/zhuangtongfa/extension/material-theme/3.15.5/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "material-theme-3.15.5.zip";
      sha256 = "sha256-sYdBeJrWPfxzgA84aJaHUvxLK9N4pBptoMQ75Nv9OTM=";
    };
    name = "material-theme";
    publisher = "zhuangtongfa";
  };
  vscode-extensions-remote-containers = {
    pname = "vscode-extensions-remote-containers";
    version = "0.256.0";
    src = fetchurl {
      url = "https://ms-vscode-remote.gallery.vsassets.io/_apis/public/gallery/publisher/ms-vscode-remote/extension/remote-containers/0.256.0/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "remote-containers-0.256.0.zip";
      sha256 = "sha256-qaqWZ7UKlNF6d033TGjc3JWsmUbDSK6hJgGzDbeVMtQ=";
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
    version = "0.0.215";
    src = fetchurl {
      url = "https://gruntfuggly.gallery.vsassets.io/_apis/public/gallery/publisher/gruntfuggly/extension/todo-tree/0.0.215/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "todo-tree-0.0.215.zip";
      sha256 = "sha256-WK9J6TvmMCLoqeKWh5FVp1mNAXPWVmRvi/iFuLWMylM=";
    };
    name = "todo-tree";
    publisher = "gruntfuggly";
  };
  vscode-extensions-vscode-icons = {
    pname = "vscode-extensions-vscode-icons";
    version = "11.20.0";
    src = fetchurl {
      url = "https://vscode-icons-team.gallery.vsassets.io/_apis/public/gallery/publisher/vscode-icons-team/extension/vscode-icons/11.20.0/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "vscode-icons-11.20.0.zip";
      sha256 = "sha256-wcSYTDMhqY2EgLmVVoXt9652THWxyPBpTI3GHfwYsQ4=";
    };
    name = "vscode-icons";
    publisher = "vscode-icons-team";
  };
  vscode-extensions-vscode-neovim = {
    pname = "vscode-extensions-vscode-neovim";
    version = "0.0.89";
    src = fetchurl {
      url = "https://asvetliakov.gallery.vsassets.io/_apis/public/gallery/publisher/asvetliakov/extension/vscode-neovim/0.0.89/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "vscode-neovim-0.0.89.zip";
      sha256 = "sha256-4cCaMw7joaXeq+dk5cPZz6/zXDlxWeP/3IjkgSmmRvs=";
    };
    name = "vscode-neovim";
    publisher = "asvetliakov";
  };
}
