# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  git-credential-manager = {
    pname = "git-credential-manager";
    version = "v2.0.886";
    src = fetchFromGitHub ({
      owner = "GitCredentialManager";
      repo = "git-credential-manager";
      rev = "v2.0.886";
      fetchSubmodules = false;
      sha256 = "sha256-zRjDdykb0WD+2HoyvTJawBMKlCfm3Aoig76IDiBdVA0=";
    });
  };
  spicetify-cli = {
    pname = "spicetify-cli";
    version = "v2.16.1";
    src = fetchFromGitHub ({
      owner = "spicetify";
      repo = "spicetify-cli";
      rev = "v2.16.1";
      fetchSubmodules = false;
      sha256 = "sha256-Pq8HjmWSfBgieSJejrlw+FiRdq9NxryYPcw++Pdjsuk=";
    });
  };
  spicetify-themes = {
    pname = "spicetify-themes";
    version = "5d5eca15aee706a9d4b115e44fba428326eba980";
    src = fetchFromGitHub ({
      owner = "spicetify";
      repo = "spicetify-themes";
      rev = "5d5eca15aee706a9d4b115e44fba428326eba980";
      fetchSubmodules = false;
      sha256 = "sha256-cJH7hQerXPktMKbk72c2zC9Dibs4WQI0+bD76R7j/44=";
    });
    date = "2023-02-01";
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
    date = "2022-07-19";
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
    date = "2022-07-08";
  };
  tmux-resurrect = {
    pname = "tmux-resurrect";
    version = "6df04051fe14032d1825fba8fee51d9e9dc8de40";
    src = fetchFromGitHub ({
      owner = "tmux-plugins";
      repo = "tmux-resurrect";
      rev = "6df04051fe14032d1825fba8fee51d9e9dc8de40";
      fetchSubmodules = false;
      sha256 = "sha256-6Q6jwYMAO0Itt1nunJuts3rxVwl6oz0rHIjNDEUTpmw=";
    });
    date = "2023-01-31";
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
    version = "1.0.5828";
    src = fetchurl {
      url = "https://MS-vsliveshare.gallery.vsassets.io/_apis/public/gallery/publisher/MS-vsliveshare/extension/vsliveshare/1.0.5828/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "vsliveshare-1.0.5828.zip";
      sha256 = "sha256-zUCHrib3sz/UErBE4ebN83ng3OmhGrcTSnlQMaVN09c=";
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
    version = "0.276.0";
    src = fetchurl {
      url = "https://ms-vscode-remote.gallery.vsassets.io/_apis/public/gallery/publisher/ms-vscode-remote/extension/remote-containers/0.276.0/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "remote-containers-0.276.0.zip";
      sha256 = "sha256-2LnWUd+ZvTHd16OkaZrYmqHCToBa3c9TSGiJSXLq46Q=";
    };
    name = "remote-containers";
    publisher = "ms-vscode-remote";
  };
  vscode-extensions-remote-wsl = {
    pname = "vscode-extensions-remote-wsl";
    version = "0.75.1";
    src = fetchurl {
      url = "https://ms-vscode-remote.gallery.vsassets.io/_apis/public/gallery/publisher/ms-vscode-remote/extension/remote-wsl/0.75.1/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "remote-wsl-0.75.1.zip";
      sha256 = "sha256-uXv+pLhwvXMjYOlks6SvUs39cuJ7gMlRsiSChE+GjU0=";
    };
    name = "remote-wsl";
    publisher = "ms-vscode-remote";
  };
  vscode-extensions-todo-tree = {
    pname = "vscode-extensions-todo-tree";
    version = "0.0.223";
    src = fetchurl {
      url = "https://gruntfuggly.gallery.vsassets.io/_apis/public/gallery/publisher/gruntfuggly/extension/todo-tree/0.0.223/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "todo-tree-0.0.223.zip";
      sha256 = "sha256-hWks3fuWqp3/UhxnUFDyNN6S2SUR9SjbaoMkXBf3pVo=";
    };
    name = "todo-tree";
    publisher = "gruntfuggly";
  };
  vscode-extensions-vscode-icons = {
    pname = "vscode-extensions-vscode-icons";
    version = "12.2.0";
    src = fetchurl {
      url = "https://vscode-icons-team.gallery.vsassets.io/_apis/public/gallery/publisher/vscode-icons-team/extension/vscode-icons/12.2.0/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "vscode-icons-12.2.0.zip";
      sha256 = "sha256-PxM+20mkj7DpcdFuExUFN5wldfs7Qmas3CnZpEFeRYs=";
    };
    name = "vscode-icons";
    publisher = "vscode-icons-team";
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
