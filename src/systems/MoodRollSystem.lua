local demons = require("src.data.demons")
local Mood = require("src.rules.Mood")

local MoodRollSystem = { name = "moodRoll" }

local function roll(scene)
    local runState = scene.world:resource("runState")
    if runState.moodDay == runState.day then return end
    Mood.roll(runState, demons, love.math.random)
    runState.moodDay = runState.day
end

function MoodRollSystem.setup(scene)
    roll(scene)
end

return MoodRollSystem
