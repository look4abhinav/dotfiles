-- Layer rules
--
-- Glassmorphism blur on shell layers, generated from a single list.
for _, ns in ipairs({ "mako", "waybar", "fuzzel" }) do
    hl.layer_rule({
        name         = ns .. "_glass",
        match        = { namespace = ns },
        blur         = true,
        ignore_alpha = 0.1,
    })
end
