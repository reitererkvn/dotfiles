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
require("sun")

-- 3. GLOBAL CONFIG
hl.config({
    input = {
        kb_layout = "de",
        numlock_by_default = true
    }
})

-- 4. SRE LOGGING (Optional)
print("Hyprland session initialized with Lua logic.")
-- hl.on("startup", function()
--     print("Hyprland session initialized with Lua logic.")
-- end)
