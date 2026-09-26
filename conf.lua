local Screen = require("src.Screen")

function love.conf(t)
    -- nombre de la carpeta de guardado (screenshots, saves)
    t.identity = "dating-demons-to-leave"
    t.window.title = "Dating Demons To Leave"
    t.window.width = Screen.w
    t.window.height = Screen.h
    t.version = "11.5"
end
