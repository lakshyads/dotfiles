local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

local is_windows = os.getenv("OS") and os.getenv("OS"):lower():find("windows")
local is_macos = wezterm.target_triple:lower():find("darwin") ~= nil

config.color_scheme = "rose-pine-moon"
config.max_fps = 120
-- Matches configs/ghostty-config font choice for a consistent look across terminals.
config.font = wezterm.font("JetBrainsMono Nerd Font", { weight = "DemiBold" })
config.font_size = 14.0
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.window_frame = {
  font = wezterm.font("JetBrainsMono Nerd Font", { weight = "Bold" }),
}
config.inactive_pane_hsb = {
  saturation = 0.0,
  brightness = 0.5,
}

-- ---- Split navigation ----
-- Mirrors configs/ghostty-config's custom split keybinds for muscle-memory parity.
config.keys = {
  { key = "d", mods = "CMD", action = act.SplitPane({ direction = "Right" }) },
  { key = "d", mods = "CMD|SHIFT", action = act.SplitPane({ direction = "Down" }) },
  { key = "LeftArrow", mods = "CMD|ALT", action = act.ActivatePaneDirection("Left") },
  { key = "RightArrow", mods = "CMD|ALT", action = act.ActivatePaneDirection("Right") },
  { key = "UpArrow", mods = "CMD|ALT", action = act.ActivatePaneDirection("Up") },
  { key = "DownArrow", mods = "CMD|ALT", action = act.ActivatePaneDirection("Down") },
  { key = "f", mods = "CMD|SHIFT", action = act.TogglePaneZoomState },
}
-- Note: Ghostty's Cmd+Shift+E "equalize splits" has no WezTerm equivalent;
-- WezTerm has no built-in quake-style quick terminal either (would need Hammerspoon).

if is_windows then
  config.win32_system_backdrop = "Acrylic"
  config.window_background_opacity = 0.7
  config.window_frame.font_size = 10.0
end

if is_macos then
  config.window_background_opacity = 0.8
  config.macos_window_background_blur = 50
  config.window_frame.font_size = 13.0
end

return config
