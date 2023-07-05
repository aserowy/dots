{ pkgs, ... }: with builtins;
let
  aliases = ''
    alias gad = git add
    alias gada = git add --all
    alias gbr = git branch
    alias gcl = git clone --recurse-submodules -j8
    alias gco = git checkout
    alias gcm = git commit -s -m
    alias gdf = git diff
    alias gfe = git fetch
    alias gfea = git fetch --all
    alias gmg = git merge
    alias gpl = git pull --autostash --rebase
    alias gpu = git push
    alias gput = git push --tags
    alias grs = git reset
    alias gst = git status
    alias gta = git tag
    alias gtam = git tag -a -m
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
