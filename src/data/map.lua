local map = {
    cell = 32,
    tiled = require("assets.map.mapa_juego"),
    folder = "assets/map/",
    ground = {
        [0] = "floor",
        [1] = "floor",
        [4] = "lava",
        [5] = "bridge",
        [6] = "bridge",
    },
    tiles = {
        floor = { terrain = "floor", solid = false },
        bridge = { terrain = "bridge", solid = false },
        lava = { terrain = "lava", solid = true },
        building = { terrain = "building", solid = true },
        void = { terrain = "void", solid = true },
    },
    spawn = { x = 31, y = 12 },
    places = {
        {
            id = "celda", name = "Tu celda", kind = "home",
            door = { x = 31, y = 12 },
            background = "assets/background/fondo_celda.png",
        },
        {
            id = "archivo", name = "Archivo del Limbo", kind = "demon", demonId = "azazel",
            door = { x = 7, y = 11 },
            background = "assets/background/fondo_archivo.png",
        },
        {
            id = "salon", name = "Salón Carmesí", kind = "demon", demonId = "lilim",
            door = { x = 7, y = 4 },
            background = "assets/background/fondo_salon.png",
        },
        {
            id = "calderas", name = "Calderas", kind = "demon", demonId = "brasa",
            door = { x = 20, y = 5 },
            background = "assets/background/fondo_cerrajeria.png",
        },
    },
}

for _, place in ipairs(map.places) do
    map.places[place.id] = place
end

return map
