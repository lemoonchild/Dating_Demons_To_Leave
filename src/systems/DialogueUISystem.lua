-- UI 2: la caja de diálogo con los demonios. 
--
--   Setup   crea las fuentes y la entidad `dialogue` (con quién habla el jugador,
--           texto, cuántas letras se ven, cursor, etapa) y abre la
--           primera conversación
--   Update  avanza el efecto de máquina de escribir con dt y lee el input:
--           arriba/abajo o mouse eligen respuesta, Enter/clic/1-3
--           confirman, izq/der/Tab cambian de demonio, Esc vuelve al
--           menú. Al responder NO toca
--           la afinidad: solo anuncia un evento `dialogueChoice`, y
--           AffinitySystem aplica las reglas en este mismo frame
--   Render  la caja, el nombre del demonio, su
--           retrato, el texto visible y las respuestas. 
--

local Screen = require("src.Screen")
local demons = require("src.data.demons")
local DemonArt = require("src.graphics.DemonArt")

local DialogueUISystem = { name = "dialogueUI" }

local fonts = {}

-- Layout: una sola fuente de verdad para update (clics) y render.
local BOX = { x = 20, y = 356, w = Screen.w - 40, h = 164 }
local TAG = { x = 20, y = 324, w = 330, h = 30 }
local PORTRAIT = { x = 34, y = 370, w = 136, h = 136 }
local TEXT_X = 186
local TEXT_W = BOX.x + BOX.w - TEXT_X - 16
local OPTIONS_Y = 432
local OPTION_H = 26
local TYPE_SPEED = 45 -- letras por segundo

-- ---------------------------------------------------------------- helpers

local function currentDemon(dialogue)
    return demons[dialogue.demonIndex]
end

local function typing(dialogue)
    return dialogue.visible < #dialogue.text
end

-- Abre lo que el demonio actual tiene que decir: su próxima conversación,
-- o un aviso si ya no le queda nada.
local function openLine(dialogue, runState)
    local demon = currentDemon(dialogue)
    local conversation = demon.conversations[runState.talks[demon.id]]
    if conversation then
        dialogue.stage = "line"
        dialogue.text = conversation.line
    else
        dialogue.stage = "done"
        dialogue.text = demon.name .. " ya te contó todo lo que sabe. Busca a otro demonio."
    end
    dialogue.visible = 0
    dialogue.cursor = 1
    dialogue.picked = nil
end

local function optionRect(i)
    return TEXT_X, OPTIONS_Y + (i - 1) * OPTION_H, TEXT_W, OPTION_H
end

local function optionAt(dialogue, runState, mx, my)
    if dialogue.stage ~= "line" or typing(dialogue) then return nil end
    local demon = currentDemon(dialogue)
    local options = demon.conversations[runState.talks[demon.id]].options
    for i = 1, #options do
        local x, y, w, h = optionRect(i)
        if mx >= x and mx <= x + w and my >= y and my < y + h then return i end
    end
end

-- Elegir una respuesta: anunciar el evento y mostrar la reacción.
local function choose(scene, dialogue, runState, i)
    local demon = currentDemon(dialogue)
    local index = runState.talks[demon.id]
    local option = demon.conversations[index].options[i]

    scene.world:spawn({
        event = true,
        dialogueChoice = { demonId = demon.id, conversation = index, option = i },
    })

    runState.talks[demon.id] = index + 1
    dialogue.stage = "reaction"
    dialogue.text = option.reaction
    dialogue.visible = 0
    dialogue.picked = { affinity = option.affinity or 0, stat = option.stat or 0, statName = demon.stat }
end

local function switchDemon(dialogue, runState, step)
    dialogue.demonIndex = (dialogue.demonIndex - 1 + step) % #demons + 1
    openLine(dialogue, runState)
end

-- "Enter": completa el texto si se está escribiendo, si no avanza.
local function advance(scene, dialogue, runState)
    if typing(dialogue) then
        dialogue.visible = #dialogue.text
    elseif dialogue.stage == "line" then
        choose(scene, dialogue, runState, dialogue.cursor)
    elseif dialogue.stage == "reaction" then
        openLine(dialogue, runState)
    end
end

-- ---------------------------------------------------------------- setup

function DialogueUISystem.setup(scene)
    fonts.name = love.graphics.newFont(16)
    fonts.text = love.graphics.newFont(17)
    fonts.option = love.graphics.newFont(16)
    fonts.small = love.graphics.newFont(12)

    local dialogue = {
        demonIndex = 1,
        stage = "line",
        text = "",
        visible = 0,
        cursor = 1,
    }
    scene.world:spawn({ dialogue = dialogue })
    openLine(dialogue, scene.world:resource("runState"))
end

function DialogueUISystem.unload(scene)
    fonts = {}
end

-- --------------------------------------------------------------- update

