local RoomArt = require("src.graphics.RoomArt")
local PlayerArt = require("src.graphics.PlayerArt")

local RoomRenderSystem = { name = "roomRender" }

function RoomRenderSystem.draw(scene)
    RoomArt.draw()

    love.graphics.push()
    love.graphics.translate(480, RoomArt.FLOOR_Y)
    love.graphics.scale(2.5)
    PlayerArt.draw(0, -10, 20, 20)
    love.graphics.pop()
end

return RoomRenderSystem
