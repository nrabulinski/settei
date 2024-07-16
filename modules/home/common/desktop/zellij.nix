{ inputs', ... }:
{
  # TODO: Move zellij to a wrapper
  programs.zellij = {
    enable = true;
    settings = {
      keybinds = {
        shared_except = {
          _args = [ "locked" ];
          unbind = "Ctrl q";
        };
      };
    };
  };

  xdg.configFile."zellij/layouts/compacter.kdl".text = ''
    layout {
      default_tab_template {
        children
        pane size=1 borderless=true {
          plugin location="file:${inputs'.zjstatus.packages.default}/bin/zjstatus.wasm" {
            hide_frame_for_single_pane "false"

            format_left  "{mode}#[fg=fg,bg=bg,bold] {session}#[bg=bg] {tabs}"
            format_right "#[fg=#424554,bg=bg]::{datetime}"
            format_space "#[bg=bg]"

            mode_normal          "#[bg=green] "
            mode_locked          "#[bg=magenta] "
            mode_tab             "#[bg=blue] "
            mode_tmux            "#[bg=red] "
            mode_default_to_mode "tmux"

            tab_normal               "#[fg=#6C7086,bg=bg] {index} {name} {fullscreen_indicator}{sync_indicator}{floating_indicator}"
            tab_active               "#[fg=#9399B2,bg=bg,bold,italic] {index} {name} {fullscreen_indicator}{sync_indicator}{floating_indicator}"
            tab_fullscreen_indicator "□ "
            tab_sync_indicator       "  "
            tab_floating_indicator   "󰉈 "

            datetime          "#[fg=#9399B2,bg=bg] {format} "
            datetime_format   "%A, %d %b %Y %H:%M"
            datetime_timezone "Europe/Warsaw"
          }
        }
      }

      swap_tiled_layout name="vertical" {
        tab max_panes=4 {
          pane split_direction="vertical" {
            pane
            pane { children; }
          }
        }
        tab max_panes=7 {
          pane split_direction="vertical" {
            pane { children; }
            pane { pane; pane; pane; pane; }
          }
        }
        tab max_panes=11 {
          pane split_direction="vertical" {
            pane { children; }
            pane { pane; pane; pane; pane; }
            pane { pane; pane; pane; pane; }
          }
        }
      }

      swap_tiled_layout name="horizontal" {
        tab max_panes=3 {
          pane
          pane
        }
        tab max_panes=7 {
          pane {
            pane split_direction="vertical" { children; }
            pane split_direction="vertical" { pane; pane; pane; pane; }
          }
        }
        tab max_panes=11 {
          pane {
            pane split_direction="vertical" { children; }
            pane split_direction="vertical" { pane; pane; pane; pane; }
            pane split_direction="vertical" { pane; pane; pane; pane; }
          }
        }
      }

      swap_tiled_layout name="stacked" {
        tab min_panes=4 {
          pane split_direction="vertical" {
            pane
            pane stacked=true { children; }
          }
        }
      }
    }
  '';
}
