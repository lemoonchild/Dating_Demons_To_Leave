-- La cámara del mundo se desliza hacia el demonio con el que hablas.
-- No es UI: mueve el resource `camera`, que solo usa HubWorldRenderSystem.
-- Sirve para demostrar la separación: el mundo se mueve, la caja de
-- diálogo y el HUD (en espacio de pantalla) se quedan quietos.

local Screen = require("src.Screen")
local demons = require("src.data.demons")

local CameraFollowSystem = { name = "cameraFollow" }

local FOLLOW = 0.5 -- 1 = centrar al demonio del todo, 0 = no moverse
local SPEED = 4 -- qué tan rápido llega la cámara

function CameraFollowSystem.update(scene, dt)
    local world = scene.world
    local camera = world:resource("camera")
    local _, dialogue = world:first("dialogue")
    if not dialogue then return end

    local talkingId = demons[dialogue.demonIndex].id
    for _, entity in ipairs(world:query("position", "demonSprite")) do
        if world:getComponent(entity, "demonSprite").demonId == talkingId then
            local pos = world:getComponent(entity, "position")
            local targetX = (pos.x - Screen.w / 2) * FOLLOW
            camera.x = camera.x + (targetX - camera.x) * math.min(1, SPEED * dt)
        end
    end
end

return CameraFollowSystem
