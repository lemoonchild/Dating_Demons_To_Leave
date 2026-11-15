local TileGrid = require("src.world.TileGrid")

local TiledMap = {}

function TiledMap.tileLayers(tiled)
    local layers = {}
    for _, layer in ipairs(tiled.layers) do
        if layer.type == "tilelayer" then layers[#layers + 1] = layer end
    end
    assert(#layers > 0, "el mapa de Tiled no tiene capas de tiles")
    return layers
end

local function cellOf(tiled, index)
    return (index - 1) % tiled.width + 1, math.floor((index - 1) / tiled.width) + 1
end

function TiledMap.terrainCells(tiled, ground)
    local layers = TiledMap.tileLayers(tiled)
    local firstgid = tiled.tilesets[1].firstgid
    local cells = {}

    for i, gid in ipairs(layers[1].data) do
        if gid == 0 then
            cells[i] = "void"
        else
            local terrain = ground[gid - firstgid]
            local x, y = cellOf(tiled, i)
            assert(terrain, ("el tile %d del suelo (en %d,%d) no tiene terreno en src/data/map.lua")
                :format(gid - firstgid, x, y))
            cells[i] = terrain
        end
    end

    for level = 1, #layers - 1 do
        for i, gid in ipairs(layers[level + 1].data) do
            if gid ~= 0 then
                local x, y = cellOf(tiled, i)
                x, y = x + level, y + level
                if x <= tiled.width and y <= tiled.height then
                    cells[(y - 1) * tiled.width + x] = "building"
                end
            end
        end
    end

    return cells
end

function TiledMap.grid(tiled, ground, tiles)
    return TileGrid.new(tiled.width, tiled.height, TiledMap.terrainCells(tiled, ground), tiles)
end

local function byDepth(a, b)
    if a.depth ~= b.depth then return a.depth < b.depth end
    if a.level ~= b.level then return a.level < b.level end
    if a.y ~= b.y then return a.y < b.y end
    return a.x < b.x
end

function TiledMap.pieces(tiled)
    local floor, raised = {}, {}
    for index, layer in ipairs(TiledMap.tileLayers(tiled)) do
        local level = index - 1
        for i, gid in ipairs(layer.data) do
            if gid ~= 0 then
                local x, y = cellOf(tiled, i)
                local piece = { gid = gid, x = x, y = y, level = level, depth = x + y - 1 + 2 * level }
                if level == 0 then
                    floor[#floor + 1] = piece
                else
                    raised[#raised + 1] = piece
                end
            end
        end
    end
    table.sort(floor, byDepth)
    table.sort(raised, byDepth)
    return floor, raised
end

function TiledMap.tileset(tiled, folder)
    local set = tiled.tilesets[1]
    return {
        image = folder .. set.image,
        firstgid = set.firstgid,
        columns = set.columns,
        tilewidth = set.tilewidth,
        tileheight = set.tileheight,
        imagewidth = set.imagewidth,
        imageheight = set.imageheight,
    }
end

return TiledMap
