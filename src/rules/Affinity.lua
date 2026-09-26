-- Las reglas de "caerle bien" a un demonio. Módulo PURO: no toca el World,
-- ni escenas, ni love.*, así que tests/affinity.lua lo prueba sin ventana.
-- AffinitySystem es el adaptador delgado que lo conecta con los eventos.
--
--   afinidad  MIN..MAX, sube o baja según tu respuesta. Puede ser NEGATIVA:
--             un demonio que te detesta (base para mecánicas futuras)
--   stat      si la respuesta le gustó, sube la stat que ese demonio enseña
--   cartas    al cruzar cada umbral te regala su siguiente carta. El conteo
--             de cartas entregadas nunca baja: si pierdes afinidad y la
--             recuperas, no te regala la misma carta dos veces.

local Affinity = {}

Affinity.MIN = -10
Affinity.MAX = 10
Affinity.THRESHOLDS = { 3, 6, 9 } -- umbral i -> carta i del demonio

-- Aplica una respuesta. Modifica runState y devuelve qué pasó:
--   { affinity = nuevo valor, delta = cambio real, stat = cuánto subió, cards = {cartas nuevas} }
function Affinity.apply(runState, demon, option)
    local before = runState.affinity[demon.id] or 0
    local after = math.max(Affinity.MIN, math.min(Affinity.MAX, before + (option.affinity or 0)))
    runState.affinity[demon.id] = after

    local statGain = option.stat or 0
    if statGain > 0 then
        runState.stats[demon.stat] = (runState.stats[demon.stat] or 0) + statGain
    end

    local gained = {}
    local given = runState.rewards[demon.id] or 0
    while given < #Affinity.THRESHOLDS
        and after >= Affinity.THRESHOLDS[given + 1]
        and demon.cards[given + 1] do
        given = given + 1
        local card = demon.cards[given]
        -- copia plana: la colección no debe compartir tablas con los datos
        local copy = { name = card.name, stat = card.stat, power = card.power, from = demon.id }
        runState.cards[#runState.cards + 1] = copy
        gained[#gained + 1] = copy
    end
    runState.rewards[demon.id] = given

    return { affinity = after, delta = after - before, stat = statGain, cards = gained }
end

-- -1..1 para barras de UI: negativo = te detesta, positivo = le agradas.
function Affinity.ratio(value)
    if value < 0 then
        return -value / Affinity.MIN
    end
    return value / Affinity.MAX
end

return Affinity
