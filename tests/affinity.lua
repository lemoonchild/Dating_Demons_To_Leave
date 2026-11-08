package.path = "./?.lua;" .. package.path

local Affinity = require("src.rules.Affinity")

local demon = {
    id = "test", stat = "astucia",
    cards = {
        { name = "A", stat = "astucia", power = 1, rarity = 1, effect = "a" },
        { name = "B", stat = "astucia", power = 2, rarity = 2, effect = "b" },
        { name = "C", stat = "astucia", power = 3, rarity = 3, effect = "c" },
    },
}

local function newRun()
    return {
        stats = { astucia = 1 },
        cards = {},
        affinity = { test = 0 },
        rewards = { test = 0 },
    }
end

local T = Affinity.THRESHOLDS
local good = { affinity = 2 }
local bad = { affinity = -1 }

local run = newRun()
local r = Affinity.apply(run, demon, good)
assert(run.affinity.test == 2 and r.delta == 2, "la afinidad no subió")
assert(run.stats.astucia == 1, "hablar movió una stat: las stats solo salen de entrenar")
assert(#r.cards == 0, "regaló carta antes del primer umbral")

r = Affinity.apply(run, demon, good, T[1] - 2)
assert(run.affinity.test == T[1], "no llegó justo al primer umbral")
assert(#r.cards == 1 and r.cards[1].name == "A", "no regaló la carta del primer umbral")
assert(#run.cards == 1 and run.cards[1].from == "test", "la carta no llegó a la colección")
assert(run.cards[1].rarity and run.cards[1].effect, "la carta llegó sin rareza ni efecto")

Affinity.apply(run, demon, bad, -3)
r = Affinity.apply(run, demon, good, 3)
assert(run.affinity.test == T[1], "no volvió al primer umbral")
assert(#r.cards == 0 and #run.cards == 1, "regaló la misma carta dos veces")

local low = newRun()
local r2 = Affinity.apply(low, demon, bad)
assert(low.affinity.test == -1 and r2.delta == -1, "la afinidad no bajó de 0")
assert(low.stats.astucia == 1, "una mala respuesta cambió la stat")

for _ = 1, 10 do Affinity.apply(run, demon, good) end
assert(run.stats.astucia == 1, "diez respuestas buenas movieron una stat")

for _ = 1, 40 do Affinity.apply(low, demon, bad) end
assert(low.affinity.test == Affinity.MIN, "la afinidad pasó el mínimo")
assert(#low.cards == 0, "un demonio que te detesta regaló cartas")

local high = newRun()
for _ = 1, 40 do Affinity.apply(high, demon, good) end
assert(high.affinity.test == Affinity.MAX, "la afinidad pasó el máximo")
assert(#high.cards == 3, "no entregó las tres cartas")
assert(high.cards[1].name == "A" and high.cards[2].name == "B" and high.cards[3].name == "C",
    "las cartas no salieron en orden")

local jump = newRun()
r = Affinity.apply(jump, demon, good, T[2])
assert(#r.cards == 2, "un salto de dos umbrales no entregó dos cartas")

-- grant entrega la próxima carta sin mirar umbrales (lo usa el crítico).
local lucky = newRun()
local card = Affinity.grant(lucky, demon)
assert(card and card.name == "A", "grant no entregó la primera carta")
assert(lucky.affinity.test == 0, "grant movió la afinidad")
assert(lucky.rewards.test == 1, "grant no consumió el contador")
r = Affinity.apply(lucky, demon, good, T[1])
assert(#r.cards == 0, "el umbral volvió a regalar la carta que ya dio el crítico")
for _ = 1, 3 do Affinity.grant(lucky, demon) end
assert(not Affinity.grant(lucky, demon), "grant siguió dando cartas que no existen")

high.cards[1].power = 99
assert(demon.cards[1].power == 1, "la colección comparte tablas con los datos")

assert(Affinity.ratio(Affinity.MIN) == -1 and Affinity.ratio(0) == 0 and Affinity.ratio(Affinity.MAX) == 1,
    "ratio fuera de -1..1")

print("affinity tests passed")
