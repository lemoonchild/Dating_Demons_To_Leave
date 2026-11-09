local Scene = require("src.ecs.Scene")
local Run = require("src.state.Run")
local TileGrid = require("src.world.TileGrid")
local map = require("src.data.map")

local MapInputSystem = require("src.systems.MapInputSystem")
local MovementSystem = require("src.systems.MovementSystem")
local TileCollisionSystem = require("src.systems.TileCollisionSystem")
local PlaceProximitySystem = require("src.systems.PlaceProximitySystem")
local PlaceEnterSystem = require("src.systems.PlaceEnterSystem")
local MapRenderSystem = require("src.systems.MapRenderSystem")
local PlaceRenderSystem = require("src.systems.PlaceRenderSystem")
local PlayerRenderSystem = require("src.systems.PlayerRenderSystem")
local MapHudRenderSystem = require("src.systems.MapHudRenderSystem")

local function cellRect(x, y, w, h)
    return { x = (x - 1) * map.cell, y = (y - 1) * map.cell, w = w * map.cell, h = h * map.cell }
end

return function(payload)
    local scene = Scene.new("map")
    local world = scene.world

    world:setResource("runState", Run.current())

    world:spawn({ tilemap = { grid = TileGrid.fromRows(map.rows, map.tiles), cell = map.cell } })

    for _, place in ipairs(map.places) do
        world:spawn({
            place = { id = place.id, name = place.name, kind = place.kind, demonId = place.demonId },
            building = cellRect(place.rect.x, place.rect.y, place.rect.w, place.rect.h),
            area = cellRect(place.door.x, place.door.y, 1, 1),
        })
    end

    local from = payload and payload.from and map.places[payload.from]
    local start = from and from.door or map.spawn
    world:spawn({
        player = true,
        position = { x = (start.x - 0.5) * map.cell, y = (start.y - 0.5) * map.cell },
        body = { w = 20, h = 20 },
        moveIntent = { dx = 0, dy = 0 },
        velocity = { x = 0, y = 0 },
        walker = { speed = 160 },
    })

    scene:addSystem(MapInputSystem)
    scene:addSystem(MovementSystem)
    scene:addSystem(TileCollisionSystem)
    scene:addSystem(PlaceProximitySystem)
    scene:addSystem(PlaceEnterSystem)
    scene:addSystem(MapRenderSystem)
    scene:addSystem(PlaceRenderSystem)
    scene:addSystem(PlayerRenderSystem)
    scene:addSystem(MapHudRenderSystem)

    return scene
end
