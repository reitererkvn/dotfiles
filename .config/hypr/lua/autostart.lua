-- 🚀 HyprCachyOS: Lua-Native Autostart (0.55+ API)
local hl = hl

local browser = os.getenv("BROWSER") or "google-chrome-stable"

hl.on("hyprland.start", function()
    print("[Autostart] Launching core apps...")
    hl.exec_cmd("uwsm app -- valent --gapplication-service")
    hl.exec_cmd("uwsm app -- " .. browser)
    
    -- Session Restore: Magic Workspace (Chat & Media)
    hl.exec_cmd("uwsm app -- vesktop")
    hl.exec_cmd("uwsm app -- " .. browser .. " --app=https://web.whatsapp.com/")
    hl.exec_cmd("uwsm app -- " .. browser .. " --app=https://music.youtube.com/")
end)

