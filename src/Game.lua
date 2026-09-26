-- Guarda las escenas y cambia entre ellas. 

local Game = {}

local factories = {} 
local current = nil

function Game.registerScene(name, factory)
    factories[name] = factory
end

local function performSwitch(name, payload)
    assert(factories[name], "escena desconocida: " .. tostring(name))
    if current then current:unload() end
    current = factories[name](payload)
    current:setup()
end

function Game.start(name, payload)
    performSwitch(name, payload)
end

function Game.update(dt)
    current:update(dt)

    for _, entity in ipairs(current.world:query("event")) do
        current.world:destroyEntity(entity)
    end

    local _, request = current.world:first("switchRequest")
    if request then
        performSwitch(request.to, request.payload)
    end
end

function Game.draw()
    current:draw()
end

function Game.keypressed(key)
    if key == "f12" then
        local file = os.date("screenshot-%Y%m%d-%H%M%S.png")
        love.graphics.captureScreenshot(file)
        print("screenshot: " .. love.filesystem.getSaveDirectory() .. "/" .. file)
        return
    end
    current.world:spawn({ event = true, keyPressed = { key = key } })
end

function Game.mousepressed(x, y, button)
    current.world:spawn({ event = true, mousePressed = { x = x, y = y, button = button } })
end

function Game.quit()
    if current then current:unload() end
end

function Game.current()
    return current
end

function Game.hasScene(name)
    return factories[name] ~= nil
end

return Game
