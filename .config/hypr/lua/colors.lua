-- 🚀 HyprCachyOS: Lua-Native Colors
local function sanitize(color, default)
    if not color then return default end
    -- If it's a 8-char or 6-char hex without prefix, add 0x
    if color:match("^%x%x%x%x%x%x%x%x$") or color:match("^%x%x%x%x%x%x$") then
        return "0x" .. color
    end
    return color
end

local colors = {
    active1 = sanitize(os.getenv("BORDERACTIVE0_RGBA"), "rgba(33ccffee)"),
    active2 = sanitize(os.getenv("BORDERACTIVE1_RGBA"), "rgba(00ff99ee)"),
    inactive = sanitize(os.getenv("BORDERINACTIVE_RGBA"), "rgba(595959aa)"),
}

return colors
