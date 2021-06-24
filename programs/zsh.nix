{ config, pkgs, lib, ... }:
{
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    dotDir = ".config/zsh";
    history = {
      ignoreDups = true;
      save = 9999;
      share = true;
      size = 9999;
    };
    oh-my-zsh = {
      enable = true;
      plugins = [ "docker" "docker-compose" "git-auto-fetch" "ssh-agent" ];
    };
    plugins = [
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-syntax-highlighting";
          rev = "0e1bb14452e3fc66dcc81531212e1061e02c1a61";
          sha256 = lib.fakeSha256;
        };
      }
    ];
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
    shellAliases = {
      update = "sudo apt update && sudo apt -y upgrade";

      # string operations
      trim = "sed -e 's/^[[:space:]]*//g' -e 's/[[:space:]]*\$//g'";

      #cargo
      c = "cargo";
      ccy = "cargo clippy";
      cfmt = "cargo fmt";
      ct = "cargo test";
      cb = "cargo build";
      cbr = "cargo build --release";

      # git
      g = "git";

      gf = "git fetch";

      gcl = "git clone --recurse-submodules -j8";

      gco = "git checkout";
      gcob = "git checkout -b";

      gb = "git branch";
      gba = "git branch -a";
      gbd = "git branch -d";

      gpla = "git pull --autostash --rebase";

      gm = "git merge";
      gms = "git merge --squash";

      gsur = "git submodule update --remote --rebase";

      ga = "git add";
      gaa = "git add --all";

      gc = "git commit -v";
      gcsm = "git commit -s -m";

      gcp = "git cherry-pick";

      gt = "git tag";
      gta = "git tag -a";

      grsh = "git reset --hard";

      gp = "git push";
      gpdr = "git push --dry-run";
      gpod = "git push origin --delete";
      gpsu = "git push --set-upstream origin";
      gpt = "git push --tags";

      gst = "git status";

      gd = "git diff";

      # ls
      ll = "ls -l";
      la = "ls -a";
      lla = "ls -la";

      # mstsc
      # m() {
      #     param=$(echo "$1" | trim)
      #     echo "$param"
      #     if [ -z "$param" ]; then
      #         mstsc.exe &
      #     else
      #         mstsc.exe /v:"$param" &
      #     fi
      # }

      # nvim
      vim = "nvim";
      vimdiff = "nvim -d";

      # tmux
      t = "tmux";

      tl = "tmux ls";
      ts = "tmux new -s";
      ta = "tmux attach -t";
      tad = "tmux attach -d -t";
      tksv = "tmux kill-server";
      tkss = "tmux kill-session -t";
      trss = "tmux rename-session";
    };
  };
}
