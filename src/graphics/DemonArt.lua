-- Cómo se ve un demonio: su sprite de assets/characters, o un rectángulo de su color si no tiene.

local Images = require("src.graphics.Images")

local DemonArt = {}

DemonArt.FOLDER = "assets/characters/"

function DemonArt.imageOf(demon)
    return Images.load(DemonArt.FOLDER .. demon.id .. ".png")
end

local function drawBlock(demon, x, y, w, h, shade)
    local r, g, b = demon.color[1] * shade, demon.color[2] * shade, demon.color[3] * shade
    love.graphics.setColor(r, g, b, 1)
    love.graphics.rectangle("fill", x - w / 2, y - h, w, h)
    love.graphics.setColor(1, 1, 1, shade)
    love.graphics.rectangle("line", x - w / 2, y - h, w, h)
end

function DemonArt.draw(demon, x, y, w, h, shade)
    shade = shade or 1
    local image = DemonArt.imageOf(demon)
    if image then
        Images.drawStanding(image, x, y, h, shade)
    else
        drawBlock(demon, x, y, w, h, shade)
    end
    love.graphics.setColor(1, 1, 1, 1)
end

return DemonArt
