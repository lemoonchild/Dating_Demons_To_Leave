local Screen = require("src.Screen")
local CardArt = require("src.graphics.CardArt")
local CollectionLayout = require("src.ui.CollectionLayout")

local CollectionRenderSystem = { name = "collectionRender" }

local fonts = {}
local CARD_W = CollectionLayout.CARD_W
local CARD_H = CollectionLayout.CARD_H

function CollectionRenderSystem.setup(scene)
    fonts.title = love.graphics.newFont(24)
    fonts.text = love.graphics.newFont(13)
end

function CollectionRenderSystem.unload(scene)
    fonts = {}
end

function CollectionRenderSystem.draw(scene)
    local world = scene.world
    local runState = world:resource("runState")
    local nav = world:resource("collectionNav")

    love.graphics.setColor(0.09, 0.04, 0.08, 1)
    love.graphics.rectangle("fill", 0, 0, Screen.w, Screen.h)

    love.graphics.setFont(fonts.title)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Tu colección", CollectionLayout.X, 40)

    love.graphics.setFont(fonts.text)
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    love.graphics.printf(("%d cartas"):format(#runState.cards), 0, 50, Screen.w - CollectionLayout.X, "right")

    if #runState.cards == 0 then
        love.graphics.setFont(fonts.title)
        love.graphics.setColor(0.6, 0.6, 0.6, 1)
        love.graphics.printf("Todavía no conseguiste nada.", 0, 240, Screen.w, "center")
        love.graphics.setFont(fonts.text)
        love.graphics.printf("Cualquier tecla para volver", 0, 280, Screen.w, "center")
        love.graphics.setColor(1, 1, 1, 1)
        return
    end

    for i, card in ipairs(runState.cards) do
        local x, y = CollectionLayout.slot(i)
        CardArt.draw(card, x, y, CARD_W, CARD_H, i == nav.cursor)

        love.graphics.setFont(fonts.text)
        local shade = i == nav.cursor and 1 or 0.6
        love.graphics.setColor(shade, shade, shade, 1)
        love.graphics.printf(card.name, x - 6, y + CARD_H + 2, CARD_W + 12, "center")
    end

    love.graphics.setFont(fonts.text)
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    love.graphics.printf("Flechas: moverse     Esc: volver", 0, Screen.h - 26, Screen.w - CollectionLayout.X, "right")
    love.graphics.setColor(1, 1, 1, 1)
end

return CollectionRenderSystem
