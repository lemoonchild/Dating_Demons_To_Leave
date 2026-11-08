local Run = require("src.state.Run")
local demons = require("src.data.demons")
local stats = require("src.data.stats")
local Mood = require("src.rules.Mood")
local DayMenuLayout = require("src.ui.DayMenuLayout")
local DayMenuInputSystem = require("src.systems.DayMenuInputSystem")

local DayMenuRenderSystem = { name = "dayMenuRender" }

local fonts = {}
local BOX = DayMenuLayout.BOX

function DayMenuRenderSystem.setup(scene)
    fonts.title = love.graphics.newFont(18)
    fonts.option = love.graphics.newFont(16)
    fonts.small = love.graphics.newFont(12)
end

function DayMenuRenderSystem.unload(scene)
    fonts = {}
end

local function label(action)
    if action.kind == "visit" then
        return demons[action.demonId].name
    end
    return "Entrenar " .. stats[action.stat].name:lower()
end

function DayMenuRenderSystem.draw(scene)
    local world = scene.world
    local phase = world:resource("dayPhase")
    if phase.phase ~= "choosing" then return end

    local runState = world:resource("runState")
    local _, menu = world:first("dayMenu")

    love.graphics.setColor(0.07, 0.03, 0.06, 1)
    love.graphics.rectangle("fill", BOX.x, BOX.y, BOX.w, BOX.h)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", BOX.x, BOX.y, BOX.w, BOX.h)

    love.graphics.setFont(fonts.title)
    love.graphics.print(("Día %d de %d - ¿a quién buscás hoy?"):format(runState.day, Run.DAYS), BOX.x + 20, BOX.y + 14)
    love.graphics.setFont(fonts.option)
    love.graphics.setColor(1, 0.85, 0.3, 1)
    love.graphics.printf(("Te quedan %d de %d acciones"):format(phase.left, Run.ACTIONS),
        BOX.x, BOX.y + 16, BOX.w - 20, "right")

    love.graphics.setFont(fonts.option)
    for i, action in ipairs(menu.actions) do
        local x, y, w, h = DayMenuLayout.rect(i)
        if i == menu.cursor then
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.rectangle("line", x - 8, y, w, h - 4)
        end

        local used = DayMenuInputSystem.spent(runState, action)
        local shade = used and 0.35 or (i == menu.cursor and 1 or 0.65)
        love.graphics.setColor(shade, shade, shade, 1)
        love.graphics.print(("%d. %s"):format(i, label(action)), x, y + 7)

        if used then
            love.graphics.setColor(0.45, 0.45, 0.45, 1)
            love.graphics.printf("ya te contó todo", x, y + 7, w - 16, "right")
        elseif action.kind == "visit" then
            local mood = Mood.of(runState.moods[action.demonId])
            love.graphics.setColor(mood.color[1], mood.color[2], mood.color[3], 1)
            love.graphics.printf(mood.name, x, y + 7, w - 16, "right")
        else
            love.graphics.setColor(0.6, 0.6, 0.6, 1)
            love.graphics.printf("+1, te toma el día", x, y + 7, w - 16, "right")
        end
    end

    love.graphics.setFont(fonts.small)
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    love.graphics.printf("Flechas: elegir   Enter: confirmar   C: colección   Esc: menú",
        BOX.x, BOX.y + BOX.h - 22, BOX.w - 20, "right")

    love.graphics.setColor(1, 1, 1, 1)
end

return DayMenuRenderSystem
