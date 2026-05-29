---------------------------------------------------------------------------------------------
-- SETTINGS
-- See https://wiki.hypr.land/Configuring/Basics/Variables/
---------------------------------------------------------------------------------------------

hl.config({
    general = {
        layout = "dwindle",
        resize_on_border = true,

        gaps_in = 5,
        gaps_out = 14,
        border_size = 1,

        col = {
            active_border = {
                colors = {
                    0xff00ffff,
                    0xffbf00ff,
                    0xffff8800,
                    0xff00ffff,
                    0xffbf00ff,
                    0xffff8800,
                    0xff00ffff,
                    0xffbf00ff,
                    0xffff8800,
                    0xff00ffff,
                },
                angle = 270,
            },
            inactive_border = {
                colors = {
                    0xff444444,
                    0xff666666,
                    0xff888888,
                    0xff444444,
                    0xff666666,
                    0xff888888,
                    0xff444444,
                    0xff666666,
                    0xff888888,
                },
                angle = 270,
            },
        },
    },

    decoration = {
        rounding = 10,
        rounding_power = 2,

        active_opacity = 1.0,
        inactive_opacity = 1.0,

        blur = {
            enabled = true,
            size = 3,
            passes = 1,
        },
    },

    animations = {
        enabled = true,
    },

    input = {
        kb_layout = "us",
        kb_variant = "",
        kb_model = "",
        kb_options = "",
        kb_rules = "",
    },

    dwindle = { preserve_split = true },
    master = { new_status = "master" },
})

hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.curve("linear", { type = "bezier", points = { { 0.0, 0.0 }, { 1.0, 1.0 } } })
hl.curve("wind", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.0 } } })
hl.curve("winIn", { type = "bezier", points = { { 0.1, 1.1 }, { 0.1, 1.1 } } })
hl.curve("winOut", { type = "bezier", points = { { 0.3, -0.3 }, { 0, 1 } } })
hl.curve("slow", { type = "bezier", points = { { 0, 0.85 }, { 0.3, 1 } } })
hl.curve("overshot", { type = "bezier", points = { { 0.7, 0.6 }, { 0.1, 1.1 } } })
hl.curve("bounce", { type = "bezier", points = { { 1.1, 1.6 }, { 0.1, 0.85 } } })
hl.curve("sligshot", { type = "bezier", points = { { 1, -1 }, { 0.15, 1.25 } } })
hl.curve("nice", { type = "bezier", points = { { 0, 2.0 }, { 0.5, -1.0 } } })

hl.animation({ leaf = "windowsIn", enabled = true, speed = 5, bezier = "slow", style = "popin" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 5, bezier = "winOut", style = "popin" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5, bezier = "wind", style = "slide" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 100, bezier = "linear", style = "loop" })
hl.animation({ leaf = "fade", enabled = true, speed = 5, bezier = "overshot" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "wind" })
hl.animation({ leaf = "windows", enabled = true, speed = 5, bezier = "bounce", style = "popin" })
