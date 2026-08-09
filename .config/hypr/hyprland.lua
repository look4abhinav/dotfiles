-- ============================================================================
-- Hyprland Lua configuration (migrated from hyprland.conf)
--
-- Hyprland loads hyprland.lua instead of hyprland.conf when both exist.
-- Deleting this file instantly restores the legacy config, which is kept
-- untouched as a fallback.
--
-- Structure: this entry point only loads modules. Each file in modules/
-- owns one logical section of the old hyprland.conf.
-- ============================================================================

require("modules.monitors")   -- display outputs
require("modules.env")        -- environment variables
require("modules.autostart")  -- programs started with the session
require("modules.input")      -- keyboard, touchpad, gestures
require("modules.look")       -- general UI, decoration, animations
require("modules.rules")      -- layer rules
require("modules.binds")      -- keybindings

-- HyprMod managed settings
require("hyprland-gui")
