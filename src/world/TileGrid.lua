local TileGrid = {}
TileGrid.__index = TileGrid

function TileGrid.fromRows(rows, tiles)
    local grid = setmetatable({ width = #rows[1], height = #rows, tiles = tiles, cells = {} }, TileGrid)
    for y, row in ipairs(rows) do
        assert(#row == grid.width, ("la fila %d del mapa tiene otro ancho"):format(y))
        for x = 1, grid.width do
            local glyph = row:sub(x, x)
            assert(tiles[glyph], ("glifo desconocido %q en %d,%d"):format(glyph, x, y))
            grid.cells[(y - 1) * grid.width + x] = glyph
        end
    end
    return grid
end

function TileGrid:inBounds(x, y)
    return x >= 1 and x <= self.width and y >= 1 and y <= self.height
end

function TileGrid:get(x, y)
    if not self:inBounds(x, y) then return nil end
    return self.cells[(y - 1) * self.width + x]
end

function TileGrid:terrain(x, y)
    local glyph = self:get(x, y)
    return glyph and self.tiles[glyph].terrain
end

function TileGrid:solid(x, y)
    local glyph = self:get(x, y)
    return glyph == nil or self.tiles[glyph].solid
end

return TileGrid
