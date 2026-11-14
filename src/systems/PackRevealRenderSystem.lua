local Screen = require("src.Screen")
local stats = require("src.data.stats")
local CardArt = require("src.graphics.CardArt")

local PackRevealRenderSystem = { name = "packRevealRender" }

local fonts = {}

local CARD_W, CARD_H = 150, 208
local GAP = 36

function PackRevealRenderSystem.setup(scene)
    fonts.title = love.graphics.newFont(26)
    fonts.name = love.graphics.newFont(16)
    fonts.text = love.graphics.newFont(13)
end

function PackRevealRenderSystem.unload(scene)
    fonts = {}
end

function PackRevealRenderSystem.entriesOf(runState, day)
    local entries = {}
    for _, entry in ipairs(runState.log) do
        if entry.day == day then entries[#entries + 1] = entry end
    end
    return entries
end

function PackRevealRenderSystem.subtitle(entries, empty)
    if not empty then
        return "De tanto hablar, algo se te pegó."
    end
    for _, entry in ipairs(entries) do
        if entry.kind == "visit" then
            return "Nadie quiso darte nada. Así son los días en que caes mal."
        end
    end
    return "Entrenaste todo el día. Eres mejor que ayer, pero nadie te regaló nada."
end

function PackRevealRenderSystem.draw(scene)
    local world = scene.world
    local runState = world:resource("runState")
    local _, reveal = world:first("reveal")
    local day = runState.day - 1
    local entries = PackRevealRenderSystem.entriesOf(runState, day)
    local empty = #reveal.pack == 0

    love.graphics.setColor(0.09, 0.04, 0.08, 1)
    love.graphics.rectangle("fill", 0, 0, Screen.w, Screen.h)

    love.graphics.setFont(fonts.title)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(("Lo que te quedó del día %d"):format(day), 0, 60, Screen.w, "center")

    love.graphics.setFont(fonts.text)
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    love.graphics.printf(PackRevealRenderSystem.subtitle(entries, empty), 0, 100, Screen.w, "center")

    if empty then
        love.graphics.setFont(fonts.title)
        love.graphics.setColor(0.55, 0.55, 0.55, 1)
        love.graphics.printf("Las manos vacías", 0, 250, Screen.w, "center")
    end

    local total = #reveal.pack
    local startX = (Screen.w - (total * CARD_W + (total - 1) * GAP)) / 2
    for i, card in ipairs(reveal.pack) do
        if i <= reveal.shown then
            local x = startX + (i - 1) * (CARD_W + GAP)
            CardArt.draw(card, x, 160, CARD_W, CARD_H, false)

            love.graphics.setFont(fonts.name)
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.printf(card.name, x - 10, 160 + CARD_H + 10, CARD_W + 20, "center")

            love.graphics.setFont(fonts.text)
            local rarity = CardArt.rarity(card)
            love.graphics.setColor(rarity.color[1], rarity.color[2], rarity.color[3], 1)
            love.graphics.printf(("%s   %s %d"):format(rarity.name, stats[card.stat].name, card.power),
                x - 10, 160 + CARD_H + 32, CARD_W + 20, "center")
        end
    end

    love.graphics.setFont(fonts.text)
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    love.graphics.printf(("Tu colección: %d cartas"):format(#runState.cards), 0, Screen.h - 70, Screen.w, "center")
    love.graphics.printf("Enter: seguir     C: ver la colección", 0, Screen.h - 44, Screen.w, "center")

    love.graphics.setColor(1, 1, 1, 1)
end

return PackRevealRenderSystem
