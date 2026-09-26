local Affinity = {}

Affinity.MIN = -10
Affinity.MAX = 10
Affinity.THRESHOLDS = { 3, 6, 9 } -- umbral i -> carta i del demonio

-- Aplica una respuesta.
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
        local copy = { name = card.name, stat = card.stat, power = card.power, from = demon.id }
        runState.cards[#runState.cards + 1] = copy
        gained[#gained + 1] = copy
    end
    runState.rewards[demon.id] = given

    return { affinity = after, delta = after - before, stat = statGain, cards = gained }
end

-- negativo = el demonio detesta al jugador, positivo = le agrada.
function Affinity.ratio(value)
    if value < 0 then
        return -value / Affinity.MIN
    end
    return value / Affinity.MAX
end

return Affinity
