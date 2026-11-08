local TrainingSystem = { name = "training" }

function TrainingSystem.update(scene, dt)
    local world = scene.world
    local runState = world:resource("runState")

    for _, entity in ipairs(world:query("actionPicked")) do
        local action = world:getComponent(entity, "actionPicked")
        if action.kind == "train" then
            runState.stats[action.stat] = (runState.stats[action.stat] or 0) + 1
            world:spawn({ event = true, actionDone = true, trained = { stat = action.stat, amount = 1 } })
        end
    end
end

return TrainingSystem
