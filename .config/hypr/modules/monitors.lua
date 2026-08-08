-- Monitors
--
-- Single catch-all rule: any display, preferred mode, auto position, scale 1.
-- kanshi (see modules/autostart.lua) applies the real per-display profiles
-- at runtime, so no per-monitor rules are needed here.
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "1",
})
