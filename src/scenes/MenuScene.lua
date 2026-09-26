-- El menú principal: la primera pantalla del juego.

local Scene = require("src.ecs.Scene")
local MainMenuUISystem = require("src.systems.MainMenuUISystem")

return function(payload)
    local scene = Scene.new("menu")
    scene:addSystem(MainMenuUISystem)
    return scene
end
