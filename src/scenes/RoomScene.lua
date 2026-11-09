local Scene = require("src.ecs.Scene")
local Run = require("src.state.Run")

local MoodRollSystem = require("src.systems.MoodRollSystem")
local RoomMenuInputSystem = require("src.systems.RoomMenuInputSystem")
local TrainingSystem = require("src.systems.TrainingSystem")
local DayLoopSystem = require("src.systems.DayLoopSystem")
local DayCloseSystem = require("src.systems.DayCloseSystem")
local RoomRenderSystem = require("src.systems.RoomRenderSystem")
local RoomMenuRenderSystem = require("src.systems.RoomMenuRenderSystem")
local HudRenderSystem = require("src.systems.HudRenderSystem")

return function(payload)
    local scene = Scene.new("room")
    scene.world:setResource("runState", Run.current())

    scene:addSystem(MoodRollSystem)
    scene:addSystem(RoomMenuInputSystem)
    scene:addSystem(TrainingSystem)
    scene:addSystem(DayLoopSystem)
    scene:addSystem(DayCloseSystem)
    scene:addSystem(RoomRenderSystem)
    scene:addSystem(RoomMenuRenderSystem)
    scene:addSystem(HudRenderSystem)

    return scene
end
