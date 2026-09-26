-- Motor ECS
--
-- Entidad: Es solo un número
-- Componente: Guardados en tablas separadas por tipo
-- Sistema: Una tabla con hooks setup/update/draw/unload que recorre los
--          componentes que le interesan (ver src/ecs/Scene.lua).
--
-- El World NO tiene lógica: solo guarda datos. La lógica vive en los sistemas.

local World = {}
World.__index = World

function World.new()
    return setmetatable({
        nextId = 1,
        entities = {},  
        components = {}, 
    }, World)
end

function World:createEntity()
    local id = self.nextId
    self.nextId = id + 1
    self.entities[id] = true
    return id
end

function World:destroyEntity(id)
    self.entities[id] = nil
    for _, store in pairs(self.components) do
        store[id] = nil
    end
end

function World:addComponent(entity, name, data)
    self.components[name] = self.components[name] or {}
    self.components[name][entity] = data or {}
    return data
end

function World:getComponent(entity, name)
    local store = self.components[name]
    return store and store[entity]
end

function World:removeComponent(entity, name)
    local store = self.components[name]
    if store then
        store[entity] = nil
    end
end

function World:has(entity, name)
    return self:getComponent(entity, name) ~= nil
end

-- Itera sobre todas las entidades que tienen el componente `name`.
function World:each(name)
    return pairs(self.components[name] or {})
end

-- Crea una entidad con varios componentes de una vez:
--   world:spawn({ position = { x = 0, y = 0 }, menu = { cursor = 1 } })
function World:spawn(components)
    local entity = self:createEntity()
    for name, data in pairs(components) do
        self:addComponent(entity, name, data)
    end
    return entity
end

-- Todas las entidades que tienen TODOS los componentes pedidos, ordenadas
-- por id: pairs() no garantiza orden y así cada frame corre igual.
--   for _, e in ipairs(world:query("position", "menu")) do ... end
function World:query(...)
    local names = { ... }
    local result = {}
    for entity in pairs(self.components[names[1]] or {}) do
        local ok = true
        for i = 2, #names do
            if not self:has(entity, names[i]) then
                ok = false
                break
            end
        end
        if ok then
            result[#result + 1] = entity
        end
    end
    table.sort(result)
    return result
end

-- Para componentes que existen en UNA sola entidad (el menú, el diálogo...).
-- Devuelve entity, data.
function World:first(name)
    for entity, data in pairs(self.components[name] or {}) do
        return entity, data
    end
end

-- RESOURCES: valores únicos que no son "cosas en el mundo", como el estado
-- de la partida. Se guardan en una entidad escondida, así que siguen siendo
-- datos normales del World.
function World:setResource(name, value)
    local entity = self:first(name)
    if entity then
        self.components[name][entity] = value
    else
        self:spawn({ [name] = value })
    end
end

function World:resource(name)
    local _, value = self:first(name)
    return value
end

return World
