---------------------------------------------------------------------------------------------
-- WINDOW & LAYER RULES CONFIGURATION
-- Defines application classification rules and window behaviors by tag/class/title
---------------------------------------------------------------------------------------------

-- Map application classes to workspace tags
local tag_mappings = {
    ["+browser"] = {
        "^([Ff]irefox|org\\.mozilla\\.firefox|[Ff]irefox-(esr|bin))$",
        "^([Gg]oogle-chrome(-beta|-dev|-unstable)?)$",
        "^(chrome-.+-Default)$",
        "^([Cc]hromium)$",
        "^([Mm]icrosoft-edge(-stable|-beta|-dev|-unstable))$",
        "^(Brave-browser(-beta|-dev|-unstable)?)$",
        "^([Tt]horium-browser|[Cc]achy-browser)$",
        "^(zen-alpha|zen)$",
    },

    ["+notif"] = {
        "^(swaync-control-center|swaync-notification-window|swaync-client|class)$",
    },

    ["+terminal"] = {
        "^(Alacritty|kitty|kitty-dropterm)$",
    },

    ["+email"] = {
        "^([Tt]hunderbird|org\\.gnome\\.Evolution)$",
        "^(eu\\.betterbird\\.Betterbird)$",
    },

    ["+projects"] = {
        "^(codium|codium-url-handler|VSCodium)$",
        "^(VSCode|code-url-handler)$",
        "^(jetbrains-.+)$",
    },

    ["+im"] = {
        "^([Dd]iscord|[Ww]ebCord|[Vv]esktop)$",
        "^([Ff]erdium)$",
        "^([Ww]hatsapp-for-linux)$",
        "^(ZapZap|com\\.rtosta\\.zapzap)$",
        "^(org\\.telegram\\.desktop|io\\.github\\.tdesktop_x64\\.TDesktop)$",
        "^(teams-for-linux)$",
    },

    ["+games"] = {
        "^(gamescope)$",
        "^(steam_app_\\d+)$",
    },

    ["+gamestore"] = {
        "^([Ss]team)$",
        "^(com\\.heroicgameslauncher\\.hgl)$",
    },

    ["+multimedia"] = {
        "^([Aa]udacious)$",
    },

    ["+multimedia_video"] = {
        "^([Mm]pv|vlc)$",
    },

    ["+file-manager"] = {
        "^([Tt]hunar|org\\.gnome\\.Nautilus|[Pp]cmanfm-qt)$",
        "^(app\\.drey\\.Warp)$",
    },

    ["+screenshare"] = {
        "^(com\\.obsproject\\.Studio)$",
    },

    ["+wallpaper"] = {
        "^([Ww]aytrogen|org\\.[Ww]aytrogen\\.[Ww]aytrogen)$",
        "^([Ww]aypaper)$",
    },

    ["+viewer"] = {
        "^([Oo]rg.gnome.eog)$",
        "^(evince)$",
        "^(gnome-system-monitor|org.gnome.SystemMonitor|io.missioncenter.MissionCenter)$",
    },

    ["+settings"] = {
        "^(wihotspot(-gui)?)$",
        "^([Bb]aobab|org.gnome.[Bb]aobab)$",
        "^(gnome-disks|wihotspot(-gui)?)$",
        "^(file-roller|org.gnome.FileRoller)$",
        "^(nm-applet|nm-connection-editor|blueman-manager)$",
        "^(qt5ct|qt6ct|[Yy]ad)$",
        "(xdg-desktop-portal-gtk)",
        "^(org.kde.polkit-kde-authentication-agent-1)$",
        "^([Rr]ofi)$",
        "^(nwg-displays|nwg-look)$",
        "^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$",
    },
}

-- Apply tag rules based on application class matching
for tag, class_patterns in pairs(tag_mappings) do
    for _, pattern in ipairs(class_patterns) do
        hl.window_rule({
            match = { class = pattern },
            tag = tag,
        })
    end
end

-- Exception rules: assign tags using window title instead of class
hl.window_rule({ match = { title = "^([Ll]utris)$" }, tag = "+gamestore" })
hl.window_rule({ match = { title = "^(ROG Control)$" }, tag = "+settings" })
hl.window_rule({ match = { title = "(Kvantum Manager)" }, tag = "+settings" })

---------------------------------------------------------------------------------------------
-- WINDOW BEHAVIOR RULES (by tag & special cases)
---------------------------------------------------------------------------------------------

local default_float_size = { "(monitor_w * 0.8)", "(monitor_h * 0.8)" }

-- Tag-based window behavior rules
hl.window_rule({ match = { tag = "wallpaper" }, float = true, size = default_float_size })
hl.window_rule({ match = { tag = "settings" }, float = true, size = default_float_size })
hl.window_rule({ match = { tag = "viewer" }, float = true, size = default_float_size })
hl.window_rule({ match = { tag = "games" }, fullscreen = true, no_blur = true })

-- Application-specific special rules
hl.window_rule({ match = { class = "^([Qq]alculate-gtk)$" }, float = true })
hl.window_rule({
    match = { title = "^(Picture-in-Picture)$|^(Hình trong hình)$" },
    float = true,
    size = { "monitor_w * 0.30", "monitor_h * 0.30" },
    move = { "monitor_w * 0.65", "monitor_h * 0.65" },
    pin = true,
})
