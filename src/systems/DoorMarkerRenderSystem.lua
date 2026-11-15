local Iso = require("src.world.Iso")
local MapArt = require("src.graphics.MapArt")

local DoorMarkerRenderSystem = { name = "doorMarkerRender" }

function DoorMarkerRenderSystem.draw(scene)
    local world = scene.world
    local _, tilemap = world:first("tilemap")
    local focus = world:resource("mapFocus")
    local view = tilemap.view

    for _, entity in ipairs(world:query("place", "door")) do
        local place = world:getComponent(entity, "place")
        local door = world:getComponent(entity, "door")
        local x, y = Iso.surfaceTop(view, door.x, door.y)
        MapArt.doorMarker(x, y, view.tw, view.th, focus.placeId == place.id)
    end
end

return DoorMarkerRenderSystem
