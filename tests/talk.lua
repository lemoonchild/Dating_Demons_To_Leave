package.path = "./?.lua;" .. package.path

local Talk = require("src.rules.Talk")
local Mood = require("src.rules.Mood")
local Run = require("src.state.Run")
local demons = require("src.data.demons")

local function seeded(seed)
    local state = seed
    return function(n)
        state = (1103515245 * state + 12345) % 2147483648
        return state % n + 1
    end
end

local azazel = demons.azazel

local function newRun(affinity, mood)
    return {
        affinity = { azazel = affinity or 0 },
        moods = { azazel = mood or "neutral" },
        talks = { azazel = {} },
    }
end

local function threadOf(demon, band)
    local list = {}
    for _, conversation in ipairs(demon.conversations) do
        if conversation.mood == band then list[#list + 1] = conversation end
    end
    return list
end

assert(Talk.band("furioso") == "mal", "furioso no cayó en la banda mal")
assert(Talk.band("arisco") == "mal", "arisco no cayó en la banda mal")
assert(Talk.band("neutral") == "neutral", "neutral no cayó en su banda")
assert(Talk.band("receptivo") == "bien", "receptivo no cayó en la banda bien")
assert(Talk.band("radiante") == "bien", "radiante no cayó en la banda bien")

for _, case in ipairs({ { "furioso", "mal" }, { "neutral", "neutral" }, { "radiante", "bien" } }) do
    local conversation = Talk.pick(newRun(0, case[1]), azazel)
    assert(conversation, "con humor " .. case[1] .. " no salió ninguna conversación")
    assert(conversation.mood == case[2],
        "con humor " .. case[1] .. " salió una conversación de banda " .. conversation.mood)
end

local run = newRun(20, "arisco")
for i, expected in ipairs(threadOf(azazel, "mal")) do
    local conversation = Talk.pick(run, azazel)
    assert(conversation and conversation.id == expected.id,
        "la parte " .. i .. " del hilo mal salió fuera de orden")
    Talk.use(run, azazel, conversation)
end
assert(not Talk.pick(run, azazel), "con el hilo mal terminado todavía contó algo de mal humor")
assert(Talk.quietLine(run, azazel) == azazel.quiet.mal, "sin nada que contar no dijo la frase de su humor")
assert(Talk.hasAny(run, azazel), "le quedan otros hilos y hasAny dice que no")

local locked = newRun(0, "furioso")
Talk.use(locked, azazel, Talk.pick(locked, azazel))
assert(not Talk.pick(locked, azazel), "contó una parte que pedía más confianza")
assert(Talk.quietLine(locked, azazel) == azazel.quiet.mal, "con la parte bloqueada no dijo la frase de su humor")
locked.affinity.azazel = 7
assert(Talk.pick(locked, azazel).minAffinity == 7, "con afinidad 7 no siguió el hilo")

local drained = newRun(5, "neutral")
for _, band in ipairs(Talk.BANDS) do
    Talk.use(drained, azazel, threadOf(azazel, band)[1])
end
assert(not Talk.hasAny(drained, azazel), "con todo lo abierto usado, hasAny dice que queda algo")
assert(Talk.hasLocked(drained, azazel), "quedaban partes con candado y hasLocked no las vio")
local all = newRun(20, "neutral")
for _, conversation in ipairs(azazel.conversations) do Talk.use(all, azazel, conversation) end
assert(not Talk.hasAny(all, azazel) and not Talk.hasLocked(all, azazel), "después de contarlo todo quedaba algo")
assert(not Talk.canVisit(all, azazel), "se puede visitar a un demonio que ya contó todo")

local hated = newRun(-10, "neutral")
local first = Talk.pick(hated, azazel)
assert(first and first.id == threadOf(azazel, "neutral")[1].id,
    "con afinidad negativa se cerró el inicio de un hilo")

local today = newRun(0, "neutral")
today.day = 3
today.log = { { day = 2, kind = "visit", demonId = "azazel" }, { day = 3, kind = "train", stat = "astucia" } }
assert(not Talk.visitedToday(today, azazel), "una visita de ayer cuenta como de hoy")
assert(Talk.canVisit(today, azazel), "sin visitarlo hoy no se lo puede visitar")
today.log[#today.log + 1] = { day = 3, kind = "visit", demonId = "azazel" }
assert(Talk.visitedToday(today, azazel), "la visita de hoy no se registró")
assert(not Talk.canVisit(today, azazel), "se puede visitar dos veces al mismo demonio en un día")
assert(Talk.canVisit(drained, azazel), "con partes bloqueadas no se lo puede visitar para hacerle compañía")

local random = seeded(7)
local talks = 0
for seed = 1, 2000 do
    local state = Run.new(seed)
    for _ = 1, Run.DAYS do
        Mood.roll(state, demons, random)
        for _ = 1, Run.ACTIONS do
            local demon = demons[random(#demons)]
            local conversation = Talk.pick(state, demon)
            if conversation then
                talks = talks + 1
                assert(conversation.mood == Talk.band(state.moods[demon.id]),
                    demon.name .. " contó " .. conversation.id .. " estando " .. state.moods[demon.id])
                Talk.use(state, demon, conversation)
                local option = conversation.options[random(#conversation.options)]
                state.affinity[demon.id] = state.affinity[demon.id] + Mood.scale(option.affinity, state.moods[demon.id])
            end
        end
    end
end
assert(talks > 0, "en dos mil semanas no se habló nunca")

local ids = {}
for _, demon in ipairs(demons) do
    for _, band in ipairs(Talk.BANDS) do
        local thread = threadOf(demon, band)
        assert(#thread > 0 and thread[1].minAffinity == nil,
            demon.name .. " pide confianza para empezar el hilo " .. band)
        for i = 2, #thread do
            assert(thread[i].minAffinity and thread[i].minAffinity >= (thread[i - 1].minAffinity or 0),
                demon.name .. " pide menos confianza en la parte " .. i .. " del hilo " .. band)
        end
        assert(type(demon.quiet[band]) == "string", demon.name .. " no tiene frase para cuando está " .. band)
    end
    for _, conversation in ipairs(demon.conversations) do
        assert(conversation.id and conversation.mood and conversation.demand,
            demon.name .. " tiene una conversación sin id, humor o exigencia")
        assert(not ids[conversation.id], "el id " .. conversation.id .. " está repetido")
        ids[conversation.id] = true
        assert(#conversation.options >= 2 and #conversation.options <= 3,
            conversation.id .. " no tiene entre dos y tres respuestas")
    end
end

print("talk tests passed")
