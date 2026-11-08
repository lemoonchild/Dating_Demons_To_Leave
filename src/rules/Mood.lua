local moods = require("src.data.moods")

local Mood = {}

Mood.DEFAULT = "neutral"
Mood.LIKES = 12
Mood.HATES = -6

local function shuffle(bag, random)
    for i = #bag, 2, -1 do
        local j = random(i)
        bag[i], bag[j] = bag[j], bag[i]
    end
end

local function replace(bag, from, to)
    for i, id in ipairs(bag) do
        if id == from then
            bag[i] = to
            return
        end
    end
end

function Mood.bagFor(affinity)
    local bag = {}
    for _, mood in ipairs(moods) do
        bag[#bag + 1] = mood.id
    end
    if affinity >= Mood.LIKES then
        replace(bag, "furioso", "radiante")
    elseif affinity <= Mood.HATES then
        replace(bag, "radiante", "furioso")
    end
    return bag
end

function Mood.roll(runState, demons, random)
    runState.bags = runState.bags or {}
    for _, demon in ipairs(demons) do
        local bag = runState.bags[demon.id]
        if not bag or #bag == 0 then
            bag = Mood.bagFor(runState.affinity[demon.id] or 0)
            shuffle(bag, random)
            runState.bags[demon.id] = bag
        end
        runState.moods[demon.id] = table.remove(bag)
    end
    return runState.moods
end

function Mood.of(moodId)
    return moods[moodId] or moods[Mood.DEFAULT]
end

function Mood.scale(base, moodId)
    local mood = Mood.of(moodId)
    if base > 0 then
        return math.ceil(base * mood.gain)
    elseif base < 0 then
        return math.floor(base * mood.loss)
    end
    return 0
end

return Mood
