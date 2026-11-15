local Iso = require("src.world.Iso")
local MapArt = require("src.graphics.MapArt")

local GroundRenderSystem = { name = "groundRender" }

function GroundRenderSystem.draw(scene)
    local _, tilemap = scene.world:first("tilemap")
    MapArt.backdrop()
    for _, piece in ipairs(tilemap.floor) do
        local x, y = Iso.image(tilemap.view, piece.x, piece.y, tilemap.tileset.tileheight)
        MapArt.tile(tilemap.tileset, piece.gid, x, y)
    end
end

return GroundRenderSystem
