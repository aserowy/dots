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
    version = "97.0.1072.54";
    src = fetchurl {
      url = "https://packages.microsoft.com/repos/edge/pool/main/m/microsoft-edge-beta/microsoft-edge-beta_97.0.1072.54-1_amd64.deb";
      sha256 = "0xcasmg17dyhpw97jd203q9cffsm8l4gf646c3zsla71yv6r6xaj";
    };
  };
  neocode = {
    pname = "neocode";
    version = "6df49959136cb3ee352c9c904cb2d7cd88329100";
    src = fetchgit {
      url = "https://github.com/aserowy/neocode";
      rev = "6df49959136cb3ee352c9c904cb2d7cd88329100";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "1q1qnp9mc9ifl6xrczhxylyrla98gcmzqqzaypj6jm0nlfrj3akw";
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
    version = "v2.8.4";
    src = fetchgit {
      url = "https://github.com/khanhas/spicetify-cli";
      rev = "v2.8.4";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "0frm9bjiw3aa7dd83gff4hn0dyy8nzww7vsax6s2dxxbb8r65hss";
    };
  };
  spicetify-themes = {
    pname = "spicetify-themes";
    version = "f6522b4eb26cf3fd012e35f886a9508ff6b2c19c";
    src = fetchgit {
      url = "https://github.com/morpheusthewhite/spicetify-themes";
      rev = "f6522b4eb26cf3fd012e35f886a9508ff6b2c19c";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "0xbijygfffb5hvprlf2pkbgyishsp4prglbn4zx97417904b9xmq";
    };
  };
  tmux-continuum = {
    pname = "tmux-continuum";
    version = "912149820bf48a3a128732854815009352dd2598";
    src = fetchgit {
      url = "https://github.com/tmux-plugins/tmux-continuum";
      rev = "912149820bf48a3a128732854815009352dd2598";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "178wzmj75mpylqdfrdashl27r5cg523wygg1pn88kdlj6nnlmck5";
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
    version = "3.13.10";
    src = fetchurl {
      url = "https://zhuangtongfa.gallery.vsassets.io/_apis/public/gallery/publisher/zhuangtongfa/extension/material-theme/3.13.10/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      sha256 = "1hjiv8dmrj5pj67fzvclx5z0zp9nr4pg44lfz43wliq3n8rzsgfy";
    };
    name = "material-theme";
    publisher = "zhuangtongfa";
  };
  vscode-extensions-remote-containers = {
    pname = "vscode-extensions-remote-containers";
    version = "0.210.1";
    src = fetchurl {
      url = "https://ms-vscode-remote.gallery.vsassets.io/_apis/public/gallery/publisher/ms-vscode-remote/extension/remote-containers/0.210.1/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      sha256 = "1nfdg7i9hq6vqqm723hzrh7v00fw4cgcq7ml10rgidsg4yv7xby4";
    };
    name = "remote-containers";
    publisher = "ms-vscode-remote";
  };
  vscode-extensions-remote-wsl = {
    pname = "vscode-extensions-remote-wsl";
    version = "0.63.13";
    src = fetchurl {
      url = "https://ms-vscode-remote.gallery.vsassets.io/_apis/public/gallery/publisher/ms-vscode-remote/extension/remote-wsl/0.63.13/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      sha256 = "06m5if4fmsjasj7p25whwwx4hr15ypwnwd8shpznxgb7mr869ix4";
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
