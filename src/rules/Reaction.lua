local Reaction = {}

Reaction.BASE_SPREAD = 3
Reaction.MAX_SPREAD = 5

function Reaction.spreadFor(stat, demand)
    local margin = (stat or 0) - (demand or 0)
    local spread = Reaction.BASE_SPREAD - margin
    if spread < 0 then spread = 0 end
    if spread > Reaction.MAX_SPREAD then spread = Reaction.MAX_SPREAD end
    return spread, margin
end

function Reaction.roll(base, stat, demand, random)
    base = base or 0
    local spread, margin = Reaction.spreadFor(stat, demand)

    local roll = 0
    if spread > 0 then
        roll = random(2 * spread + 1) - spread - 1
    end

    local gain = base + roll
    if margin >= 0 then
        if base > 0 and gain < 1 then
            gain = 1
        elseif base < 0 and gain > -1 then
            gain = -1
        end
    end

    return {
        gain = gain,
        roll = roll,
        spread = spread,
        margin = margin,
        crit = spread > 0 and roll == spread,
    }
end

return Reaction