function DialogueUISystem.update(scene, dt)
    local world = scene.world
    local runState = world:resource("runState")
    local _, dialogue = world:first("dialogue")

    dialogue.visible = math.min(#dialogue.text, dialogue.visible + TYPE_SPEED * dt)

    -- mouse: hover elige respuesta (estado continuo), clic confirma (evento)
    local mx, my = love.mouse.getPosition()
    local hovered = optionAt(dialogue, runState, mx, my)
    if hovered and (mx ~= dialogue.lastMouseX or my ~= dialogue.lastMouseY) then
        dialogue.cursor = hovered
    end
    dialogue.lastMouseX, dialogue.lastMouseY = mx, my

    for _, entity in ipairs(world:query("mousePressed")) do
        local click = world:getComponent(entity, "mousePressed")
        if click.button == 1 then
            local i = optionAt(dialogue, runState, click.x, click.y)
            if i then
                choose(scene, dialogue, runState, i)
            elseif click.y >= BOX.y then
                advance(scene, dialogue, runState)
            end
        end
    end

    -- teclado
    for _, entity in ipairs(world:query("keyPressed")) do
        local key = world:getComponent(entity, "keyPressed").key
        local choosing = dialogue.stage == "line" and not typing(dialogue)

        if key == "escape" then
            world:spawn({ switchRequest = { to = "menu" } })
        elseif key == "return" or key == "space" then
            advance(scene, dialogue, runState)
        elseif (key == "up" or key == "w") and choosing then
            dialogue.cursor = (dialogue.cursor - 2) % 3 + 1
        elseif (key == "down" or key == "s") and choosing then
            dialogue.cursor = dialogue.cursor % 3 + 1
        elseif (key == "1" or key == "2" or key == "3") and choosing then
            choose(scene, dialogue, runState, tonumber(key))
        elseif (key == "right" or key == "d" or key == "tab") and dialogue.stage ~= "reaction" then
            switchDemon(dialogue, runState, 1)
        elseif (key == "left" or key == "a") and dialogue.stage ~= "reaction" then
            switchDemon(dialogue, runState, -1)
        end
    end
end

-- --------------------------------------------------------------- render

-- `visible` cuenta BYTES. En UTF-8 ("¿Qué...") un corte a la mitad de una
-- letra rompe el string: si el byte siguiente es de continuación
-- (10xxxxxx), se retrocede hasta el inicio de la letra.
local function visibleText(dialogue)
    local cut = math.floor(dialogue.visible)
    local text = dialogue.text
    while cut > 0 and cut < #text do
        local b = text:byte(cut + 1)
        if b < 0x80 or b >= 0xC0 then break end
        cut = cut - 1
    end
    return text:sub(1, cut)
end

local function describePick(picked)
    local parts = {}
    if picked.affinity ~= 0 then
        parts[#parts + 1] = ("%+d afinidad"):format(picked.affinity)
    end
    if picked.stat > 0 then
        parts[#parts + 1] = ("+%d %s"):format(picked.stat, picked.statName)
    end
    if #parts == 0 then return "sin cambios" end
    return table.concat(parts, "   ")
end

function DialogueUISystem.draw(scene)
    local world = scene.world
    local runState = world:resource("runState")
    local _, dialogue = world:first("dialogue")
    local demon = currentDemon(dialogue)

    -- etiqueta con el nombre
    love.graphics.setColor(0.07, 0.03, 0.06, 1)
    love.graphics.rectangle("fill", TAG.x, TAG.y, TAG.w, TAG.h)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", TAG.x, TAG.y, TAG.w, TAG.h)
    love.graphics.setFont(fonts.name)
    love.graphics.print(demon.name .. " - " .. demon.title, TAG.x + 10, TAG.y + 6)

    love.graphics.setFont(fonts.small)
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    love.graphics.printf(("Demonio %d/%d   Izq/Der: cambiar   Esc: menú"):format(dialogue.demonIndex, #demons),
        TAG.x, TAG.y + 10, BOX.w, "right")

    -- la caja
    love.graphics.setColor(0.07, 0.03, 0.06, 1)
    love.graphics.rectangle("fill", BOX.x, BOX.y, BOX.w, BOX.h)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", BOX.x, BOX.y, BOX.w, BOX.h)

    -- retrato: placeholder del color del demonio (el mismo DemonArt que el mundo)
    DemonArt.draw(demon, PORTRAIT.x + PORTRAIT.w / 2, PORTRAIT.y + PORTRAIT.h, PORTRAIT.w, PORTRAIT.h)

    -- el texto que ya se "escribió"
    love.graphics.setFont(fonts.text)
    love.graphics.setColor(1, 0.95, 0.9, 1)
    love.graphics.printf(visibleText(dialogue), TEXT_X, BOX.y + 16, TEXT_W, "left")

    if typing(dialogue) then
        love.graphics.setColor(1, 1, 1, 1)
        return
    end

    if dialogue.stage == "line" then
        local options = demon.conversations[runState.talks[demon.id]].options
        love.graphics.setFont(fonts.option)
        for i, option in ipairs(options) do
            local x, y, w, h = optionRect(i)
            if i == dialogue.cursor then
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.rectangle("line", x - 6, y, w + 6, h - 2)
            else
                love.graphics.setColor(0.7, 0.7, 0.7, 1)
            end
            love.graphics.print(("%d. %s"):format(i, option.text), x, y + 4)
        end
    elseif dialogue.stage == "reaction" then
        local picked = dialogue.picked
        if picked.affinity > 0 then
            love.graphics.setColor(0.5, 1, 0.5, 1)
        elseif picked.affinity < 0 then
            love.graphics.setColor(1, 0.45, 0.4, 1)
        else
            love.graphics.setColor(0.85, 0.8, 0.8, 1)
        end
        love.graphics.setFont(fonts.option)
        love.graphics.print(describePick(picked), TEXT_X, OPTIONS_Y + 10)
    end

    if dialogue.stage ~= "line" then
        love.graphics.setFont(fonts.small)
        love.graphics.setColor(0.8, 0.8, 0.8, 1)
        local hint = dialogue.stage == "reaction" and "Enter: continuar" or "Izq/Der: habla con otro demonio"
        love.graphics.printf(hint, BOX.x, BOX.y + BOX.h - 22, BOX.w - 16, "right")
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return DialogueUISystem
