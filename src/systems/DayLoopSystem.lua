local DayLoopSystem = { name = "dayLoop" }

function DayLoopSystem.setup(scene)
    scene.world:setResource("dayPhase", { phase = "choosing" })
end

function DayLoopSystem.update(scene, dt)
    local world = scene.world
    local phase = world:resource("dayPhase")

    for _, entity in ipairs(world:query("actionPicked")) do
        local action = world:getComponent(entity, "actionPicked")
        phase.kind = action.kind
        phase.demonId = action.demonId
        phase.stat = action.stat
        phase.phase = action.kind == "visit" and "acting" or "closing"
    end

    if #world:query("dayDone") > 0 then
        phase.phase = "closing"
    end
end

return DayLoopSystem
