---------------------
-- KEYBINDINGS
---------------------

local M = "SUPER"

local bind = hl.bind
local dsp = hl.dsp

local exec = dsp.exec_cmd
local focus = dsp.focus
local win = dsp.window
local ws = dsp.workspace

local tp = false

local function q(cmd)
    return exec("qs -c ei ipc call ei " .. cmd)
end

---------------------
-- KEYMAPS
---------------------

local keymaps = {
    -- EI
    ei = {
        { M .. "+R", exec("qs -c ei kill; qs -c ei") },
        { M .. "+D", q("dashboard") },
        { M .. "+W", q("wallpaper") },
        { M .. "+V", q("clipboard") },
        { M .. "+ESCAPE", q("powerMenu") },
        { M .. "+SUPER_L", q("launcher"), { release = true } },
        { "CTRL+ALT+L", q("lock") },
    },

    -- Apps
    apps = {
        { M .. "+T", exec("kitty") },
        { M .. "+F", exec("thunar") },
        { M .. "+SHIFT+C", exec("hyprpicker -a") },
    },

    -- Windows
    windows = {
        { M .. "+Q", win.close() },
        { M .. "+P", win.pin() },
        { M .. "+SHIFT+F", win.float({ action = "toggle" }) },
        { M .. "+M", win.fullscreen({ mode = "maximized", action = "toggle" }) },
        { M .. "+SHIFT+M", win.fullscreen({ mode = "fullscreen", action = "toggle" }) },
        { "ALT+TAB", win.cycle_next({}) },
    },

    -- Workspace navigation
    workspace = {
        { M .. "+TAB", focus({ workspace = "e+1" }) },
        { M .. "+SHIFT+TAB", focus({ workspace = "e-1" }) },
        { M .. "+mouse_up", focus({ workspace = "e+1" }) },
        { M .. "+mouse_down", focus({ workspace = "e-1" }) },
    },

    -- Mouse move / resize window
    mouse = {
        { M .. "+mouse:272", win.drag(), { mouse = true } },
        { M .. "+mouse:273", win.resize(), { mouse = true } },
    },

    -- Special workspace
    special = {
        { M .. "+U", ws.toggle_special("Scratchpad") },
        { M .. "+SHIFT+U", win.move({ workspace = "special:magic" }) },
        { M .. "+CTRL+U", win.move({ workspace = "e+0" }) },
    },

    -- Media / Laptop keys
    media = {
        { "XF86MonBrightnessUp", q("brightnessUp"), { repeating = true } },
        { "XF86MonBrightnessDown", q("brightnessDown"), { repeating = true } },

        { "XF86AudioMute", exec("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true } },
        { "XF86AudioMicMute", q("micMute"), { locked = true } },

        { "XF86AudioRaiseVolume", q("volumeUp"), { repeating = true, locked = true } },
        { "XF86AudioLowerVolume", q("volumeDown"), { repeating = true, locked = true } },
    },

    -- Screenshot / Record
    capture = {
        { "Print", q("screenshotScreen") },
        { M .. "+SHIFT+S", q("screenshot") },
        { M .. "+SHIFT+R", q("screenrecord") },
    },
}

---------------------
-- GENERATED KEYMAPS
---------------------

local generated = {
    -- Focus / swith window with HJKL
    directions = {
        h = "left",
        j = "down",
        k = "up",
        l = "right",
    },

    -- Move window with ALT + HJKL
    move_slow = {
        h = { x = -20, y = 0 },
        j = { x = 0, y = 20 },
        k = { x = 0, y = -20 },
        l = { x = 20, y = 0 },
    },

    -- Resize with CTRL + HJKL
    resize = {
        ["CTRL+h"] = { x = -40, y = 0 },
        ["CTRL+j"] = { x = 0, y = 40 },
        ["CTRL+k"] = { x = 0, y = -40 },
        ["CTRL+l"] = { x = 40, y = 0 },
    },
}

---------------------
-- APPLY KEYMAPS
---------------------

for _, group in pairs(keymaps) do
    for _, map in ipairs(group) do
        bind(map[1], map[2], map[3])
    end
end

for key, dir in pairs(generated.directions) do
    local delta = generated.move_slow[key]

    -- SUPER + HJKL: focus window
    bind(M .. "+" .. key, focus({ direction = dir }))

    -- SUPER + SHIFT + HJKL: switch window
    bind(M .. "+SHIFT+" .. key, win.move({ direction = dir }))

    -- SUPER + ALT + HJKL: move window
    bind(
        M .. "+ALT+" .. key,
        win.move({
            x = delta.x,
            y = delta.y,
            relative = true,
        }),
        { repeating = true }
    )
end

for i = 1, 10 do
    local key = tostring(i % 10)

    bind(M .. "+" .. key, focus({ workspace = i }))
    bind(M .. "+CTRL+" .. key, win.move({ workspace = i }))
    bind(M .. "+SHIFT+" .. key, win.move({ workspace = i, follow = false }))
end

for key, delta in pairs(generated.resize) do
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
-- TOUCHPAD TOGGLE
---------------------

bind("XF86TouchpadToggle", function()
    tp = not tp

    hl.device({
        name = "elan1203:00-04f3:307a-touchpad",
        enabled = tp,
    })

    os.execute("notify-send 'Touchpad' '" .. (tp and "ENABLED" or "DISABLED") .. "'")
end)
