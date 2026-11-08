local Screen = require("src.Screen")

local MainMenuLayout = {}

MainMenuLayout.OPTION_W = 260
MainMenuLayout.OPTION_H = 44
MainMenuLayout.SPACING = 56
MainMenuLayout.X = (Screen.w - 260) / 2
MainMenuLayout.Y = 270

function MainMenuLayout.rect(i)
    return MainMenuLayout.X, MainMenuLayout.Y + (i - 1) * MainMenuLayout.SPACING,
        MainMenuLayout.OPTION_W, MainMenuLayout.OPTION_H
end

function MainMenuLayout.hit(count, mx, my)
    for i = 1, count do
        local x, y, w, h = MainMenuLayout.rect(i)
        if mx >= x and mx <= x + w and my >= y and my <= y + h then return i end
    end
end

return MainMenuLayout
