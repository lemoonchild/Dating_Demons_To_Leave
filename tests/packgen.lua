package.path = "./?.lua;" .. package.path

local PackGen = require("src.rules.PackGen")
local cards = require("src.data.cards")
local demons = require("src.data.demons")

local function seeded(seed)
    local state = seed
    return function(n)
        state = (1103515245 * state + 12345) % 2147483648
        return state % n + 1
    end
end

local function newRun(astucia, affinity)
    return {
        stats = { astucia = astucia or 1, encanto = 1, furia = 1 },
        affinity = { azazel = affinity or 0, lilim = affinity or 0, brasa = affinity or 0 },
    }
end

local visit = { { kind = "visit", demonId = "azazel", mood = "neutral" } }
local train = { { kind = "train", stat = "furia" } }

local pack = PackGen.forDay(newRun(), visit, seeded(1))
assert(#pack >= PackGen.MIN and #pack <= PackGen.MAX, "el paquete salió de rango: " .. #pack)
for _, card in ipairs(pack) do
    assert(card.name and card.stat and card.power and card.rarity and card.effect,
        "una carta salió sin todos sus datos")
end

local a = PackGen.forDay(newRun(), visit, seeded(77))
local b = PackGen.forDay(newRun(), visit, seeded(77))
assert(#a == #b, "la misma semilla dio paquetes de distinto tamaño")
for i = 1, #a do
    assert(a[i].name == b[i].name and a[i].power == b[i].power, "la misma semilla dio paquetes distintos")
end

-- El tamaño del paquete sale de la afinidad con quien visitaste.
assert(PackGen.sizeFor(newRun(1, -1), visit) == PackGen.NONE, "un demonio que te detesta igual dio carta")
assert(PackGen.sizeFor(newRun(1, -9), visit) == PackGen.NONE, "afinidad muy negativa igual dio carta")
assert(#PackGen.forDay(newRun(1, -4), visit, seeded(1)) == 0, "el paquete de un día malo no salió vacío")
assert(PackGen.sizeFor(newRun(1, 0), visit) == PackGen.MIN, "un desconocido no dio el mínimo")
assert(PackGen.sizeFor(newRun(1, PackGen.CLOSE), visit) == PackGen.MIN + 1, "la afinidad CLOSE no sumó una carta")
assert(PackGen.sizeFor(newRun(1, PackGen.FRIEND), visit) == PackGen.MAX, "la afinidad FRIEND no llegó al máximo")
assert(PackGen.sizeFor(newRun(1, 99), visit) == PackGen.MAX, "el paquete se pasó del máximo")
-- Entrenar sube stats, no da cartas: el juego es sobre los demonios.
assert(PackGen.sizeFor(newRun(1, PackGen.FRIEND), train) == PackGen.NONE,
    "entrenar dio cartas aunque no visitaste a nadie")
assert(#PackGen.forDay(newRun(1, PackGen.FRIEND), train, seeded(5)) == 0,
    "un día de puro entrenamiento dejó cartas")
local twoTrainings = { { kind = "train", stat = "furia" }, { kind = "train", stat = "astucia" } }
assert(#PackGen.forDay(newRun(1, PackGen.FRIEND), twoTrainings, seeded(5)) == 0,
    "entrenar dos veces dio cartas")

-- Con dos acciones manda la mejor: una visita buena salva un día con una mala.
local mixed = { { kind = "visit", demonId = "azazel", mood = "neutral" },
                { kind = "visit", demonId = "lilim",  mood = "neutral" } }
local rescued = { stats = { astucia = 1, encanto = 1, furia = 1 },
                  affinity = { azazel = -5, lilim = PackGen.CLOSE, brasa = 0 } }
assert(PackGen.sizeFor(rescued, mixed) == PackGen.MIN + 1,
    "una visita buena no rescató el día de una mala")

-- Las cartas son de las stats de lo que hiciste ese día.
for _, card in ipairs(PackGen.forDay(newRun(1, PackGen.FRIEND), visit, seeded(5))) do
    assert(card.stat == demons.azazel.stat, "visitar a Azazel dio una carta que no es de su stat")
end
-- Un día mixto da cartas solo de la stat del demonio que visitaste.
local mixedDay = { visit[1], { kind = "train", stat = "furia" } }
local mixedPack = PackGen.forDay(newRun(1, PackGen.FRIEND), mixedDay, seeded(5))
assert(#mixedPack > 0, "un día con una visita no dio cartas")
for _, card in ipairs(mixedPack) do
    assert(card.stat == demons.azazel.stat, "entrenar se coló en el paquete con una carta de su stat")
end

-- Dos visitas sí reparten entre las dos stats.
local twoVisits = { visit[1], { kind = "visit", demonId = "brasa", mood = "neutral" } }
local seen = {}
for _, card in ipairs(PackGen.forDay(newRun(1, PackGen.FRIEND), twoVisits, seeded(5))) do
    seen[card.stat] = true
end
assert(seen[demons.azazel.stat] and seen[demons.brasa.stat],
    "dos visitas distintas no repartieron entre las dos stats")

assert(#PackGen.forDay(newRun(), {}, seeded(1)) == 0, "un día sin acciones dio cartas")

-- El humor mueve la rareza máxima.
local run = newRun()
local furious = PackGen.maxRarity(PackGen.qualityOf(run, { { kind = "visit", demonId = "azazel", mood = "furioso" } }))
local neutral = PackGen.maxRarity(PackGen.qualityOf(run, { { kind = "visit", demonId = "azazel", mood = "neutral" } }))
local radiant = PackGen.maxRarity(PackGen.qualityOf(run, { { kind = "visit", demonId = "azazel", mood = "radiante" } }))
assert(furious <= neutral and neutral < radiant, "el humor no mueve la rareza: " .. furious .. " " .. neutral .. " " .. radiant)
assert(furious == 1, "con un demonio furioso debería caer solo lo común")

-- Entrenar da un paquete más flojo que visitar con el mismo humor neutral.
assert(PackGen.qualityOf(run, train) < PackGen.qualityOf(run, { { kind = "visit", demonId = "brasa", mood = "neutral" } }),
    "entrenar no salió más flojo que visitar")

-- Tu stat sube la rareza máxima y el poder.
local weak = PackGen.maxRarity(PackGen.qualityOf(newRun(1), visit))
local strong = PackGen.maxRarity(PackGen.qualityOf(newRun(9), visit))
assert(strong > weak, "subir la stat no abrió rarezas mejores")

local poor = PackGen.forDay(newRun(1, PackGen.FRIEND), visit, seeded(3))
local rich = PackGen.forDay(newRun(12, PackGen.FRIEND), visit, seeded(3))
local poorMax, richMax = 0, 0
for i = 1, #poor do poorMax = math.max(poorMax, poor[i].power) end
for i = 1, #rich do richMax = math.max(richMax, rich[i].power) end
assert(richMax > poorMax, "subir la stat no subió el poder de las cartas")

-- La rareza máxima se respeta siempre.
local capped = PackGen.forDay(newRun(), { { kind = "visit", demonId = "azazel", mood = "furioso" } }, seeded(9))
for _, card in ipairs(capped) do
    assert(card.rarity == 1, "con humor furioso salió una carta de rareza " .. card.rarity)
end
assert(PackGen.maxRarity(99) == #cards.rarities, "la rareza máxima se pasó del tope")
assert(PackGen.maxRarity(-99) == 1, "la rareza máxima cayó por debajo de 1")

-- Las cartas se copian: tocar una de la colección no toca los datos del juego.
local original = cards.astucia[1].power
local mine = PackGen.forDay(newRun(), visit, seeded(2))
mine[1].power = 999
assert(cards.astucia[1].power == original, "la colección comparte tablas con src/data/cards.lua")

print("packgen tests passed")
