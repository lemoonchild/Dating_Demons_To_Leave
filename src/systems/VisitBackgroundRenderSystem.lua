local PlaceArt = require("src.graphics.PlaceArt")

local VisitBackgroundRenderSystem = { name = "visitBackgroundRender" }

function VisitBackgroundRenderSystem.draw(scene)
    PlaceArt.interior(scene.world:resource("visit").placeId)
end

return VisitBackgroundRenderSystem
