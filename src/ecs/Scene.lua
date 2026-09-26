-- Una Scene es una pantalla del juego: el menú, el círculo del infierno...
-- Junta las dos mitades del ECS:
--
--   scene.world    -- los DATOS: entidades y componentes
--   scene.systems  -- la LÓGICA: corre en orden, cada frame
--
-- Un sistema es una tabla que puede implementar estos hooks:
--
--   setup(scene)       una vez, al entrar: crea lo que le pertenece
--   update(scene, dt)  cada frame: lógica, input, animación
--   draw(scene)        cada frame: dibuja
--   unload(scene)      al salir: suelta lo que creó
--
-- Setup → Update → Render. No hay hook de input: las teclas llegan como
-- entidades de evento `keyPressed` (ver src/Game.lua) y se leen en update().

local World = require("src.ecs.World")

local Scene = {}
Scene.__index = Scene

function Scene.new(name)
    return setmetatable({
        name = name,
        world = World.new(),
        systems = {}, -- lista ordenada: el orden importa
    }, Scene)
end

function Scene:addSystem(system)
    self.systems[#self.systems + 1] = system
end

function Scene:setup()
    for _, system in ipairs(self.systems) do
        if system.setup then system.setup(self) end
    end
end

function Scene:update(dt)
    for _, system in ipairs(self.systems) do
        if system.update then system.update(self, dt) end
    end
end

function Scene:draw()
    for _, system in ipairs(self.systems) do
        if system.draw then system.draw(self) end
    end
end

function Scene:unload()
    for _, system in ipairs(self.systems) do
        if system.unload then system.unload(self) end
    end
end

return Scene
