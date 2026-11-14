local TrainingSystem = { name = "training" }

TrainingSystem.GAIN = 2

function TrainingSystem.gainFor(left)
    return TrainingSystem.GAIN * math.max(left or 0, 1)
end

function TrainingSystem.update(scene, dt)
    local world = scene.world
    local runState = world:resource("runState")
    local left = world:resource("dayPhase").left

    for _, entity in ipairs(world:query("actionPicked")) do
        local action = world:getComponent(entity, "actionPicked")
        if action.kind == "train" then
            local amount = TrainingSystem.gainFor(left)
            runState.stats[action.stat] = (runState.stats[action.stat] or 0) + amount
            world:spawn({ event = true, actionDone = true, trained = { stat = action.stat, amount = amount } })
        end
    end
end

return TrainingSystem
