local stats = require("src.data.stats")
local RoomMenuLayout = require("src.ui.RoomMenuLayout")

local RoomMenuInputSystem = { name = "roomMenuInput" }

function RoomMenuInputSystem.options(menu)
    if menu.screen == "training" then
        local list = {}
        for _, stat in ipairs(stats) do
            list[#list + 1] = { id = "stat", stat = stat.id }
        end
        list[#list + 1] = { id = "back" }
        return list
    end
    return { { id = "training" }, { id = "visit" } }
end

local function open(menu, screen)
    menu.screen = screen
    menu.cursor = 1
end

local function confirm(scene, menu)
    local option = RoomMenuInputSystem.options(menu)[menu.cursor]
    if option.id == "training" then
        open(menu, "training")
    elseif option.id == "back" then
        open(menu, "main")
    elseif option.id == "visit" then
        scene.world:spawn({ switchRequest = { to = "map" } })
    elseif option.id == "stat" then
        scene.world:spawn({ event = true, actionPicked = { kind = "train", stat = option.stat } })
    end
end

function RoomMenuInputSystem.setup(scene)
    scene.world:spawn({ roomMenu = { screen = "main", cursor = 1 } })
end

function RoomMenuInputSystem.update(scene, dt)
    local world = scene.world
    if world:resource("dayPhase").phase ~= "choosing" then return end

    local _, menu = world:first("roomMenu")
    local count = #RoomMenuInputSystem.options(menu)

    local mx, my = love.mouse.getPosition()
    local hovered = RoomMenuLayout.hit(count, mx, my)
    if hovered and (mx ~= menu.lastMouseX or my ~= menu.lastMouseY) then
        menu.cursor = hovered
    end
    menu.lastMouseX, menu.lastMouseY = mx, my

    for _, entity in ipairs(world:query("mousePressed")) do
        local click = world:getComponent(entity, "mousePressed")
        local i = RoomMenuLayout.hit(count, click.x, click.y)
        if click.button == 1 and i then
            menu.cursor = i
            confirm(scene, menu)
        end
    end

    for _, entity in ipairs(world:query("keyPressed")) do
        local key = world:getComponent(entity, "keyPressed").key
        local picked = tonumber(key)
        if key == "escape" and menu.screen == "training" then
            open(menu, "main")
        elseif key == "escape" then
            world:spawn({ switchRequest = { to = "menu" } })
        elseif key == "c" then
            world:spawn({ switchRequest = { to = "collection", payload = { back = "room" } } })
        elseif key == "up" or key == "w" then
            menu.cursor = (menu.cursor - 2) % count + 1
        elseif key == "down" or key == "s" then
            menu.cursor = menu.cursor % count + 1
        elseif key == "return" or key == "space" then
            confirm(scene, menu)
        elseif picked and picked >= 1 and picked <= count then
            menu.cursor = picked
            confirm(scene, menu)
        end
    end
end

return RoomMenuInputSystem
