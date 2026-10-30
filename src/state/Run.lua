local demons = require("src.data.demons")

local Run = {}

Run.DAYS = 7

local current = nil

function Run.new(seed)
    local state = {
        day = 1,
        seed = seed or os.time(),
        stats = { astucia = 1, encanto = 1, furia = 1 },
        cards = {},
        affinity = {},
        rewards = {},
        talks = {},
        moods = {},
        help = {},
        log = {},
    }
    for _, demon in ipairs(demons) do
        state.affinity[demon.id] = 0
        state.rewards[demon.id] = 0
        state.talks[demon.id] = 1
        state.moods[demon.id] = "neutral"
        state.help[demon.id] = false
    end
    return state
end

function Run.start(seed)
    current = Run.new(seed)
    return current
end

function Run.current()
    return current or Run.start()
end

function Run.clear()
    current = nil
end

return Run
