-- Hyprland Lua configuration. Entry point only loads modules, each file
-- in modules/ owns one section. hyprland-gui.lua is managed by HyprMod.

require("modules.monitors")   -- display outputs
require("modules.env")        -- environment variables
require("modules.autostart")  -- programs started with the session
require("modules.input")      -- keyboard, touchpad, gestures
require("modules.look")       -- general UI, decoration, animations
require("modules.rules")      -- layer rules
require("modules.binds")      -- keybindings

-- HyprMod managed settings
require("hyprland-gui")
