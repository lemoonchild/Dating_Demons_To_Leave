local Affinity = {}

Affinity.MIN = -20
Affinity.MAX = 20
Affinity.THRESHOLDS = { 7, 13, 20 } -- umbral i -> carta i del demonio
Affinity.COMPANY = 1

-- Entrega la próxima carta que le queda al demonio, sin mirar umbrales.
function Affinity.grant(runState, demon)
    local given = runState.rewards[demon.id] or 0
    local card = demon.cards[given + 1]
    if not card then return nil end

    runState.rewards[demon.id] = given + 1
    local copy = {
        name = card.name, stat = card.stat, power = card.power,
        rarity = card.rarity, effect = card.effect, from = demon.id,
    }
    runState.cards[#runState.cards + 1] = copy
    return copy
end

-- Aplica una respuesta.
function Affinity.apply(runState, demon, option, gain)
    local before = runState.affinity[demon.id] or 0
    local after = math.max(Affinity.MIN, math.min(Affinity.MAX, before + (gain or option.affinity or 0)))
    runState.affinity[demon.id] = after

    local gained = {}
    local given = runState.rewards[demon.id] or 0
    while given < #Affinity.THRESHOLDS and after >= Affinity.THRESHOLDS[given + 1] do
        local copy = Affinity.grant(runState, demon)
        if not copy then break end
        gained[#gained + 1] = copy
        given = runState.rewards[demon.id]
    end

    return { affinity = after, delta = after - before, cards = gained }
end

-- negativo = el demonio detesta al jugador, positivo = le agrada.
function Affinity.ratio(value)
    if value < 0 then
        return -value / Affinity.MIN
    end
    return value / Affinity.MAX
end

return Affinity
