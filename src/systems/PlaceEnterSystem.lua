local map = require("src.data.map")

local PlaceEnterSystem = { name = "placeEnter" }

PlaceEnterSystem.HOME = "room"

function PlaceEnterSystem.update(scene, dt)
    local world = scene.world
    local focus = world:resource("mapFocus")
    local place = focus.placeId and map.places[focus.placeId]

    for _, entity in ipairs(world:query("keyPressed")) do
        local key = world:getComponent(entity, "keyPressed").key
        if key == "escape" then
            world:spawn({ switchRequest = { to = PlaceEnterSystem.HOME } })
        elseif (key == "return" or key == "space" or key == "e") and place and place.kind == "home" then
            world:spawn({ switchRequest = { to = PlaceEnterSystem.HOME } })
        end
    end
end

return PlaceEnterSystem
