-- El hub: el círculo del infierno donde hablas con los demonios.
-- Por ahora es un placeholder para que "Jugar" tenga a dónde ir; el mundo,
-- el diálogo y el HUD llegan en las siguientes fases.

local Scene = require("src.ecs.Scene")
local run = require("src.data.run")
local circles = require("src.data.circles")

local PlaceholderSystem = { name = "placeholder" }

function PlaceholderSystem.update(scene, dt)
    for _, entity in ipairs(scene.world:query("keyPressed")) do
        if scene.world:getComponent(entity, "keyPressed").key == "escape" then
            scene.world:spawn({ switchRequest = { to = "menu" } })
        end
    end
end

function PlaceholderSystem.draw(scene)
    local runState = scene.world:resource("runState")
    local circle = circles[runState.circle]
    love.graphics.print(("Círculo %d — %s (en construcción). Esc: volver al menú")
        :format(runState.circle, circle.name), 10, 10)
end

return function(payload)
    local scene = Scene.new("hub")

    -- RUN state: la partida viene del menú (Jugar crea una nueva); si se
    -- abre directo con `love . hub`, se empieza una.
    scene.world:setResource("runState", payload and payload.runState or run.new())

    scene:addSystem(PlaceholderSystem)
    return scene
end
