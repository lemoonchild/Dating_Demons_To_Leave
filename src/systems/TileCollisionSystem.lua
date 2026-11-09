local Collision = require("src.world.Collision")

local TileCollisionSystem = { name = "tileCollision" }

function TileCollisionSystem.update(scene, dt)
    local world = scene.world
    local _, tilemap = world:first("tilemap")

    for _, entity in ipairs(world:query("position", "velocity", "body")) do
        local pos = world:getComponent(entity, "position")
        local velocity = world:getComponent(entity, "velocity")
        local body = world:getComponent(entity, "body")

        pos.x, pos.y = Collision.move(tilemap.grid, tilemap.cell, body, pos.x, pos.y,
            velocity.x * dt, velocity.y * dt)
    end
end

return TileCollisionSystem
