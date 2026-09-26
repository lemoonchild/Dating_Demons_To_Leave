local demons = require("src.data.demons")

local run = {}

function run.new()
    local state = {
        circle = 1, -- índice en src/data/circles.lua
        stats = { astucia = 1, encanto = 1, furia = 1 },
        cards = {}, -- cartas que regalan los demonios
        affinity = {}, 
        rewards = {}, 
        talks = {},
    }
    for _, demon in ipairs(demons) do
        state.affinity[demon.id] = 0
        state.rewards[demon.id] = 0
        state.talks[demon.id] = 1
    end
    return state
end

return run
