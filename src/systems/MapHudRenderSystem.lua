local Screen = require("src.Screen")
local Run = require("src.state.Run")
local Talk = require("src.rules.Talk")
local demons = require("src.data.demons")
local map = require("src.data.map")

local MapHudRenderSystem = { name = "mapHudRender" }

local fonts = {}

function MapHudRenderSystem.setup(scene)
    fonts.info = love.graphics.newFont(14)
    fonts.prompt = love.graphics.newFont(16)
    fonts.small = love.graphics.newFont(12)
end

function MapHudRenderSystem.unload(scene)
    fonts = {}
end

local function promptFor(place, runState)
    if place.kind == "home" then
        return "Presiona Enter para volver a tu celda"
    elseif place.kind == "demon" then
        local demon = demons[place.demonId]
        if not Talk.hasLeft(runState, demon) then
            return demon.name .. " ya te contó todo lo que sabe"
        elseif Talk.visitedToday(runState, demon) then
            return demon.name .. " ya no tiene ganas de hablar hoy. Vuelve mañana."
        elseif not Talk.hasAny(runState, demon) then
            return demon.name .. " todavía no te tiene confianza. Presiona Enter para hacerle compañía."
        end
        return place.name .. ": " .. demon.name .. " está adentro. Presiona Enter para entrar."
    end
    return "La " .. place.name .. " sigue cerrada. Todavía no puedes abrirla."
end

local function panel(x, y, w, h)
    love.graphics.setColor(0.07, 0.03, 0.06, 0.9)
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", x, y, w, h)
end

function MapHudRenderSystem.draw(scene)
    local world = scene.world
    local runState = world:resource("runState")
    local focus = world:resource("mapFocus")

    love.graphics.setFont(fonts.info)
    local left = runState.actionsLeft
    local info = ("Día %d de %d, te quedan %d %s"):format(runState.day, Run.DAYS, left,
        left == 1 and "acción" or "acciones")
    panel(8, 6, fonts.info:getWidth(info) + 16, 22)
    love.graphics.print(info, 16, 9)

    local place = focus.placeId and map.places[focus.placeId]
    if place then
        love.graphics.setFont(fonts.prompt)
        local text = promptFor(place, runState)
        local w = fonts.prompt:getWidth(text) + 24
        local x = (Screen.w - w) / 2
        panel(x, 482, w, 26)
        love.graphics.setColor(1, 0.85, 0.3, 1)
        love.graphics.printf(text, x, 486, w, "center")
    end

    love.graphics.setFont(fonts.small)
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    love.graphics.printf("WASD/Flechas: caminar   Enter: entrar   Esc: volver a tu celda",
        0, Screen.h - 22, Screen.w - 12, "right")

    love.graphics.setColor(1, 1, 1, 1)
end

return MapHudRenderSystem
