-- UI 3: el HUD del hub. Te dice dónde estás y qué tan preparado vas para
-- la puerta: el círculo y su guardián, tus stats, tu afinidad con cada
-- demonio y cuántas cartas llevas. Cuando un demonio te regala una carta,
-- aparece un aviso.
--
--   Setup   crea las fuentes y la entidad `hud`: los valores que se
--           MUESTRAN (arrancan igual que la partida) y la cola de avisos
--   Update  lee runState y acerca los valores mostrados a los reales (las
--           barras se llenan suave en vez de saltar); lee los eventos
--           `cardGained` que anuncia AffinitySystem y los encola como avisos
--   Render  en ESPACIO DE PANTALLA: push + origin ignora la cámara del
--           mundo, así que el HUD no se mueve aunque la cámara sí
--
-- El HUD nunca modifica la partida: solo la lee.

local Screen = require("src.Screen")
local demons = require("src.data.demons")
local circles = require("src.data.circles")
local Affinity = require("src.rules.Affinity")

local HudUISystem = { name = "hudUI" }

local fonts = {}

local STATS = { "astucia", "encanto", "furia" }
local STAT_MAX = 10 -- las barras de stats se dibujan sobre 0..10
local PANEL_W, PANEL_H = 300, 112
local BAR_W, BAR_H = 140, 10
local TOAST_TIME = 3 -- segundos que dura un aviso
local FILL_SPEED = 6 -- qué tan rápido se acercan las barras al valor real

-- ---------------------------------------------------------------- setup

function HudUISystem.setup(scene)
    fonts.title = love.graphics.newFont(15)
    fonts.text = love.graphics.newFont(13)
    fonts.toast = love.graphics.newFont(16)

    local runState = scene.world:resource("runState")
    local shown = { stats = {}, affinity = {} }
    for _, stat in ipairs(STATS) do
        shown.stats[stat] = runState.stats[stat]
    end
    for _, demon in ipairs(demons) do
        shown.affinity[demon.id] = runState.affinity[demon.id]
    end

    scene.world:spawn({
        hud = {
            shown = shown,
            toasts = {}, -- cola de avisos pendientes: { text }
            toastTimer = 0, -- tiempo restante del aviso actual
        },
    })
end

function HudUISystem.unload(scene)
    fonts = {}
end

-- --------------------------------------------------------------- update

local function approach(current, target, dt)
    local next = current + (target - current) * math.min(1, FILL_SPEED * dt)
    if math.abs(target - next) < 0.01 then return target end
    return next
end

function HudUISystem.update(scene, dt)
    local world = scene.world
    local runState = world:resource("runState")
    local _, hud = world:first("hud")

    for _, stat in ipairs(STATS) do
        hud.shown.stats[stat] = approach(hud.shown.stats[stat], runState.stats[stat], dt)
    end
    for _, demon in ipairs(demons) do
        hud.shown.affinity[demon.id] = approach(hud.shown.affinity[demon.id], runState.affinity[demon.id], dt)
    end

    -- reaccionar a los eventos del juego
    for _, entity in ipairs(world:query("cardGained")) do
        local gained = world:getComponent(entity, "cardGained")
        local demon = demons[gained.demonId]
        hud.toasts[#hud.toasts + 1] = {
            text = ("¡%s te dio una carta: %s!"):format(demon.name, gained.card.name),
        }
    end

    -- un aviso a la vez: cuando se acaba el actual, pasa al siguiente
    if hud.toastTimer > 0 then
        hud.toastTimer = hud.toastTimer - dt
        if hud.toastTimer <= 0 then
            table.remove(hud.toasts, 1)
        end
    end
    if hud.toastTimer <= 0 and #hud.toasts > 0 then
        hud.toastTimer = TOAST_TIME
    end
end

-- --------------------------------------------------------------- render

local function panel(x, y, w, h)
    love.graphics.setColor(0.07, 0.03, 0.06, 1)
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", x, y, w, h)
end

local function bar(x, y, ratio, color)
    love.graphics.setColor(0.25, 0.25, 0.25, 1)
    love.graphics.rectangle("fill", x, y, BAR_W, BAR_H)
    love.graphics.setColor(color[1], color[2], color[3], 1)
    love.graphics.rectangle("fill", x, y, BAR_W * math.max(0, math.min(1, ratio)), BAR_H)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", x, y, BAR_W, BAR_H)
end

-- Panel izquierdo: dónde estás y tus stats.
local function drawStatus(runState, hud)
    local x, y = 10, 10
    panel(x, y, PANEL_W, PANEL_H)
    local circle = circles[runState.circle]

    love.graphics.setFont(fonts.title)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(("Círculo %d: %s"):format(runState.circle, circle.name), x + 10, y + 8)
    love.graphics.setFont(fonts.text)
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    love.graphics.print("Guardián: " .. circle.guardian, x + 10, y + 28)

    for i, stat in ipairs(STATS) do
        local ry = y + 50 + (i - 1) * 20
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(stat:sub(1, 1):upper() .. stat:sub(2), x + 10, ry)
        bar(x + 90, ry + 3, hud.shown.stats[stat] / STAT_MAX, { 0.9, 0.9, 0.9 })
        love.graphics.print(tostring(runState.stats[stat]), x + 90 + BAR_W + 10, ry)
    end
end

-- Panel derecho: afinidad con cada demonio y cartas.
local function drawRelations(runState, hud)
    local x, y = Screen.w - PANEL_W - 10, 10
    panel(x, y, PANEL_W, PANEL_H)

    love.graphics.setFont(fonts.title)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Afinidad", x + 10, y + 8)
    love.graphics.printf(("Cartas: %d"):format(#runState.cards), x, y + 8, PANEL_W - 10, "right")

    love.graphics.setFont(fonts.text)
    for i, demon in ipairs(demons) do
        local ry = y + 34 + (i - 1) * 24
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(demon.name, x + 10, ry)
        bar(x + 90, ry + 3, Affinity.ratio(hud.shown.affinity[demon.id]), demon.color)
        love.graphics.print(("%d/%d"):format(runState.affinity[demon.id], Affinity.MAX), x + 90 + BAR_W + 10, ry)
    end
end

local function drawToast(hud)
    if hud.toastTimer <= 0 or #hud.toasts == 0 then return end
    local text = hud.toasts[1].text
    local w, h = 460, 34
    local x, y = (Screen.w - w) / 2, 130
    panel(x, y, w, h)
    love.graphics.setFont(fonts.toast)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(text, x, y + 8, w, "center")
end

function HudUISystem.draw(scene)
    local world = scene.world
    local runState = world:resource("runState")
    local _, hud = world:first("hud")

    love.graphics.push()
    love.graphics.origin() -- espacio de pantalla: la cámara del mundo no aplica

    drawStatus(runState, hud)
    drawRelations(runState, hud)
    drawToast(hud)

    love.graphics.pop()
    love.graphics.setColor(1, 1, 1, 1)
end

return HudUISystem
