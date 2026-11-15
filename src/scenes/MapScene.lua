local Scene = require("src.ecs.Scene")
local Screen = require("src.Screen")
local Run = require("src.state.Run")
local Iso = require("src.world.Iso")
local TiledMap = require("src.world.TiledMap")
local map = require("src.data.map")

local MoodRollSystem = require("src.systems.MoodRollSystem")
local MapInputSystem = require("src.systems.MapInputSystem")
local MovementSystem = require("src.systems.MovementSystem")
local FacingSystem = require("src.systems.FacingSystem")
local TileCollisionSystem = require("src.systems.TileCollisionSystem")
local PlaceProximitySystem = require("src.systems.PlaceProximitySystem")
local PlaceEnterSystem = require("src.systems.PlaceEnterSystem")
local GroundRenderSystem = require("src.systems.GroundRenderSystem")
local DoorMarkerRenderSystem = require("src.systems.DoorMarkerRenderSystem")
local DepthRenderSystem = require("src.systems.DepthRenderSystem")
local PlaceLabelRenderSystem = require("src.systems.PlaceLabelRenderSystem")
local MapHudRenderSystem = require("src.systems.MapHudRenderSystem")

local function cellRect(x, y, w, h)
    return { x = (x - 1) * map.cell, y = (y - 1) * map.cell, w = w * map.cell, h = h * map.cell }
end

return function(payload)
    local scene = Scene.new("map")
    local world = scene.world

    world:setResource("runState", Run.current())

    local floor, raised = TiledMap.pieces(map.tiled)
    world:spawn({
        tilemap = {
            grid = TiledMap.grid(map.tiled, map.ground, map.tiles),
            cell = map.cell,
            view = Iso.view(map.tiled, Screen.w, Screen.h),
            tileset = TiledMap.tileset(map.tiled, map.folder),
            floor = floor,
            raised = raised,
        },
    })

    for _, place in ipairs(map.places) do
        world:spawn({
            place = { id = place.id, name = place.name, kind = place.kind, demonId = place.demonId },
            door = { x = place.door.x, y = place.door.y },
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
        facing = { dir = "enfrente" },
        walker = { speed = 160 },
    })

    scene:addSystem(MoodRollSystem)
    scene:addSystem(MapInputSystem)
    scene:addSystem(MovementSystem)
    scene:addSystem(FacingSystem)
    scene:addSystem(TileCollisionSystem)
    scene:addSystem(PlaceProximitySystem)
    scene:addSystem(PlaceEnterSystem)
    scene:addSystem(GroundRenderSystem)
    scene:addSystem(DoorMarkerRenderSystem)
    scene:addSystem(DepthRenderSystem)
    scene:addSystem(PlaceLabelRenderSystem)
    scene:addSystem(MapHudRenderSystem)

    return scene
end
