local Screen = require("src.Screen")
local demons = require("src.data.demons")
local Run = require("src.state.Run")
local Mood = require("src.rules.Mood")

local DayMenuUISystem = { name = "dayMenuUI" }

local fonts = {}

local STATS = { "astucia", "encanto", "furia" }
local BOX = { x = 20, y = 356, w = Screen.w - 40, h = 164 }
local COLS = { 40, 496 }
local COL_W = 424
local ROW_H = 36
local FIRST_Y = 398

local function actionRect(i)
    local col = i <= #demons and 1 or 2
    local row = (i - 1) % #demons
    return COLS[col], FIRST_Y + row * ROW_H, COL_W, ROW_H
end

local function actionAt(menu, mx, my)
    for i = 1, #menu.actions do
        local x, y, w, h = actionRect(i)
        if mx >= x and mx <= x + w and my >= y and my < y + h then return i end
    end
end

local function confirm(scene, menu)
    local action = menu.actions[menu.cursor]
    scene.world:spawn({
        event = true,
        actionPicked = { kind = action.kind, demonId = action.demonId, stat = action.stat },
    })
end

function DayMenuUISystem.setup(scene)
    fonts.title = love.graphics.newFont(18)
    fonts.option = love.graphics.newFont(16)
    fonts.small = love.graphics.newFont(12)

    local list = {}
    for _, demon in ipairs(demons) do
        list[#list + 1] = { kind = "visit", demonId = demon.id }
    end
    for _, stat in ipairs(STATS) do
        list[#list + 1] = { kind = "train", stat = stat }
    end

    scene.world:spawn({ dayMenu = { actions = list, cursor = 1 } })
end

function DayMenuUISystem.unload(scene)
    fonts = {}
end

function DayMenuUISystem.update(scene, dt)
    local world = scene.world
    if world:resource("dayPhase").phase ~= "choosing" then return end

    local _, menu = world:first("dayMenu")
    local count = #menu.actions

    local mx, my = love.mouse.getPosition()
    local hovered = actionAt(menu, mx, my)
    if hovered and (mx ~= menu.lastMouseX or my ~= menu.lastMouseY) then
        menu.cursor = hovered
    end
    menu.lastMouseX, menu.lastMouseY = mx, my

    for _, entity in ipairs(world:query("mousePressed")) do
        local click = world:getComponent(entity, "mousePressed")
        local i = actionAt(menu, click.x, click.y)
        if click.button == 1 and i then
            menu.cursor = i
            confirm(scene, menu)
        end
    end

    for _, entity in ipairs(world:query("keyPressed")) do
        local key = world:getComponent(entity, "keyPressed").key
        local picked = tonumber(key)
        if key == "escape" then
            world:spawn({ switchRequest = { to = "menu" } })
        elseif key == "up" or key == "w" then
            menu.cursor = (menu.cursor - 2) % count + 1
        elseif key == "down" or key == "s" then
            menu.cursor = menu.cursor % count + 1
        elseif key == "left" or key == "a" or key == "right" or key == "d" then
            menu.cursor = (menu.cursor - 1 + #demons) % count + 1
        elseif key == "return" or key == "space" then
            confirm(scene, menu)
        elseif picked and picked >= 1 and picked <= count then
            menu.cursor = picked
            confirm(scene, menu)
        end
    end
end

local function label(action, runState)
    if action.kind == "visit" then
        return demons[action.demonId].name
    end
    return "Entrenar " .. action.stat
end

function DayMenuUISystem.draw(scene)
    local world = scene.world
    if world:resource("dayPhase").phase ~= "choosing" then return end

    local runState = world:resource("runState")
    local _, menu = world:first("dayMenu")

    love.graphics.setColor(0.07, 0.03, 0.06, 1)
    love.graphics.rectangle("fill", BOX.x, BOX.y, BOX.w, BOX.h)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", BOX.x, BOX.y, BOX.w, BOX.h)

    love.graphics.setFont(fonts.title)
    love.graphics.print(("Día %d de %d - ¿a quién buscás hoy?"):format(runState.day, Run.DAYS), BOX.x + 20, BOX.y + 14)

    love.graphics.setFont(fonts.option)
    for i, action in ipairs(menu.actions) do
        local x, y, w, h = actionRect(i)
        if i == menu.cursor then
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.rectangle("line", x - 8, y, w, h - 4)
        end

        love.graphics.setColor(i == menu.cursor and 1 or 0.65, i == menu.cursor and 1 or 0.65, i == menu.cursor and 1 or 0.65, 1)
        love.graphics.print(("%d. %s"):format(i, label(action, runState)), x, y + 7)

        if action.kind == "visit" then
            local mood = Mood.of(runState.moods[action.demonId])
            love.graphics.setColor(mood.color[1], mood.color[2], mood.color[3], 1)
            love.graphics.printf(mood.name, x, y + 7, w - 16, "right")
        else
            love.graphics.setColor(0.6, 0.6, 0.6, 1)
            love.graphics.printf("+1", x, y + 7, w - 16, "right")
        end
    end

    love.graphics.setFont(fonts.small)
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    love.graphics.printf("Flechas: elegir   Enter: confirmar   1-6: atajo   Esc: menú",
        BOX.x, BOX.y + BOX.h - 22, BOX.w - 20, "right")

    love.graphics.setColor(1, 1, 1, 1)
end

return DayMenuUISystem
