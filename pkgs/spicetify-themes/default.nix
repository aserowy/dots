{ stdenv, sources }:
let
  theme = builtins.replaceStrings [ "#" ] [ "" ] ''
    [onedark]
    text               = #ccd0d8
    subtext            = #abb2bf
    sidebar-text       = #eeeff2
    main               = #282c34
    sidebar            = #23272e
    player             = #282c34
    card               = #282c34
    shadow             = #111317
    selected-row       = #828997
    button             = #61afef
    button-active      = #e06c75
    button-disabled    = #5c6370
    tab-active         = #61afef
    notification       = #98c379
    notification-error = #e06c75
    misc               = #ccd0d8
  '';
in
stdenv.mkDerivation {
  inherit (sources.spicetify-themes) pname version src;

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    cp -r . $out

    echo -e "\n\n${theme}" >> $out/Dribbblish/color.ini
  '';
}
