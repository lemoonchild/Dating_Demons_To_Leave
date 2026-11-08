package.path = "./?.lua;" .. package.path

local PackGen = require("src.rules.PackGen")
local Affinity = require("src.rules.Affinity")

math.randomseed(tonumber(arg and arg[1]) or 4)
local random = function(n) return math.random(n) end

local function run(affinity, stat)
    return {
        stats = { astucia = stat or 1, encanto = stat or 1, furia = stat or 1 },
        affinity = { azazel = affinity or 0, lilim = affinity or 0, brasa = affinity or 0 },
    }
end

local function visit(demonId, mood)
    return { { kind = "visit", demonId = demonId or "azazel", mood = mood or "neutral" } }
end

local function show(label, state, entries)
    local pack = PackGen.forDay(state, entries, random)
    local parts = {}
    for _, card in ipairs(pack) do
        parts[#parts + 1] = ("%s(%s p%d r%d)"):format(card.name, card.stat:sub(1, 3), card.power, card.rarity)
    end
    print(("  %-40s %d carta(s), rareza max %d  ->  %s")
        :format(label, #pack, PackGen.maxRarity(PackGen.qualityOf(state, entries)),
            #parts > 0 and table.concat(parts, "  ") or "(nada)"))
end

print()
print("LA REGLA DEL PAQUETE, demostrada")
print()
print("1. CUANTAS cartas: la afinidad con quien visitaste")
for _, affinity in ipairs({ -5, -1, 0, PackGen.CLOSE - 1, PackGen.CLOSE, PackGen.FRIEND, Affinity.MAX }) do
    show(("afinidad %d"):format(affinity), run(affinity), visit())
end
show("entrenaste (no visitaste a nadie)", run(Affinity.MAX), { { kind = "train", stat = "furia" } })

print()
print("2. QUE sale: el humor del demonio")
for _, mood in ipairs({ "furioso", "arisco", "neutral", "receptivo", "radiante" }) do
    show("Azazel " .. mood, run(PackGen.FRIEND), visit("azazel", mood))
end

print()
print("3. QUE sale: tu stat sube el poder")
for _, stat in ipairs({ 1, 4, 8, 12 }) do
    show(("stat %d"):format(stat), run(PackGen.FRIEND, stat), visit("azazel", "radiante"))
end

print()
print("4. DE QUE TIPO: a quien visitaste")
for _, demonId in ipairs({ "azazel", "lilim", "brasa" }) do
    show("visitaste a " .. demonId, run(PackGen.FRIEND), visit(demonId))
end
show("dos visitas distintas", run(PackGen.FRIEND), {
    { kind = "visit", demonId = "azazel", mood = "neutral" },
    { kind = "visit", demonId = "brasa", mood = "neutral" },
})
print()
