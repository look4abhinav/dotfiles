-- Layer rules
--
-- Glassmorphism blur on shell layers, generated from a single list.
for _, namespace in ipairs({
    "notifications",
    "logout_dialog",
    "launcher",
    "clipboard",
    "quickshell",
}) do
    hl.layer_rule({
        name = namespace .. "_glass",
        match = { namespace = namespace },
        blur = true,
        ignore_alpha = 0.1,
    })
end

-- Keep settings dialogs out of the tiling layout.
hl.window_rule({
    name = "float-pavucontrol",
    match = { class = "org.pulseaudio.pavucontrol" },
    float = true,
})
hl.window_rule({
    name = "float-waypaper",
    match = { class = "waypaper" },
    float = true,
})
