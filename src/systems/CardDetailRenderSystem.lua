local stats = require("src.data.stats")
local demons = require("src.data.demons")
local CardArt = require("src.graphics.CardArt")
local CollectionLayout = require("src.ui.CollectionLayout")

local CardDetailRenderSystem = { name = "cardDetailRender" }

local fonts = {}

local PANEL = CollectionLayout.PANEL

function CardDetailRenderSystem.setup(scene)
    fonts.name = love.graphics.newFont(20)
    fonts.label = love.graphics.newFont(12)
    fonts.text = love.graphics.newFont(14)
end

function CardDetailRenderSystem.unload(scene)
    fonts = {}
end

local function line(label, value, x, y, color)
    love.graphics.setFont(fonts.label)
    love.graphics.setColor(0.6, 0.6, 0.6, 1)
    love.graphics.print(label, x, y)
    love.graphics.setFont(fonts.text)
    love.graphics.setColor(color[1], color[2], color[3], 1)
    love.graphics.print(value, x, y + 14)
end

function CardDetailRenderSystem.draw(scene)
    local world = scene.world
    local runState = world:resource("runState")
    local card = runState.cards[world:resource("collectionNav").cursor]
    if not card then return end

    love.graphics.setColor(0.07, 0.03, 0.06, 1)
    love.graphics.rectangle("fill", PANEL.x, PANEL.y, PANEL.w, PANEL.h)

    local rarity = CardArt.rarity(card)
    love.graphics.setColor(rarity.color[1], rarity.color[2], rarity.color[3], 1)
    love.graphics.rectangle("line", PANEL.x, PANEL.y, PANEL.w, PANEL.h)

    CardArt.draw(card, PANEL.x + (PANEL.w - 128) / 2, PANEL.y + 18, 128, 176, false)

    local x = PANEL.x + 20
    love.graphics.setFont(fonts.name)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(card.name, PANEL.x, PANEL.y + 206, PANEL.w, "center")

    local stat = stats[card.stat]
    line("TIPO", stat.name, x, PANEL.y + 244, stat.color)
    line("PODER", tostring(card.power), x + 150, PANEL.y + 244, { 1, 1, 1 })
    line("RAREZA", rarity.name, x, PANEL.y + 286, rarity.color)

    local source = card.from == "day" and "Encontrada" or ("Regalo de " .. (demons[card.from] and demons[card.from].name or card.from))
    line("ORIGEN", source, x + 150, PANEL.y + 286, { 0.8, 0.8, 0.8 })

    love.graphics.setFont(fonts.label)
    love.graphics.setColor(0.6, 0.6, 0.6, 1)
    love.graphics.print("EFECTO", x, PANEL.y + 328)
    love.graphics.setFont(fonts.text)
    love.graphics.setColor(0.85, 0.82, 0.82, 1)
    love.graphics.printf(card.effect or "", x, PANEL.y + 342, PANEL.w - 40, "left")

    love.graphics.setColor(1, 1, 1, 1)
end

return CardDetailRenderSystem
