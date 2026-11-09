local PlayerArt = require("src.graphics.PlayerArt")

local PlayerRenderSystem = { name = "playerRender" }

function PlayerRenderSystem.draw(scene)
    local world = scene.world
    for _, entity in ipairs(world:query("player", "position", "body")) do
        local pos = world:getComponent(entity, "position")
        local body = world:getComponent(entity, "body")
        PlayerArt.draw(pos.x, pos.y, body.w, body.h)
    end
end

return PlayerRenderSystem
