local Screen = require("src.Screen")

local DialogueLayout = {}

DialogueLayout.BOX = { x = 20, y = 356, w = Screen.w - 40, h = 164 }
DialogueLayout.TAG = { x = 20, y = 324, w = 330, h = 30 }
DialogueLayout.MOODTAG = { x = 360, y = 318, w = 580, h = 36 }
DialogueLayout.TEXT_X = 40
DialogueLayout.TEXT_W = DialogueLayout.BOX.x + DialogueLayout.BOX.w - DialogueLayout.TEXT_X - 16
DialogueLayout.OPTIONS_Y = 432
DialogueLayout.OPTION_H = 26

function DialogueLayout.optionRect(i)
    return DialogueLayout.TEXT_X,
        DialogueLayout.OPTIONS_Y + (i - 1) * DialogueLayout.OPTION_H,
        DialogueLayout.TEXT_W, DialogueLayout.OPTION_H
end

function DialogueLayout.hit(count, mx, my)
    for i = 1, count do
        local x, y, w, h = DialogueLayout.optionRect(i)
        if mx >= x and mx <= x + w and my >= y and my < y + h then return i end
    end
end

return DialogueLayout
