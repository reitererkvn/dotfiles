-- 🚀 HyprCachyOS: Lua-Native Keybindings (0.55+ API)
local hl = hl

local mainMod = "SUPER"
local terminal = os.getenv("TERMINAL") or "kitty"
local launcher = os.getenv("LAUNCHER") or "fuzzel"
local browser = os.getenv("BROWSER") or "google-chrome-stable"
local filemanager = os.getenv("FILEMANAGER") or "yazi"
local monitor2 = os.getenv("MONITOR2") or ""

-- Core
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd("uwsm app -- " .. terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("uwsm app -- " .. launcher))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("loginctl lock-session"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("uwsm app -- " .. browser))
hl.bind(mainMod .. " + A", function()
    local current = hl.get_config("general.layout")
    local layouts = { "dwindle", "master", "lua:master-grid" }
    local next_layout = layouts[1]
    
    for i, l in ipairs(layouts) do
        if l == current then
            next_layout = layouts[(i % #layouts) + 1]
            break
        end
    end
    
    hl.config({ general = { layout = next_layout } })
    print("[Layout] Switched to: " .. next_layout)
end)

-- Navigation
local directions = { left = "l", right = "r", up = "u", down = "d" }
for key, dir in pairs(directions) do
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ direction = dir }))
    hl.bind(mainMod .. " + ALT + " .. key, hl.dsp.window.move({ direction = dir }))
end

-- Workspaces
for i = 1, 10 do
    local key = tostring(i % 10)
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scratchpads
hl.bind(mainMod .. " + S", function()
    if monitor2 ~= "" then hl.dispatch(hl.dsp.focus({ monitor = monitor2 })) end
    hl.dispatch(hl.dsp.workspace.toggle_special("magic"))
end)
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind(mainMod .. " + M", function()
    if monitor2 ~= "" then hl.dispatch(hl.dsp.focus({ monitor = monitor2 })) end
    hl.dispatch(hl.dsp.workspace.toggle_special("monitor"))
end)
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.window.move({ workspace = "special:monitor" }))

-- Multimedia (bindel/bindl -> bind with options)
local media_opts = { ["repeat"] = true, locked = true }
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), media_opts)
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), media_opts)
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), media_opts)
hl.bind("SHIFT + XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), media_opts)
hl.bind("SHIFT + XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SOURCE@ 5%+"), media_opts)
hl.bind("SHIFT + XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%-"), media_opts)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), media_opts)
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), media_opts)

local lock_opts = { locked = true }
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), lock_opts)
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), lock_opts)
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), lock_opts)
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), lock_opts)

-- Custom
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.layout("swapprev master"))
hl.bind(mainMod .. " + D", hl.dsp.layout("swapwithmaster master"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("uwsm app -- " .. terminal .. " zsh -i -c '" .. filemanager .. "; exec zsh'"))
hl.bind(mainMod .. " + CTRL + V", hl.dsp.exec_cmd("cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.dpms({ action = "off" }))
hl.bind(mainMod .. " + W", hl.dsp.dpms({ action = "on" }))
hl.bind("PRINT", hl.dsp.exec_cmd("uwsm app -- grimblast -f copy area -n"))
hl.bind("ALT + PRINT", hl.dsp.exec_cmd("uwsm app -- grimblast -f copysave area -n"))
hl.bind("SHIFT + PRINT", hl.dsp.exec_cmd("uwsm app -- grimblast -f edit area -n"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("uwsm app -- " .. terminal .. " -e note"))
hl.bind(mainMod .. " + ALT + N", hl.dsp.exec_cmd("uwsm app -- " .. terminal .. " -e note -ly"))

-- Mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
