local MapArt = require("src.graphics.MapArt")

local MapRenderSystem = { name = "mapRender" }

function MapRenderSystem.draw(scene)
    local _, tilemap = scene.world:first("tilemap")
    local grid, cell = tilemap.grid, tilemap.cell

    for y = 1, grid.height do
        for x = 1, grid.width do
            MapArt.tile(grid:terrain(x, y), (x - 1) * cell, (y - 1) * cell, cell, x, y)
        end
    end
end

return MapRenderSystem
