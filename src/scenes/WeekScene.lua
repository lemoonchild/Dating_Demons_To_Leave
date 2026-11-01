-- La semana: siete días en el infierno para ganarse a los demonios que pueden ayudar a escapar.

local Scene = require("src.ecs.Scene")
local Run = require("src.state.Run")
local demons = require("src.data.demons")

local CameraFollowSystem = require("src.systems.CameraFollowSystem")
local HubWorldRenderSystem = require("src.systems.HubWorldRenderSystem")
local DayMenuUISystem = require("src.systems.DayMenuUISystem")
local DialogueUISystem = require("src.systems.DialogueUISystem")
local DayLoopSystem = require("src.systems.DayLoopSystem")
local AffinitySystem = require("src.systems.AffinitySystem")
local TrainingSystem = require("src.systems.TrainingSystem")
local DayCloseSystem = require("src.systems.DayCloseSystem")
local MoodRollSystem = require("src.systems.MoodRollSystem")
local HudUISystem = require("src.systems.HudUISystem")

return function(payload)
    local scene = Scene.new("week")
    local world = scene.world

    world:setResource("runState", Run.current())
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
    scene:addSystem(DayMenuUISystem)
    scene:addSystem(DialogueUISystem)
    scene:addSystem(DayLoopSystem)
    scene:addSystem(AffinitySystem)
    scene:addSystem(TrainingSystem)
    scene:addSystem(DayCloseSystem)
    scene:addSystem(MoodRollSystem)
    scene:addSystem(HudUISystem)

    return scene
end
