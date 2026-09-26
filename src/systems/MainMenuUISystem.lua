-- UI 1: el menú principal. Jugar / Créditos / Salir.

local Screen = require("src.Screen")
local run = require("src.data.run")

local MainMenuUISystem = { name = "mainMenuUI" }

local fonts = {}

local OPTION_W, OPTION_H, SPACING = 260, 44, 56

function MainMenuUISystem.setup(scene)
    fonts.title = love.graphics.newFont(48)
    fonts.subtitle = love.graphics.newFont(16)
    fonts.option = love.graphics.newFont(22)
    fonts.small = love.graphics.newFont(13)

    scene.world:spawn({
        menu = {
            options = {
                { id = "play", label = "Jugar" },
                { id = "credits", label = "Créditos" },
                { id = "quit", label = "Salir" },
            },
            cursor = 1,
            x = (Screen.w - OPTION_W) / 2,
            y = 270,
            showCredits = false,
        },
    })
end

function MainMenuUISystem.unload(scene)
    fonts = {} 
end

local function optionAt(menu, mx, my)
    for i = 1, #menu.options do
        local oy = menu.y + (i - 1) * SPACING
        if mx >= menu.x and mx <= menu.x + OPTION_W and my >= oy and my <= oy + OPTION_H then
            return i
        end
    end
end

local function confirm(scene, menu)
    local option = menu.options[menu.cursor].id
    if option == "play" then
        scene.world:spawn({ switchRequest = { to = "hub", payload = { runState = run.new() } } })
    elseif option == "credits" then
        menu.showCredits = true
    elseif option == "quit" then
        love.event.quit()
    end
end

function MainMenuUISystem.update(scene, dt)
    local world = scene.world
    local _, menu = world:first("menu")

    if menu.showCredits then
        if #world:query("keyPressed") > 0 or #world:query("mousePressed") > 0 then
            menu.showCredits = false
        end
        return
    end

    local mx, my = love.mouse.getPosition()
    local hovered = optionAt(menu, mx, my)
    if hovered and (mx ~= menu.lastMouseX or my ~= menu.lastMouseY) then
        menu.cursor = hovered
    end
    menu.lastMouseX, menu.lastMouseY = mx, my

    for _, entity in ipairs(world:query("mousePressed")) do
        local click = world:getComponent(entity, "mousePressed")
        local i = optionAt(menu, click.x, click.y)
        if click.button == 1 and i then
            menu.cursor = i
            confirm(scene, menu)
        end
    end

    for _, entity in ipairs(world:query("keyPressed")) do
        local key = world:getComponent(entity, "keyPressed").key
        if key == "up" or key == "w" then
            menu.cursor = (menu.cursor - 2) % #menu.options + 1
        elseif key == "down" or key == "s" then
            menu.cursor = menu.cursor % #menu.options + 1
        elseif key == "return" or key == "space" then
            confirm(scene, menu)
        elseif key == "escape" then
            love.event.quit()
        end
    end
end

local function drawCredits()
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, Screen.w, Screen.h)

    local w, h = 520, 240
    local x, y = (Screen.w - w) / 2, (Screen.h - h) / 2
    love.graphics.setColor(0.07, 0.03, 0.06, 1)
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", x, y, w, h)

    love.graphics.setFont(fonts.option)
    love.graphics.printf("Créditos", x, y + 20, w, "center")
    love.graphics.setFont(fonts.subtitle)
    love.graphics.printf(
        "Diseño y programación: Nahomy Castro\n\n"
            .. "CC3096 — Game Engine Architecture, UVG 2026\n"
            .. "Motor: ECS propio en Lua + LÖVE 11.5",
        x + 30, y + 70, w - 60, "center")
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    love.graphics.setFont(fonts.small)
    love.graphics.printf("Cualquier tecla o clic para volver", x, y + h - 32, w, "center")
end

function MainMenuUISystem.draw(scene)
    local _, menu = scene.world:first("menu")

    love.graphics.setColor(0.12, 0.05, 0.1, 1)
    love.graphics.rectangle("fill", 0, 0, Screen.w, Screen.h)

    love.graphics.setFont(fonts.title)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("Dating Demons To Leave", 0, 100, Screen.w, "center")

    love.graphics.setFont(fonts.subtitle)
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    love.graphics.printf("Escapa del infierno... con un poco de ayuda.", 0, 170, Screen.w, "center")

    love.graphics.setFont(fonts.option)
    for i, option in ipairs(menu.options) do
        local oy = menu.y + (i - 1) * SPACING
        if i == menu.cursor then
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.rectangle("line", menu.x, oy, OPTION_W, OPTION_H)
        else
            love.graphics.setColor(0.6, 0.6, 0.6, 1)
        end
        love.graphics.printf(option.label, menu.x, oy + (OPTION_H - fonts.option:getHeight()) / 2, OPTION_W, "center")
    end

    love.graphics.setFont(fonts.small)
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    love.graphics.printf("Flechas / W S: elegir    Enter: confirmar    Mouse: clic    Esc: salir",
        0, Screen.h - 30, Screen.w, "center")

    if menu.showCredits then
        drawCredits()
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return MainMenuUISystem
