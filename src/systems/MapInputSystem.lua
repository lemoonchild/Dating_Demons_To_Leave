local MapInputSystem = { name = "mapInput" }

local LEFT = { "left", "a" }
local RIGHT = { "right", "d" }
local UP = { "up", "w" }
local DOWN = { "down", "s" }

local function anyDown(keys)
    for _, key in ipairs(keys) do
        if love.keyboard.isDown(key) then return true end
    end
    return false
end

function MapInputSystem.update(scene, dt)
    local dx = (anyDown(RIGHT) and 1 or 0) - (anyDown(LEFT) and 1 or 0)
    local dy = (anyDown(DOWN) and 1 or 0) - (anyDown(UP) and 1 or 0)

    for _, intent in scene.world:each("moveIntent") do
        intent.dx = dx
        intent.dy = dy
    end
end

return MapInputSystem
