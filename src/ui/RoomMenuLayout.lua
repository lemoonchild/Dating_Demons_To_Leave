local Screen = require("src.Screen")

local RoomMenuLayout = {}

RoomMenuLayout.BOX = { x = 20, y = 330, w = Screen.w - 40, h = 190 }
RoomMenuLayout.X = 40
RoomMenuLayout.W = Screen.w - 80
RoomMenuLayout.FIRST_Y = 374
RoomMenuLayout.ROW_H = 30

function RoomMenuLayout.rect(i)
    return RoomMenuLayout.X, RoomMenuLayout.FIRST_Y + (i - 1) * RoomMenuLayout.ROW_H,
        RoomMenuLayout.W, RoomMenuLayout.ROW_H
end

function RoomMenuLayout.hit(count, mx, my)
    for i = 1, count do
        local x, y, w, h = RoomMenuLayout.rect(i)
        if mx >= x and mx <= x + w and my >= y and my < y + h then return i end
    end
end

return RoomMenuLayout
