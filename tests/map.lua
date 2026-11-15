package.path = "./?.lua;" .. package.path

local Screen = require("src.Screen")
local TileGrid = require("src.world.TileGrid")
local Movement = require("src.world.Movement")
local Collision = require("src.world.Collision")
local Iso = require("src.world.Iso")
local TiledMap = require("src.world.TiledMap")
local map = require("src.data.map")
local demons = require("src.data.demons")

local function near(a, b) return math.abs(a - b) < 1e-6 end

local dx, dy = Movement.direction(1, 1)
assert(near(dx * dx + dy * dy, 1), "la diagonal camina más rápido que una recta")
dx, dy = Movement.direction(-1, 0)
assert(dx == -1 and dy == 0, "una recta cambió de velocidad")
dx, dy = Movement.direction(0, 0)
assert(dx == 0 and dy == 0, "sin teclas el personaje se mueve")

local h = math.sqrt(0.5)
dx, dy = Movement.isoDirection(1, 0)
assert(near(dx, h) and near(dy, -h), "la flecha derecha no camina hacia la derecha de la pantalla")
dx, dy = Movement.isoDirection(0, -1)
assert(near(dx, -h) and near(dy, -h), "la flecha arriba no camina hacia arriba de la pantalla")
dx, dy = Movement.isoDirection(1, 1)
assert(near(dx, 1) and near(dy, 0), "derecha y abajo juntas no siguen el eje del mapa")
dx, dy = Movement.isoDirection(0, 0)
assert(dx == 0 and dy == 0, "sin teclas el personaje se mueve en el mapa isométrico")

assert(Movement.facing(1, 0, "enfrente") == "der", "caminar a la derecha no lo voltea a la derecha")
assert(Movement.facing(-1, 0, "enfrente") == "izq", "caminar a la izquierda no lo voltea a la izquierda")
assert(Movement.facing(0, 1, "atras") == "enfrente", "caminar hacia abajo no lo pone de frente")
assert(Movement.facing(0, -1, "enfrente") == "atras", "caminar hacia arriba no lo pone de espaldas")
assert(Movement.facing(1, -1, "atras") == "der", "en diagonal no mira hacia el lado")
assert(Movement.facing(0, 0, "izq") == "izq", "al quedarse quieto cambió de dirección")

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

local tiny = {
    width = 4, height = 4, tilewidth = 32, tileheight = 16,
    tilesets = { { firstgid = 1, tileheight = 32 } },
    layers = {
        { type = "tilelayer", data = { 1, 1, 5, 1, 1, 1, 1, 1, 1, 6, 1, 1, 1, 1, 1, 1 } },
        { type = "tilelayer", data = { 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 } },
        { type = "objectgroup" },
        { type = "tilelayer", data = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 13 } },
    },
}
local tinyGround = { [0] = "floor", [4] = "lava", [5] = "bridge" }
local tinyGrid = TiledMap.grid(tiny, tinyGround, map.tiles)
assert(tinyGrid:terrain(3, 1) == "lava" and tinyGrid:solid(3, 1), "la lava de Tiled no es sólida")
assert(tinyGrid:terrain(2, 3) == "bridge" and not tinyGrid:solid(2, 3), "el puente de Tiled no se puede pisar")
assert(tinyGrid:terrain(2, 2) == "building", "un edificio no bloquea la celda donde se ve parado")
assert(tinyGrid:terrain(1, 1) == "floor", "un edificio bloquea la celda donde se pintó en vez de donde se ve")
assert(tinyGrid:terrain(4, 4) == "floor", "un tile alto que cae fuera del mapa bloqueó otra celda")

