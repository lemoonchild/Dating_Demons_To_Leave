-- El menú principal: la primera pantalla del juego.

local Scene = require("src.ecs.Scene")
local MainMenuInputSystem = require("src.systems.MainMenuInputSystem")
local MainMenuRenderSystem = require("src.systems.MainMenuRenderSystem")

return function(payload)
    local scene = Scene.new("menu")
    scene:addSystem(MainMenuInputSystem)
    scene:addSystem(MainMenuRenderSystem)
    return scene
end
