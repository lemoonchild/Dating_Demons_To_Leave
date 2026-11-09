local Scene = require("src.ecs.Scene")
local Run = require("src.state.Run")
local CollectionNavSystem = require("src.systems.CollectionNavSystem")
local CollectionRenderSystem = require("src.systems.CollectionRenderSystem")
local CardDetailRenderSystem = require("src.systems.CardDetailRenderSystem")

return function(payload)
    local scene = Scene.new("collection")
    scene.world:setResource("runState", Run.current())
    scene.world:setResource("collectionNav", {
        cursor = 1,
        back = payload and payload.back or "room",
    })
    scene:addSystem(CollectionNavSystem)
    scene:addSystem(CollectionRenderSystem)
    scene:addSystem(CardDetailRenderSystem)
    return scene
end
