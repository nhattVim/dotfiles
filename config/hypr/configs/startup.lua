---------------------------------------------------------------------------------------------
-- AUTOSTART
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
---------------------------------------------------------------------------------------------

local exec = hl.exec_cmd
local on = hl.on

on("hyprland.start", function()
    -- shell
    exec("qs -c ei")

    -- one-time boot script (auto-commented after first run)
    exec("$HOME/.config/hypr/scripts/boot.sh")

    -- authentication agents
    exec("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")

    -- import environment for systemd services
    exec("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    exec("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

    -- clipboard manager
    exec("wl-paste --type text   --watch cliphist store")
    exec("wl-paste --type image  --watch cliphist store")

    -- auto delete trash 30 days old
    exec("trash-empty 30")

    --  Startup applications
    -- exec("fcitx5 -d")
end)
