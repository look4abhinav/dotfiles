-- Monitors
--
-- Single catch-all rule: any display, preferred mode, auto position, scale 1.
-- Docking (disable laptop panel, move workspaces, save/restore brightness)
-- lives in kanshi profiles plus hypr/scripts/dock.sh, so this file stays
-- identical on all machines.
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "1",
})
