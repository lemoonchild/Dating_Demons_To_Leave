local Scene = require("src.ecs.Scene")
local Run = require("src.state.Run")
local PackInputSystem = require("src.systems.PackInputSystem")
local PackRevealRenderSystem = require("src.systems.PackRevealRenderSystem")

return function(payload)
    local scene = Scene.new("pack")
    scene.world:setResource("runState", Run.current())
    scene:addSystem(PackInputSystem)
    scene:addSystem(PackRevealRenderSystem)
    return scene
end
