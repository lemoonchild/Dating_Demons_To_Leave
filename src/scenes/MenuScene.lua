-- Menú principal. Por ahora es un placeholder: solo prueba que el engine
-- de escenas funciona. El sistema de UI del menú llega en la siguiente fase.

local Scene = require("src.ecs.Scene")

local PlaceholderSystem = { name = "placeholder" }

function PlaceholderSystem.update(scene, dt)
    for _, entity in ipairs(scene.world:query("keyPressed")) do
        if scene.world:getComponent(entity, "keyPressed").key == "escape" then
            love.event.quit()
        end
    end
end

function PlaceholderSystem.draw(scene)
    love.graphics.print("Dating Demons To Leave — escena: " .. scene.name, 10, 10)
end

return function(payload)
    local scene = Scene.new("menu")
    scene:addSystem(PlaceholderSystem)
    return scene
end
