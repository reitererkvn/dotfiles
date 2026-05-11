-- 🚀 HyprCachyOS: Lua-Native Autostart (0.55+ API)
local hl = hl

local browser = os.getenv("BROWSER") or "google-chrome-stable"

hl.on("hyprland.start", function()
    hl.exec_cmd("uwsm app -- valent --gapplication-service")
    hl.exec_cmd("uwsm app -- " .. browser)
end)
