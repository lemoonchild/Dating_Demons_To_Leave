package.path = "./?.lua;" .. package.path

local stub = require("tools.love_stub")
stub.install()

local Game = require("src.Game")
local Run = require("src.state.Run")
local TrainingSystem = require("src.systems.TrainingSystem")
local stats = require("src.data.stats")
local map = require("src.data.map")

Game.registerScene("menu", require("src.scenes.MenuScene"))
Game.registerScene("room", require("src.scenes.RoomScene"))
Game.registerScene("pack", require("src.scenes.PackScene"))
Game.registerScene("collection", require("src.scenes.CollectionScene"))
Game.registerScene("map", require("src.scenes.MapScene"))
Game.registerScene("visit", require("src.scenes.VisitScene"))

local function tick(n) for _ = 1, (n or 1) do Game.update(1 / 60); Game.draw() end end
local function press(k, n) Game.keypressed(k); tick(n or 1) end
local function scene() return Game.current().name end
local function roomMenu() local _, menu = Game.current().world:first("roomMenu") return menu end
local function actionsLeft() return Game.current().world:resource("dayPhase").left end
local function player()
    local world = Game.current().world
    return world:getComponent(world:query("player", "position")[1], "position")
end
local function focus() return Game.current().world:resource("mapFocus").placeId end
local function standAt(id)
    local door = map.places[id].door
    local pos = player()
    pos.x, pos.y = (door.x - 0.5) * map.cell, (door.y - 0.5) * map.cell
    stub.clear()
    tick(1)
end
local function talk()
    local guard = 0
    while scene() == "visit" and guard < 12 do
        press("return", 3)
        guard = guard + 1
    end
    assert(guard < 12, "la conversación no terminó")
end

local function leavePack()
    local guard = 0
    while scene() == "pack" and guard < 12 do
        press("return", 2)
        guard = guard + 1
    end
    assert(guard < 12, "no se pudo salir del paquete")
end

math.randomseed(12)
Game.start("menu")
press("return", 2)
assert(scene() == "room", "Jugar no llevó a la celda")

local run = Run.current()
assert(actionsLeft() == Run.ACTIONS, "el día no arrancó con " .. Run.ACTIONS .. " acciones")
assert(roomMenu().screen == "main", "la celda no abrió en el menú principal")
local roomLoaded = {}
for _, path in ipairs(stub.images) do roomLoaded[path] = true end
assert(roomLoaded[map.places.celda.background], "la celda no cargó su fondo")
assert(roomLoaded["assets/characters/jugador.png"], "la celda no dibujó al jugador")

press("return", 1)
assert(roomMenu().screen == "training", "Entrenar no abrió el panel de entrenamiento")
stub.clear()
tick(1)
for _, stat in ipairs(stats) do
    assert(stub.find(stat.description), "el panel de entrenamiento no explica " .. stat.name)
