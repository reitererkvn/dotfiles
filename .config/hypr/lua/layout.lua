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

        -- Calculate dimensions
        local mw = math.floor(area.w * mfact)
        local sw_avail = area.w - mw

        -- Slaves
        local slaves = {}
        for i = 2, n do
            table.insert(slaves, windows[i])
        end

        -- Distribute slaves (L, R, L, R...)
        local left_slaves = {}
        local right_slaves = {}
        for i, s in ipairs(slaves) do
            if i % 2 == 1 then
                table.insert(left_slaves, s)
            else
                table.insert(right_slaves, s)
            end
        end

        -- Dynamic Master Positioning & Stack Widths
        local lw, rw, mx
        if #left_slaves > 0 and #right_slaves > 0 then
            -- Both sides occupied: Master in center
            lw = math.floor(sw_avail / 2)
            rw = sw_avail - lw
            mx = area.x + lw
        elseif #left_slaves > 0 then
            -- Only left side: Master moves to the right
            lw = sw_avail
            rw = 0
            mx = area.x + lw
        elseif #right_slaves > 0 then
            -- Only right side: Master moves to the left
            lw = 0
            rw = sw_avail
            mx = area.x
        else
            -- Safety fallback
            lw, rw = 0, 0
            mx = area.x
        end

        -- 1. Place Master
        windows[1]:place({
            x = mx,
            y = area.y,
            w = mw,
            h = area.h
        })

        -- 2. Helper for Side-Grid logic
        local function layout_side(side_slaves, side_x, side_w)
            local num = #side_slaves
            if num == 0 then return end

            if num == 1 then
                -- Single slave: fills height and side-width
                side_slaves[1]:place({
                    x = side_x,
                    y = area.y,
                    w = side_w,
                    h = area.h
                })
            else
                -- Grid: arranges side-by-side starting from 2 windows
                local cols = 2
                local rows = math.ceil(num / cols)
                local rh = math.floor(area.h / rows)
                
                for i, s in ipairs(side_slaves) do
                    local r = math.floor((i - 1) / cols)
                    local c = (i - 1) % cols
                    
                    -- Check if it's the last row to "fill width"
                    local is_last_row = (r == rows - 1)
                    local windows_in_last_row = num % cols
                    if windows_in_last_row == 0 then windows_in_last_row = cols end
                    
                    local current_row_cols = is_last_row and windows_in_last_row or cols
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
