local demons = require("src.data.demons")

local Run = {}

Run.DAYS = 7
Run.ACTIONS = 2

local current = nil

function Run.new(seed)
    local state = {
        day = 1,
        actionsLeft = Run.ACTIONS,
        moodDay = 0,
        seed = seed or os.time(),
        stats = { astucia = 1, encanto = 1, furia = 1 },
        cards = {},
        pendingPack = {},
        affinity = {},
        rewards = {},
        talks = {},
        moods = {},
        bags = {},
        help = {},
        log = {},
    }
    for _, demon in ipairs(demons) do
        state.affinity[demon.id] = 0
        state.rewards[demon.id] = 0
        state.talks[demon.id] = {}
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
