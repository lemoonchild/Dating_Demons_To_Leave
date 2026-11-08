local stats = require("src.data.stats")
local cards = require("src.data.cards")

local CardArt = {}

CardArt.W = 128
CardArt.H = 176

function CardArt.rarity(card)
    return cards.rarities[card.rarity] or cards.rarities[1]
end

function CardArt.color(card)
    local stat = stats[card.stat]
    return stat and stat.color or { 0.7, 0.7, 0.7 }
end

function CardArt.draw(card, x, y, w, h, selected)
    w, h = w or CardArt.W, h or CardArt.H
    local color = CardArt.color(card)
    local rarity = CardArt.rarity(card)

    love.graphics.setColor(0.07, 0.03, 0.06, 1)
    love.graphics.rectangle("fill", x, y, w, h)

    love.graphics.setColor(color[1] * 0.6, color[2] * 0.6, color[3] * 0.6, 1)
    love.graphics.rectangle("fill", x + 6, y + 6, w - 12, h * 0.45)

    love.graphics.setColor(color[1], color[2], color[3], 1)
    for i = 1, card.power do
        local px = x + 8 + (i - 1) * 9
        if px + 6 < x + w - 8 then
            love.graphics.rectangle("fill", px, y + h - 22, 6, 14)
        end
    end

    love.graphics.setColor(rarity.color[1], rarity.color[2], rarity.color[3], selected and 1 or 0.7)
    love.graphics.rectangle("line", x, y, w, h)
    if selected then
        love.graphics.rectangle("line", x - 3, y - 3, w + 6, h + 6)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return CardArt
