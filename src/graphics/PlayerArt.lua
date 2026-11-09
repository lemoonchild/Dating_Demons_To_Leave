local PlayerArt = {}

function PlayerArt.draw(x, y, w, h)
    love.graphics.setColor(0.95, 0.9, 0.8, 1)
    love.graphics.rectangle("fill", x - w / 2, y + h / 2 - 30, w, 30)
    love.graphics.setColor(0.2, 0.1, 0.1, 1)
    love.graphics.rectangle("line", x - w / 2, y + h / 2 - 30, w, 30)
    love.graphics.setColor(1, 1, 1, 1)
end

return PlayerArt
