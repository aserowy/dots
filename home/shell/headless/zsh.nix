{ config, pkgs, lib, ... }:
{
  imports = [
    ./direnv.nix
    ./fzf.nix
    ./starship.nix
    ./zoxide.nix
  ];

  home.packages = with pkgs; [
    exa
  ];

  programs = {
    direnv.enableZshIntegration = true;
    fzf.enableZshIntegration = true;
    starship.enableZshIntegration = true;
    zoxide.enableZshIntegration = true;

    zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      dotDir = ".config/zsh";
      envExtra = ''
        local nixos_version=`which nixos-version`
        if [[ ! -x "$nixos_version" ]]; then
          source ~/.nix-profile/etc/profile.d/nix.sh

          export fpath=(~/.nix-profile/share/zsh/vendor-completions ''${fpath})
          export NIX_PATH="$HOME/.nix-defexpr/channels:$NIX_PATH"
        fi
      '';
      history = {
        ignoreDups = true;
        save = 9999;
        share = true;
        size = 9999;
      };
      oh-my-zsh = {
        enable = true;
        plugins = [ "docker" "docker-compose" "rust" "ssh-agent" ];
      };
      plugins = [
        {
          name = "zsh-vi-mode";
          src = pkgs.fetchFromGitHub {
            owner = "jeffreytse";
            repo = "zsh-vi-mode";
            rev = "v0.8.4";
            sha256 = "0a1rvc03rl66v8rgzvxpq0vw55hxn5b9dkmhdqghvi2f4dvi8fzx";
          };
        }
        {
          name = "zsh-syntax-highlighting";
          src = pkgs.fetchFromGitHub {
            owner = "zsh-users";
            repo = "zsh-syntax-highlighting";
            rev = "0e1bb14452e3fc66dcc81531212e1061e02c1a61";
            sha256 = "09ncmyqlk9a3h470z0wgbkrznb5zyc9dj96011wm89rdxc1irxk2";
          };
        }
      ];
      sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };
      shellAliases = {
        fu = "fuck";
        ls = "exa";

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

        gsui = "git submodule update --init --recursive";
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

        tlb = "tmux list-buffers";
        tcb = "tmux choose-buffer";
      };
    };
  };
}
