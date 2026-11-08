local CollectionLayout = {}

CollectionLayout.COLS = 6
CollectionLayout.CARD_W = 92
CollectionLayout.CARD_H = 126
CollectionLayout.GAP = 14
CollectionLayout.X = 24
CollectionLayout.Y = 92
CollectionLayout.PANEL = { x = 646, y = 92, w = 290, h = 376 }

function CollectionLayout.slot(i)
    local col = (i - 1) % CollectionLayout.COLS
    local row = math.floor((i - 1) / CollectionLayout.COLS)
    return CollectionLayout.X + col * (CollectionLayout.CARD_W + CollectionLayout.GAP),
        CollectionLayout.Y + row * (CollectionLayout.CARD_H + CollectionLayout.GAP + 18)
end

function CollectionLayout.hit(count, mx, my)
    for i = 1, count do
        local x, y = CollectionLayout.slot(i)
        if mx >= x and mx <= x + CollectionLayout.CARD_W
            and my >= y and my <= y + CollectionLayout.CARD_H then
            return i
        end
    end
end

return CollectionLayout
