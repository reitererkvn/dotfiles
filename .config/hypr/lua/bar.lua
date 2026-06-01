-- 🚀 HyprCachyOS: Native Lua Bar (0.55+ API)
-- Zero GTK, Event-Driven, UWSM SSOT Colors
local hl = hl

-- 1. SSOT Theme Integration (via UWSM Environment)
local function get_color(env_var, default)
    local hex = os.getenv(env_var)
    if not hex or hex == "" then return default end
    -- Convert #RRGGBB to rgba(...) for native renderer if necessary, or just return hex
    -- Assuming hl.ui natively supports #RRGGBB
    return hex
end

local theme = {
    bg = get_color("BASE00", "#1E1E2E"),
    fg = get_color("BASE05", "#CDD6F4"),
    accent = get_color("ACCENT", "#89B4FA"),
    alert = get_color("BASE08", "#F38BA8"),
    warning = get_color("BASE09", "#FAB387"),
    workspace_active = get_color("BORDERACTIVE1", "#A6E3A1"),
    workspace_inactive = get_color("BORDERINACTIVE", "#313244")
}

-- 2. Init Native Bar
local bar = hl.ui.bar({
    output = "DP-3",
    position = "bottom",
    height = 30,
    spacing = 8,
    background = theme.bg,
    color = theme.fg,
    font = "sans-serif 10"
})

-- ==========================================
-- LEFT MODULES
-- ==========================================
local workspaces = hl.ui.widget.workspaces({
    active_color = theme.workspace_active,
    inactive_color = theme.workspace_inactive,
    urgent_color = theme.alert,
    on_click = function(ws_id) hl.exec_cmd("hyprctl dispatch workspace " .. ws_id) end
})
bar:add_left(workspaces)

-- ==========================================
-- CENTER MODULES
-- ==========================================
local window_title = hl.ui.widget.text({ text = "" })
hl.on("activewindow", function(win_class, win_title)
    if win_title then
        window_title:set_text(string.sub(win_title, 1, 60)) -- Truncate long titles
    else
        window_title:set_text("")
    end
end)
bar:add_center(window_title)

-- ==========================================
-- RIGHT MODULES (KISS & Hardware-Native)
-- ==========================================

-- A) CPU (Read natively from /proc/stat)
local cpu_widget = hl.ui.widget.text({ text = "CPU: --%" })
hl.timer.every(2000, function()
    local f = io.open("/proc/loadavg", "r")
    if f then
        local load = f:read("*a"):match("^(%S+)")
        f:close()
        cpu_widget:set_text("CPU: " .. load)
    end
end)

-- B) RAM (Read natively from /proc/meminfo)
local mem_widget = hl.ui.widget.text({ text = "RAM: --%" })
hl.timer.every(3000, function()
    local f = io.open("/proc/meminfo", "r")
    if f then
        local content = f:read("*a")
        f:close()
        local total = content:match("MemTotal:%s+(%d+)")
        local avail = content:match("MemAvailable:%s+(%d+)")
        if total and avail then
            local used_pct = math.floor(((total - avail) / total) * 100)
            mem_widget:set_text("RAM: " .. used_pct .. "%")
        end
    end
end)

-- C) Temperature
local temp_widget = hl.ui.widget.text({ text = "Temp: --°C" })
hl.timer.every(5000, function()
    local f = io.open("/sys/class/thermal/thermal_zone0/temp", "r")
    if f then
        local temp = tonumber(f:read("*a"))
        f:close()
        if temp then
            temp_widget:set_text(string.format("Temp: %d°C", math.floor(temp / 1000)))
        end
    end
end)

-- D) Audio (Native Wireplumber binding if available, else async CLI)
local audio_widget = hl.ui.widget.text({ text = "Vol: --%" })
hl.timer.every(1000, function()
    hl.async_exec("wpctl get-volume @DEFAULT_AUDIO_SINK@", function(out)
        local vol = out:match("Volume: (%d+%.%d+)")
        if vol then
            audio_widget:set_text("Vol: " .. math.floor(tonumber(vol) * 100) .. "%")
        end
    end)
end)

-- E) Nvidia Custom Module
local nvidia_widget = hl.ui.widget.text({ text = "GPU: --%" })
hl.timer.every(3000, function()
    hl.async_exec("nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits", function(out)
        nvidia_widget:set_text("GPU: " .. vim.trim(out) .. "%")
    end)
end)

-- F) Mouse Battery (G903)
local mouse_widget = hl.ui.widget.text({ text = "Mouse: --%" })
hl.timer.every(60000, function() -- Only every 60s
    hl.async_exec("upower -i $(upower -e | grep 'mouse') | grep 'percentage' | awk '{print $2}'", function(out)
        mouse_widget:set_text("Mouse: " .. vim.trim(out))
    end)
end)

-- G) Clock
local clock_widget = hl.ui.widget.text({ text = os.date("%H:%M") })
hl.timer.every(10000, function()
    clock_widget:set_text(os.date("%H:%M  %d.%m."))
end)

-- H) Dedicated SNI-Host (Tray)
local tray = hl.ui.widget.sni_tray({
    icon_size = 14,
    spacing = 4,
    transparent = true
})

-- Assemble Right Side (Reversed order from right edge)
bar:add_right(tray)
bar:add_right(clock_widget)
bar:add_right(mouse_widget)
bar:add_right(nvidia_widget)
bar:add_right(temp_widget)
bar:add_right(mem_widget)
bar:add_right(cpu_widget)
bar:add_right(audio_widget)

-- Register the Bar in Hyprland
hl.ui.register(bar)
