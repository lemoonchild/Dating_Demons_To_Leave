local Screen = require("src.Screen")

local RoomArt = {}

RoomArt.FLOOR_Y = 300

function RoomArt.draw()
    love.graphics.setColor(0.14, 0.07, 0.1, 1)
    love.graphics.rectangle("fill", 0, 0, Screen.w, Screen.h)
    love.graphics.setColor(0.22, 0.1, 0.08, 1)
    love.graphics.rectangle("fill", 0, RoomArt.FLOOR_Y, Screen.w, Screen.h - RoomArt.FLOOR_Y)

    love.graphics.setColor(0.05, 0.02, 0.03, 1)
    love.graphics.rectangle("fill", 440, 140, 80, 50)
    love.graphics.setColor(0.8, 0.3, 0.15, 1)
    for bar = 1, 3 do
        love.graphics.line(440 + bar * 20, 140, 440 + bar * 20, 190)
    end
    love.graphics.rectangle("line", 440, 140, 80, 50)

    love.graphics.setColor(0.35, 0.35, 0.45, 1)
    love.graphics.rectangle("fill", 120, 255, 190, 45)
    love.graphics.setColor(0.6, 0.55, 0.6, 1)
    love.graphics.rectangle("fill", 125, 245, 50, 18)
    love.graphics.setColor(1, 1, 1, 0.6)
    love.graphics.rectangle("line", 120, 255, 190, 45)

    love.graphics.setColor(0.05, 0.02, 0.03, 1)
    love.graphics.rectangle("fill", 760, 160, 90, 140)
    love.graphics.setColor(0.8, 0.3, 0.15, 1)
    love.graphics.rectangle("line", 760, 160, 90, 140)
    love.graphics.rectangle("fill", 835, 230, 6, 6)

    love.graphics.setColor(1, 1, 1, 1)
end

return RoomArt
