-- Dibuja el MUNDO del hub: el círculo del infierno y los demonios que
-- viven ahí. Solo dibuja; no es UI. Figuras simples como placeholder hasta
-- tener el arte en pixel art.
--
-- Todo pasa por la cámara (resource `camera`): si la cámara se mueve, el
-- mundo se mueve. La UI (diálogo, HUD) se dibuja después, en espacio de
-- pantalla, y no se entera.
--
-- Resalta al demonio con el que estás hablando (lo lee del componente
-- `dialogue`) y deja a los demás en penumbra.

local Screen = require("src.Screen")
local demons = require("src.data.demons")
local DemonArt = require("src.graphics.DemonArt")

local HubWorldRenderSystem = { name = "hubWorldRender" }

local FLOOR_Y = 290
local MARGIN = 400 -- el mundo es más ancho que la pantalla: la cámara se mueve

local function drawCircle()
    -- fondo y suelo
    love.graphics.setColor(0.12, 0.05, 0.1, 1)
    love.graphics.rectangle("fill", -MARGIN, -MARGIN, Screen.w + 2 * MARGIN, Screen.h + 2 * MARGIN)
    love.graphics.setColor(0.25, 0.1, 0.08, 1)
    love.graphics.rectangle("fill", -MARGIN, FLOOR_Y, Screen.w + 2 * MARGIN, Screen.h + MARGIN)

    -- la puerta del guardián, al fondo
    love.graphics.setColor(0.05, 0.02, 0.03, 1)
    love.graphics.rectangle("fill", Screen.w / 2 - 60, FLOOR_Y - 180, 120, 180)
    love.graphics.setColor(0.8, 0.3, 0.15, 1)
    love.graphics.rectangle("line", Screen.w / 2 - 60, FLOOR_Y - 180, 120, 180)
end

function HubWorldRenderSystem.draw(scene)
    local world = scene.world
    local camera = world:resource("camera")
    local _, dialogue = world:first("dialogue")

    love.graphics.push()
    love.graphics.translate(-camera.x, -camera.y)

    drawCircle()

    for _, entity in ipairs(world:query("position", "demonSprite")) do
        local pos = world:getComponent(entity, "position")
        local sprite = world:getComponent(entity, "demonSprite")
        local demon = demons[sprite.demonId]
        local talking = dialogue and demons[dialogue.demonIndex].id == demon.id

        DemonArt.draw(demon, pos.x, pos.y, 48, 96, talking and 1 or 0.4)
    end

    love.graphics.pop()
    love.graphics.setColor(1, 1, 1, 1)
end

return HubWorldRenderSystem
