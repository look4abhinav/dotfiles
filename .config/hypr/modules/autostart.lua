-- Autostart
--
-- Programs spawned once when the Hyprland session starts.
-- Equivalent of the legacy `exec-once` lines: the hyprland.start event
-- fires exactly once per session, so these are not re-run on config reload.
local programs = {
    "waybar",                                       -- status bar
    "mako",                                         -- notification daemon
    "waypaper --restore",                           -- restore last wallpaper
    "hypridle -c ~/.config/hypr/hypridle.conf",     -- idle daemon (lock/suspend timers)
    "wl-paste --type text --watch cliphist store",  -- clipboard history: text
    "wl-paste --type image --watch cliphist store", -- clipboard history: images
    "/usr/lib/polkit-kde-authentication-agent-1",   -- polkit authentication agent
    "hyprctl setcursor Bibata-Modern-Ice 26",       -- cursor theme
    "kanshi",                                       -- monitor profile daemon
}

hl.on("hyprland.start", function()
    for _, cmd in ipairs(programs) do
        hl.exec_cmd(cmd)
    end
end)
