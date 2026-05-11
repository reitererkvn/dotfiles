-- 🚀 HyprCachyOS: Lua-Native Colors
local function to_rgba(hex, default)
    if not hex or hex == "" then return default end
    
    -- If it's already rgba, return it
    if hex:match("^rgba") then return hex end
    
    -- Clean hex
    local clean = hex:gsub("#", "")
    
    -- Handle 6-char RRGGBB
    if #clean == 6 then
        local r = tonumber(clean:sub(1, 2), 16)
        local g = tonumber(clean:sub(3, 4), 16)
        local b = tonumber(clean:sub(5, 6), 16)
        if r and g and b then
            return string.format("rgba(%d, %d, %d, 1.0)", r, g, b)
        end
    -- Handle 8-char RRGGBBAA (User's format)
    elseif #clean == 8 then
        local r = tonumber(clean:sub(1, 2), 16)
        local g = tonumber(clean:sub(3, 4), 16)
        local b = tonumber(clean:sub(5, 6), 16)
        local a = tonumber(clean:sub(7, 8), 16) / 255
        if r and g and b and a then
            return string.format("rgba(%d, %d, %d, %.2f)", r, g, b, a)
        end
    end
    
    return default
end

-- Fallback color is RED to indicate broken envs
local error_red = "rgba(255, 0, 0, 1.0)"

local colors = {
    -- Swapped: active1 gets BORDERACTIVE1, active2 gets BORDERACTIVE0
    active1 = to_rgba(os.getenv("BORDERACTIVE1"), error_red),
    active2 = to_rgba(os.getenv("BORDERACTIVE0"), error_red),
    inactive = to_rgba(os.getenv("BORDERINACTIVE"), error_red),
}

return colors
