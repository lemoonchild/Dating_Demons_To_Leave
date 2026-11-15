local Screen = require("src.Screen")
local Images = require("src.graphics.Images")

local MapArt = {}

local quads = {}

local function quadFor(tileset, id)
    local key = tileset.image .. "#" .. id
    if not quads[key] then
        local col, row = id % tileset.columns, math.floor(id / tileset.columns)
        quads[key] = love.graphics.newQuad(col * tileset.tilewidth, row * tileset.tileheight,
            tileset.tilewidth, tileset.tileheight, tileset.imagewidth, tileset.imageheight)
    end
    return quads[key]
end

function MapArt.backdrop()
    love.graphics.setColor(0.08, 0.04, 0.06, 1)
    love.graphics.rectangle("fill", 0, 0, Screen.w, Screen.h)
    love.graphics.setColor(1, 1, 1, 1)
end

function MapArt.tile(tileset, gid, x, y)
    local image = Images.load(tileset.image)
    if not image then return end
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(image, quadFor(tileset, gid - tileset.firstgid), x, y)
end

local function diamond(cx, cy, hw, hh)
    return { cx, cy - hh, cx + hw, cy, cx, cy + hh, cx - hw, cy }
end

function MapArt.doorMarker(x, y, w, h, focused)
    local cx, cy = x, y + h / 2
    if focused then
        love.graphics.setColor(1, 0.85, 0.3, 0.45)
        love.graphics.polygon("fill", diamond(cx, cy, w * 0.4, h * 0.4))
        love.graphics.setColor(1, 0.85, 0.3, 1)
        love.graphics.polygon("line", diamond(cx, cy, w * 0.45, h * 0.45))
    else
        love.graphics.setColor(1, 0.85, 0.3, 0.6)
        love.graphics.polygon("line", diamond(cx, cy, w * 0.35, h * 0.35))
    end
    love.graphics.setColor(1, 1, 1, 1)
end

return MapArt
