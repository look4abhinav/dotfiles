-- Layer rules
--
-- Glassmorphism blur on shell layers, generated from a single list.
for _, namespace in ipairs({
    "notifications",
    "logout_dialog",
    "launcher",
    "clipboard",
    "waybar",
}) do
    hl.layer_rule({
        name         = namespace .. "_glass",
        match        = { namespace = namespace },
        blur         = true,
        ignore_alpha = 0.1,
    })
end
