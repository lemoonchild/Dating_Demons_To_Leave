package.path = "./?.lua;" .. package.path

local Reaction = require("src.rules.Reaction")
local Mood     = require("src.rules.Mood")
local Affinity = require("src.rules.Affinity")
local Talk     = require("src.rules.Talk")
local PackGen  = require("src.rules.PackGen")
local Run      = require("src.state.Run")
local demons   = require("src.data.demons")

local N = tonumber(arg and arg[1]) or 20000
local CSV = arg and arg[2]

math.randomseed(tonumber(arg and arg[3]) or 7)
local random = function(n) return math.random(n) end

local rolls = {}

local function newRun()
    local run = { stats = { astucia = 1, encanto = 1, furia = 1 }, cards = {},
                  affinity = {}, rewards = {}, talks = {}, moods = {}, bags = {}, log = {} }
    for _, demon in ipairs(demons) do
        run.affinity[demon.id] = 0
        run.rewards[demon.id] = 0
        run.talks[demon.id] = {}
        run.moods[demon.id] = "neutral"
    end
    return run
end

local function playWeek(smart, record)
    local run = newRun()
    for day = 1, Run.DAYS do
        Mood.roll(run, demons, random)
        local entries = {}
        for _ = 1, Run.ACTIONS do
            local pool = {}
            for _, demon in ipairs(demons) do
                if Talk.hasAny(run, demon) then pool[#pool + 1] = demon end
            end
            if #pool == 0 then break end

            local pick = pool[random(#pool)]
            if smart then
                local bestQuality = -99
                for _, demon in ipairs(pool) do
                    local quality = Mood.of(run.moods[demon.id]).quality
                    if quality > bestQuality then pick, bestQuality = demon, quality end
                end
            end

            local conversation = Talk.pick(run, pick, random)
            local option = smart and conversation.options[1]
                or conversation.options[random(#conversation.options)]
            local rolled = Reaction.roll(option.affinity, run.stats[pick.stat], conversation.demand, random)
            local gain = Mood.scale(rolled.gain, run.moods[pick.id])
            Affinity.apply(run, pick, option, gain)
            Talk.use(run, pick, conversation)

            if record then
                rolls[#rolls + 1] = {
                    day, pick.id, run.moods[pick.id], conversation.demand,
                    run.stats[pick.stat], rolled.spread, rolled.roll, gain, run.affinity[pick.id],
                }
            end
            entries[#entries + 1] = { kind = "visit", demonId = pick.id, mood = run.moods[pick.id] }
        end
        for _, card in ipairs(PackGen.forDay(run, entries, random)) do
            run.cards[#run.cards + 1] = card
        end
    end
    return run
end

local function percentile(sorted, p)
    return sorted[math.max(1, math.min(#sorted, math.floor(#sorted * p + 0.5)))]
end

local function report(label, smart, record)
    local totals, demonCards, maxed, third, worst = {}, 0, 0, 0, nil
    for i = 1, N do
        local run = playWeek(smart, record and i <= 200)
        totals[#totals + 1] = #run.cards
        local high = -99
        for _, demon in ipairs(demons) do
            high = math.max(high, run.affinity[demon.id])
            demonCards = demonCards + run.rewards[demon.id]
        end
        if high >= Affinity.MAX then maxed = maxed + 1 end
        if high >= Affinity.THRESHOLDS[3] then third = third + 1 end
        if not worst or #run.cards < worst then worst = #run.cards end
    end
    table.sort(totals)
    local sum = 0
    for _, v in ipairs(totals) do sum = sum + v end

    print(("  %-18s cartas: min %d  p1 %d  media %.2f  p99 %d  max %d")
        :format(label, totals[1], percentile(totals, 0.01), sum / N, percentile(totals, 0.99), totals[#totals]))
    print(("  %-18s cartas de demonio: %.2f/semana   tope de afinidad: %.1f%%   tercer umbral: %.1f%%")
        :format("", demonCards / N, maxed / N * 100, third / N * 100))
    return totals[1]
end

print()
print(("SIMULADOR -- %d semanas de %d dias x %d acciones"):format(N, Run.DAYS, Run.ACTIONS))
print(("afinidad %d..%d, umbrales %s")
    :format(Affinity.MIN, Affinity.MAX, table.concat(Affinity.THRESHOLDS, "/")))
print()
local worstSmart = report("jugando perfecto", true, true)
print()
local worstRandom = report("jugando al azar", false, false)
print()
print(("PEOR CASO: la semana mas desafortunada de %d jugando bien dejo %d cartas"):format(N, worstSmart))
if worstSmart == 0 then
    print("  ATENCION: jugando bien se puede terminar sin nada. Revisar el piso.")
end

if CSV then
    local file = assert(io.open(CSV, "w"))
    file:write("dia,demonio,humor,exigencia,stat,spread,tirada,ganancia,afinidad\n")
    for _, row in ipairs(rolls) do
        file:write(table.concat(row, ",") .. "\n")
    end
    file:close()
    print(("  CSV con %d tiradas -> %s"):format(#rolls, CSV))
end
print()
