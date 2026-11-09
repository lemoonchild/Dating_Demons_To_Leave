local PlaceProximitySystem = { name = "placeProximity" }

local function overlaps(ax, ay, aw, ah, b)
    return ax < b.x + b.w and ax + aw > b.x and ay < b.y + b.h and ay + ah > b.y
end

function PlaceProximitySystem.setup(scene)
    scene.world:setResource("mapFocus", { placeId = nil })
end

function PlaceProximitySystem.update(scene, dt)
    local world = scene.world
    local focus = world:resource("mapFocus")
    focus.placeId = nil

    local players = world:query("player", "position", "body")
    if #players == 0 then return end
    local pos = world:getComponent(players[1], "position")
    local body = world:getComponent(players[1], "body")
    local x, y = pos.x - body.w / 2, pos.y - body.h / 2

    for _, entity in ipairs(world:query("place", "area")) do
        if overlaps(x, y, body.w, body.h, world:getComponent(entity, "area")) then
            focus.placeId = world:getComponent(entity, "place").id
            return
        end
    end
end

return PlaceProximitySystem
