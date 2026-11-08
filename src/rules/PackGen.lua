local cards = require("src.data.cards")
local stats = require("src.data.stats")
local demons = require("src.data.demons")
local Mood = require("src.rules.Mood")

local PackGen = {}

PackGen.NONE = 0
PackGen.MIN = 1
PackGen.MAX = 3
PackGen.CLOSE = 7
PackGen.FRIEND = 13
PackGen.TRAIN_PENALTY = -1
PackGen.STAT_PER_RARITY = 3
PackGen.STAT_PER_POWER = 4

function PackGen.statOf(entry)
    if entry.kind == "visit" then
        return demons[entry.demonId].stat
    end
    return entry.stat
end

function PackGen.statsOfDay(entries)
    local list = {}
    for _, entry in ipairs(entries) do
        if entry.kind == "visit" then
            list[#list + 1] = PackGen.statOf(entry)
        end
    end
    return list
end

function PackGen.bestAffinity(runState, entries)
    local best = nil
    for _, entry in ipairs(entries) do
        if entry.kind == "visit" then
            local affinity = runState.affinity[entry.demonId] or 0
            best = math.max(best or affinity, affinity)
        end
    end
    return best
end

function PackGen.sizeFor(runState, entries)
    local best = PackGen.bestAffinity(runState, entries)
    if not best or best < 0 then return PackGen.NONE end

    local size = PackGen.MIN
    if best >= PackGen.CLOSE then size = size + 1 end
    if best >= PackGen.FRIEND then size = size + 1 end
    return math.min(size, PackGen.MAX)
end

function PackGen.qualityOf(runState, entries)
    local mood = nil
    for _, entry in ipairs(entries) do
        if entry.kind == "visit" then
            local quality = Mood.of(entry.mood).quality
            mood = math.max(mood or quality, quality)
        end
    end

    local best = 0
    for _, stat in ipairs(PackGen.statsOfDay(entries)) do
        best = math.max(best, runState.stats[stat] or 0)
    end

    return (mood or PackGen.TRAIN_PENALTY) + math.floor(best / PackGen.STAT_PER_RARITY)
end

function PackGen.maxRarity(quality)
    local rarity = 1 + quality
    if rarity < 1 then return 1 end
    if rarity > #cards.rarities then return #cards.rarities end
    return rarity
end

local function pick(pool, maxRarity, random)
    local allowed = {}
    for _, card in ipairs(pool) do
        if card.rarity <= maxRarity then
            allowed[#allowed + 1] = card
        end
    end
    return allowed[random(#allowed)]
end

function PackGen.forDay(runState, entries, random)
    local focus = PackGen.statsOfDay(entries)
    if #focus == 0 then return {} end

    local size = PackGen.sizeFor(runState, entries)
    if size == PackGen.NONE then return {} end

    local maxRarity = PackGen.maxRarity(PackGen.qualityOf(runState, entries))

    local pack = {}
    for slot = 1, size do
        local stat = focus[(slot - 1) % #focus + 1]
        local card = pick(cards[stat], maxRarity, random)
        local bonus = math.floor((runState.stats[stat] or 0) / PackGen.STAT_PER_POWER)

        pack[slot] = {
            name = card.name,
            stat = stat,
            power = card.power + bonus,
            rarity = card.rarity,
            effect = card.effect,
            from = "day",
        }
    end
    return pack
end

return PackGen
