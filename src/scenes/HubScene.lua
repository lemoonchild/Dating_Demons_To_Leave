-- El hub: un círculo del infierno donde el jugador habla con los demonios que lo pueden ayudar a escapar. 

local Scene = require("src.ecs.Scene")
local run = require("src.data.run")
local demons = require("src.data.demons")

local HubWorldRenderSystem = require("src.systems.HubWorldRenderSystem")
local DialogueUISystem = require("src.systems.DialogueUISystem")
local AffinitySystem = require("src.systems.AffinitySystem")
local CameraFollowSystem = require("src.systems.CameraFollowSystem")
local HudUISystem = require("src.systems.HudUISystem")

return function(payload)
    local scene = Scene.new("hub")
    local world = scene.world

    world:setResource("runState", payload and payload.runState or run.new())
    world:setResource("camera", { x = 0, y = 0 })

    local spacing = 260
    local firstX = 480 - spacing * (#demons - 1) / 2
    for i, demon in ipairs(demons) do
        world:spawn({
            position = { x = firstX + (i - 1) * spacing, y = 305 },
            demonSprite = { demonId = demon.id },
        })
    end

    scene:addSystem(CameraFollowSystem)
    scene:addSystem(HubWorldRenderSystem)
    scene:addSystem(DialogueUISystem)
    scene:addSystem(AffinitySystem)
    scene:addSystem(HudUISystem)

    return scene
end
