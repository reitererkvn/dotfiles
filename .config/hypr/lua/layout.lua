-- 🚀 HyprCachyOS: Lua-Native Custom Layout (master-grid)
local hl = hl

hl.layout.register("master-grid", {
    recalculate = function(ctx)
        local windows = ctx.targets
        local n = #windows
        if n == 0 then return end

        local area = ctx.area
        local mfact = hl.get_config("master.mfact") or 0.5

        -- 1 Window: Fullscreen
        if n == 1 then
            windows[1]:place(area)
            return
        end

        -- Dimensions
        local mw = math.floor(area.w * mfact)
        local sw_total = area.w - mw
        local lw = math.floor(sw_total / 2)
        local rw = sw_total - lw

        -- Master (Window 1)
        windows[1]:place({
            x = area.x + lw,
            y = area.y,
            w = mw,
            h = area.h
        })

        -- Slaves
        local left_slaves = {}
        local right_slaves = {}
        for i = 2, n do
            if i % 2 == 0 then
                table.insert(left_slaves, windows[i])
            else
                table.insert(right_slaves, windows[i])
            end
        end

        local function layout_side(side_slaves, sx, sw)
            local num = #side_slaves
            if num == 0 then return end

            if num <= 2 then
                local h = math.floor(area.h / num)
                for i, s in ipairs(side_slaves) do
                    s:place({ x = sx, y = area.y + (i-1)*h, w = sw, h = h })
                end
            else
                local rows = math.ceil(num / 2)
                local rh = math.floor(area.h / rows)
                for i, s in ipairs(side_slaves) do
                    local r = math.floor((i-1) / 2)
                    local c = (i-1) % 2
                    local is_last_row = (r == rows - 1)
                    local last_row_count = num % 2
                    if last_row_count == 0 then last_row_count = 2 end
                    
                    local cur_cols = is_last_row and last_row_count or 2
                    local cw = math.floor(sw / cur_cols)
                    
                    s:place({ x = sx + c*cw, y = area.y + r*rh, w = cw, h = rh })
                end
            end
        end

        layout_side(left_slaves, area.x, lw)
        layout_side(right_slaves, area.x + mw + lw, rw)
    end,

    layout_msg = function(msg)
        if msg == "swap_master" then
            local active = hl.get_active_window()
            local ws = hl.get_active_workspace()
            -- Use hyprctl-style dispatch for maximum compatibility
            hl.exec_cmd("hyprctl dispatch swapwithmaster")
        end
    end
})
