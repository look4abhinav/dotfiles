-- Look and feel
--
-- Gaps, borders, layout, window decoration (rounding, opacity, shadow,
-- glassmorphism blur), and all animation curves and rules.
hl.config({
    general = {
        gaps_in     = 1,
        gaps_out    = 0,
        border_size = 2,

        col = {
            -- Animated cyan-to-green gradient on the active window border
            active_border   = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },

        layout = "dwindle",
    },

    decoration = {
        rounding           = 12,

        -- Transparency
        active_opacity     = 0.90,
        inactive_opacity   = 0.80,
        fullscreen_opacity = 1.0,

        -- Glow effect
        shadow = {
            enabled        = true,
            range          = 12,
            render_power   = 2,
            color          = "rgba(33ccff55)",
            color_inactive = "rgba(00000033)",
        },

        -- Glassmorphism blur
        blur = {
            enabled        = true,
            size           = 5,
            passes         = 2,
            ignore_opacity = true,
            vibrancy       = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    misc = {
        focus_on_activate = true,
    },
})

-- Custom bezier curves. These must be defined before the animations that
-- reference them. ("liner" is spelled as in the legacy config.)
hl.curve("easeOutQuint",   { type = "bezier", points = { { 0.23, 1 },    { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("liner",          { type = "bezier", points = { { 1, 1 },       { 1, 1 } } })

-- Smooth, fast, zero-bounce animation rules.
local animations = {
    { leaf = "windows",     speed = 4,  bezier = "easeOutQuint",   style = "slide" },
    { leaf = "windowsIn",   speed = 4,  bezier = "easeOutQuint",   style = "slide" },
    { leaf = "windowsOut",  speed = 4,  bezier = "easeOutQuint",   style = "slide" },
    { leaf = "windowsMove", speed = 4,  bezier = "easeInOutCubic", style = "slide" },
    { leaf = "border",      speed = 1,  bezier = "liner" },
    { leaf = "borderangle", speed = 30, bezier = "liner",          style = "loop" },
    { leaf = "fade",        speed = 3,  bezier = "default" },
    { leaf = "workspaces",  speed = 4,  bezier = "easeOutQuint",   style = "slide" },
}

for _, anim in ipairs(animations) do
    anim.enabled = true
    hl.animation(anim)
end
