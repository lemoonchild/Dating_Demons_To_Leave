local TrainingSystem = { name = "training" }

TrainingSystem.GAIN = 2

function TrainingSystem.update(scene, dt)
    local world = scene.world
    local runState = world:resource("runState")

    for _, entity in ipairs(world:query("actionPicked")) do
        local action = world:getComponent(entity, "actionPicked")
        if action.kind == "train" then
            runState.stats[action.stat] = (runState.stats[action.stat] or 0) + TrainingSystem.GAIN
            world:spawn({ event = true, actionDone = true, trained = { stat = action.stat, amount = TrainingSystem.GAIN } })
        end
    end
end

return TrainingSystem
