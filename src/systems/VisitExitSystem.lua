local VisitExitSystem = { name = "visitExit" }

function VisitExitSystem.update(scene, dt)
    local world = scene.world
    if #world:query("actionDone") == 0 then return end
    if world:resource("dayPhase").phase ~= "choosing" then return end

    local visit = world:resource("visit")
    world:spawn({ switchRequest = { to = "map", payload = { from = visit.placeId } } })
end

return VisitExitSystem
