# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  git-credential-manager = {
    pname = "git-credential-manager";
    version = "v2.5.1";
    src = fetchFromGitHub {
      owner = "GitCredentialManager";
      repo = "git-credential-manager";
      rev = "v2.5.1";
      fetchSubmodules = false;
      sha256 = "sha256-fD/HToyreYS8PG85CHHLPQOUKV1cDYGukxyVOr+7cKk=";
    };
  };
  spicetify-cli = {
    pname = "spicetify-cli";
    version = "v2.38.3";
    src = fetchFromGitHub {
      owner = "spicetify";
      repo = "spicetify-cli";
      rev = "v2.38.3";
      fetchSubmodules = false;
      sha256 = "sha256-la0zNYWzsU49Z6OKTefocN3xzoyNceaPAzG+CAFKMPc=";
    };
  };
  spicetify-themes = {
    pname = "spicetify-themes";
    version = "bf2263b71b9ed4f4cff4125df45ef157f5b2b01e";
    src = fetchFromGitHub {
      owner = "spicetify";
      repo = "spicetify-themes";
      rev = "bf2263b71b9ed4f4cff4125df45ef157f5b2b01e";
      fetchSubmodules = false;
      sha256 = "sha256-8d3Vlrv/RvAF52B+a6jy8ZTG0r5IVt0nCgrRjAUuliA=";
    };
    date = "2024-09-20";
  };
  tmux-continuum = {
    pname = "tmux-continuum";
    version = "0698e8f4b17d6454c71bf5212895ec055c578da0";
    src = fetchFromGitHub {
      owner = "tmux-plugins";
      repo = "tmux-continuum";
      rev = "0698e8f4b17d6454c71bf5212895ec055c578da0";
      fetchSubmodules = false;
      sha256 = "sha256-W71QyLwC/MXz3bcLR2aJeWcoXFI/A3itjpcWKAdVFJY=";
    };
    date = "2024-01-20";
  };
  tmux-easy-motion = {
    pname = "tmux-easy-motion";
    version = "3e2edbd0a3d9924cc1df3bd3529edc507bdf5934";
    src = fetchFromGitHub {
      owner = "IngoMeyer441";
      repo = "tmux-easy-motion";
      rev = "3e2edbd0a3d9924cc1df3bd3529edc507bdf5934";
      fetchSubmodules = false;
      sha256 = "sha256-wOIPq12OqqxLERKfvVp4JgLkDXnM0KKtTqRWMqj4rfs=";
    };
    date = "2024-04-05";
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
    version = "0.6.7";
    src = fetchurl {
      url = "https://serayuzgur.gallery.vsassets.io/_apis/public/gallery/publisher/serayuzgur/extension/crates/0.6.7/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "crates-0.6.7.zip";
      sha256 = "sha256-FVZxMZ0QpCKLD0vX7LPvBywZgQ4kptjnCW9jCefwgJo=";
    };
    publisher = "serayuzgur";
    name = "crates";
  };
  vscode-extensions-errorlens = {
    pname = "vscode-extensions-errorlens";
    version = "3.20.0";
    src = fetchurl {
      url = "https://usernamehw.gallery.vsassets.io/_apis/public/gallery/publisher/usernamehw/extension/errorlens/3.20.0/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "errorlens-3.20.0.zip";
      sha256 = "sha256-0gCT+u6rfkEcWcdzqRdc4EosROllD/Q0TIOQ4k640j0=";
    };
    publisher = "usernamehw";
    name = "errorlens";
  };
  vscode-extensions-even-better-toml = {
    pname = "vscode-extensions-even-better-toml";
    version = "0.19.2";
    src = fetchurl {
      url = "https://tamasfe.gallery.vsassets.io/_apis/public/gallery/publisher/tamasfe/extension/even-better-toml/0.19.2/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "even-better-toml-0.19.2.zip";
      sha256 = "sha256-JKj6noi2dTe02PxX/kS117ZhW8u7Bhj4QowZQiJKP2E=";
    };
    publisher = "tamasfe";
    name = "even-better-toml";
  };
  vscode-extensions-keyboard-quickfix = {
    pname = "vscode-extensions-keyboard-quickfix";
    version = "0.0.6";
    src = fetchurl {
      url = "https://pascalsenn.gallery.vsassets.io/_apis/public/gallery/publisher/pascalsenn/extension/keyboard-quickfix/0.0.6/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "keyboard-quickfix-0.0.6.zip";
      sha256 = "sha256-BK7ND6gtRVEitxaokJHmQ5rvSOgssVz+s9dktGQnY6M=";
    };
    publisher = "pascalsenn";
    name = "keyboard-quickfix";
  };
  vscode-extensions-live-share = {
    pname = "vscode-extensions-live-share";
    version = "1.0.5941";
    src = fetchurl {
      url = "https://MS-vsliveshare.gallery.vsassets.io/_apis/public/gallery/publisher/MS-vsliveshare/extension/vsliveshare/1.0.5941/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "vsliveshare-1.0.5941.zip";
      sha256 = "sha256-s7N6Qywq/SaubOOGw3+Rx1sl/Y1tHrtA2Cz8KiTB62I=";
    };
    publisher = "MS-vsliveshare";
    name = "vsliveshare";
  };
  vscode-extensions-material-theme = {
    pname = "vscode-extensions-material-theme";
    version = "3.17.5";
    src = fetchurl {
      url = "https://zhuangtongfa.gallery.vsassets.io/_apis/public/gallery/publisher/zhuangtongfa/extension/material-theme/3.17.5/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "material-theme-3.17.5.zip";
      sha256 = "sha256-5rpLTG5MWvOf2l/KMA+/aZgJxoBTzBiHGY4q7Ac1xhg=";
    };
    publisher = "zhuangtongfa";
    name = "material-theme";
  };
  vscode-extensions-remote-containers = {
    pname = "vscode-extensions-remote-containers";
    version = "0.387.0";
    src = fetchurl {
      url = "https://ms-vscode-remote.gallery.vsassets.io/_apis/public/gallery/publisher/ms-vscode-remote/extension/remote-containers/0.387.0/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "remote-containers-0.387.0.zip";
      sha256 = "sha256-r/u8b8NnaohSlm3mtn/kYqcGhEGHgCuKK73JYfHFeMU=";
    };
    publisher = "ms-vscode-remote";
    name = "remote-containers";
  };
  vscode-extensions-remote-wsl = {
    pname = "vscode-extensions-remote-wsl";
    version = "0.88.3";
    src = fetchurl {
      url = "https://ms-vscode-remote.gallery.vsassets.io/_apis/public/gallery/publisher/ms-vscode-remote/extension/remote-wsl/0.88.3/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "remote-wsl-0.88.3.zip";
      sha256 = "sha256-LzfKMzn2t/LY5eV/+M5MyMCGwCberlTc+rMIQa7QvVY=";
    };
    publisher = "ms-vscode-remote";
    name = "remote-wsl";
  };
  vscode-extensions-todo-tree = {
    pname = "vscode-extensions-todo-tree";
    version = "0.0.226";
    src = fetchurl {
      url = "https://gruntfuggly.gallery.vsassets.io/_apis/public/gallery/publisher/gruntfuggly/extension/todo-tree/0.0.226/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "todo-tree-0.0.226.zip";
      sha256 = "sha256-Fj9cw+VJ2jkTGUclB1TLvURhzQsaryFQs/+f2RZOLHs=";
    };
    publisher = "gruntfuggly";
    name = "todo-tree";
  };
  vscode-extensions-vscode-direnv = {
    pname = "vscode-extensions-vscode-direnv";
    version = "1.0.0";
    src = fetchurl {
      url = "https://cab404.gallery.vsassets.io/_apis/public/gallery/publisher/cab404/extension/vscode-direnv/1.0.0/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "vscode-direnv-1.0.0.zip";
      sha256 = "sha256-+nLH+T9v6TQCqKZw6HPN/ZevQ65FVm2SAo2V9RecM3Y=";
    };
    publisher = "cab404";
    name = "vscode-direnv";
  };
  vscode-extensions-vscode-icons = {
    pname = "vscode-extensions-vscode-icons";
    version = "12.9.0";
    src = fetchurl {
      url = "https://vscode-icons-team.gallery.vsassets.io/_apis/public/gallery/publisher/vscode-icons-team/extension/vscode-icons/12.9.0/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "vscode-icons-12.9.0.zip";
      sha256 = "sha256-ULjZlbGcVbPiokfnx7d4z7cmVVEfy2d+SUch80rZRA4=";
    };
    publisher = "vscode-icons-team";
    name = "vscode-icons";
  };
  vscode-extensions-vscode-lldb = {
    pname = "vscode-extensions-vscode-lldb";
    version = "1.10.0";
    src = fetchurl {
      url = "https://vadimcn.gallery.vsassets.io/_apis/public/gallery/publisher/vadimcn/extension/vscode-lldb/1.10.0/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "vscode-lldb-1.10.0.zip";
      sha256 = "sha256-RAKv7ESw0HG/avBOPE1CTr0THsB7UWx0haJVd/Dm9Gg=";
    };
    publisher = "vadimcn";
    name = "vscode-lldb";
  };
  vscode-extensions-vscode-neovim = {
    pname = "vscode-extensions-vscode-neovim";
    version = "1.18.12";
    src = fetchurl {
      url = "https://asvetliakov.gallery.vsassets.io/_apis/public/gallery/publisher/asvetliakov/extension/vscode-neovim/1.18.12/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "vscode-neovim-1.18.12.zip";
      sha256 = "sha256-3Nmk0MFIMFYQHrRyZ7ioFk9KfHSk0CSF7FwNaEJbsyg=";
    };
    publisher = "asvetliakov";
    name = "vscode-neovim";
  };
}
