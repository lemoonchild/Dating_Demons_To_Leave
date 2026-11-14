local Images = require("src.graphics.Images")

local PlayerArt = {}

PlayerArt.SPRITE = "assets/characters/jugador.png"

function PlayerArt.draw(x, y, w, h)
    love.graphics.setColor(0.95, 0.9, 0.8, 1)
    love.graphics.rectangle("fill", x - w / 2, y + h / 2 - 30, w, 30)
    love.graphics.setColor(0.2, 0.1, 0.1, 1)
    love.graphics.rectangle("line", x - w / 2, y + h / 2 - 30, w, 30)
    love.graphics.setColor(1, 1, 1, 1)
end

function PlayerArt.drawStanding(x, y, h)
    local image = Images.load(PlayerArt.SPRITE)
    if image then
        Images.drawStanding(image, x, y, h)
        love.graphics.setColor(1, 1, 1, 1)
        return
    end

    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.scale(2.5)
    PlayerArt.draw(0, -10, 20, 20)
    love.graphics.pop()
end

return PlayerArt
