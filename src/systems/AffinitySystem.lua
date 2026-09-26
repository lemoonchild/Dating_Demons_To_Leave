-- Aplica las consecuencias de lo que respondiste. NO es UI: la caja de
-- diálogo solo anuncia "elegí la opción X" con un evento `dialogueChoice`;
-- este sistema lo lee, aplica las reglas (src/rules/Affinity.lua) sobre la
-- partida y, si un demonio te regaló una carta, anuncia `cardGained` para
-- que el HUD reaccione en este mismo frame.
--
--   dialogueChoice { demonId, conversation, option }  ->  runState
--                                                     ->  cardGained { demonId, card }

local demons = require("src.data.demons")
local Affinity = require("src.rules.Affinity")

local AffinitySystem = { name = "affinity" }

function AffinitySystem.update(scene, dt)
    local world = scene.world
    local runState = world:resource("runState")

    for _, entity in ipairs(world:query("dialogueChoice")) do
        local choice = world:getComponent(entity, "dialogueChoice")
        local demon = demons[choice.demonId]
        local option = demon.conversations[choice.conversation].options[choice.option]

        local result = Affinity.apply(runState, demon, option)
        for _, card in ipairs(result.cards) do
            world:spawn({ event = true, cardGained = { demonId = demon.id, card = card } })
        end
    end
end

return AffinitySystem
