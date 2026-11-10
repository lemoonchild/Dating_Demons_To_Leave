local Mood = require("src.rules.Mood")
local DialogueLayout = require("src.ui.DialogueLayout")
local DialogueInputSystem = require("src.systems.DialogueInputSystem")

local DialogueRenderSystem = { name = "dialogueRender" }

local fonts = {}

local BOX = DialogueLayout.BOX
local TAG = DialogueLayout.TAG
local MOODTAG = DialogueLayout.MOODTAG
local TEXT_X = DialogueLayout.TEXT_X
local TEXT_W = DialogueLayout.TEXT_W
local OPTIONS_Y = DialogueLayout.OPTIONS_Y

function DialogueRenderSystem.setup(scene)
    fonts.name = love.graphics.newFont(16)
    fonts.text = love.graphics.newFont(17)
    fonts.option = love.graphics.newFont(16)
    fonts.small = love.graphics.newFont(12)
end

function DialogueRenderSystem.unload(scene)
    fonts = {}
end

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

local function reactionWords(picked, name)
    if picked.crit then return "¡" .. name .. " quedó fascinado!" end
    local a = picked.affinity
    if a >= 5 then return "A " .. name .. " le encantó" end
    if a >= 3 then return "A " .. name .. " le gustó mucho" end
    if a >= 1 then return "A " .. name .. " le gustó" end
    if a == 0 then return "A " .. name .. " le dio igual" end
    if a >= -2 then return "A " .. name .. " le molestó" end
    return "Ofendiste a " .. name
end

local function describePick(picked)
    local parts = {}
    if picked.affinity ~= 0 then
        parts[#parts + 1] = ("%+d afinidad"):format(picked.affinity)
    end
    if #parts == 0 then return "nada cambió" end
    return table.concat(parts, "   ")
end

function DialogueRenderSystem.draw(scene)
    local world = scene.world
    if world:resource("dayPhase").phase ~= "acting" then return end

    local runState = world:resource("runState")
    local _, dialogue = world:first("dialogue")
    local demon = DialogueInputSystem.demonOf(dialogue)
    if not demon then return end

    love.graphics.setColor(0.07, 0.03, 0.06, 1)
    love.graphics.rectangle("fill", TAG.x, TAG.y, TAG.w, TAG.h)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", TAG.x, TAG.y, TAG.w, TAG.h)
    love.graphics.setFont(fonts.name)
    love.graphics.print(demon.name .. " - " .. demon.title, TAG.x + 10, TAG.y + 6)

    local mood = Mood.of(runState.moods[demon.id])
    love.graphics.setColor(0.07, 0.03, 0.06, 1)
    love.graphics.rectangle("fill", MOODTAG.x, MOODTAG.y, MOODTAG.w, MOODTAG.h)
    love.graphics.setColor(mood.color[1], mood.color[2], mood.color[3], 1)
    love.graphics.rectangle("line", MOODTAG.x, MOODTAG.y, MOODTAG.w, MOODTAG.h)

    love.graphics.setFont(fonts.small)
    love.graphics.setColor(0.6, 0.6, 0.6, 1)
    love.graphics.print("SU HUMOR HOY", MOODTAG.x + 10, MOODTAG.y + 4)
    love.graphics.setFont(fonts.name)
    love.graphics.setColor(mood.color[1], mood.color[2], mood.color[3], 1)
    love.graphics.print(mood.name, MOODTAG.x + 10, MOODTAG.y + 17)
    love.graphics.setFont(fonts.small)
    love.graphics.setColor(0.75, 0.72, 0.72, 1)
    love.graphics.printf(mood.hint, MOODTAG.x, MOODTAG.y + 19, MOODTAG.w - 12, "right")

    love.graphics.setColor(0.07, 0.03, 0.06, 1)
    love.graphics.rectangle("fill", BOX.x, BOX.y, BOX.w, BOX.h)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", BOX.x, BOX.y, BOX.w, BOX.h)

    love.graphics.setFont(fonts.text)
    love.graphics.setColor(1, 0.95, 0.9, 1)
    love.graphics.printf(visibleText(dialogue), TEXT_X, BOX.y + 16, TEXT_W, "left")

    if DialogueInputSystem.typing(dialogue) then
        love.graphics.setColor(1, 1, 1, 1)
        return
    end

    if dialogue.stage == "line" then
        local options = DialogueInputSystem.optionsOf(dialogue)
        love.graphics.setFont(fonts.option)
        for i, option in ipairs(options) do
            local x, y, w, h = DialogueLayout.optionRect(i)
            if i == dialogue.cursor then
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.rectangle("line", x - 6, y, w + 6, h - 2)
            else
                love.graphics.setColor(0.7, 0.7, 0.7, 1)
            end
            love.graphics.print(("%d. %s"):format(i, option.text), x, y + 4)
        end
    elseif dialogue.stage == "reaction" then
        local picked = world:resource("lastReaction")
        if not picked then
            love.graphics.setColor(1, 1, 1, 1)
            return
        end
        if picked.crit then
            love.graphics.setColor(1, 0.85, 0.3, 1)
        elseif picked.affinity > 0 then
            love.graphics.setColor(0.5, 1, 0.5, 1)
        elseif picked.affinity < 0 then
            love.graphics.setColor(1, 0.45, 0.4, 1)
        else
            love.graphics.setColor(0.85, 0.8, 0.8, 1)
        end
        love.graphics.setFont(fonts.option)
        love.graphics.print(reactionWords(picked, demon.name), TEXT_X, OPTIONS_Y + 2)

        love.graphics.setFont(fonts.small)
        love.graphics.setColor(0.55, 0.55, 0.55, 1)
        love.graphics.print(describePick(picked), TEXT_X, OPTIONS_Y + 28)
    end

    if dialogue.stage ~= "line" then
        love.graphics.setFont(fonts.small)
        love.graphics.setColor(0.8, 0.8, 0.8, 1)
        love.graphics.printf("Enter: continuar", BOX.x, BOX.y + BOX.h - 22, BOX.w - 16, "right")
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return DialogueRenderSystem
