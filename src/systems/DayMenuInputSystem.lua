local demons = require("src.data.demons")
local stats = require("src.data.stats")
local Talk = require("src.rules.Talk")
local DayMenuLayout = require("src.ui.DayMenuLayout")

local DayMenuInputSystem = { name = "dayMenuInput" }

function DayMenuInputSystem.spent(runState, action)
    if action.kind ~= "visit" then return false end
    return not Talk.hasAny(runState, demons[action.demonId])
end

local function confirm(scene, menu, runState)
    local action = menu.actions[menu.cursor]
    if DayMenuInputSystem.spent(runState, action) then return end
    scene.world:spawn({
        event = true,
        actionPicked = { kind = action.kind, demonId = action.demonId, stat = action.stat },
    })
end

function DayMenuInputSystem.setup(scene)
    local list = {}
    for _, demon in ipairs(demons) do
        list[#list + 1] = { kind = "visit", demonId = demon.id }
    end
    for _, stat in ipairs(stats) do
        list[#list + 1] = { kind = "train", stat = stat.id }
    end
    scene.world:spawn({ dayMenu = { actions = list, cursor = 1 } })
end

function DayMenuInputSystem.update(scene, dt)
    local world = scene.world
    if world:resource("dayPhase").phase ~= "choosing" then return end

    local runState = world:resource("runState")
    local _, menu = world:first("dayMenu")
    local count = #menu.actions

    local mx, my = love.mouse.getPosition()
    local hovered = DayMenuLayout.hit(count, mx, my)
    if hovered and (mx ~= menu.lastMouseX or my ~= menu.lastMouseY) then
        menu.cursor = hovered
    end
    menu.lastMouseX, menu.lastMouseY = mx, my

    for _, entity in ipairs(world:query("mousePressed")) do
        local click = world:getComponent(entity, "mousePressed")
        local i = DayMenuLayout.hit(count, click.x, click.y)
        if click.button == 1 and i then
            menu.cursor = i
            confirm(scene, menu, runState)
        end
    end

    for _, entity in ipairs(world:query("keyPressed")) do
        local key = world:getComponent(entity, "keyPressed").key
        local picked = tonumber(key)
        if key == "escape" then
            world:spawn({ switchRequest = { to = "menu" } })
        elseif key == "c" then
            world:spawn({ switchRequest = { to = "collection", payload = { back = "week" } } })
        elseif key == "up" or key == "w" then
            menu.cursor = (menu.cursor - 2) % count + 1
        elseif key == "down" or key == "s" then
            menu.cursor = menu.cursor % count + 1
        elseif key == "left" or key == "a" or key == "right" or key == "d" then
            menu.cursor = (menu.cursor - 1 + DayMenuLayout.PER_COL) % count + 1
        elseif key == "return" or key == "space" then
            confirm(scene, menu, runState)
        elseif picked and picked >= 1 and picked <= count then
            menu.cursor = picked
            confirm(scene, menu, runState)
        end
    end
end

return DayMenuInputSystem
