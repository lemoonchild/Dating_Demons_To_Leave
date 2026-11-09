local PlaceArt = require("src.graphics.PlaceArt")

local PlaceRenderSystem = { name = "placeRender" }

local fonts = {}

function PlaceRenderSystem.setup(scene)
    fonts.label = love.graphics.newFont(13)
end

function PlaceRenderSystem.unload(scene)
    fonts = {}
end

function PlaceRenderSystem.draw(scene)
    local world = scene.world
    local focus = world:resource("mapFocus")
    for _, entity in ipairs(world:query("place", "building", "area")) do
        local place = world:getComponent(entity, "place")
        PlaceArt.draw(
            place,
            world:getComponent(entity, "building"),
            world:getComponent(entity, "area"),
            fonts.label,
            focus and focus.placeId == place.id)
    end
end

return PlaceRenderSystem
