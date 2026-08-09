-- 🚀 HyprCachyOS: Lua-Native Window Rules (0.55+ API)
local hl = hl

-- Simple Rules
hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })
hl.window_rule({ match = { class = "^$", title = "^$", xwayland = true }, float = true, no_focus = true })
hl.window_rule({ match = { class = "hyprland-run" }, float = true })
hl.window_rule({ match = { fullscreen = true }, border_size = 0 })

-- Workspace Rules: Monitors
hl.window_rule({ match = { class = "btop-sys" }, opacity = 0.95, workspace = "special:monitor" })
hl.window_rule({ match = { class = "nvtop-sys" }, opacity = 0.95, workspace = "special:monitor" })
hl.window_rule({ match = { class = "org.pulseaudio.pavucontrol" }, float = true })

-- Workspace Rules: Magic (Chat / clients)
hl.window_rule({ match = { class = "steam" }, workspace = "special:magic", pseudo = true })
hl.window_rule({ match = { class = "vesktop" }, workspace = "special:magic", opaque = true })
hl.window_rule({ match = { class = "bolt-launcher" }, workspace = "special:magic", pseudo = true })

hl.window_rule({ match = { class = "chrome-web.whatsapp.com.*" }, workspace = "special:magic", pseudo = true })
hl.window_rule({ match = { class = "chrome-music.youtube.com.*" }, workspace = "special:magic", pseudo = true })
hl.window_rule({
    match = { class = "chrome-teams.live.com.*" },
    workspace = "special:magic",
    pseudo = true,
    opaque = true,
})

-- Workspace Rules: Empty (Games)
hl.window_rule({ match = { class = "cs2" }, workspace = "empty" })
hl.window_rule({ match = { class = "net-runelite-client-RuneLite" }, workspace = "empty", opaque = true })
hl.window_rule({ match = { class = "steam_app_1343400" }, workspace = "empty", opaque = true }) -- runescape
hl.window_rule({ match = { class = "steam_app_1449850" }, workspace = "empty", fullscreen = true, opaque = true }) -- yugioh
hl.window_rule({ match = { title = "VDI.*" }, workspace = "empty", fullscreen = true })

-- Workspace Layout Overrides
hl.workspace_rule({ workspace = "special:magic", layout = "dwindle" })
hl.workspace_rule({ workspace = "special:monitor", layout = "dwindle" })