end
press("escape", 1)
assert(scene() == "room" and roomMenu().screen == "main", "Esc no volvió del panel de entrenamiento")
press("1", 1)
press(tostring(#stats + 1), 1)
assert(roomMenu().screen == "main", "Volver no cerró el panel de entrenamiento")
assert(actionsLeft() == Run.ACTIONS and #run.log == 0, "mirar el panel de entrenamiento gastó una acción")

local moodsBefore = {}
for id, mood in pairs(run.moods) do moodsBefore[id] = mood end
press("2", 2)
assert(scene() == "map", "Visitar demonios no salió al mapa")
press("return", 2)
assert(scene() == "room", "Enter en la puerta de tu celda no volvió a la celda")
press("2", 2)
press("escape", 2)
assert(scene() == "room", "Esc en el mapa no volvió a la celda")
assert(actionsLeft() == Run.ACTIONS, "salir al mapa y volver gastó acciones")
for id, mood in pairs(moodsBefore) do
    assert(run.moods[id] == mood, "salir al mapa y volver cambió el humor de " .. id)
end

press("c", 2)
assert(scene() == "collection", "C no abrió la colección desde la celda")
press("escape", 2)
assert(scene() == "room", "salir de la colección no volvió a la celda")

press("2", 2)
standAt("archivo")
assert(stub.find("Presiona Enter para entrar"), "el Archivo del Limbo no invita a entrar")
for _, path in ipairs(stub.images) do
    assert(path == "assets/characters/jugador.png" or not path:find("assets/characters/", 1, true),
        "el mapa dibuja a los demonios: " .. path)
end
press("return", 2)
assert(scene() == "visit", "Enter en el Archivo del Limbo no entró a la casa")
local loaded = {}
for _, path in ipairs(stub.images) do loaded[path] = true end
assert(loaded["assets/characters/azazel.png"], "entrar al Archivo no cargó el sprite de Azazel")
assert(loaded[map.places.archivo.background], "entrar al Archivo no cargó su fondo")
assert(Game.current().world:resource("dayPhase").demonId == "azazel", "adentro del Archivo no está Azazel")
stub.clear()
tick(60)
assert(stub.find("Azazel"), "la visita no muestra a Azazel")
local statsBeforeTalking = run.stats.astucia
talk()
assert(scene() == "map", "terminar la conversación no volvió al mapa, estoy en " .. scene())
assert(focus() == "archivo", "volver de la visita no dejó al jugador frente al Archivo")
assert(run.actionsLeft == Run.ACTIONS - 1, "visitar a Azazel no gastó una acción")
assert(run.stats.astucia == statsBeforeTalking, "hablar subió una stat: eso solo lo hace entrenar")
local used = 0
for _ in pairs(run.talks.azazel) do used = used + 1 end
assert(used == 1, "hablar no marcó la conversación como usada")
standAt("archivo")
assert(stub.find("ya no tiene ganas de hablar hoy"), "el Archivo no avisa que Azazel ya habló hoy")
press("return", 2)
assert(scene() == "map", "se pudo visitar a Azazel dos veces el mismo día")

standAt("salon")
press("return", 2)
assert(scene() == "visit", "Enter en el Salón Carmesí no entró a la casa")
talk()
assert(scene() == "pack", "gastar las dos acciones visitando no abrió el paquete, estoy en " .. scene())
assert(run.day == 2, "el día no avanzó después de dos visitas")
local visits = 0
for _, e in ipairs(run.log) do if e.day == 1 and e.kind == "visit" then visits = visits + 1 end end
assert(visits == Run.ACTIONS, "el día 1 no registró las dos visitas")
for _, card in ipairs(run.cards) do
    assert(card.name and card.stat and card.power and card.rarity and card.effect,
        "una carta de la colección está incompleta")
end
leavePack()
assert(scene() == "room", "salir del paquete no volvió a la celda")
local cardsBeforeTraining = #run.cards

local furiaBefore = run.stats.furia
local trainingDays = 0
while run.day <= Run.DAYS do
    local d = run.day
    local halfDay = d == Run.DAYS
    if halfDay then
        assert(#run.cards == cardsBeforeTraining, "entrenar dio cartas")
        press("2", 2)
        standAt("calderas")
        press("return", 2)
        assert(scene() == "visit", "Enter en las Calderas no entró a la casa")
        talk()
        standAt("celda")
        press("return", 2)
        assert(scene() == "room", "volver a la celda después de visitar no funcionó")
        assert(actionsLeft() == Run.ACTIONS - 1, "visitar antes de entrenar no gastó una acción")
    end
    press("1", 1)
    stub.clear()
    tick(1)
    local expected = TrainingSystem.gainFor(actionsLeft())
    assert(stub.find("+" .. expected .. " furia"), "el panel no muestra que entrenar da +" .. expected)
    press("3", 2)
    assert(scene() == "pack", "entrenar no cerró el día " .. d .. ", estoy en " .. scene())
    local dayLog = 0
    for _, e in ipairs(run.log) do if e.day == d then dayLog = dayLog + 1 end end
    local wanted = halfDay and 2 or 1
    assert(dayLog == wanted, "el día " .. d .. " registró " .. dayLog .. " acciones, esperaba " .. wanted)
    trainingDays = trainingDays + 1

    if d == 1 then
        press("c", 2)
        assert(scene() == "collection", "C no abrió la colección desde el paquete")
        press("escape", 2)
        assert(scene() == "pack", "salir de la colección no volvió al paquete")
    end

    leavePack()
    if run.day <= Run.DAYS then
        assert(scene() == "room", "salir del paquete no volvió a la celda")
        assert(actionsLeft() == Run.ACTIONS, "el día nuevo no arrancó con todas sus acciones")
    end
end

local furiaWanted = furiaBefore + (trainingDays - 1) * TrainingSystem.gainFor(Run.ACTIONS)
    + TrainingSystem.gainFor(Run.ACTIONS - 1)
assert(run.stats.furia == furiaWanted,
    "entrenar no subió la stat según las acciones que quedaban, quedó en " .. run.stats.furia
    .. " y esperaba " .. furiaWanted)
assert(TrainingSystem.gainFor(Run.ACTIONS) > TrainingSystem.gainFor(Run.ACTIONS - 1),
    "entrenar el día entero no rinde más que medio día")
assert(run.day == Run.DAYS + 1, "la semana no terminó")
assert(scene() == "menu", "después del día 7 no se salió de la semana")
assert(#run.log == Run.ACTIONS + trainingDays + 1, "el log no cuadra con las acciones gastadas")

local flat = {}
local function scan(value, path, depth)
    if depth > 8 then return end
    local t = type(value)
    if t == "function" or t == "userdata" or t == "thread" then
        flat[#flat + 1] = path .. " = " .. t
    elseif t == "table" then
        if getmetatable(value) then flat[#flat + 1] = path .. " tiene metatable" end
        for k, v in pairs(value) do scan(v, path .. "." .. tostring(k), depth + 1) end
    end
end
scan(run, "runState", 0)
assert(#flat == 0, "el estado compartido guarda algo que no es un dato simple: " .. table.concat(flat, ", "))

Game.start("map")
stub.clear()
tick(2)
assert(scene() == "map", "no se pudo abrir el mapa")
for _, name in ipairs({ "Tu celda", "Archivo del Limbo", "Salón Carmesí", "Calderas", "Puerta del Guardián" }) do
    assert(stub.find(name), "el mapa no dibujó " .. name)
end

local function hold(key, n)
    stub.hold(key) tick(n) stub.release()
end
local function close(a, b) return math.abs(a - b) < 0.01 end

local start = player()
local startX, startY = start.x, start.y
hold("right", 30)
assert(close(player().x, startX + 80) and close(player().y, startY),
    ("caminar medio segundo a la derecha no avanzó 80 px: %.2f"):format(player().x - startX))
hold("left", 30)
assert(close(player().x, startX), "volver a la izquierda no regresó al mismo lugar")

hold("w", 120)
assert(close(player().y, 298) and close(player().x, startX),
    ("la lava no detuvo al jugador: %.2f, %.2f"):format(player().x, player().y))
hold("a", 120)
assert(close(player().x, 42), ("el muro izquierdo no detuvo al jugador: %.2f"):format(player().x))

stub.hold("right") stub.hold("down")
tick(30)
stub.release()
local moved = math.sqrt((player().x - 42) ^ 2 + (player().y - 298) ^ 2)
assert(close(moved, 80), ("la diagonal no camina a la misma velocidad: %.2f px"):format(moved))

assert(focus() == nil, "lejos de las puertas igual hay un lugar enfocado")
standAt("salon")
assert(focus() == "salon", "pararse en la puerta del Salón Carmesí no lo enfocó")
assert(stub.find("Lilim"), "el cartel del Salón Carmesí no nombra a Lilim")
press("return", 2)
assert(scene() == "visit", "Enter en el Salón Carmesí no entró a la casa")
Game.start("map")
tick(1)
standAt("puerta")
assert(stub.find("Todavía no"), "la Puerta del Guardián no avisa que está cerrada")
press("return", 1)
assert(scene() == "map", "la Puerta del Guardián dejó pasar")

local demons = require("src.data.demons")
local Talk = require("src.rules.Talk")
for _, conversation in ipairs(demons.brasa.conversations) do
    Talk.use(run, demons.brasa, conversation)
end
standAt("calderas")
assert(stub.find("Brasa ya te contó todo"), "las Calderas no avisan que Brasa ya contó todo")
press("return", 2)
assert(scene() == "map", "se pudo entrar a hablar con Brasa sin conversaciones pendientes")

run.affinity.lilim = 0
for _, conversation in ipairs(demons.lilim.conversations) do
    if conversation.minAffinity == nil then Talk.use(run, demons.lilim, conversation) end
end
standAt("salon")
assert(stub.find("hacerle compañía"), "el Salón no invita a hacerle compañía a Lilim")
press("return", 2)
assert(scene() == "visit", "con partes bloqueadas no se pudo entrar a hacerle compañía a Lilim")
stub.clear()
tick(240)
assert(stub.find("compañía a Lilim"), "la visita no dice que se quedó haciéndole compañía")
assert(run.affinity.lilim == 1, "hacerle compañía no subió la afinidad en 1, quedó en " .. run.affinity.lilim)
talk()
assert(scene() == "map", "terminar la visita de compañía no volvió al mapa")
standAt("salon")
assert(stub.find("ya no tiene ganas de hablar hoy"), "después de hacerle compañía se puede volver a entrar")

standAt("celda")
assert(focus() == "celda", "la puerta de tu celda no se enfocó")
press("return", 2)
assert(scene() == "room", "Enter en tu celda no volvió")

Game.start("map")
tick(1)
press("escape", 2)
assert(scene() == "room", "Esc en el mapa no volvió")

Game.start("map", { from = "calderas" })
tick(1)
assert(focus() == "calderas", "volver desde las Calderas no dejó al jugador en su puerta")

print(("smoke ok -- semana de entrenamiento completa, mapa recorrido, %d cartas, estado compartido plano"):format(#run.cards))
