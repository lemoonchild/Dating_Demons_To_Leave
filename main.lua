-- Dating Demons To Leave
--
-- Este archivo solo arranca el juego: registra las escenas, abre una y le
-- pasa los callbacks de LÖVE al Game. Toda la lógica vive en los sistemas
-- de cada escena (src/systems) sobre el World de src/ecs.
--
--   love .          abre el menú
--   love . <scene>  abre directo una escena registrada

local Game = require("src.Game")

function love.load(args)
    Game.registerScene("menu", require("src.scenes.MenuScene"))
    Game.registerScene("hub", require("src.scenes.HubScene"))

    local start = "menu"
    if args[1] and Game.hasScene(args[1]) then
        start = args[1]
    end
    Game.start(start)
end

function love.update(dt)
    Game.update(dt)
end

function love.draw()
    Game.draw()
end

function love.keypressed(key)
    Game.keypressed(key)
end

function love.mousepressed(x, y, button)
    Game.mousepressed(x, y, button)
end

function love.quit()
    Game.quit()
end
