-- El Game: guarda las escenas y cambia entre ellas. Solo hay uno, así que es
-- un módulo simple (require lo cachea), no una clase.
--
-- Nadie llama a una función de "cambiar escena". Cualquier sistema pide el
-- cambio creando una entidad:
--
--   world:spawn({ switchRequest = { to = "hub", payload = {...} } })
--
-- y el Game lo hace DESPUÉS del update del frame, cuando ya ningún sistema
-- está recorriendo el World que se va a destruir.

local Game = {}

local factories = {} -- nombre -> function(payload) -> Scene
local current = nil

-- Se registra una FÁBRICA, no una instancia: cada visita arma la escena
-- desde cero, así no sobrevive estado viejo.
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

    -- Los eventos (entidades con `event = true`) viven exactamente un
    -- update: los sistemas los leen y aquí se borran al terminar el frame.
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
    -- F12 es del engine, no de una escena: guarda un screenshot en la
    -- carpeta de guardado de LÖVE (evidencia para el portafolio).
    if key == "f12" then
        local file = os.date("screenshot-%Y%m%d-%H%M%S.png")
        love.graphics.captureScreenshot(file)
        print("screenshot: " .. love.filesystem.getSaveDirectory() .. "/" .. file)
        return
    end
    -- Todo lo demás entra al mundo como DATO. LÖVE entrega las teclas antes
    -- de love.update, así que los sistemas lo ven en este mismo frame.
    current.world:spawn({ event = true, keyPressed = { key = key } })
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
