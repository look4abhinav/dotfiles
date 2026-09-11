-- Environment variables
--
-- Exported to the Hyprland session and inherited by every launched app.

local vars = {
    { "XCURSOR_SIZE",                       "26" },
    { "HYPRCURSOR_SIZE",                    "26" },
    { "QT_QPA_PLATFORM",                    "wayland;xcb" },
    { "QT_QPA_PLATFORMTHEME",               "qt5ct" },
    { "QT_WAYLAND_DISABLE_WINDOWDECORATION", "1" },
    { "QT_AUTO_SCREEN_SCALE_FACTOR",        "1" },
    { "GDK_SCALE",                          "1" },
    { "GTK_THEME",                          "Adwaita:dark" },
    -- Expanded here because env values are not shell-expanded by the compositor.
}

local runtime = os.getenv("XDG_RUNTIME_DIR")
if runtime ~= nil and runtime ~= "" then
    hl.env("SSH_AUTH_SOCK", runtime .. "/ssh-agent.socket")
end

for _, v in ipairs(vars) do
    hl.env(v[1], v[2])
end
