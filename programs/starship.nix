{ config, lib, pkgs, ... }:
{
  home.file.".config/starship.toml".text = ''
    # settings
    [directory]
    format = " [$path]($style)[$read_only]($read_only_style) "
    read_only = " "

    [git_status]
    format = "[$all_status$ahead_behind]($style)"

    ahead = "[⇡$count](green) "
    behind = "[⇣$count](red) "
    diverged = "[⇡$ahead_count](green)[⇣$behind_count](red) "

    conflicted = "[~$count](red) "
    deleted = "[-$count](yellow) "
    modified = "[!$count](yellow) "
    renamed = "[>$count](yellow) "
    staged = "[+$count](green) "
    stashed = "[*$count](blue) "
    untracked = "[?$count](blue) "

    [time]
    disabled = false
    format = "[$time ]($style)"
    time_format = "%T"

    # customs
    [custom.gitautofetch]
    description = "Display status of ohmyzsh git-auto-fetch plugin"
    # guard from https://github.com/ohmyzsh/ohmyzsh/blob/706b2f3765d41bee2853b17724888d1a3f6f00d9/plugins/git-auto-fetch/git-auto-fetch.plugin.zsh#L37
    command = """
    if [[ -f "$(command git rev-parse --git-dir)/NO_AUTO_FETCH" ]]; then
        printf ""
    else
        printf " "
    fi
    """
    style = "red"
    shell = ["bash","--norc","--noprofile"]
    when = "git rev-parse --is-inside-work-tree 2> /dev/null"

    [custom.giturl]
    description = "Display symbol for remote Git server"
    command = """
    GIT_REMOTE=$(command git ls-remote --get-url 2> /dev/null)

    if [[ "$GIT_REMOTE" =~ "azure" ]]; then
        GIT_REMOTE_SYMBOL="ﴃ "
    elif [[ "$GIT_REMOTE" =~ "bitbucket" ]]; then
        GIT_REMOTE_SYMBOL=" "
    elif [[ "$GIT_REMOTE" =~ "github" ]]; then
        GIT_REMOTE_SYMBOL=" "
    elif [[ "$GIT_REMOTE" =~ "gitlab" ]]; then
        GIT_REMOTE_SYMBOL=" "
    elif [[ "$GIT_REMOTE" =~ "git" ]]; then
        GIT_REMOTE_SYMBOL=" "
    else
        GIT_REMOTE_SYMBOL=" "
    fi
    printf "$GIT_REMOTE_SYMBOL"
    """
    format = "at [$output](bright-white) "
    shell = ["bash","--norc","--noprofile"]
    when = "git rev-parse --is-inside-work-tree 2> /dev/null"

    # symbols
    [aws]
    symbol = "  "

    [conda]
    symbol = " "

    [dart]
    symbol = " "

    [docker_context]
    symbol = " "

    [dotnet]
    format = "[$symbol($version )(什 $tfm)]($style)"
    symbol = ".net "

    [elixir]
    symbol = " "

    [elm]
    symbol = " "

    [git_branch]
    symbol = " "

    [golang]
    symbol = " "

    [hg_branch]
    symbol = " "

    [java]
    symbol = " "

    [julia]
    symbol = " "

    [lua]
    symbol = " "

    [memory_usage]
    symbol = " "

    [nim]
    symbol = " "

    [nix_shell]
    symbol = " "

    [package]
    symbol = " "

    [perl]
    symbol = " "

    [php]
    symbol = " "

    [python]
    symbol = " "

    [ruby]
    symbol = " "

    [rust]
    symbol = " "

    [scala]
    symbol = " "

    [swift]
    symbol = "ﯣ "
  '';
  
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };
}
