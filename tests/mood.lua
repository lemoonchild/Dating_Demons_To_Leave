package.path = "./?.lua;" .. package.path

local Mood = require("src.rules.Mood")
local moods = require("src.data.moods")

local function seeded(seed)
    local state = seed
    return function(n)
        state = (1103515245 * state + 12345) % 2147483648
        return state % n + 1
    end
end

local demons = { { id = "a" }, { id = "b" }, { id = "c" } }

local function newRun()
    local state = { affinity = {}, moods = {} }
    for _, demon in ipairs(demons) do
        state.affinity[demon.id] = 0
        state.moods[demon.id] = "neutral"
    end
    return state
end

local run = newRun()
Mood.roll(run, demons, seeded(7))
for _, demon in ipairs(demons) do
    assert(moods[run.moods[demon.id]], "salió un humor que no existe: " .. tostring(run.moods[demon.id]))
end

local a, b = newRun(), newRun()
Mood.roll(a, demons, seeded(99))
Mood.roll(b, demons, seeded(99))
for _, demon in ipairs(demons) do
    assert(a.moods[demon.id] == b.moods[demon.id], "la misma semilla dio humores distintos")
end

local bag = newRun()
local random = seeded(3)
local seen = {}
for _ = 1, #moods do
    Mood.roll(bag, demons, random)
    local id = bag.moods.a
    assert(not seen[id], "la bolsa repitió " .. id .. " antes de vaciarse")
    seen[id] = true
end
assert(#moods == 5, "la bolsa base ya no tiene 5 humores")

local loved = Mood.bagFor(Mood.LIKES)
local hasFurioso = false
for _, id in ipairs(loved) do if id == "furioso" then hasFurioso = true end end
assert(not hasFurioso, "un demonio que te quiere todavía puede amanecer furioso")

local hated = Mood.bagFor(Mood.HATES)
local hasRadiante = false
for _, id in ipairs(hated) do if id == "radiante" then hasRadiante = true end end
assert(not hasRadiante, "un demonio que te detesta todavía puede amanecer radiante")

assert(Mood.scale(2, "neutral") == 2, "neutral cambió una ganancia")
assert(Mood.scale(-1, "neutral") == -1, "neutral cambió una pérdida")
assert(Mood.scale(2, "radiante") == 3, "radiante no premió")
assert(Mood.scale(2, "furioso") == 1, "una buena respuesta con furioso llegó a cero")
assert(Mood.scale(-1, "furioso") == -2, "furioso no castigó de más")
assert(Mood.scale(-1, "radiante") == -1, "radiante perdonó de más")
assert(Mood.scale(0, "furioso") == 0, "una respuesta neutra movió la afinidad")
assert(Mood.scale(2, "no-existe") == 2, "un humor desconocido no cayó a neutral")

print("mood tests passed")
