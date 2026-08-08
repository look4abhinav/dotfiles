-- Input
--
-- Keyboard layout, mouse focus behavior, touchpad settings, and the
-- touchpad workspace swipe (both its tuning values and the gesture itself).
hl.config({
    input = {
        kb_layout    = "us",
        follow_mouse = 1,
        sensitivity  = 0, -- -1.0 to 1.0, 0 means no modification

        touchpad = {
            natural_scroll = true,
        },
    },

    -- Workspace swipe tuning
    gestures = {
        workspace_swipe_invert             = true,
        workspace_swipe_distance           = 300,
        workspace_swipe_min_speed_to_force = 5,
    },
})

-- Switch workspaces with a 3-finger horizontal swipe
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
