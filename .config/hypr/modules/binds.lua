-- Keybindings
--
-- Legacy bind flag mapping:
--   bind  -> plain hl.bind(...)
--   binde -> hl.bind(..., { repeating = true }) (fires while held)
--   bindr -> hl.bind(..., { release = true })   (fires on key release)
--   bindm -> hl.bind(..., { mouse = true })     (drag with mouse button)

-- Keybind behavior
hl.config({
    binds = {
        allow_workspace_cycles = true,
    },
})

local mainMod     = "SUPER"
local terminal    = "ghostty"
local browser     = "zen-browser"
local menu        = "fuzzel"
local wallpaper   = "waypaper"
local fileManager = "thunar"
local editor      = "code"

local sysScript   = "~/.config/hypr/scripts/sys_info.sh"

-- Apps and window management
hl.bind(mainMod .. " + Return",    hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + E",         hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + Q",         hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exit())
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd("hyprlock -c ~/.config/hypr/hyprlock.conf"))
hl.bind(mainMod .. " + B",         hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + P",         hl.dsp.exec_cmd(browser .. " --private-window"))
hl.bind(mainMod .. " + Space",     hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + W",         hl.dsp.exec_cmd(wallpaper))
hl.bind(mainMod .. " + F",         hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + S",         hl.dsp.exec_cmd("signal-desktop"))
hl.bind(mainMod .. " + C",         hl.dsp.exec_cmd(editor))

-- Move focus (vim keys and arrows)
for _, m in ipairs({
    { key = "h",     dir = "left"  },
    { key = "l",     dir = "right" },
    { key = "k",     dir = "up"    },
    { key = "j",     dir = "down"  },
    { key = "left",  dir = "left"  },
    { key = "right", dir = "right" },
    { key = "up",    dir = "up"    },
    { key = "down",  dir = "down"  },
}) do
    hl.bind(mainMod .. " + " .. m.key, hl.dsp.focus({ direction = m.dir }))
end

-- Move/resize windows by dragging with SUPER + left/right mouse button
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Workspaces 1-5: SUPER switches, SUPER + SHIFT moves the active window
for i = 1, 5 do
    hl.bind(mainMod .. " + " .. i,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

-- Volume and screen brightness (OSD notifications via sys_info.sh)
for _, m in ipairs({
    { key = "XF86AudioRaiseVolume",  arg = "vol_up",      repeating = true },
    { key = "XF86AudioLowerVolume",  arg = "vol_down",    repeating = true },
    { key = "XF86AudioMute",         arg = "vol_mute" },
    { key = "XF86MonBrightnessUp",   arg = "bright_up",   repeating = true },
    { key = "XF86MonBrightnessDown", arg = "bright_down", repeating = true },
}) do
    hl.bind(m.key, hl.dsp.exec_cmd(sysScript .. " " .. m.arg), { repeating = m.repeating })
end

-- Caps Lock OSD (release flag so the reported state is already updated)
hl.bind("CAPS + Caps_Lock", hl.dsp.exec_cmd(sysScript .. " caps"), { release = true })

-- Screenshot: select a region and copy it to the clipboard
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh"))

-- Clipboard history
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("cliphist list | fuzzel -d -w 80 | cliphist decode | wl-copy"))

-- Toggle to the previously focused workspace
hl.bind(mainMod .. " + Tab", hl.dsp.focus({ workspace = "previous" }))

-- Voice to text (push-to-talk): start on press, stop on release
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("~/Codebase/Whisper/hyprvoice.sh start"))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("~/Codebase/Whisper/hyprvoice.sh stop"), { release = true })
