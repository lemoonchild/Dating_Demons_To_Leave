package.path = "./?.lua;" .. package.path

local Screen = require("src.Screen")
local TileGrid = require("src.world.TileGrid")
local Movement = require("src.world.Movement")
local Collision = require("src.world.Collision")
local map = require("src.data.map")
local demons = require("src.data.demons")

local function near(a, b) return math.abs(a - b) < 1e-6 end

local dx, dy = Movement.direction(1, 1)
assert(near(dx * dx + dy * dy, 1), "la diagonal camina más rápido que una recta")
dx, dy = Movement.direction(-1, 0)
assert(dx == -1 and dy == 0, "una recta cambió de velocidad")
dx, dy = Movement.direction(0, 0)
assert(dx == 0 and dy == 0, "sin teclas el personaje se mueve")

local tiles = {
    ["."] = { terrain = "floor", solid = false },
    ["#"] = { terrain = "wall", solid = true },
}
local box = { w = 6, h = 6 }
local room = TileGrid.fromRows({
    "#####",
    "#...#",
    "#.#.#",
    "#...#",
    "#####",
}, tiles)

assert(room:solid(0, 3) and room:solid(6, 3) and room:solid(3, 0) and room:solid(3, 6),
    "fuera del grid no cuenta como sólido")
assert(room:terrain(2, 2) == "floor" and room:terrain(1, 1) == "wall", "el grid leyó mal el terreno")

local function walk(grid, x, y, mx, my, times)
    for _ = 1, times do
        x, y = Collision.move(grid, 10, box, x, y, mx, my)
    end
    return x, y
end

local x, y = walk(room, 15, 15, 1, 0, 50)
assert(near(x, 37) and near(y, 15), ("atravesó o no llegó al muro derecho: %.2f, %.2f"):format(x, y))

x, y = walk(room, 15, 15, 0, 1, 50)
assert(near(x, 15) and near(y, 37), ("atravesó o no llegó al muro de abajo: %.2f, %.2f"):format(x, y))

x, y = walk(room, 15, 25, 1, 0, 20)
assert(near(x, 17), ("atravesó el pilar: %.2f"):format(x))

x, y = walk(room, 15, 15, 1, -1, 10)
assert(near(x, 25) and near(y, 13), ("no se deslizó por la pared: %.2f, %.2f"):format(x, y))

local open = TileGrid.fromRows({ "...", "..." }, tiles)
x, y = Collision.move(open, 10, box, 15, 10, -100, -100)
assert(near(x, 3) and near(y, 3), ("se salió por el borde de arriba a la izquierda: %.2f, %.2f"):format(x, y))
x, y = Collision.move(open, 10, box, 15, 10, 100, 100)
assert(near(x, 27) and near(y, 17), ("se salió por el borde de abajo a la derecha: %.2f, %.2f"):format(x, y))

local thin = TileGrid.fromRows({ "..#.." }, tiles)
x = Collision.move(thin, 10, box, 5, 5, 100, 0)
assert(near(x, 17), ("un salto grande de dt atravesó la pared: %.2f"):format(x))

local grid = TileGrid.fromRows(map.rows, map.tiles)
assert(grid.width * map.cell == Screen.w, "el mapa no ocupa el ancho de la pantalla")
assert(grid.height * map.cell >= Screen.h, "el mapa no llega al fondo de la pantalla")
assert(#map.places >= 3, "el mapa necesita al menos 3 lugares")
assert(not grid:solid(map.spawn.x, map.spawn.y), "el jugador aparece dentro de algo sólido")

local reached = {}
local queue = { { map.spawn.x, map.spawn.y } }
reached[map.spawn.y * 100 + map.spawn.x] = true
while #queue > 0 do
    local cell = table.remove(queue)
    local cx, cy = cell[1], cell[2]
    for _, d in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
        local nx, ny = cx + d[1], cy + d[2]
        if not grid:solid(nx, ny) and not reached[ny * 100 + nx] then
            reached[ny * 100 + nx] = true
            queue[#queue + 1] = { nx, ny }
        end
    end
end

local player = { w = 20, h = 20 }
local houses = {}
local homes = 0
for _, place in ipairs(map.places) do
    assert(map.places[place.id] == place, "dos lugares comparten id: " .. place.id)
    for ry = place.rect.y, place.rect.y + place.rect.h - 1 do
        for rx = place.rect.x, place.rect.x + place.rect.w - 1 do
            assert(grid:terrain(rx, ry) == "building", ("%s no coincide con su edificio en %d,%d"):format(place.id, rx, ry))
        end
    end

    local door = place.door
    assert(not grid:solid(door.x, door.y), place.id .. " tiene la puerta en algo sólido")
    local insideX = door.x >= place.rect.x and door.x < place.rect.x + place.rect.w
    local insideY = door.y >= place.rect.y and door.y < place.rect.y + place.rect.h
    local touchesX = insideX and (door.y == place.rect.y - 1 or door.y == place.rect.y + place.rect.h)
    local touchesY = insideY and (door.x == place.rect.x - 1 or door.x == place.rect.x + place.rect.w)
    assert(touchesX or touchesY, place.id .. " tiene la puerta lejos de su edificio")
    assert(reached[door.y * 100 + door.x], place.id .. " no se puede alcanzar desde la celda")
    assert(not Collision.blocked(grid, map.cell, player, (door.x - 0.5) * map.cell, (door.y - 0.5) * map.cell),
        "el jugador no cabe frente a " .. place.id)

    if place.kind == "home" then homes = homes + 1 end
    if place.kind == "demon" then
        assert(demons[place.demonId], place.id .. " es la casa de un demonio que no existe")
        houses[place.demonId] = true
    end
end

for _, demon in ipairs(demons) do
    assert(houses[demon.id], demon.name .. " no tiene casa en el mapa")
end
assert(homes == 1, "el mapa necesita exactamente una celda del jugador")

print("map tests passed")
