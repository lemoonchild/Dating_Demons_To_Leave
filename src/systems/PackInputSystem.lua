local Run = require("src.state.Run")

local PackInputSystem = { name = "packInput" }

PackInputSystem.REVEAL_EVERY = 0.45

function PackInputSystem.setup(scene)
    local runState = scene.world:resource("runState")
    local pack = runState.pendingPack or {}

    for _, card in ipairs(pack) do
        runState.cards[#runState.cards + 1] = card
    end
    runState.pendingPack = {}

    scene.world:spawn({ reveal = { pack = pack, shown = 0, timer = 0 } })
end

local function leave(scene, to)
    scene.world:spawn({ switchRequest = { to = to, payload = { back = "pack" } } })
end

function PackInputSystem.update(scene, dt)
    local world = scene.world
    local runState = world:resource("runState")
    local _, reveal = world:first("reveal")
    local done = runState.day > Run.DAYS and "menu" or "room"

    if reveal.shown < #reveal.pack then
        reveal.timer = reveal.timer + dt
        if reveal.timer >= PackInputSystem.REVEAL_EVERY then
            reveal.timer = 0
            reveal.shown = reveal.shown + 1
        end
    end

    for _, entity in ipairs(world:query("keyPressed")) do
        local key = world:getComponent(entity, "keyPressed").key
        if reveal.shown < #reveal.pack then
            reveal.shown = #reveal.pack
        elseif key == "c" then
            leave(scene, "collection")
        elseif key == "return" or key == "space" or key == "escape" then
            leave(scene, done)
        end
    end

    for _, entity in ipairs(world:query("mousePressed")) do
        if world:getComponent(entity, "mousePressed").button == 1 then
            if reveal.shown < #reveal.pack then
                reveal.shown = #reveal.pack
            else
                leave(scene, done)
            end
        end
    end
end

return PackInputSystem
