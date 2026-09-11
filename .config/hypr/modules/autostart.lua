-- Autostart
--
-- Programs spawned once when the session starts. The hyprland.start event
-- fires exactly once per session, so these are not re-run on config reload.
local programs = {
    "waybar",
    "mako",
    "waypaper --restore",
    "hypridle -c ~/.config/hypr/hypridle.conf",
    "wl-paste --type text --watch cliphist store",
    "wl-paste --type image --watch cliphist store",
    "sh -c 'test -x /usr/lib/polkit-kde-authentication-agent-1 && exec /usr/lib/polkit-kde-authentication-agent-1'",
    "hyprctl setcursor Bibata-Modern-Ice 26",
    "kanshi",
}

hl.on("hyprland.start", function()
    for _, cmd in ipairs(programs) do
        hl.exec_cmd(cmd)
    end
end)
