local map = {
    cell = 32,
    rows = {
        "##############################",
        "#............HHHH............#",
        "#.HHHH.......HHHH......HHHH..#",
        "#.HHHH.......HHHH......HHHH..#",
        "#.HHHH.................HHHH..#",
        "#........o.........o.........#",
        "#............................#",
        "#~~~~~~==~~~~~~~~~~==~~~~~~~~#",
        "#~~~~~~==~~~~~~~~~~==~~~~~~~~#",
        "#............................#",
        "#..........o.....o...........#",
        "#.....................HHHHH..#",
        "#..HHHH...............HHHHH..#",
        "#..HHHH...............HHHHH..#",
        "#..HHHH.......o..............#",
        "#..........................o.#",
        "##############################",
    },
    tiles = {
        ["."] = { terrain = "floor", solid = false },
        ["="] = { terrain = "bridge", solid = false },
        ["#"] = { terrain = "wall", solid = true },
        ["~"] = { terrain = "lava", solid = true },
        ["o"] = { terrain = "rock", solid = true },
        ["H"] = { terrain = "building", solid = true },
    },
    spawn = { x = 5, y = 12 },
    places = {
        {
            id = "celda", name = "Tu celda", kind = "home",
            rect = { x = 4, y = 13, w = 4, h = 3 }, door = { x = 5, y = 12 },
            background = "assets/background/fondo_celda.png",
        },
        {
            id = "archivo", name = "Archivo del Limbo", kind = "demon", demonId = "azazel",
            rect = { x = 3, y = 3, w = 4, h = 3 }, door = { x = 4, y = 6 },
            background = "assets/background/fondo_archivo.png",
        },
        {
            id = "salon", name = "Salón Carmesí", kind = "demon", demonId = "lilim",
            rect = { x = 24, y = 3, w = 4, h = 3 }, door = { x = 25, y = 6 },
            background = "assets/background/fondo_salon.png",
        },
        {
            id = "calderas", name = "Calderas", kind = "demon", demonId = "brasa",
            rect = { x = 23, y = 12, w = 5, h = 3 }, door = { x = 25, y = 11 },
            background = "assets/background/fondo_cerrajeria.png",
        },
        {
            id = "puerta", name = "Puerta del Guardián", kind = "door",
            rect = { x = 14, y = 2, w = 4, h = 3 }, door = { x = 15, y = 5 },
        },
    },
}

for _, place in ipairs(map.places) do
    map.places[place.id] = place
end

return map
