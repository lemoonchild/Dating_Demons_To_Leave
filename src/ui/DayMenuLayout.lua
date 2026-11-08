local Screen = require("src.Screen")

local DayMenuLayout = {}

DayMenuLayout.BOX = { x = 20, y = 356, w = Screen.w - 40, h = 164 }
DayMenuLayout.COLS = { 40, 496 }
DayMenuLayout.COL_W = 424
DayMenuLayout.ROW_H = 36
DayMenuLayout.FIRST_Y = 398
DayMenuLayout.PER_COL = 3

function DayMenuLayout.rect(i)
    local col = i <= DayMenuLayout.PER_COL and 1 or 2
    local row = (i - 1) % DayMenuLayout.PER_COL
    return DayMenuLayout.COLS[col], DayMenuLayout.FIRST_Y + row * DayMenuLayout.ROW_H,
        DayMenuLayout.COL_W, DayMenuLayout.ROW_H
end

function DayMenuLayout.hit(count, mx, my)
    for i = 1, count do
        local x, y, w, h = DayMenuLayout.rect(i)
        if mx >= x and mx <= x + w and my >= y and my < y + h then return i end
    end
end

return DayMenuLayout
