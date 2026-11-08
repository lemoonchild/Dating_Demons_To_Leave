-- La semana: siete días en el infierno para ganarse a los demonios que pueden ayudar a escapar.

local Scene = require("src.ecs.Scene")
local Run = require("src.state.Run")
local demons = require("src.data.demons")

local CameraFollowSystem = require("src.systems.CameraFollowSystem")
local DayMenuInputSystem = require("src.systems.DayMenuInputSystem")
local DialogueInputSystem = require("src.systems.DialogueInputSystem")
local AffinitySystem = require("src.systems.AffinitySystem")
local TrainingSystem = require("src.systems.TrainingSystem")
local DayLoopSystem = require("src.systems.DayLoopSystem")
local DayCloseSystem = require("src.systems.DayCloseSystem")
local MoodRollSystem = require("src.systems.MoodRollSystem")
local HubWorldRenderSystem = require("src.systems.HubWorldRenderSystem")
local ReactionPopupSystem = require("src.systems.ReactionPopupSystem")
local DayMenuRenderSystem = require("src.systems.DayMenuRenderSystem")
local DialogueRenderSystem = require("src.systems.DialogueRenderSystem")
local HudRenderSystem = require("src.systems.HudRenderSystem")

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

    -- input -> logica -> render, en ese orden: cada evento se consume
    -- en el mismo frame en que se emite.
    scene:addSystem(CameraFollowSystem)
    scene:addSystem(DayMenuInputSystem)
    scene:addSystem(DialogueInputSystem)
    scene:addSystem(AffinitySystem)
    scene:addSystem(TrainingSystem)
    scene:addSystem(DayLoopSystem)
    scene:addSystem(DayCloseSystem)
    scene:addSystem(MoodRollSystem)
    scene:addSystem(HubWorldRenderSystem)
    scene:addSystem(ReactionPopupSystem)
    scene:addSystem(DayMenuRenderSystem)
    scene:addSystem(DialogueRenderSystem)
    scene:addSystem(HudRenderSystem)

    return scene
end
