local demons = require("src.data.demons")
local DemonArt = require("src.graphics.DemonArt")

local VisitDemonRenderSystem = { name = "visitDemonRender" }

function VisitDemonRenderSystem.draw(scene)
    local world = scene.world
    for _, entity in ipairs(world:query("position", "demonSprite")) do
        local pos = world:getComponent(entity, "position")
        local sprite = world:getComponent(entity, "demonSprite")
        DemonArt.draw(demons[sprite.demonId], pos.x, pos.y, sprite.w, sprite.h)
    end
end

return VisitDemonRenderSystem
