local CollectionLayout = require("src.ui.CollectionLayout")

local CollectionNavSystem = { name = "collectionNav" }

function CollectionNavSystem.update(scene, dt)
    local world = scene.world
    local nav = world:resource("collectionNav")
    local count = #world:resource("runState").cards

    if count == 0 then
        if #world:query("keyPressed") > 0 or #world:query("mousePressed") > 0 then
            world:spawn({ switchRequest = { to = nav.back } })
        end
        return
    end

    nav.cursor = math.max(1, math.min(count, nav.cursor))

    local mx, my = love.mouse.getPosition()
    local hovered = CollectionLayout.hit(count, mx, my)
    if hovered and (mx ~= nav.lastMouseX or my ~= nav.lastMouseY) then
        nav.cursor = hovered
    end
    nav.lastMouseX, nav.lastMouseY = mx, my

    for _, entity in ipairs(world:query("mousePressed")) do
        local click = world:getComponent(entity, "mousePressed")
        local i = CollectionLayout.hit(count, click.x, click.y)
        if click.button == 1 and i then nav.cursor = i end
    end

    for _, entity in ipairs(world:query("keyPressed")) do
        local key = world:getComponent(entity, "keyPressed").key
        local cols = CollectionLayout.COLS
        if key == "escape" or key == "return" or key == "space" or key == "c" then
            world:spawn({ switchRequest = { to = nav.back } })
        elseif key == "left" or key == "a" then
            nav.cursor = (nav.cursor - 2) % count + 1
        elseif key == "right" or key == "d" then
            nav.cursor = nav.cursor % count + 1
        elseif key == "up" or key == "w" then
            nav.cursor = ((nav.cursor - 1 - cols) % count) + 1
        elseif key == "down" or key == "s" then
            nav.cursor = ((nav.cursor - 1 + cols) % count) + 1
        end
    end
end

return CollectionNavSystem
