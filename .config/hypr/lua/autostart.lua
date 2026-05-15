-- 🚀 HyprCachyOS: Lua-Native Autostart (0.55+ API)
local hl = hl

local browser = os.getenv("BROWSER") or "google-chrome-stable"

local function run_autostart()
    print("[Autostart] Launching core apps...")
    hl.exec_cmd("uwsm app -- valent --gapplication-service")
    hl.exec_cmd("uwsm app -- " .. browser)
end

-- Subscribe to event for reloads/completeness
hl.on("hyprland.start", run_autostart)

-- Execute immediately (guarded by exec-once logic of uwsm/hyprland if needed, 
-- but here we just call it to ensure it runs at boot load)
run_autostart()

