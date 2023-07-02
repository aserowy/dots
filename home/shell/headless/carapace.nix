{ pkgs, ... }: with builtins;
let
  aliases = ''
    alias gfe = git fetch
    alias gfea = git fetch --all
    alias gcl = git clone --recurse-submodules -j8
    alias gco = git checkout
    alias gbr = git branch
    alias gpl = git pull --autostash --rebase
    alias gada = git add --all
    alias gcm = git commit -s -m
    alias grs = git reset
    alias gpu = git push
    alias gst = git status
    alias gdf = git diff
  '';

  string_filter = x: isString x && x != "";
  splat = str: list: filter string_filter (split str list);

  lines = splat "\n" aliases;

  into_spec = line:
    let
      parts = splat " = " line;
      alias = elemAt (splat " " (elemAt parts 0)) 1;
      cmd = splat " " (elemAt parts 1);
    in
    {
      ".config/carapace/specs/${alias}.yaml".text =
        ''
          name: ${alias}
          description: ${concatStringsSep " " cmd}
          group: ${elemAt cmd 0}
          run: "[${concatStringsSep ", " cmd}]"
        '';
    };

  specs = foldl' (acc: x: acc // x) { } (map into_spec lines);
in
{
  home = {
    packages = with pkgs; [
      carapace
    ];
    file = { } // specs;
  };
}
