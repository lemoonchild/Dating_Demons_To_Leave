local World = require("src.ecs.World")

local Scene = {}
Scene.__index = Scene

function Scene.new(name)
    return setmetatable({
        name = name,
        world = World.new(),
        systems = {}, -- lista ordenada
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
