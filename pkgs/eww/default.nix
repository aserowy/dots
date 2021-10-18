# https://github.com/danielphan2003/flk/blob/cd3e6246e75b54822397f02d85848e6e4a39d3fd/pkgs/applications/misc/eww/default.nix
{ lib
, sources
, makeRustPlatform
, wrapGAppsHook
, pkg-config
, gtk3
, cairo
, glib
, atk
, pango
, gdk-pixbuf
, wayland
, wayland-protocols
, gtk-layer-shell
  #, enableWayland ? false
}:

makeRustPlatform.buildRustPackage {
  inherit (sources.eww) pname version src cargoLock;

  cargoBuildFlags = with lib; [
    "--no-default-features"
    "--features=wayland"
    #(optionalString enableWayland "--features=wayland")
  ];

  nativeBuildInputs = [ wrapGAppsHook pkg-config ];

  buildInputs = [
    gtk3
    cairo
    glib
    atk
    pango
    gdk-pixbuf
    gtk-layer-shell
    wayland
    wayland-protocols
  ]
    #++ (lib.optionals enableWayland [ wayland wayland-protocols ]);
  ;

  doCheck = false;

  meta = with lib; {
    description = "A standalone widget system made in Rust to add AwesomeWM like widgets to any WM";
    homepage = "https://github.com/elkowar/eww";
    license = licenses.mit;
    maintainers = with maintainers; [ fortuneteller2k danielphan2003 ];
  };
}
