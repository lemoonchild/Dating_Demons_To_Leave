-- Dating Demons To Leave
--
-- Lo único que queda de Breakout es el motor ECS (src/ecs/World.lua).
-- El paddle, la pelota, los bloques, las colisiones y las constantes del
-- juego anterior se eliminaron: este main solo abre una ventana vacía
-- mientras se construye el juego nuevo encima del mismo World.

local World = require("src.ecs.World")

local world

function love.load()
    love.window.setTitle("Dating Demons To Leave")
    world = World.new()
end

function love.update(dt)
end

function love.draw()
    love.graphics.print("Dating Demons To Leave", 10, 10)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end
