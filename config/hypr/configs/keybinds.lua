---------------------
-- KEYBINDINGS
---------------------

local M = "SUPER"

local bind = hl.bind
local dsp = hl.dsp

local global = dsp.global
local exec = dsp.exec_cmd
local focus = dsp.focus
local win = dsp.window
local ws = dsp.workspace

local tp = false

---------------------
-- CAELESTIA
---------------------

bind(M .. "+A", global("caelestia:showall"))
bind(M .. "+N", global("caelestia:sidebar"))
bind(M .. "+D", global("caelestia:dashboard"))
bind(M .. "+R", exec("qs -c caelestia kill; caelestia shell -d"))
bind(M .. "+V", exec("caelestia clipboard"))
bind(M .. "+SHIFT+V", exec("cliphist wipe"))
bind(M .. "+ESCAPE", global("caelestia:session"))

bind(M .. "+SHIFT+E", exec("caelestia emoji -p"))
bind(M .. "+SHIFT+C", exec("hyprpicker -a"))

bind(M .. "+SUPER_L", global("caelestia:launcher"), { release = true })
bind(M .. "+SHIFT+N", global("caelestia:clearNotifs"))

bind("CTRL+ALT+L", global("caelestia:lock"))

---------------------
-- APPS / WINDOWS
---------------------

bind(M .. "+T", exec("kitty"))
bind(M .. "+F", exec("thunar"))

bind(M .. "+Q", win.close())
bind(M .. "+P", win.pin())

bind(M .. "+SHIFT+F", win.float({ action = "toggle" }))
bind(M .. "+M", win.fullscreen({ mode = "maximized", action = "toggle" }))
bind(M .. "+SHIFT+M", win.fullscreen({ mode = "fullscreen", action = "toggle" }))

bind("ALT+TAB", win.cycle_next({}))

---------------------
-- FOCUS (HJKL)
---------------------

local directions = {
    h = "left",
    j = "down",
    k = "up",
    l = "right",
}

for key, dir in pairs(directions) do
    bind(M .. "+" .. key, focus({ direction = dir }))
    bind(M .. "+SHIFT+" .. key, win.move({ direction = dir }))
end

---------------------
-- WORKSPACES
---------------------

for i = 1, 10 do
    local key = tostring(i % 10)

    bind(M .. "+" .. key, focus({ workspace = i }))
    bind(M .. "+CTRL+" .. key, win.move({ workspace = i }))
    bind(M .. "+SHIFT+" .. key, win.move({ workspace = i, follow = false }))
end

bind(M .. "+TAB", focus({ workspace = "e+1" }))
bind(M .. "+SHIFT+TAB", focus({ workspace = "e-1" }))
bind(M .. "+mouse_up", focus({ workspace = "e+1" }))
bind(M .. "+mouse_down", focus({ workspace = "e-1" }))

---------------------
-- WINDOW RESIZE
---------------------

local resize_map = {
    ["CTRL+l"] = { x = 40, y = 0 },
    ["CTRL+h"] = { x = -40, y = 0 },
    ["CTRL+j"] = { x = 0, y = 40 },
    ["CTRL+k"] = { x = 0, y = -40 },
}

for key, delta in pairs(resize_map) do
    bind(
        M .. "+" .. key,
        win.resize({
            x = delta.x,
            y = delta.y,
            relative = true,
        }),
        { repeating = true }
    )
end

---------------------
-- MOUSE
---------------------

bind(M .. "+mouse:272", win.drag(), { mouse = true })
bind(M .. "+mouse:273", win.resize(), { mouse = true })

---------------------
-- SPECIAL WORKSPACE
---------------------

bind(M .. "+U", ws.toggle_special("Scratchpad"))
bind(M .. "+SHIFT+U", win.move({ workspace = "special:magic" }))
bind(M .. "+CTRL+U", win.move({ workspace = "e+0" }))

---------------------
-- MEDIA / LAPTOP KEYS
---------------------

bind("XF86TouchpadToggle", function()
    tp = not tp
    hl.device({ name = "elan1203:00-04f3:307a-touchpad", enabled = tp })
    os.execute("notify-send 'Touchpad' '" .. (tp and "ENABLED" or "DISABLED") .. "'")
end)

bind("XF86MonBrightnessUp", global("caelestia:brightnessUp"), { repeating = true })
bind("XF86MonBrightnessDown", global("caelestia:brightnessDown"), { repeating = true })

bind("XF86AudioMute", exec("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
bind("XF86AudioMicMute", exec("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })

bind("XF86AudioRaiseVolume", exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true, locked = true })
bind("XF86AudioLowerVolume", exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true, locked = true })

---------------------
-- SCREENSHOT
---------------------

bind("Print", exec("caelestia screenshot"))
bind(M .. "+SHIFT+S", global("caelestia:screenshot"))

---------------------
-- MEDIA CONTROL
---------------------

bind("XF86AudioPlay", global("caelestia:mediaToggle"), { locked = true })
bind("XF86AudioPrev", global("caelestia:mediaPrev"), { locked = true })
bind("XF86AudioNext", global("caelestia:mediaNext"), { locked = true })
bind("XF86AudioStop", global("caelestia:mediaStop"), { locked = true })
