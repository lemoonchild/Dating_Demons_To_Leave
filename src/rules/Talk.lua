local Mood = require("src.rules.Mood")

local Talk = {}

Talk.BANDS = { "mal", "neutral", "bien" }

function Talk.band(moodId)
    local quality = Mood.of(moodId).quality
    if quality < 0 then return "mal" end
    if quality == 0 then return "neutral" end
    return "bien"
end

function Talk.unlocked(runState, demon, conversation)
    return conversation.minAffinity == nil
        or (runState.affinity[demon.id] or 0) >= conversation.minAffinity
end

function Talk.nextOf(runState, demon, band)
    local used = runState.talks[demon.id] or {}
    for _, conversation in ipairs(demon.conversations) do
        if conversation.mood == band and not used[conversation.id] then
            return conversation
        end
    end
    return nil
end

function Talk.pick(runState, demon)
    local conversation = Talk.nextOf(runState, demon, Talk.band(runState.moods[demon.id]))
    if conversation and Talk.unlocked(runState, demon, conversation) then
        return conversation
    end
    return nil
end

function Talk.quietLine(runState, demon)
    return demon.quiet[Talk.band(runState.moods[demon.id])]
end

function Talk.hasAny(runState, demon)
    for _, band in ipairs(Talk.BANDS) do
        local conversation = Talk.nextOf(runState, demon, band)
        if conversation and Talk.unlocked(runState, demon, conversation) then
            return true
        end
    end
    return false
end

function Talk.hasLocked(runState, demon)
    for _, band in ipairs(Talk.BANDS) do
        local conversation = Talk.nextOf(runState, demon, band)
        if conversation and not Talk.unlocked(runState, demon, conversation) then
            return true
        end
    end
    return false
end

function Talk.visitedToday(runState, demon)
    for _, entry in ipairs(runState.log or {}) do
        if entry.day == runState.day and entry.kind == "visit" and entry.demonId == demon.id then
            return true
        end
    end
    return false
end

function Talk.hasLeft(runState, demon)
    return Talk.hasAny(runState, demon) or Talk.hasLocked(runState, demon)
end

function Talk.canVisit(runState, demon)
    return Talk.hasLeft(runState, demon) and not Talk.visitedToday(runState, demon)
end

function Talk.use(runState, demon, conversation)
    runState.talks[demon.id] = runState.talks[demon.id] or {}
    runState.talks[demon.id][conversation.id] = true
end

return Talk
