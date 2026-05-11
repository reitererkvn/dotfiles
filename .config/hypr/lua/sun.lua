-- 🚀 HyprCachyOS: Lua-Native Solar Scheduler (v0.55+)
-- Replaces hypr-sun.sh with intelligent timer-based updates
local hl = hl

-- Config
local LAT, LON = "48.20N", "16.30E"
local SYMLINK = os.getenv("HOME") .. "/.config/hypr/assets/images/WALLPAPER"
local MONITOR = os.getenv("MONITOR1") or "DP-3"

-- Wallpapers from environment
local wp = {
    day = os.getenv("WALLPAPER0"), -- Normal Day
    morning = os.getenv("WALLPAPER1"), -- Morning Civil
    evening = os.getenv("WALLPAPER2"), -- Evening Civil
    night = os.getenv("WALLPAPER3"), -- Deep Night
}

local function apply_wallpaper(path)
    if not path or path == "" then
        return
    end

    -- Check if already active to prevent flickering
    local handle = io.popen("readlink -f " .. SYMLINK)
    local current_symlink = handle:read("*a"):gsub("%s+", "")
    handle:close()

    if current_symlink == path then
        return
    end

    hl.exec_cmd("ln -sf " .. path .. " " .. SYMLINK)
    hl.dispatch(hl.dsp.exec_cmd("hyprctl hyprpaper wallpaper '" .. MONITOR .. "," .. path .. ",cover'"))
    print("[Sun] Switched wallpaper to: " .. path)
end

local function update_solar_schedule()
    print("[Sun] Updating solar schedule...")

    -- Get times from sunwait
    -- list: sunrise, sunset
    -- list civil: rise, set
    local h1 = io.popen("sunwait list " .. LAT .. " " .. LON)
    local r1 = h1:read("*a")
    h1:close()

    local h2 = io.popen("sunwait list civil " .. LAT .. " " .. LON)
    local r2 = h2:read("*a")
    h2:close()

    local times = {}
    local now_t = os.date("*t")

    -- Parse "HH:MM, HH:MM"
    local sr_h, sr_m, ss_h, ss_m = r1:match("(%d%d):(%d%d),%s+(%d%d):(%d%d)")
    local cr_h, cr_m, cs_h, cs_m = r2:match("(%d%d):(%d%d),%s+(%d%d):(%d%d)")

    if sr_h and ss_h then
        times.sunrise =
            os.time({ year = now_t.year, month = now_t.month, day = now_t.day, hour = sr_h, min = sr_m, sec = 0 })
        times.sunset =
            os.time({ year = now_t.year, month = now_t.month, day = now_t.day, hour = ss_h, min = ss_m, sec = 0 })
    end

    if cr_h and cs_h then
        times.rise =
            os.time({ year = now_t.year, month = now_t.month, day = now_t.day, hour = cr_h, min = cr_m, sec = 0 })
        times.set =
            os.time({ year = now_t.year, month = now_t.month, day = now_t.day, hour = cs_h, min = cs_m, sec = 0 })
    end

    local now = os.time()

    -- Safety check: if parsing failed, don't crash
    if not (times.sunrise and times.sunset and times.rise and times.set) then
        print("[Sun] Error: Could not parse solar times. Retrying in 1 hour.")
        hl.timer(update_solar_schedule, { timeout = 3600000, type = "once" })
        return
    end

    -- Determine current state
    if now >= times.sunrise and now < times.sunset then
        apply_wallpaper(wp.day)
    elseif now >= times.rise and now < times.sunrise then
        apply_wallpaper(wp.morning)
    elseif now >= times.sunset and now < times.set then
        apply_wallpaper(wp.evening)
    else
        apply_wallpaper(wp.night)
    end

    -- Schedule next transitions
    local events = { "rise", "sunrise", "sunset", "set" }
    local next_event_found = false
    for _, event in ipairs(events) do
        local target = times[event]
        if target > now then
            local delay = (target - now + 1) * 1000 -- +1s buffer
            hl.timer(update_solar_schedule, { timeout = delay, type = "once" })
            print("[Sun] Next transition scheduled: " .. event .. " at " .. os.date("%H:%M", target))
            next_event_found = true
            break -- Only schedule the VERY next one to avoid multiple triggers
        end
    end

    -- If all events for today are passed, schedule daily refresh at midnight + 1min
    if not next_event_found then
        local tomorrow = os.date("*t", now + 86400)
        local midnight =
            os.time({ year = tomorrow.year, month = tomorrow.month, day = tomorrow.day, hour = 0, min = 1, sec = 0 })
        hl.timer(update_solar_schedule, { timeout = (midnight - now) * 1000, type = "oneshot" })
        print("[Sun] All events for today passed. Scheduled refresh for tomorrow.")
    end
end

-- Initial Trigger
update_solar_schedule()
