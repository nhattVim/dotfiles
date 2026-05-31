---------------------------------------------------------------------------------------------
-- ENVIRONMENT VARIABLES
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
---------------------------------------------------------------------------------------------

local env = hl.env

-- Cursor
env("XCURSOR_SIZE", "24")
env("XCURSOR_THEME", "Bibata-Modern-Ice")
env("HYPRCURSOR_SIZE", "24")
env("HYPRCURSOR_THEME", "Bibata-Modern-Ice")

-- QT
env("QT_QPA_PLATFORMTHEME", "gtk3")

-- NVIDIA GPU support
-- env("LIBVA_DRIVER_NAME", "nvidia")
-- env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
