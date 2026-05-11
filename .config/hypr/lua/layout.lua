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

        -- Calculate dimensions for fixed centering (Turn 40 logic)
        local mw = math.floor(area.w * mfact)
        local sw_total = area.w - mw
        local lw = math.floor(sw_total / 2)
        local rw = sw_total - lw

        -- Master Window (Fixed Center)
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
            if (i - 2) % 2 == 0 then
                table.insert(left_slaves, windows[i])
            else
                table.insert(right_slaves, windows[i])
            end
        end

        -- Helper for Side Layout
        local function layout_side(side_slaves, side_x, side_w)
            local num = #side_slaves
            if num == 0 then return end

            if num <= 2 then
                -- Vertical Stack (fills width)
                local h = math.floor(area.h / num)
                for i, s in ipairs(side_slaves) do
                    s:place({
                        x = side_x,
                        y = area.y + (i - 1) * h,
                        w = side_w,
                        h = h
                    })
                end
            else
                -- Smart Grid with Width Fill
                local cols = 2
                local rows = math.ceil(num / cols)
                local rh = math.floor(area.h / rows)
                
                for i, s in ipairs(side_slaves) do
                    local r = math.floor((i - 1) / cols)
                    local c = (i - 1) % cols
                    
                    -- Optimization: If it's the last row and only has 1 window, fill full side width
                    local is_last_row = (r == rows - 1)
                    local windows_in_last_row = num % cols
                    if windows_in_last_row == 0 then windows_in_last_row = cols end
                    
                    local current_row_cols = (is_last_row) and windows_in_last_row or cols
                    local cw = math.floor(side_w / current_row_cols)

                    s:place({
                        x = side_x + c * cw,
                        y = area.y + r * rh,
                        w = cw,
                        h = rh
                    })
                end
            end
        end

        -- Apply side layouts
        layout_side(left_slaves, area.x, lw)
        layout_side(right_slaves, area.x + mw + lw, rw)
    end
})
