local Movement = require("src.world.Movement")

local MovementSystem = { name = "movement" }

function MovementSystem.update(scene, dt)
    local world = scene.world
    for _, entity in ipairs(world:query("moveIntent", "velocity", "walker")) do
        local intent = world:getComponent(entity, "moveIntent")
        local velocity = world:getComponent(entity, "velocity")
        local speed = world:getComponent(entity, "walker").speed

        local dx, dy = Movement.direction(intent.dx, intent.dy)
        velocity.x = dx * speed
        velocity.y = dy * speed
    end
end

return MovementSystem
