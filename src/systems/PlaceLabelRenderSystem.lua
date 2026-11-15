local Iso = require("src.world.Iso")
local PlaceArt = require("src.graphics.PlaceArt")

local PlaceLabelRenderSystem = { name = "placeLabelRender" }

local fonts = {}

function PlaceLabelRenderSystem.setup(scene)
    fonts.label = love.graphics.newFont(13)
end

function PlaceLabelRenderSystem.unload(scene)
    fonts = {}
end

function PlaceLabelRenderSystem.draw(scene)
    local world = scene.world
    local _, tilemap = world:first("tilemap")
    local focus = world:resource("mapFocus")
    local view = tilemap.view

    for _, entity in ipairs(world:query("place", "door")) do
        local place = world:getComponent(entity, "place")
        local door = world:getComponent(entity, "door")
        local x, y = Iso.surfaceTop(view, door.x, door.y)
        PlaceArt.label(place.name, x, y + view.th + 4, fonts.label, focus.placeId == place.id)
    end
end

return PlaceLabelRenderSystem
