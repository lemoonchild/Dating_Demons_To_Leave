local Scene = require("src.ecs.Scene")
local Run = require("src.state.Run")
local map = require("src.data.map")

local MoodRollSystem = require("src.systems.MoodRollSystem")
local DialogueInputSystem = require("src.systems.DialogueInputSystem")
local AffinitySystem = require("src.systems.AffinitySystem")
local DayLoopSystem = require("src.systems.DayLoopSystem")
local DayCloseSystem = require("src.systems.DayCloseSystem")
local VisitExitSystem = require("src.systems.VisitExitSystem")
local VisitBackgroundRenderSystem = require("src.systems.VisitBackgroundRenderSystem")
local VisitDemonRenderSystem = require("src.systems.VisitDemonRenderSystem")
local ReactionPopupSystem = require("src.systems.ReactionPopupSystem")
local DialogueRenderSystem = require("src.systems.DialogueRenderSystem")
local HudRenderSystem = require("src.systems.HudRenderSystem")

return function(payload)
    local place = map.places[payload and payload.placeId or "archivo"]
    local scene = Scene.new("visit")
    local world = scene.world

    world:setResource("runState", Run.current())
    world:setResource("camera", { x = 0, y = 0 })
    world:setResource("visit", { placeId = place.id })

    world:spawn({
        position = { x = 170, y = 314 },
        demonSprite = { demonId = place.demonId, w = 90, h = 180 },
    })
    world:spawn({ event = true, actionPicked = { kind = "visit", demonId = place.demonId } })

    scene:addSystem(MoodRollSystem)
    scene:addSystem(DialogueInputSystem)
    scene:addSystem(AffinitySystem)
    scene:addSystem(DayLoopSystem)
    scene:addSystem(DayCloseSystem)
    scene:addSystem(VisitExitSystem)
    scene:addSystem(VisitBackgroundRenderSystem)
    scene:addSystem(VisitDemonRenderSystem)
    scene:addSystem(ReactionPopupSystem)
    scene:addSystem(DialogueRenderSystem)
    scene:addSystem(HudRenderSystem)

    return scene
end
