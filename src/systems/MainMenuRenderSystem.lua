local Screen = require("src.Screen")
local MainMenuLayout = require("src.ui.MainMenuLayout")

local MainMenuRenderSystem = { name = "mainMenuRender" }

local fonts = {}

function MainMenuRenderSystem.setup(scene)
    fonts.title = love.graphics.newFont(48)
    fonts.subtitle = love.graphics.newFont(16)
    fonts.option = love.graphics.newFont(22)
    fonts.small = love.graphics.newFont(13)
end

function MainMenuRenderSystem.unload(scene)
    fonts = {}
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

function MainMenuRenderSystem.draw(scene)
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
        local x, y, w, h = MainMenuLayout.rect(i)
        if i == menu.cursor then
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.rectangle("line", x, y, w, h)
        else
            love.graphics.setColor(0.6, 0.6, 0.6, 1)
        end
        love.graphics.printf(option.label, x, y + (h - fonts.option:getHeight()) / 2, w, "center")
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

return MainMenuRenderSystem
