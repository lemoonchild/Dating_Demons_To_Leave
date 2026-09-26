-- UI 1: el menú principal. Jugar / Créditos / Salir.
--
--   Setup   crea las fuentes y la entidad `menu` (opciones, cursor,
--           posiciones, brasas del fondo, panel de créditos cerrado)
--   Update  lee el input (teclado como eventos `keyPressed`, mouse como
--           hover + evento `mousePressed`), mueve el cursor y decide:
--           Jugar pide el cambio a la escena "hub" con una partida NUEVA,
--           Créditos abre/cierra el panel, Salir cierra el juego
--   Render  fondo infernal, título, opciones (la elegida resaltada),
--           ayuda de controles y, encima de todo, el panel de créditos
--
-- El menú no sabe nada del hub: solo crea un `switchRequest` y el Game
-- hace el cambio al terminar el frame.

local Screen = require("src.Screen")
local run = require("src.data.run")

local MainMenuUISystem = { name = "mainMenuUI" }

local fonts = {}

local OPTION_W, OPTION_H, SPACING = 260, 44, 56
local EMBERS = 40

-- ---------------------------------------------------------------- setup

function MainMenuUISystem.setup(scene)
    fonts.title = love.graphics.newFont(48)
    fonts.subtitle = love.graphics.newFont(16)
    fonts.option = love.graphics.newFont(22)
    fonts.small = love.graphics.newFont(13)

    -- brasas que suben por el fondo: solo decoración, pero viven en el
    -- componente para que el update las mueva y el render las pinte
    local embers = {}
    for i = 1, EMBERS do
        embers[i] = {
            x = love.math.random() * Screen.w,
            y = love.math.random() * Screen.h,
            speed = 15 + love.math.random() * 35,
            size = 1 + love.math.random() * 2.5,
        }
    end

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
            time = 0,
            embers = embers,
        },
    })
end

function MainMenuUISystem.unload(scene)
    fonts = {} -- soltar las referencias; el GC recoge las fuentes
end

-- --------------------------------------------------------------- update

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

    menu.time = menu.time + dt
    for _, ember in ipairs(menu.embers) do
        ember.y = ember.y - ember.speed * dt
        if ember.y < -5 then
            ember.y = Screen.h + 5
            ember.x = love.math.random() * Screen.w
        end
    end

    -- con los créditos abiertos, cualquier tecla o clic los cierra
    if menu.showCredits then
        if #world:query("keyPressed") > 0 or #world:query("mousePressed") > 0 then
            menu.showCredits = false
        end
        return
    end

    -- mouse: el hover mueve el cursor (estado continuo, se consulta cada frame)
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

    -- teclado: acciones discretas, llegan como eventos
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

-- --------------------------------------------------------------- render

local function drawBackground(menu)
    -- degradado vertical: negro arriba, rojo brasa abajo
    local bands = 24
    for i = 0, bands - 1 do
        local t = i / (bands - 1)
        love.graphics.setColor(0.05 + 0.35 * t, 0.02 + 0.04 * t, 0.04, 1)
        love.graphics.rectangle("fill", 0, Screen.h * i / bands, Screen.w, Screen.h / bands + 1)
    end
    for _, ember in ipairs(menu.embers) do
        local glow = 0.5 + 0.5 * math.sin(menu.time * 3 + ember.x)
        love.graphics.setColor(1, 0.45 + 0.3 * glow, 0.1, 0.35 + 0.5 * glow)
        love.graphics.circle("fill", ember.x, ember.y, ember.size)
    end
end

local function drawCredits()
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, Screen.w, Screen.h)

    local w, h = 520, 240
    local x, y = (Screen.w - w) / 2, (Screen.h - h) / 2
    love.graphics.setColor(0.12, 0.05, 0.07, 1)
    love.graphics.rectangle("fill", x, y, w, h, 8, 8)
    love.graphics.setColor(0.9, 0.35, 0.2, 1)
    love.graphics.rectangle("line", x, y, w, h, 8, 8)

    love.graphics.setFont(fonts.option)
    love.graphics.printf("Créditos", x, y + 20, w, "center")
    love.graphics.setColor(0.95, 0.9, 0.85, 1)
    love.graphics.setFont(fonts.subtitle)
    love.graphics.printf(
        "Diseño y programación: Nahomy Castro\n\n"
            .. "CC3096 — Game Engine Architecture, UVG 2026\n"
            .. "Motor: ECS propio en Lua + LÖVE 11.5",
        x + 30, y + 70, w - 60, "center")
    love.graphics.setColor(0.7, 0.6, 0.6, 1)
    love.graphics.setFont(fonts.small)
    love.graphics.printf("Cualquier tecla o clic para volver", x, y + h - 32, w, "center")
end

function MainMenuUISystem.draw(scene)
    local _, menu = scene.world:first("menu")

    drawBackground(menu)

    -- título con un leve pulso, como fuego
    local pulse = 0.85 + 0.15 * math.sin(menu.time * 2)
    love.graphics.setFont(fonts.title)
    love.graphics.setColor(0.2, 0, 0, 0.8)
    love.graphics.printf("Dating Demons To Leave", 3, 103, Screen.w, "center")
    love.graphics.setColor(1, 0.35 * pulse + 0.2, 0.15, 1)
    love.graphics.printf("Dating Demons To Leave", 0, 100, Screen.w, "center")

    love.graphics.setFont(fonts.subtitle)
    love.graphics.setColor(0.95, 0.8, 0.75, 0.9)
    love.graphics.printf("Escapa del infierno... con un poco de ayuda.", 0, 170, Screen.w, "center")

    love.graphics.setFont(fonts.option)
    for i, option in ipairs(menu.options) do
        local oy = menu.y + (i - 1) * SPACING
        local selected = i == menu.cursor
        if selected then
            love.graphics.setColor(0.85, 0.25, 0.15, 0.35 + 0.2 * math.sin(menu.time * 5))
            love.graphics.rectangle("fill", menu.x, oy, OPTION_W, OPTION_H, 6, 6)
            love.graphics.setColor(1, 0.6, 0.3, 1)
            love.graphics.rectangle("line", menu.x, oy, OPTION_W, OPTION_H, 6, 6)
            love.graphics.setColor(1, 0.95, 0.85, 1)
        else
            love.graphics.setColor(0.8, 0.65, 0.6, 1)
        end
        local label = selected and ("> " .. option.label .. " <") or option.label
        love.graphics.printf(label, menu.x, oy + (OPTION_H - fonts.option:getHeight()) / 2, OPTION_W, "center")
    end

    love.graphics.setFont(fonts.small)
    love.graphics.setColor(0.8, 0.7, 0.65, 0.8)
    love.graphics.printf("Flechas / W S: elegir    Enter: confirmar    Mouse: clic    Esc: salir",
        0, Screen.h - 30, Screen.w, "center")

    if menu.showCredits then
        drawCredits()
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return MainMenuUISystem
