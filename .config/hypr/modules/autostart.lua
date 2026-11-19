-- Autostart
--
-- Programs spawned once when the session starts. The hyprland.start event
-- fires exactly once per session, so these are not re-run on config reload.
local programs = {
    "qs --no-duplicate",
    "mako",
    "waypaper --restore",
    "hypridle -c ~/.config/hypr/hypridle.conf",
    -- cliphist -max-items mirrors the daily prune cap in
    -- ~/.config/systemd/user/cliphist-prune.service; keep both in sync.
    "wl-paste --type text --watch cliphist store -max-items 500",
    "wl-paste --type image --watch cliphist store -max-items 500",
    "sh -c 'test -x /usr/lib/polkit-kde-authentication-agent-1 && exec /usr/lib/polkit-kde-authentication-agent-1'",
    "hyprctl setcursor Bibata-Modern-Ice 26",
    "kanshi",
}

hl.on("hyprland.start", function()
    for _, cmd in ipairs(programs) do
        hl.exec_cmd(cmd)
    end
end)
