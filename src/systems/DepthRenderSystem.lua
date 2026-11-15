local Iso = require("src.world.Iso")
local MapArt = require("src.graphics.MapArt")
local PlayerArt = require("src.graphics.PlayerArt")

local DepthRenderSystem = { name = "depthRender" }

local function walkers(world, cell)
    local list = {}
    for _, entity in ipairs(world:query("player", "position")) do
        local pos = world:getComponent(entity, "position")
        list[#list + 1] = { entity = entity, depth = Iso.depth(cell, pos.x, pos.y) }
    end
    table.sort(list, function(a, b) return a.depth < b.depth end)
    return list
end

local function drawWalker(world, tilemap, entity)
    local pos = world:getComponent(entity, "position")
    local facing = world:getComponent(entity, "facing")
    local x, y = Iso.toScreen(tilemap.view, tilemap.cell, pos.x, pos.y)
    PlayerArt.drawWalking(facing and facing.dir, x, y)
end

function DepthRenderSystem.draw(scene)
    local world = scene.world
    local _, tilemap = world:first("tilemap")
    local list = walkers(world, tilemap.cell)
    local nextWalker = 1

    local function drawWalkersBefore(depth)
        while list[nextWalker] and list[nextWalker].depth < depth do
            drawWalker(world, tilemap, list[nextWalker].entity)
            nextWalker = nextWalker + 1
        end
    end

    for _, piece in ipairs(tilemap.raised) do
        drawWalkersBefore(piece.depth)
        local x, y = Iso.image(tilemap.view, piece.x, piece.y, tilemap.tileset.tileheight)
        MapArt.tile(tilemap.tileset, piece.gid, x, y)
    end
    drawWalkersBefore(math.huge)
end

return DepthRenderSystem
