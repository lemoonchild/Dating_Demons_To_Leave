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
    for _, entity in ipairs(world:query("place", "building", "area")) do
        PlaceArt.draw(
            world:getComponent(entity, "place"),
            world:getComponent(entity, "building"),
            world:getComponent(entity, "area"),
            fonts.label)
    end
end

return PlaceRenderSystem
