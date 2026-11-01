local Run = require("src.state.Run")

local DayCloseSystem = { name = "dayClose" }

function DayCloseSystem.update(scene, dt)
    local world = scene.world
    local phase = world:resource("dayPhase")
    if phase.phase ~= "closing" then return end

    local runState = world:resource("runState")
    runState.log[#runState.log + 1] = {
        day = runState.day,
        kind = phase.kind,
        demonId = phase.demonId,
        stat = phase.stat,
        mood = phase.demonId and runState.moods[phase.demonId],
    }

    if runState.day >= Run.DAYS then
        phase.phase = "over"
        world:spawn({ switchRequest = { to = "menu" } })
        return
    end

    runState.day = runState.day + 1
    phase.phase = "choosing"
    phase.kind = nil
    phase.demonId = nil
    phase.stat = nil
    world:spawn({ event = true, dayStarted = { day = runState.day } })
end

return DayCloseSystem
