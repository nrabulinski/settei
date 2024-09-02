local wezterm = require 'wezterm'

local cfg = {
  color_scheme = 'Default Dark (base16)',
  enable_tab_bar = false,
  font = wezterm.font('IosevkaTerm Nerd Font'),
  window_decorations = 'TITLE | RESIZE',
  font_size = 10.5,
  native_macos_fullscreen_mode = true,
  hide_mouse_cursor_when_typing = false,
}

if string.find(wezterm.target_triple, "darwin") then
  cfg.font_size = 14.0
  cfg.window_decorations = 'RESIZE'
else
  cfg.front_end = "WebGpu"
end

return cfg
