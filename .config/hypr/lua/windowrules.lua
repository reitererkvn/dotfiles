-- 🚀 HyprCachyOS: Lua-Native Window Rules (0.55+ API)
local hl = hl

-- Simple Rules
hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })
hl.window_rule({ match = { class = "^$", title = "^$", xwayland = true }, float = true, no_focus = true })

-- Workspace Rules
hl.window_rule({ match = { class = "org.pulseaudio.pavucontrol" }, float = true })
hl.window_rule({ match = { class = "htop-sys" }, opacity = 0.95, workspace = "special:monitor" })
hl.window_rule({ match = { class = "nvtop-sys" }, opacity = 0.95, workspace = "special:monitor" })
hl.window_rule({ match = { class = "cs2" }, workspace = "empty" })
hl.window_rule({ match = { class = "vesktop" }, workspace = "special:magic" })
hl.window_rule({ match = { class = "steam" }, workspace = "special:magic" })

-- Specific Effects
hl.window_rule({ match = { class = "net-runelite-client-RuneLite" }, opaque = true })
hl.window_rule({ match = { title = "VDI.*" }, fullscreen = true })
