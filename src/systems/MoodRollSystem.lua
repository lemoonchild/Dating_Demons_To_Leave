local demons = require("src.data.demons")
local Mood = require("src.rules.Mood")

local MoodRollSystem = { name = "moodRoll" }

local function roll(scene)
    Mood.roll(scene.world:resource("runState"), demons, love.math.random)
end

function MoodRollSystem.setup(scene)
    roll(scene)
end

return MoodRollSystem
