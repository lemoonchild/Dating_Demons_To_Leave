package.path = "./?.lua;" .. package.path

local Reaction = require("src.rules.Reaction")

local function seeded(seed)
    local state = seed
    return function(n)
        state = (1103515245 * state + 12345) % 2147483648
        return state % n + 1
    end
end

local function always(value)
    return function() return value end
end

local spread = Reaction.spreadFor(1, 1)
assert(spread == 3, "margen 0 debería dar ±3, dio " .. spread)
assert(Reaction.spreadFor(3, 1) == 1, "margen 2 debería dar ±1")
assert(Reaction.spreadFor(4, 1) == 0, "margen 3 debería dejar de tirar dados")
assert(Reaction.spreadFor(9, 1) == 0, "un margen enorme no puede dar spread negativo")
assert(Reaction.spreadFor(1, 9) == Reaction.MAX_SPREAD, "el spread no quedó topado")

local sure = Reaction.roll(2, 8, 1, function() error("no debería tirar dados") end)
assert(sure.gain == 2 and sure.roll == 0 and sure.spread == 0, "con la stat dominada la reacción no fue determinista")
assert(not sure.crit, "un resultado seguro no puede ser crítico")

local a = Reaction.roll(2, 1, 1, seeded(42))
local b = Reaction.roll(2, 1, 1, seeded(42))
assert(a.gain == b.gain and a.roll == b.roll, "la misma semilla dio tiradas distintas")

local random = seeded(5)
local low, high = math.huge, -math.huge
for _ = 1, 500 do
    local r = Reaction.roll(2, 1, 1, random)
    assert(r.roll >= -3 and r.roll <= 3, "la tirada se salió de ±3: " .. r.roll)
    low = math.min(low, r.gain)
    high = math.max(high, r.gain)
end
assert(low >= 1, "una buena respuesta terminó valiendo menos de 1: " .. low)
assert(high > 2, "la tirada nunca premió por encima de la base")
assert(low < high, "la tirada no varió nada")

-- A la altura del tema (margen >= 0) el piso protege: una buena respuesta
-- nunca sale negativa y un insulto nunca sale positivo.
local floored = Reaction.roll(2, 4, 4, always(1))
assert(floored.margin == 0, "el margen esperado era 0")
assert(floored.gain == 1, "con margen 0 el piso de una buena respuesta no se respetó: " .. floored.gain)

local badFloored = Reaction.roll(-1, 4, 4, always(2 * 3 + 1))
assert(badFloored.gain <= -1, "con margen 0 un insulto llegó a ser positivo: " .. badFloored.gain)

-- Fuera de tu nivel (margen < 0) el piso desaparece: meterte en un tema que no
-- manejás puede salirte al revés, en los dos sentidos.
local reckless = Reaction.roll(2, 1, 9, always(1))
assert(reckless.margin < 0, "el margen debería ser negativo")
assert(reckless.gain < 0, "un tema muy por encima de tu stat no pudo salir mal: " .. reckless.gain)

local luckyInsult = Reaction.roll(-1, 1, 9, always(2 * Reaction.MAX_SPREAD + 1))
assert(luckyInsult.gain > 0, "fuera de tu nivel un insulto no pudo salir bien: " .. luckyInsult.gain)

-- El tema difícil ya no es estrictamente mejor que el fácil.
local function rangeFor(stat, demand)
    local spread = Reaction.spreadFor(stat, demand)
    local lo, hi = math.huge, -math.huge
    for roll = -spread, spread do
        local g = Reaction.roll(2, stat, demand, always(roll + spread + 1)).gain
        lo, hi = math.min(lo, g), math.max(hi, g)
    end
    return lo, hi
end

local easyLo = rangeFor(1, 1)
local hardLo = rangeFor(1, 3)
assert(hardLo < easyLo, "el tema exigente sigue sin tener desventaja: piso " .. hardLo .. " vs " .. easyLo)

local a1 = select(2, rangeFor(1, 1))
local a2 = select(2, rangeFor(1, 2))
local a3 = select(2, rangeFor(1, 3))
assert(a1 < a2 and a2 < a3, "las tres exigencias no dan techos distintos")

local topRoll = Reaction.roll(2, 1, 1, always(7))
assert(topRoll.roll == 3 and topRoll.crit, "la tirada máxima no marcó crítico")
local nearTop = Reaction.roll(2, 1, 1, always(6))
assert(not nearTop.crit, "una tirada que no es la máxima marcó crítico")

assert(Reaction.roll(0, 1, 1, always(1)).gain ~= nil, "una respuesta neutra rompió la tirada")

print("reaction tests passed")
