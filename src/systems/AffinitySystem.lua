-- Aplica las consecuencias de lo que respondió el jugador. 

local demons = require("src.data.demons")
local Affinity = require("src.rules.Affinity")
local Mood = require("src.rules.Mood")
local Reaction = require("src.rules.Reaction")

local AffinitySystem = { name = "affinity" }

function AffinitySystem.update(scene, dt)
    local world = scene.world
    local runState = world:resource("runState")

    for _, entity in ipairs(world:query("dialogueChoice")) do
        local choice = world:getComponent(entity, "dialogueChoice")
        local demon = demons[choice.demonId]
        local conversation = demon.conversations[choice.conversation]
        local option = conversation.options[choice.option]

        local rolled = Reaction.roll(option.affinity or 0, runState.stats[demon.stat],
            conversation.demand, love.math.random)
        local result = Affinity.apply(runState, demon, option,
            Mood.scale(rolled.gain, runState.moods[demon.id]))

        if rolled.crit then
            local card = Affinity.grant(runState, demon)
            if card then
                result.cards[#result.cards + 1] = card
            end
        end

        for _, card in ipairs(result.cards) do
            world:spawn({ event = true, cardGained = { demonId = demon.id, card = card } })
        end

        world:spawn({
            event = true,
            reactionApplied = { demonId = demon.id, affinity = result.delta, crit = rolled.crit },
        })

        world:setResource("lastReaction", {
            demonId = demon.id,
            affinity = result.delta,
            stat = result.stat,
            statName = demon.stat,
            roll = rolled.roll,
            spread = rolled.spread,
            crit = rolled.crit,
        })
    end
end

return AffinitySystem
