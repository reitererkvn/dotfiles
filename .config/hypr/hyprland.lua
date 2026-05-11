-- 🚀 HyprCachyOS: SRE-Driven Lua Configuration
-- Entry Point for the new programmable Hyprland Era (0.55+)

local hl = hl

-- 1. EXTEND PATH FOR MODULARITY
local home = os.getenv("HOME")
package.path = package.path .. ";" .. home .. "/.config/hypr/lua/?.lua"

-- 2. LOAD MODULES
require("colors")
require("monitors")
require("look")
require("keybinds")
require("windowrules")
require("autostart")

-- 3. GLOBAL CONFIG
hl.config({
    input = {
        kb_layout = "de"
    }
})

-- 4. SRE LOGGING (Optional)
-- hl.on("startup", function()
--     print("Hyprland session initialized with Lua logic.")
-- end)
