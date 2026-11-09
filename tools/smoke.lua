package.path = "./?.lua;" .. package.path

local stub = require("tools.love_stub")
stub.install()

local Game = require("src.Game")
local Run = require("src.state.Run")
local PackGen = require("src.rules.PackGen")
local TrainingSystem = require("src.systems.TrainingSystem")

Game.registerScene("menu", require("src.scenes.MenuScene"))
Game.registerScene("week", require("src.scenes.WeekScene"))
Game.registerScene("pack", require("src.scenes.PackScene"))
Game.registerScene("collection", require("src.scenes.CollectionScene"))

local function tick(n) for _ = 1, (n or 1) do Game.update(1 / 60); Game.draw() end end
local function press(k, n) Game.keypressed(k); tick(n or 1) end
local function scene() return Game.current().name end

local function leavePack()
    local guard = 0
    while scene() == "pack" and guard < 12 do
        press("return", 2)
        guard = guard + 1
    end
    assert(guard < 12, "no se pudo salir del paquete")
end

local function talkTo(n)
    press(tostring(n)) tick(2)
    press("return", 3) press("return", 3)
    press("1", 2)
    press("return", 3) press("return", 3)
end

math.randomseed(12)
Game.start("menu")
press("return", 2)
assert(scene() == "week", "Jugar no llevó a la semana")

local run = Run.current()
local phase = Game.current().world:resource("dayPhase")
assert(phase.left == Run.ACTIONS, "el día no arrancó con " .. Run.ACTIONS .. " acciones")

local statsBeforeTalking = run.stats.astucia
talkTo(1)
assert(scene() == "week", "el día cerró con una sola acción")
assert(run.stats.astucia == statsBeforeTalking, "hablar subió una stat: eso ahora solo lo hace entrenar")
assert(Game.current().world:resource("dayPhase").left == Run.ACTIONS - 1, "no se descontó la acción")
local used = 0
for _ in pairs(run.talks.azazel) do used = used + 1 end
assert(used == 1, "hablar no marcó la conversación como usada")

local moodsBefore = {}
for id, mood in pairs(run.moods) do moodsBefore[id] = mood end
press("c", 2)
assert(scene() == "collection", "C no abrió la colección a mitad del día")
press("escape", 2)
assert(scene() == "week", "salir de la colección no volvió a la semana a mitad del día")
assert(Game.current().world:resource("dayPhase").left == Run.ACTIONS - 1,
    "volver a la semana a mitad del día devolvió las acciones")
for id, mood in pairs(moodsBefore) do
    assert(run.moods[id] == mood, "volver a la semana a mitad del día cambió el humor de " .. id)
end

talkTo(2)
assert(scene() == "pack", "gastar las dos acciones no abrió el paquete, estoy en " .. scene())
assert(run.day == 2, "el día no avanzó")
assert(#run.cards >= PackGen.MIN, "el paquete no llegó a la colección")
for _, card in ipairs(run.cards) do
    assert(card.name and card.stat and card.power and card.rarity and card.effect,
        "una carta de la colección está incompleta")
end
assert(#run.pendingPack == 0, "el paquete pendiente no se limpió")

local dayOne = 0
for _, e in ipairs(run.log) do if e.day == 1 then dayOne = dayOne + 1 end end
assert(dayOne == Run.ACTIONS, "el día 1 no registró las dos acciones")

press("return") press("c", 2)
assert(scene() == "collection", "C no abrió la colección desde el paquete")
local before = #run.cards
press("right", 2) press("down", 2)
press("escape", 2)
assert(scene() == "pack", "salir de la colección no volvió al paquete")
assert(#run.cards == before, "mirar la colección cambió las cartas")

leavePack()
assert(scene() == "week", "salir del paquete no volvió a la semana")

press("c", 2)
assert(scene() == "collection", "C no abrió la colección desde el menú del día")
assert(#run.cards == before, "la colección perdió cartas al reabrirla")
press("escape", 2)
assert(scene() == "week", "salir de la colección no volvió a la semana")

local cardsBeforeTraining = #run.cards
local furiaBefore = run.stats.furia
local trainingDays = 0
while run.day <= Run.DAYS do
    local d = run.day
    press("6", 2)
    assert(scene() == "pack", "entrenar no cerró el día " .. d .. ", estoy en " .. scene())
    local dayLog = 0
    for _, e in ipairs(run.log) do if e.day == d then dayLog = dayLog + 1 end end
    assert(dayLog == 1, "el día de entrenamiento registró " .. dayLog .. " acciones, esperaba 1")
    trainingDays = trainingDays + 1
    leavePack()
end

assert(run.stats.furia == furiaBefore + trainingDays * TrainingSystem.GAIN,
    "entrenar no subió la stat " .. TrainingSystem.GAIN .. " por día, quedó en " .. run.stats.furia)
assert(#run.cards == cardsBeforeTraining, "entrenar dio cartas")
assert(run.day == Run.DAYS + 1, "la semana no terminó")
assert(scene() == "menu", "después del día 7 no se salió de la semana")
assert(#run.log == Run.ACTIONS + trainingDays, "el log no cuadra con las acciones gastadas")

local kinds = {}
for _, entry in ipairs(run.log) do kinds[entry.kind] = true end
assert(kinds.visit and kinds.train, "el log no registró los dos tipos de acción")

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

print(("smoke ok -- semana completa, %d cartas, estado compartido plano"):format(#run.cards))
