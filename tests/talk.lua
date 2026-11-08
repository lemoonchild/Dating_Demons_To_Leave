package.path = "./?.lua;" .. package.path

local Talk = require("src.rules.Talk")
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

assert(Talk.band("furioso") == "mal", "furioso no cayó en la banda mal")
assert(Talk.band("arisco") == "mal", "arisco no cayó en la banda mal")
assert(Talk.band("neutral") == "neutral", "neutral no cayó en su banda")
assert(Talk.band("receptivo") == "bien", "receptivo no cayó en la banda bien")
assert(Talk.band("radiante") == "bien", "radiante no cayó en la banda bien")

-- El humor decide QUÉ te cuenta.
for _, case in ipairs({ { "furioso", "mal" }, { "neutral", "neutral" }, { "radiante", "bien" } }) do
    local conversation = Talk.pick(newRun(0, case[1]), azazel, seeded(3))
    assert(conversation, "con humor " .. case[1] .. " no salió ninguna conversación")
    assert(conversation.mood == case[2],
        "con humor " .. case[1] .. " salió una conversación de banda " .. conversation.mood)
end

-- La afinidad abre conversaciones nuevas.
local stranger = Talk.available(newRun(0), azazel, nil)
local known = Talk.available(newRun(7), azazel, nil)
local close = Talk.available(newRun(13), azazel, nil)
assert(#stranger < #known, "subir a 7 de afinidad no abrió conversaciones")
assert(#known < #close, "subir a 13 de afinidad no abrió conversaciones")
assert(#close == #azazel.conversations, "con afinidad alta no están todas disponibles")
for _, conversation in ipairs(stranger) do
    assert(conversation.minAffinity == 0, "un desconocido alcanzó una conversación con candado")
end

-- Una conversación usada no vuelve a salir.
local run = newRun(20, "neutral")
local seen = {}
for i = 1, #azazel.conversations do
    local conversation = Talk.pick(run, azazel, seeded(i))
    assert(conversation, "se acabaron las conversaciones en la vuelta " .. i)
    assert(not seen[conversation.id], "repitió la conversación " .. conversation.id)
    seen[conversation.id] = true
    Talk.use(run, azazel, conversation)
end
assert(not Talk.pick(run, azazel, seeded(1)), "después de usarlas todas todavía quedaba una")
assert(not Talk.hasAny(run, azazel), "hasAny dice que todavía queda algo")

-- Si no queda nada de su humor, cae en lo que haya en vez de dejarte sin nada.
local drained = newRun(0, "radiante")
for _, conversation in ipairs(azazel.conversations) do
    if conversation.mood == "bien" then Talk.use(drained, azazel, conversation) end
end
local fallback = Talk.pick(drained, azazel, seeded(2))
assert(fallback, "sin conversaciones de su humor se quedó sin nada que decir")
assert(fallback.mood ~= "bien", "el fallback devolvió una conversación ya usada")

-- La misma semilla elige la misma conversación.
local a = Talk.pick(newRun(20), azazel, seeded(42))
local b = Talk.pick(newRun(20), azazel, seeded(42))
assert(a.id == b.id, "la misma semilla eligió conversaciones distintas")

-- Todos los demonios cubren las tres bandas desde afinidad 0.
for _, demon in ipairs(demons) do
    for _, band in ipairs({ "mal", "neutral", "bien" }) do
        local run0 = { affinity = { [demon.id] = 0 }, moods = {}, talks = { [demon.id] = {} } }
        local list = Talk.available(run0, demon, band)
        assert(#list > 0, demon.name .. " no tiene nada que decir en la banda " .. band .. " desde cero")
    end
    for _, conversation in ipairs(demon.conversations) do
        assert(conversation.id and conversation.mood and conversation.demand,
            demon.name .. " tiene una conversación sin id, humor o exigencia")
        assert(#conversation.options >= 2, conversation.id .. " tiene menos de dos respuestas")
    end
end

print("talk tests passed")
