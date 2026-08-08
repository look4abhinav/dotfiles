-- Layer rules
--
-- Applies the glassmorphism blur to shell layers. All three layers get the
-- same treatment, so they are generated from a single list. This unifies
-- the two rule syntaxes the legacy config used (inline and block form).
for _, ns in ipairs({ "mako", "waybar", "fuzzel" }) do
    hl.layer_rule({
        name         = ns .. "_glass",
        match        = { namespace = ns },
        blur         = true,
        ignore_alpha = 0.1,
    })
end
