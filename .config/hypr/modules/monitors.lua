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

-- The kernel zeroes intel_backlight when eDP-1 is disabled at the KMS level
-- (e.g. by kanshi's docked profile). Save the current brightness before that
-- happens and restore it when the external monitor goes away.
local brightnessFile = "/tmp/kanshi-brightness"

hl.on("monitor.added", function()
    hl.exec_cmd("sh -c 'brightnessctl -q get > " .. brightnessFile .. "'")
end)

hl.on("monitor.removed", function()
    hl.exec_cmd("sh -c 'brightnessctl -q set $(cat " .. brightnessFile .. " 2>/dev/null) 2>/dev/null || brightnessctl -q set 50%'")
end)
