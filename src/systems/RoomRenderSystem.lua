local RoomArt = require("src.graphics.RoomArt")
local PlayerArt = require("src.graphics.PlayerArt")

local RoomRenderSystem = { name = "roomRender" }

RoomRenderSystem.PLAYER_H = 180

function RoomRenderSystem.draw(scene)
    RoomArt.draw()

    PlayerArt.drawStanding(480, RoomArt.FLOOR_Y, RoomRenderSystem.PLAYER_H)
end

return RoomRenderSystem
