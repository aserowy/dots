# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  git-credential-manager = {
    pname = "git-credential-manager";
    version = "v2.5.0";
    src = fetchFromGitHub {
      owner = "GitCredentialManager";
      repo = "git-credential-manager";
      rev = "v2.5.0";
      fetchSubmodules = false;
      sha256 = "sha256-eRSTF9Ldj00cQbUzHzdMihte0+W4nZ9T/qg/L/yes/w=";
    };
  };
  spicetify-cli = {
    pname = "spicetify-cli";
    version = "v2.36.12";
    src = fetchFromGitHub {
      owner = "spicetify";
      repo = "spicetify-cli";
      rev = "v2.36.12";
      fetchSubmodules = false;
      sha256 = "sha256-tQSVPi9dfcxC6axd7BKGOZzXJy32CXXL8yfKZnB1hq8=";
    };
  };
  spicetify-themes = {
    pname = "spicetify-themes";
    version = "dfdd89ad84d5c68915c65e4a83580047349c49b4";
    src = fetchFromGitHub {
      owner = "spicetify";
      repo = "spicetify-themes";
      rev = "dfdd89ad84d5c68915c65e4a83580047349c49b4";
      fetchSubmodules = false;
      sha256 = "sha256-8IF2Y7xJtzk92rl4bfjiMXCISzUMaxXxOaMZkLS5mww=";
    };
    date = "2024-05-17";
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
    version = "0.6.6";
    src = fetchurl {
      url = "https://serayuzgur.gallery.vsassets.io/_apis/public/gallery/publisher/serayuzgur/extension/crates/0.6.6/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "crates-0.6.6.zip";
      sha256 = "sha256-HXoH1IgMLniq0kxHs2snym4rerScu9qCqUaqwEC+O/E=";
    };
    publisher = "serayuzgur";
    name = "crates";
  };
  vscode-extensions-errorlens = {
    pname = "vscode-extensions-errorlens";
    version = "3.18.0";
    src = fetchurl {
      url = "https://usernamehw.gallery.vsassets.io/_apis/public/gallery/publisher/usernamehw/extension/errorlens/3.18.0/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "errorlens-3.18.0.zip";
      sha256 = "sha256-sRZRBUne9IqDBSe4BXyqBqirIyjeP03B2w9+ptNrJl0=";
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
    version = "1.0.5918";
    src = fetchurl {
      url = "https://MS-vsliveshare.gallery.vsassets.io/_apis/public/gallery/publisher/MS-vsliveshare/extension/vsliveshare/1.0.5918/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "vsliveshare-1.0.5918.zip";
      sha256 = "sha256-Tk0mKydUF8M7l7NC9wEA7t2rzJWy/mq4/HvIHI2/ldQ=";
    };
    publisher = "MS-vsliveshare";
    name = "vsliveshare";
  };
  vscode-extensions-material-theme = {
    pname = "vscode-extensions-material-theme";
    version = "3.17.2";
    src = fetchurl {
      url = "https://zhuangtongfa.gallery.vsassets.io/_apis/public/gallery/publisher/zhuangtongfa/extension/material-theme/3.17.2/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "material-theme-3.17.2.zip";
      sha256 = "sha256-4s3I6FJUqvannOq6osPU79qExQJrgfP51wcr55yJ2Nc=";
    };
    publisher = "zhuangtongfa";
    name = "material-theme";
  };
  vscode-extensions-remote-containers = {
    pname = "vscode-extensions-remote-containers";
    version = "0.371.0";
    src = fetchurl {
      url = "https://ms-vscode-remote.gallery.vsassets.io/_apis/public/gallery/publisher/ms-vscode-remote/extension/remote-containers/0.371.0/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "remote-containers-0.371.0.zip";
      sha256 = "sha256-RXLgNrMvKSCrCo2CYq9xap6a3LLWkYetObcHY7bvRqw=";
    };
    publisher = "ms-vscode-remote";
    name = "remote-containers";
  };
  vscode-extensions-remote-wsl = {
    pname = "vscode-extensions-remote-wsl";
    version = "0.88.2";
    src = fetchurl {
      url = "https://ms-vscode-remote.gallery.vsassets.io/_apis/public/gallery/publisher/ms-vscode-remote/extension/remote-wsl/0.88.2/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "remote-wsl-0.88.2.zip";
      sha256 = "sha256-fl7fLNd3EHA9eMiPUIL/23SUiA81gveqZLFkqaHTX+Q=";
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
    version = "12.8.0";
    src = fetchurl {
      url = "https://vscode-icons-team.gallery.vsassets.io/_apis/public/gallery/publisher/vscode-icons-team/extension/vscode-icons/12.8.0/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "vscode-icons-12.8.0.zip";
      sha256 = "sha256-2+Wf0AL9C5xOQCjA9maMt/W/kviNuiyMfaOFDU82KxM=";
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
    version = "1.15.2";
    src = fetchurl {
      url = "https://asvetliakov.gallery.vsassets.io/_apis/public/gallery/publisher/asvetliakov/extension/vscode-neovim/1.15.2/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "vscode-neovim-1.15.2.zip";
      sha256 = "sha256-gurh2DSLH/gM/EZCUACHGlzOf0LPwkc+zYxw7AOcb1E=";
    };
    publisher = "asvetliakov";
    name = "vscode-neovim";
  };
}
