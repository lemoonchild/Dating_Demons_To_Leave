local Screen = require("src.Screen")
local demons = require("src.data.demons")
local DemonArt = require("src.graphics.DemonArt")

local PlaceArt = {}

local COLORS = {
    home = { 0.35, 0.35, 0.45 },
    door = { 0.05, 0.02, 0.03 },
}

local function colorOf(place)
    if place.kind == "demon" then
        local c = demons[place.demonId].color
        return { c[1] * 0.55, c[2] * 0.55, c[3] * 0.55 }
    end
    return COLORS[place.kind]
end

local function doorRect(building, area)
    local w = area.w - 12
    local x = area.x + 6
    if area.y >= building.y + building.h then
        return x, building.y + building.h - 18, w, 18
    end
    return x, building.y, w, 18
end

function PlaceArt.draw(place, building, area, font, focused)
    local color = colorOf(place)
    love.graphics.setColor(color[1], color[2], color[3], 1)
    love.graphics.rectangle("fill", building.x, building.y, building.w, building.h)

    if place.kind == "door" then
        love.graphics.setColor(0.8, 0.3, 0.15, 1)
    else
        love.graphics.setColor(1, 1, 1, 0.8)
    end
    love.graphics.rectangle("line", building.x, building.y, building.w, building.h)

    local dx, dy, dw, dh = doorRect(building, area)
    love.graphics.setColor(0.05, 0.02, 0.03, 1)
    love.graphics.rectangle("fill", dx, dy, dw, dh)
    love.graphics.setColor(0.8, 0.3, 0.15, 1)
    love.graphics.rectangle("line", dx, dy, dw, dh)

    if focused then
        love.graphics.setColor(1, 0.85, 0.3, 1)
        love.graphics.rectangle("line", area.x + 1, area.y + 1, area.w - 2, area.h - 2)
        love.graphics.rectangle("line", area.x + 3, area.y + 3, area.w - 6, area.h - 6)
        love.graphics.rectangle("line", dx - 2, dy - 2, dw + 4, dh + 4)
    end

    if place.kind == "demon" then
        local doorCenter = area.x + area.w / 2
        local side = doorCenter < building.x + building.w / 2 and building.x + building.w - 22 or building.x + 22
        DemonArt.draw(demons[place.demonId], side, building.y + building.h - 6, 18, 34)
    end

    love.graphics.setFont(font)
    local labelW = font:getWidth(place.name) + 12
    local lx = building.x + (building.w - labelW) / 2
    local ly = area.y < building.y and building.y + building.h + 2 or building.y - 20
    love.graphics.setColor(0.07, 0.03, 0.06, 0.85)
    love.graphics.rectangle("fill", lx, ly, labelW, 18)
    love.graphics.setColor(1, 0.95, 0.9, 1)
    love.graphics.printf(place.name, lx, ly + 2, labelW, "center")

    love.graphics.setColor(1, 1, 1, 1)
end

local INTERIORS = {
    archivo = { wall = { 0.16, 0.14, 0.3 }, floor = { 0.1, 0.09, 0.2 } },
    salon = { wall = { 0.35, 0.08, 0.15 }, floor = { 0.2, 0.05, 0.08 } },
    calderas = { wall = { 0.3, 0.12, 0.05 }, floor = { 0.18, 0.08, 0.04 } },
}

local FLOOR_Y = 316

local function shelves()
    for row = 0, 3 do
        local y = 150 + row * 40
        love.graphics.setColor(0.3, 0.2, 0.12, 1)
        love.graphics.rectangle("fill", 420, y + 30, 480, 6)
        for book = 0, 21 do
            local shade = 0.35 + ((book * 7 + row * 3) % 5) * 0.08
            love.graphics.setColor(shade * 0.7, shade * 0.6, shade, 1)
            love.graphics.rectangle("fill", 424 + book * 21, y + 4 + (book % 3) * 3, 16, 26 - (book % 3) * 3)
        end
    end
end

local function curtains()
    love.graphics.setColor(0.55, 0.08, 0.18, 1)
    love.graphics.rectangle("fill", 380, 130, 60, FLOOR_Y - 130)
    love.graphics.rectangle("fill", 860, 130, 60, FLOOR_Y - 130)
    love.graphics.setColor(0.6, 0.2, 0.3, 1)
    love.graphics.rectangle("fill", 520, 262, 280, 54)
    love.graphics.setColor(1, 0.8, 0.4, 1)
    love.graphics.rectangle("fill", 640, 140, 40, 10)
end

local function forge()
    love.graphics.setColor(0.15, 0.08, 0.06, 1)
    love.graphics.rectangle("fill", 640, 170, 220, FLOOR_Y - 170)
    love.graphics.setColor(1, 0.5, 0.1, 1)
    love.graphics.rectangle("fill", 690, 230, 120, 60)
    love.graphics.setColor(0.3, 0.3, 0.32, 1)
    love.graphics.rectangle("fill", 470, 280, 90, 20)
    love.graphics.rectangle("fill", 495, 300, 40, 16)
end

local PROPS = { archivo = shelves, salon = curtains, calderas = forge }

function PlaceArt.interior(placeId)
    local room = INTERIORS[placeId]
    love.graphics.setColor(room.wall[1], room.wall[2], room.wall[3], 1)
    love.graphics.rectangle("fill", 0, 0, Screen.w, Screen.h)
    love.graphics.setColor(room.floor[1], room.floor[2], room.floor[3], 1)
    love.graphics.rectangle("fill", 0, FLOOR_Y, Screen.w, Screen.h - FLOOR_Y)
    PROPS[placeId]()
    love.graphics.setColor(1, 1, 1, 1)
end

return PlaceArt
