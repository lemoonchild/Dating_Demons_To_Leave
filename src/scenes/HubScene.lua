-- El hub: un círculo del infierno donde hablas con los demonios que te
-- pueden ayudar a escapar. La historia de la escena es su lista de sistemas:
--
--   CameraFollowSystem    demonio actual         -> camera (solo el mundo)
--   HubWorldRenderSystem  camera + demonios      -> el mundo (con cámara)
--   DialogueUISystem      input + conversaciones -> la caja + dialogueChoice
--   AffinitySystem        dialogueChoice         -> runState + cardGained
--   HudUISystem           runState + cardGained  -> el HUD (pantalla)
--
-- La UI de diálogo anuncia, la regla decide, el HUD reacciona: todo en el
-- mismo frame, sin que ninguno llame a otro.

local Scene = require("src.ecs.Scene")
local run = require("src.data.run")
local demons = require("src.data.demons")

local HubWorldRenderSystem = require("src.systems.HubWorldRenderSystem")
local DialogueUISystem = require("src.systems.DialogueUISystem")
local AffinitySystem = require("src.systems.AffinitySystem")
local CameraFollowSystem = require("src.systems.CameraFollowSystem")
local HudUISystem = require("src.systems.HudUISystem")

return function(payload)
    local scene = Scene.new("hub")
    local world = scene.world

    -- RUN state: la partida viene del menú (Jugar crea una nueva); si se
    -- abre directo con `love . hub`, se empieza una.
    world:setResource("runState", payload and payload.runState or run.new())

    -- SCENE state: la cámara del mundo. La UI no la usa.
    world:setResource("camera", { x = 0, y = 0 })

    -- un demonio = una entidad con posición y cómo se dibuja
    local spacing = 260
    local firstX = 480 - spacing * (#demons - 1) / 2
    for i, demon in ipairs(demons) do
        world:spawn({
            position = { x = firstX + (i - 1) * spacing, y = 305 },
            demonSprite = { demonId = demon.id },
        })
    end

    -- mundo primero, UI encima; la regla después de quien la anuncia;
    -- el HUD al final: reacciona a lo que pasó y se dibuja sobre todo
    scene:addSystem(CameraFollowSystem)
    scene:addSystem(HubWorldRenderSystem)
    scene:addSystem(DialogueUISystem)
    scene:addSystem(AffinitySystem)
    scene:addSystem(HudUISystem)

    return scene
end
