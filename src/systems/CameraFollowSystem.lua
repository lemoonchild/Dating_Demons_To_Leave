-- La cámara del mundo se desliza hacia el demonio con el que habla el jugador.

local Screen = require("src.Screen")

local CameraFollowSystem = { name = "cameraFollow" }

local FOLLOW = 0.5 -- 1 = centrar al demonio del todo, 0 = no moverse
local SPEED = 4 -- qué tan rápido llega la cámara

function CameraFollowSystem.update(scene, dt)
    local world = scene.world
    local camera = world:resource("camera")
    local _, dialogue = world:first("dialogue")
    if not dialogue then return end

    local targetX = 0
    for _, entity in ipairs(world:query("position", "demonSprite")) do
        if world:getComponent(entity, "demonSprite").demonId == dialogue.demonId then
            local pos = world:getComponent(entity, "position")
            targetX = (pos.x - Screen.w / 2) * FOLLOW
        end
    end
    camera.x = camera.x + (targetX - camera.x) * math.min(1, SPEED * dt)
end

return CameraFollowSystem
