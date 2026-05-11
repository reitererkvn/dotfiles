-- 🚀 HyprCachyOS: Lua-Native Look & Feel (0.55+ API)
local hl = hl
local colors = require("colors")

hl.config({
    general = {
        gaps_in = 2,
        gaps_out = 5,
        border_size = 2,
        col = {
            active_border = { colors = { colors.active1, colors.active2 }, angle = 45 },
            inactive_border = { colors = { colors.inactive } },
        },
        layout = "master"
    },
    decoration = {
        rounding = 10,
        rounding_power = 2,
        active_opacity = 0.95,
        inactive_opacity = 0.9,
        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = "rgba(26, 26, 26, 0.93)"
        },
        blur = {
            enabled = true,
            size = 3,
            passes = 1,
            vibrancy = 0.1696
        }
    },
    animations = {
        enabled = true,
        bezier = {
            "easeOutQuint, 0.23, 1, 0.32, 1",
            "easeInOutCubic, 0.65, 0.05, 0.36, 1",
            "linear, 0, 0, 1, 1",
            "almostLinear, 0.5, 0.5, 0.75, 1",
            "quick, 0.15, 0, 0.1, 1"
        },
        animation = {
            "global, 1, 10, default",
            "border, 1, 5.39, easeOutQuint",
            "windows, 1, 4.79, easeOutQuint",
            "windowsIn, 1, 4.1, easeOutQuint, popin 87%",
            "windowsOut, 1, 1.49, linear, popin 87%",
            "fadeIn, 1, 1.73, almostLinear",
            "fadeOut, 1, 1.46, almostLinear",
            "fade, 1, 3.03, quick",
            "layers, 1, 3.81, easeOutQuint",
            "layersIn, 1, 4, easeOutQuint, fade",
            "layersOut, 1, 1.5, linear, fade",
            "fadeLayersIn, 1, 1.79, almostLinear",
            "fadeLayersOut, 1, 1.39, almostLinear",
            "workspaces, 1, 1.94, almostLinear, fade",
            "workspacesIn, 1, 1.21, almostLinear, fade",
            "workspacesOut, 1, 1.94, almostLinear, fade",
            "zoomFactor, 1, 7, quick"
        }
    },
    master = {
        orientation = "center",
        slave_count_for_center_master = 0,
        mfact = 0.5,
        always_keep_position = true,
        allow_small_split = true
    },
    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo = false
    }
})
