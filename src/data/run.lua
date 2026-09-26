-- La partida nueva: el estado que TODAS las escenas leen y escriben.
-- Solo datos planos (números, strings, tablas), para poder guardarlo
-- algún día sin sorpresas.

local demons = require("src.data.demons")

local run = {}

function run.new()
    local state = {
        circle = 1, -- índice en src/data/circles.lua
        stats = { astucia = 1, encanto = 1, furia = 1 },
        cards = {}, -- cartas que te regalaron los demonios
        affinity = {}, -- demonId -> 0..Affinity.MAX
        rewards = {}, -- demonId -> cuántas cartas ya te dio (nunca baja)
    }
    for _, demon in ipairs(demons) do
        state.affinity[demon.id] = 0
        state.rewards[demon.id] = 0
    end
    return state
end

return run
