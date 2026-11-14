local demons = require("src.data.demons")
local Affinity = require("src.rules.Affinity")

local CompanySystem = { name = "company" }

function CompanySystem.update(scene, dt)
    local world = scene.world
    local runState = world:resource("runState")

    for _, entity in ipairs(world:query("companyKept")) do
        local kept = world:getComponent(entity, "companyKept")
        local demon = demons[kept.demonId]
        local result = Affinity.apply(runState, demon, nil, Affinity.COMPANY)

        for _, card in ipairs(result.cards) do
            world:spawn({ event = true, cardGained = { demonId = demon.id, card = card } })
        end

        world:spawn({
            event = true,
            reactionApplied = { demonId = demon.id, affinity = result.delta },
        })

        world:setResource("lastReaction", {
            demonId = demon.id,
            affinity = result.delta,
            company = true,
        })
    end
end

return CompanySystem
