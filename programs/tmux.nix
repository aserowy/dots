{ config, pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    aggressiveResize = true;
    baseIndex = 1;
    clock24 = true;
    escapeTime = 0;
    historyLimit = 5000;
    keyMode = "vi";
    prefix = "C-t";
    sensibleOnTop = false;
    terminal = "tmux-256color";
    extraConfig = ''
      # terminal
      set -ga terminal-overrides ",xterm*:TC"
      setw -g xterm-keys on

      # controls
      set -g mouse on

      # title handling
      setw -g automatic-rename on
      set -g set-titles on

      # activity
      setw -g monitor-activity off
      set -g visual-activity off
      set -g visual-bell off

      # misc
      set -g display-time 4000
      set -s focus-events on

      ##### THEMING
      set -g window-style default
      set -g status-style bg=default

      set -g status-left "\
      #[fg=green, bg=default]#{?client_prefix,#[fg=red],}   #S \
      #[fg=brightblack, bg=default]|"

      set -g window-status-separator "|"
      set -g window-status-current-format "#[fg=brightwhite,bg=brightblack]  #W "
      set -g window-status-format "#[fg=brightblack,bg=default]  #W "

      set -g status-right "\
      #{battery_color_charge_fg} #{battery_icon_charge}\
      #[fg=brightblack, bg=default] |\
      #[fg=yellow]  #{continuum_status}\
      #[fg=brightblack, bg=default] |\
      #[fg=green]  %R\
      #[fg=green] %F"

      ##### BINDINGS
      # windows
      bind C-p previous-window
      bind C-n next-window

      # panes
      unbind '"'
      bind x split-window -v -c "#{pane_current_path}"

      unbind %
      bind v split-window -h -c "#{pane_current_path}"

      is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"

      bind-key -n "C-h" if-shell "$is_vim" "send-keys C-h" { if -F "#{pane_at_left}" "" "select-pane -L" }
      bind-key -n "C-j" if-shell "$is_vim" "send-keys C-j" { if -F "#{pane_at_bottom}" "" "select-pane -D" }
      bind-key -n "C-k" if-shell "$is_vim" "send-keys C-k" { if -F "#{pane_at_top}" "" "select-pane -U" }
      bind-key -n "C-l" if-shell "$is_vim" "send-keys C-l" { if -F "#{pane_at_right}" "" "select-pane -R" }

      bind-key -T copy-mode-vi "C-h" if -F "#{pane_at_left}" "" "select-pane -L"
      bind-key -T copy-mode-vi "C-j" if -F "#{pane_at_bottom}" "" "select-pane -D"
      bind-key -T copy-mode-vi "C-k" if -F "#{pane_at_top}" "" "select-pane -U"
      bind-key -T copy-mode-vi "C-l" if -F "#{pane_at_right}" "" "select-pane -R"

      bind -n "M-h" if-shell "$is_vim" "send-keys M-h" "resize-pane -L 1"
      bind -n "M-j" if-shell "$is_vim" "send-keys M-j" "resize-pane -D 1"
      bind -n "M-k" if-shell "$is_vim" "send-keys M-k" "resize-pane -U 1"
      bind -n "M-l" if-shell "$is_vim" "send-keys M-l" "resize-pane -R 1"

      bind-key -T copy-mode-vi M-h resize-pane -L 1
      bind-key -T copy-mode-vi M-j resize-pane -D 1
      bind-key -T copy-mode-vi M-k resize-pane -U 1
      bind-key -T copy-mode-vi M-l resize-pane -R 1

      # selection mode
      bind-key -T copy-mode-vi "v" send -X begin-selection
      bind-key -T copy-mode-vi "V" send -X select-line

      # yank
      bind-key -T copy-mode-vi "y" send -X copy-selection-and-cancel
      bind-key -T copy-mode-vi "r" send -X rectangle-toggle

      # search
      bind-key / copy-mode \; send-key ?
    '';
    plugins = with pkgs; [
      {
        plugin = tmuxPlugins.battery;
        extraConfig = ''
          set -g @batt_icon_charge_tier8 ' '
          set -g @batt_icon_charge_tier7 ' '
          set -g @batt_icon_charge_tier6 ' '
          set -g @batt_icon_charge_tier5 ' '
          set -g @batt_icon_charge_tier4 ' '
          set -g @batt_icon_charge_tier3 ' '
          set -g @batt_icon_charge_tier2 ' '
          set -g @batt_icon_charge_tier1 ' '
          set -g @batt_color_charge_primary_tier8 'green'
          set -g @batt_color_charge_primary_tier7 'green'
          set -g @batt_color_charge_primary_tier6 'green'
          set -g @batt_color_charge_primary_tier5 'yellow'
          set -g @batt_color_charge_primary_tier4 'yellow'
          set -g @batt_color_charge_primary_tier3 'yellow'
          set -g @batt_color_charge_primary_tier2 'red'
          set -g @batt_color_charge_primary_tier1 'red'
          set -g @batt_color_charge_secondary_tier8 'default'
          set -g @batt_color_charge_secondary_tier7 'default'
          set -g @batt_color_charge_secondary_tier6 'default'
          set -g @batt_color_charge_secondary_tier5 'default'
          set -g @batt_color_charge_secondary_tier4 'default'
          set -g @batt_color_charge_secondary_tier3 'default'
          set -g @batt_color_charge_secondary_tier2 'default'
          set -g @batt_color_charge_secondary_tier1 'default'
        '';
      }
      {
        plugin = tmuxPlugins.resurrect;
        extraConfig = ''
          set -g @resurrect-capture-pane-contents 'on'
          set -g @resurrect-strategy-nvim 'session'
        '';
      }
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '5' # minutes
        '';
      }
    ];
  };
}

