local Mood = require("src.rules.Mood")

local Talk = {}

function Talk.band(moodId)
    local quality = Mood.of(moodId).quality
    if quality < 0 then return "mal" end
    if quality == 0 then return "neutral" end
    return "bien"
end

function Talk.available(runState, demon, band)
    local used = runState.talks[demon.id] or {}
    local affinity = runState.affinity[demon.id] or 0

    local list = {}
    for _, conversation in ipairs(demon.conversations) do
        if not used[conversation.id]
            and affinity >= (conversation.minAffinity or 0)
            and (band == nil or conversation.mood == band) then
            list[#list + 1] = conversation
        end
    end
    return list
end

function Talk.pick(runState, demon, random)
    local list = Talk.available(runState, demon, Talk.band(runState.moods[demon.id]))
    if #list == 0 then
        list = Talk.available(runState, demon, nil)
    end
    if #list == 0 then return nil end
    return list[random(#list)]
end

function Talk.hasAny(runState, demon)
    return #Talk.available(runState, demon, nil) > 0
end

function Talk.use(runState, demon, conversation)
    runState.talks[demon.id] = runState.talks[demon.id] or {}
    runState.talks[demon.id][conversation.id] = true
end

return Talk
