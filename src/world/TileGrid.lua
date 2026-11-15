local TileGrid = {}
TileGrid.__index = TileGrid

function TileGrid.new(width, height, cells, tiles)
    return setmetatable({ width = width, height = height, tiles = tiles, cells = cells }, TileGrid)
end

function TileGrid.fromRows(rows, tiles)
    local width = #rows[1]
    local cells = {}
    for y, row in ipairs(rows) do
        assert(#row == width, ("la fila %d del mapa tiene otro ancho"):format(y))
        for x = 1, width do
            local glyph = row:sub(x, x)
            assert(tiles[glyph], ("glifo desconocido %q en %d,%d"):format(glyph, x, y))
            cells[(y - 1) * width + x] = glyph
        end
    end
    return TileGrid.new(width, #rows, cells, tiles)
end

function TileGrid:inBounds(x, y)
    return x >= 1 and x <= self.width and y >= 1 and y <= self.height
end

function TileGrid:get(x, y)
    if not self:inBounds(x, y) then return nil end
    return self.cells[(y - 1) * self.width + x]
end

function TileGrid:terrain(x, y)
    local key = self:get(x, y)
    return key and self.tiles[key].terrain
end

function TileGrid:solid(x, y)
    local key = self:get(x, y)
    return key == nil or self.tiles[key].solid
end

return TileGrid
