local demons = require("src.data.demons")
local Talk = require("src.rules.Talk")
local DialogueLayout = require("src.ui.DialogueLayout")

local DialogueInputSystem = { name = "dialogueInput" }

DialogueInputSystem.TYPE_SPEED = 45

function DialogueInputSystem.demonOf(dialogue)
    return demons[dialogue.demonId]
end

function DialogueInputSystem.typing(dialogue)
    return dialogue.visible < #dialogue.text
end

function DialogueInputSystem.conversationOf(dialogue)
    local demon = DialogueInputSystem.demonOf(dialogue)
    return dialogue.conversationId and demon.conversations[dialogue.conversationId]
end

function DialogueInputSystem.optionsOf(dialogue)
    local conversation = DialogueInputSystem.conversationOf(dialogue)
    return conversation and conversation.options
end

local function openLine(dialogue, runState)
    local demon = DialogueInputSystem.demonOf(dialogue)
    local conversation = Talk.pick(runState, demon, love.math.random)
    dialogue.conversationId = conversation and conversation.id
    if conversation then
        dialogue.stage = "line"
        dialogue.text = conversation.line
    else
        dialogue.stage = "done"
        dialogue.text = demon.name .. " ya te contó todo lo que sabe. Busca a otro demonio."
    end
    dialogue.visible = 0
    dialogue.cursor = 1
end

local function choose(scene, dialogue, runState, i)
    local demon = DialogueInputSystem.demonOf(dialogue)
    local conversation = DialogueInputSystem.conversationOf(dialogue)
    local option = conversation.options[i]

    scene.world:spawn({
        event = true,
        dialogueChoice = { demonId = demon.id, conversation = conversation.id, option = i },
    })

    Talk.use(runState, demon, conversation)
    dialogue.stage = "reaction"
    dialogue.text = option.reaction
    dialogue.visible = 0
end

local function advance(scene, dialogue, runState)
    if DialogueInputSystem.typing(dialogue) then
        dialogue.visible = #dialogue.text
    elseif dialogue.stage == "line" then
        choose(scene, dialogue, runState, dialogue.cursor)
    else
        dialogue.demonId = nil
        scene.world:spawn({ event = true, actionDone = true })
    end
end

function DialogueInputSystem.setup(scene)
    scene.world:spawn({
        dialogue = { stage = "line", text = "", visible = 0, cursor = 1 },
    })
end

function DialogueInputSystem.update(scene, dt)
    local world = scene.world
    local phase = world:resource("dayPhase")
    if phase.phase ~= "acting" then return end

    local runState = world:resource("runState")
    local _, dialogue = world:first("dialogue")

    if dialogue.demonId ~= phase.demonId then
        dialogue.demonId = phase.demonId
        openLine(dialogue, runState)
    end

    dialogue.visible = math.min(#dialogue.text,
        dialogue.visible + DialogueInputSystem.TYPE_SPEED * dt)

    local choosing = dialogue.stage == "line" and not DialogueInputSystem.typing(dialogue)
    local options = choosing and DialogueInputSystem.optionsOf(dialogue)
    local count = options and #options or 0

    local mx, my = love.mouse.getPosition()
    local hovered = choosing and DialogueLayout.hit(count, mx, my)
    if hovered and (mx ~= dialogue.lastMouseX or my ~= dialogue.lastMouseY) then
        dialogue.cursor = hovered
    end
    dialogue.lastMouseX, dialogue.lastMouseY = mx, my

    for _, entity in ipairs(world:query("mousePressed")) do
        local click = world:getComponent(entity, "mousePressed")
        if click.button == 1 then
            local i = choosing and DialogueLayout.hit(count, click.x, click.y)
            if i then
                choose(scene, dialogue, runState, i)
            elseif click.y >= DialogueLayout.BOX.y then
                advance(scene, dialogue, runState)
            end
        end
    end

    for _, entity in ipairs(world:query("keyPressed")) do
        local key = world:getComponent(entity, "keyPressed").key
        local picked = tonumber(key)
        if key == "return" or key == "space" then
            advance(scene, dialogue, runState)
        elseif (key == "up" or key == "w") and choosing then
            dialogue.cursor = (dialogue.cursor - 2) % count + 1
        elseif (key == "down" or key == "s") and choosing then
            dialogue.cursor = dialogue.cursor % count + 1
        elseif choosing and picked and picked >= 1 and picked <= count then
            choose(scene, dialogue, runState, picked)
        end
    end
end

return DialogueInputSystem
