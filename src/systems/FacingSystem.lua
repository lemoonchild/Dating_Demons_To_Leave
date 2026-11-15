local Movement = require("src.world.Movement")

local FacingSystem = { name = "facing" }

function FacingSystem.update(scene, dt)
    local world = scene.world
    for _, entity in ipairs(world:query("moveIntent", "facing")) do
        local intent = world:getComponent(entity, "moveIntent")
        local facing = world:getComponent(entity, "facing")
        facing.dir = Movement.facing(intent.dx, intent.dy, facing.dir)
    end
end

return FacingSystem
