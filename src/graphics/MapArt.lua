local MapArt = {}

local COLORS = {
    floor = { 0.25, 0.1, 0.08 },
    building = { 0.25, 0.1, 0.08 },
    bridge = { 0.45, 0.3, 0.18 },
    wall = { 0.08, 0.03, 0.05 },
    lava = { 0.95, 0.4, 0.1 },
    rock = { 0.25, 0.1, 0.08 },
}

function MapArt.tile(terrain, x, y, size, cx, cy)
    local color = COLORS[terrain]
    local shade = (terrain == "floor" or terrain == "building") and (cx + cy) % 2 == 0 and 0.9 or 1
    love.graphics.setColor(color[1] * shade, color[2] * shade, color[3] * shade, 1)
    love.graphics.rectangle("fill", x, y, size, size)

    if terrain == "rock" then
        love.graphics.setColor(0.4, 0.36, 0.36, 1)
        love.graphics.rectangle("fill", x + 4, y + 6, size - 8, size - 10)
        love.graphics.setColor(0.15, 0.12, 0.12, 1)
        love.graphics.rectangle("line", x + 4, y + 6, size - 8, size - 10)
    elseif terrain == "bridge" then
        love.graphics.setColor(0.3, 0.18, 0.1, 1)
        love.graphics.line(x, y + size / 3, x + size, y + size / 3)
        love.graphics.line(x, y + size * 2 / 3, x + size, y + size * 2 / 3)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return MapArt
