local Run = require("src.state.Run")
local MainMenuLayout = require("src.ui.MainMenuLayout")

local MainMenuInputSystem = { name = "mainMenuInput" }

local function confirm(scene, menu)
    local option = menu.options[menu.cursor].id
    if option == "play" then
        Run.start()
        scene.world:spawn({ switchRequest = { to = "week" } })
    elseif option == "credits" then
        menu.showCredits = true
    elseif option == "quit" then
        love.event.quit()
    end
end

function MainMenuInputSystem.setup(scene)
    scene.world:spawn({
        menu = {
            options = {
                { id = "play", label = "Jugar" },
                { id = "credits", label = "Créditos" },
                { id = "quit", label = "Salir" },
            },
            cursor = 1,
            showCredits = false,
        },
    })
end

function MainMenuInputSystem.update(scene, dt)
    local world = scene.world
    local _, menu = world:first("menu")
    local count = #menu.options

    if menu.showCredits then
        if #world:query("keyPressed") > 0 or #world:query("mousePressed") > 0 then
            menu.showCredits = false
        end
        return
    end

    local mx, my = love.mouse.getPosition()
    local hovered = MainMenuLayout.hit(count, mx, my)
    if hovered and (mx ~= menu.lastMouseX or my ~= menu.lastMouseY) then
        menu.cursor = hovered
    end
    menu.lastMouseX, menu.lastMouseY = mx, my

    for _, entity in ipairs(world:query("mousePressed")) do
        local click = world:getComponent(entity, "mousePressed")
        local i = MainMenuLayout.hit(count, click.x, click.y)
        if click.button == 1 and i then
            menu.cursor = i
            confirm(scene, menu)
        end
    end

    for _, entity in ipairs(world:query("keyPressed")) do
        local key = world:getComponent(entity, "keyPressed").key
        if key == "up" or key == "w" then
            menu.cursor = (menu.cursor - 2) % count + 1
        elseif key == "down" or key == "s" then
            menu.cursor = menu.cursor % count + 1
        elseif key == "return" or key == "space" then
            confirm(scene, menu)
        elseif key == "escape" then
            love.event.quit()
        end
    end
end

return MainMenuInputSystem
