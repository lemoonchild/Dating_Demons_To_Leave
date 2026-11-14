local Run = require("src.state.Run")
local stats = require("src.data.stats")
local TrainingSystem = require("src.systems.TrainingSystem")
local RoomMenuLayout = require("src.ui.RoomMenuLayout")
local RoomMenuInputSystem = require("src.systems.RoomMenuInputSystem")

local RoomMenuRenderSystem = { name = "roomMenuRender" }

local fonts = {}
local BOX = RoomMenuLayout.BOX

local LABELS = {
    training = "Entrenar",
    visit = "Visitar demonios",
    back = "Volver",
}

local HINTS = {
    training = "Sube una de tus stats, pero te toma el resto del día",
    visit = "Sales de tu celda al círculo para buscarlos",
    back = "Regresas sin entrenar",
}

function RoomMenuRenderSystem.setup(scene)
    fonts.title = love.graphics.newFont(18)
    fonts.option = love.graphics.newFont(16)
    fonts.small = love.graphics.newFont(13)
end

function RoomMenuRenderSystem.unload(scene)
    fonts = {}
end

local function titleOf(menu, runState, left)
    if menu.screen == "training" and left < Run.ACTIONS then
        return "¿Qué quieres entrenar? Te queda medio día, rinde menos."
    elseif menu.screen == "training" then
        return "¿Qué quieres entrenar? Te toma el día entero."
    end
    return ("Día %d de %d. ¿Qué vas a hacer hoy?"):format(runState.day, Run.DAYS)
end

local function leftText(left)
    return ("Te quedan %d %s"):format(left, left == 1 and "acción" or "acciones")
end

function RoomMenuRenderSystem.draw(scene)
    local world = scene.world
    local phase = world:resource("dayPhase")
    if phase.phase ~= "choosing" then return end

    local runState = world:resource("runState")
    local _, menu = world:first("roomMenu")

    love.graphics.setColor(0.07, 0.03, 0.06, 1)
    love.graphics.rectangle("fill", BOX.x, BOX.y, BOX.w, BOX.h)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", BOX.x, BOX.y, BOX.w, BOX.h)

    love.graphics.setFont(fonts.title)
    love.graphics.print(titleOf(menu, runState, phase.left), BOX.x + 20, BOX.y + 14)
    love.graphics.setFont(fonts.option)
    love.graphics.setColor(1, 0.85, 0.3, 1)
    love.graphics.printf(leftText(phase.left), BOX.x, BOX.y + 16, BOX.w - 20, "right")

    for i, option in ipairs(RoomMenuInputSystem.options(menu)) do
        local x, y, w, h = RoomMenuLayout.rect(i)
        local selected = i == menu.cursor
        if selected then
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.rectangle("line", x - 8, y, w + 8, h - 4)
        end

        local shade = selected and 1 or 0.65
        local label, hint = LABELS[option.id], HINTS[option.id]
        if option.id == "stat" then
            local stat = stats[option.stat]
            label = stat.name
            hint = stat.description
            love.graphics.setFont(fonts.small)
            love.graphics.setColor(0.6, 0.6, 0.6, 1)
            love.graphics.printf(("+%d %s"):format(TrainingSystem.gainFor(phase.left), stat.name:lower()), x, y + 7, w - 16, "right")
        end

        love.graphics.setFont(fonts.option)
        love.graphics.setColor(shade, shade, shade, 1)
        love.graphics.print(("%d. %s"):format(i, label), x, y + 5)

        love.graphics.setFont(fonts.small)
        love.graphics.setColor(0.75 * shade, 0.72 * shade, 0.72 * shade, 1)
        love.graphics.print(hint, x + 190, y + 7)
    end

    love.graphics.setFont(fonts.small)
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    local back = menu.screen == "training" and "Esc: volver" or "Esc: menú"
    love.graphics.printf("Flechas: elegir   Enter: confirmar   C: colección   " .. back,
        BOX.x, BOX.y + BOX.h - 22, BOX.w - 20, "right")

    love.graphics.setColor(1, 1, 1, 1)
end

return RoomMenuRenderSystem