local tinyFloor, tinyRaised = TiledMap.pieces(tiny)
assert(#tinyFloor == 16 and #tinyRaised == 2, "las piezas del mapa no separan el suelo de lo alto")
assert(tinyRaised[1].depth == Iso.depth(32, 1.5 * 32, 1.5 * 32),
    "un edificio no se ordena con la profundidad de la celda donde está parado")
for i = 2, #tinyFloor do
    assert(tinyFloor[i - 1].depth <= tinyFloor[i].depth, "el suelo no se dibuja de atrás hacia adelante")
end

local ok, err = pcall(TiledMap.grid, tiny, { [0] = "floor" }, map.tiles)
assert(not ok and err:find("no tiene terreno"), "un tile de suelo sin terreno no avisó")

local view = Iso.view(map.tiled, Screen.w, Screen.h)
local sx, sy = Iso.toScreen(view, map.cell, 0.5 * map.cell, 0.5 * map.cell)
local tx, ty = Iso.surfaceTop(view, 1, 1)
assert(near(sx, tx) and near(sy, ty + view.th / 2), "el centro de una celda no cae en el centro de su tile")
local span = map.tiled.width + map.tiled.height
assert(view.ox - map.tiled.height * view.tw / 2 >= 0 and view.ox + map.tiled.width * view.tw / 2 <= Screen.w,
    "el mapa no cabe a lo ancho de la pantalla")
assert(view.oy - view.lift >= 0 and view.oy + span * view.th / 2 <= Screen.h, "el mapa no cabe a lo alto de la pantalla")

local grid = TiledMap.grid(map.tiled, map.ground, map.tiles)
assert(#map.places >= 3, "el mapa necesita al menos 3 lugares")
assert(not grid:solid(map.spawn.x, map.spawn.y), "el jugador aparece dentro de algo sólido")

local function reachable(g)
    local reached = {}
    local queue = { { map.spawn.x, map.spawn.y } }
    reached[map.spawn.y * 100 + map.spawn.x] = true
    while #queue > 0 do
        local cell = table.remove(queue)
        for _, d in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
            local nx, ny = cell[1] + d[1], cell[2] + d[2]
            if not g:solid(nx, ny) and not reached[ny * 100 + nx] then
                reached[ny * 100 + nx] = true
                queue[#queue + 1] = { nx, ny }
            end
        end
    end
    return reached
end

local reached = reachable(grid)
local noBridges = {}
for i, key in ipairs(grid.cells) do noBridges[i] = key == "bridge" and "lava" or key end
local withoutBridges = reachable(TileGrid.new(grid.width, grid.height, noBridges, map.tiles))

local player = { w = 20, h = 20 }
local houses = {}
local homes = 0
local cutOff = 0
for _, place in ipairs(map.places) do
    assert(map.places[place.id] == place, "dos lugares comparten id: " .. place.id)

    local door = place.door
    assert(not grid:solid(door.x, door.y), place.id .. " tiene la puerta en algo sólido")
    local nextToBuilding = false
    for _, d in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
        if grid:terrain(door.x + d[1], door.y + d[2]) == "building" then nextToBuilding = true end
    end
    assert(nextToBuilding, place.id .. " tiene la puerta lejos de su edificio")
    assert(reached[door.y * 100 + door.x], place.id .. " no se puede alcanzar desde la celda")
    if not withoutBridges[door.y * 100 + door.x] then cutOff = cutOff + 1 end
    assert(not Collision.blocked(grid, map.cell, player, (door.x - 0.5) * map.cell, (door.y - 0.5) * map.cell),
        "el jugador no cabe frente a " .. place.id)

    if place.kind == "home" then homes = homes + 1 end
    if place.kind == "demon" then
        assert(demons[place.demonId], place.id .. " es la casa de un demonio que no existe")
        houses[place.demonId] = true
    end
end
assert(cutOff > 0, "sin puentes igual se llega a todas las puertas: la lava no separa nada")

for _, demon in ipairs(demons) do
    assert(houses[demon.id], demon.name .. " no tiene casa en el mapa")
end
assert(homes == 1, "el mapa necesita exactamente una celda del jugador")

print("map tests passed")
