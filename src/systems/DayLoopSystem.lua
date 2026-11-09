local DayLoopSystem = { name = "dayLoop" }

function DayLoopSystem.setup(scene)
    local runState = scene.world:resource("runState")
    scene.world:setResource("dayPhase", { phase = "choosing", left = runState.actionsLeft })
end

function DayLoopSystem.update(scene, dt)
    local world = scene.world
    local phase = world:resource("dayPhase")
    local runState = world:resource("runState")

    for _, entity in ipairs(world:query("actionPicked")) do
        local action = world:getComponent(entity, "actionPicked")
        phase.kind = action.kind
        phase.demonId = action.demonId
        phase.stat = action.stat
        phase.phase = action.kind == "visit" and "acting" or "resolving"
    end

    if #world:query("actionDone") > 0 then
        local kind = phase.kind
        runState.log[#runState.log + 1] = {
            day = runState.day,
            kind = kind,
            demonId = phase.demonId,
            stat = phase.stat,
            mood = phase.demonId and runState.moods[phase.demonId],
        }
        phase.left = kind == "train" and 0 or phase.left - 1
        runState.actionsLeft = phase.left
        phase.kind, phase.demonId, phase.stat = nil, nil, nil
        phase.phase = phase.left > 0 and "choosing" or "closing"
    end
end

return DayLoopSystem
