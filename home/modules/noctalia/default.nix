{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cnfg = config.home.modules.noctalia;
in
{
  options.home.modules.noctalia = {
    enable = mkEnableOption "noctalia";

    prependedConfig = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Extra commands that are prepended to noctalias niri config.
      '';
    };
  };

  config =
    let
      niriConfig = builtins.readFile ./config.kdl;
    in
    mkIf cnfg.enable {
      home = {
        components = {
          brave = {
            enable = true;
            enableXdgAssociations = true;
            setDefaultBrowserSessionVariable = true;
          };

          ghostty.enable = true;
        };

        file = {
          ".config/niri/config.kdl".source = builtins.toFile "niri-config" ''
            ${cnfg.prependedConfig}

            ${niriConfig}
          '';
        };

        packages = with pkgs; [
          niri

          (pkgs.writeShellScriptBin "outputshot" ''
            niri msg action screenshot-screen
          '')
          (pkgs.writeShellScriptBin "screenshot" ''
            niri msg action screenshot
          '')
          (pkgs.writeShellScriptBin "windowshot" ''
            niri msg action screenshot-window
          '')
        ];

        sessionVariables = {
          XDG_CURRENT_DESKTOP = "niri";
          XDG_SESSION_DESKTOP = "niri";
          XDG_SESSION_TYPE = "wayland";
        };
      };

      programs.noctalia-shell = {
        enable = true;
        systemd.enable = true;

        settings = {
          settingsVersion = 0;
          bar = {
            position = "left";
            monitors = [ "DP-2" ];
            showCapsule = true;
            backgroundOpacity = 0;
            useSeparateOpacity = true;
            floating = true;
            widgets = {
              left = [
                {
                  colorizeDistroLogo = false;
                  colorizeSystemIcon = "none";
                  customIconPath = "";
                  enableColorization = false;
                  icon = "niri";
                  id = "ControlCenter";
                  useDistroLogo = false;
                }
                {
                  hideWhenZero = false;
                  id = "NotificationHistory";
                  showUnreadBadge = true;
                }
              ];
              center = [
                {
                  id = "Workspace";
                  followFocusedScreen = true;
                }
              ];
              right = [
                {
                  displayMode = "onhover";
                  id = "KeyboardLayout";
                  showIcon = true;
                }
                {
                  displayMode = "onhover";
                  id = "Volume";
                }
                {
                  id = "plugin:network-indicator";
                }
                {
                  blacklist = [
                  ];
                  colorizeIcons = false;
                  drawerEnabled = true;
                  hidePassive = false;
                  id = "Tray";
                  pinned = [
                  ];
                }
                {
                  id = "Spacer";
                  width = 20;
                }
                {
                  customFont = "JetBrainsMono Nerd Font Mono";
                  formatHorizontal = "HH:mm ddd, MMM dd";
                  formatVertical = "HH mm";
                  id = "Clock";
                  tooltipFormat = "HH:mm ddd, MMM dd";
                  useCustomFont = true;
                  usePrimaryColor = false;
                }
              ];
            };
          };
          general = {
            avatarImage = "/home/serowy/.face";
            dimmerOpacity = 0.75;
            radiusRatio = 0.25;
            iRadiusRatio = 0.5;
            compactLockScreen = true;
          };
          ui = {
            fontDefault = "Inter Variable";
            fontFixed = "JetBrainsMono Nerd Font Mono";
            panelBackgroundOpacity = 0.4;
            settingsPanelMode = "centered";
          };
          location = {
            name = "Drensteinfurt, Germany";
            weatherShowEffects = false;
            showCalendarWeather = false;
            firstDayOfWeek = 1;
          };
          calendar = {
            cards = [
              {
                enabled = true;
                id = "calendar-header-card";
              }
              {
                enabled = true;
                id = "calendar-month-card";
              }
              {
                enabled = true;
                id = "timer-card";
              }
            ];
          };
          screenRecorder = {
            directory = "/home/serowy/videos/";
          };
          wallpaper = {
            enabled = true;
            directory = "/home/serowy/onedrive/Wallpapers";
            randomEnabled = true;
            randomIntervalSec = 7200;
            transitionType = "fade";
            panelPosition = "center";
          };
          appLauncher = {
            terminalCommand = "ghostty -e";
          };
          controlCenter = {
            position = "center";
            shortcuts = {
              left = [
                {
                  id = "ScreenRecorder";
                }
                {
                  id = "WallpaperSelector";
                }
              ];
              right = [
                {
                  id = "Notifications";
                }
                {
                  id = "KeepAwake";
                }
                {
                  id = "NightLight";
                }
              ];
            };
            cards = [
              {
                enabled = true;
                id = "profile-card";
              }
              {
                enabled = true;
                id = "shortcuts-card";
              }
              {
                enabled = true;
                id = "audio-card";
              }
              {
                enabled = false;
                id = "brightness-card";
              }
              {
                enabled = true;
                id = "media-sysmon-card";
              }
            ];
          };
          dock.enabled = false;
          sessionMenu = {
            largeButtonsStyle = true;
            powerOptions = [
              {
                action = "lock";
                enabled = true;
              }
              {
                action = "suspend";
                enabled = true;
              }
              {
                action = "hibernate";
                enabled = true;
              }
              {
                action = "reboot";
                enabled = true;
              }
              {
                action = "logout";
                enabled = true;
              }
              {
                action = "shutdown";
                enabled = true;
              }
            ];
          };
          notifications = {
            monitors = [ "HDMI-A-1" ];
            saveToHistory.low = false;
          };
          audio.preferredPlayer = "spotify";
          colorSchemes = {
            predefinedScheme = "Catppuccin-Lavender";
            schedulingMode = "location";
          };
          templates = {
            enableUserTemplates = false;

            gtk = true;
            qt = true;
            kcolorscheme = true;
            niri = true;
          };
          desktopWidgets = {
            enabled = true;
            gridSnap = true;
            monitorWidgets = [
              {
                name = "DP-2";
                widgets = [ ];
              }
              {
                name = "HDMI-A-1";
                widgets = [
                  {
                    clockStyle = "analog";
                    customFont = "";
                    format = "HH:mm\\nd MMMM yyyy";
                    id = "Clock";
                    roundedCorners = true;
                    showBackground = true;
                    useCustomFont = false;
                    usePrimaryColor = false;
                    x = 40;
                    y = 40;
                  }
                  {
                    hideMode = "visible";
                    id = "MediaPlayer";
                    roundedCorners = true;
                    showAlbumArt = true;
                    showBackground = true;
                    showButtons = true;
                    showVisualizer = true;
                    visualizerType = "linear";
                    x = 40;
                    y = 220;
                  }
                  {
                    id = "Weather";
                    showBackground = true;
                    x = 40;
                    y = 320;
                  }
                ];
              }
            ];
          };
        };
      };
    };
}
