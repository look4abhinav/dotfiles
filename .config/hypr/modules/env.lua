-- Environment variables
--
-- Exported to the Hyprland session and inherited by every launched app.
-- Equivalent of the legacy `env = NAME,value` lines.

-- Wayland and Qt/GTK integration, plus cursor sizing.
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
    { "SSH_AUTH_SOCK",                      (os.getenv("XDG_RUNTIME_DIR") or "") .. "/ssh-agent.socket" },
}

for _, v in ipairs(vars) do
    hl.env(v[1], v[2])
end
