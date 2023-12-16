# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  git-credential-manager = {
    pname = "git-credential-manager";
    version = "v2.4.1";
    src = fetchFromGitHub {
      owner = "GitCredentialManager";
      repo = "git-credential-manager";
      rev = "v2.4.1";
      fetchSubmodules = false;
      sha256 = "sha256-Uf0EXaGM4k9Aanz16B9xA2EcseXTI9lLCws/ZVNb3e8=";
    };
  };
  spicetify-cli = {
    pname = "spicetify-cli";
    version = "v2.28.1";
    src = fetchFromGitHub {
      owner = "spicetify";
      repo = "spicetify-cli";
      rev = "v2.28.1";
      fetchSubmodules = false;
      sha256 = "sha256-PiOpj9FsolFZzoMATnJmMwjZrBLGXDIHv8SIaJQetRc=";
    };
  };
  spicetify-themes = {
    pname = "spicetify-themes";
    version = "8b6a8010359914b3c8fdaf810705c754ce69c2a4";
    src = fetchFromGitHub {
      owner = "spicetify";
      repo = "spicetify-themes";
      rev = "8b6a8010359914b3c8fdaf810705c754ce69c2a4";
      fetchSubmodules = false;
      sha256 = "sha256-iMRutzOrZHaKfHOr2qOM/TkTYHysFBlmunVhU65kf2k=";
    };
    date = "2023-11-30";
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
    version = "f4ae57d2f4d030afc866a6d074e22573515159a0";
    src = fetchFromGitHub {
      owner = "IngoMeyer441";
      repo = "tmux-easy-motion";
      rev = "f4ae57d2f4d030afc866a6d074e22573515159a0";
      fetchSubmodules = false;
      sha256 = "sha256-uzvv/m0sN/cqKt85VL5UcBYQFEFZ5GJphPSlSMN9uvo=";
    };
    date = "2023-09-20";
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
    version = "0.6.5";
    src = fetchurl {
      url = "https://serayuzgur.gallery.vsassets.io/_apis/public/gallery/publisher/serayuzgur/extension/crates/0.6.5/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "crates-0.6.5.zip";
      sha256 = "sha256-HgqM4PKGk3R5MLY4cVjKxv79p5KlOkVDeDbv7/6FmpM=";
    };
    publisher = "serayuzgur";
    name = "crates";
  };
  vscode-extensions-errorlens = {
    pname = "vscode-extensions-errorlens";
    version = "3.16.0";
    src = fetchurl {
      url = "https://usernamehw.gallery.vsassets.io/_apis/public/gallery/publisher/usernamehw/extension/errorlens/3.16.0/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "errorlens-3.16.0.zip";
      sha256 = "sha256-Y3M/A5rYLkxQPRIZ0BUjhlkvixDae+wIRUsBn4tREFw=";
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
    version = "1.0.5900";
    src = fetchurl {
      url = "https://MS-vsliveshare.gallery.vsassets.io/_apis/public/gallery/publisher/MS-vsliveshare/extension/vsliveshare/1.0.5900/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "vsliveshare-1.0.5900.zip";
      sha256 = "sha256-syVW/aS2ppJjg4OZaenzGM3lczt+sLy7prwsYFTDl9s=";
    };
    publisher = "MS-vsliveshare";
    name = "vsliveshare";
  };
  vscode-extensions-material-theme = {
    pname = "vscode-extensions-material-theme";
    version = "3.16.2";
    src = fetchurl {
      url = "https://zhuangtongfa.gallery.vsassets.io/_apis/public/gallery/publisher/zhuangtongfa/extension/material-theme/3.16.2/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "material-theme-3.16.2.zip";
      sha256 = "sha256-KYw45IdB3QoO6CYWWqga4OM0VM0lowPv8J0iYz9Jais=";
    };
    publisher = "zhuangtongfa";
    name = "material-theme";
  };
  vscode-extensions-remote-containers = {
    pname = "vscode-extensions-remote-containers";
    version = "0.328.0";
    src = fetchurl {
      url = "https://ms-vscode-remote.gallery.vsassets.io/_apis/public/gallery/publisher/ms-vscode-remote/extension/remote-containers/0.328.0/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "remote-containers-0.328.0.zip";
      sha256 = "sha256-kA0f5lObxseC6HefuF2vqlPbobwUDjDn6mKmvTc3heA=";
    };
    publisher = "ms-vscode-remote";
    name = "remote-containers";
  };
  vscode-extensions-remote-wsl = {
    pname = "vscode-extensions-remote-wsl";
    version = "0.81.8";
    src = fetchurl {
      url = "https://ms-vscode-remote.gallery.vsassets.io/_apis/public/gallery/publisher/ms-vscode-remote/extension/remote-wsl/0.81.8/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "remote-wsl-0.81.8.zip";
      sha256 = "sha256-ZR87G2Rxh+DZiyLeQMyOeagIP5VfTo/ZE0qw6B4r/BA=";
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
    version = "12.6.0";
    src = fetchurl {
      url = "https://vscode-icons-team.gallery.vsassets.io/_apis/public/gallery/publisher/vscode-icons-team/extension/vscode-icons/12.6.0/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "vscode-icons-12.6.0.zip";
      sha256 = "sha256-SylhhaPiuz0dxrb1NmatAr8rby5IsrJ16eQh2sQWFzQ=";
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
    version = "1.4.0";
    src = fetchurl {
      url = "https://asvetliakov.gallery.vsassets.io/_apis/public/gallery/publisher/asvetliakov/extension/vscode-neovim/1.4.0/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "vscode-neovim-1.4.0.zip";
      sha256 = "sha256-j+EiGeq1v1IF99TUwFF6Gk9RKIP0Qi5I+2hYn4GqEFQ=";
    };
    publisher = "asvetliakov";
    name = "vscode-neovim";
  };
}
