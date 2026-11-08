local PackGen = require("src.rules.PackGen")

local DayCloseSystem = { name = "dayClose" }

function DayCloseSystem.update(scene, dt)
    local world = scene.world
    local phase = world:resource("dayPhase")
    if phase.phase ~= "closing" then return end

    local runState = world:resource("runState")
    local entries = {}
    for _, entry in ipairs(runState.log) do
        if entry.day == runState.day then
            entries[#entries + 1] = entry
        end
    end

    runState.pendingPack = PackGen.forDay(runState, entries, love.math.random)
    runState.day = runState.day + 1

    phase.phase = "over"
    world:spawn({ switchRequest = { to = "pack" } })
end

return DayCloseSystem
