-- Cómo se ve un demonio. Por ahora es un PLACEHOLDER: un rectángulo de su
-- color. Lo comparten el mundo (HubWorldRenderSystem) y el retrato del
-- diálogo (DialogueUISystem), así que cuando existan los sprites en pixel
-- art solo cambia esta función.
--
--   DemonArt.draw(demon, x, y, w, h, shade)
--     x, y   el punto entre los pies (centro de la base)
--     w, h   tamaño del rectángulo
--     shade  0..1: 1 = color normal, menos = en penumbra

local DemonArt = {}

function DemonArt.draw(demon, x, y, w, h, shade)
    shade = shade or 1
    local r, g, b = demon.color[1] * shade, demon.color[2] * shade, demon.color[3] * shade

    love.graphics.setColor(r, g, b, 1)
    love.graphics.rectangle("fill", x - w / 2, y - h, w, h)
    love.graphics.setColor(1, 1, 1, shade)
    love.graphics.rectangle("line", x - w / 2, y - h, w, h)

    love.graphics.setColor(1, 1, 1, 1)
end

return DemonArt
