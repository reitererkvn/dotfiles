-- 🚀 HyprCachyOS: Lua-Native Monitors (0.55+ API)
local hl = hl

local monitor1 = os.getenv("MONITOR1") or "DP-3"
local res1 = os.getenv("RES1") or "preferred"
local rfr1 = os.getenv("RFR1") or "60"
local mpos1 = os.getenv("MPOS1") or "0x0"

-- 1. Configure Primary Monitor
hl.monitor({
    output = monitor1,
    mode = res1 .. "@" .. rfr1,
    position = mpos1,
    scale = 1,
})

-- 2. Disable any other monitors (Phantom/Ghost monitors)
hl.monitor({
    output = "",
    disabled = true,
})
