local Movement = {}

function Movement.direction(dx, dy)
    local length = math.sqrt(dx * dx + dy * dy)
    if length == 0 then return 0, 0 end
    return dx / length, dy / length
end

function Movement.isoDirection(dx, dy)
    return Movement.direction(dx + dy, dy - dx)
end

function Movement.facing(dx, dy, current)
    if dx > 0 then return "der" end
    if dx < 0 then return "izq" end
    if dy > 0 then return "enfrente" end
    if dy < 0 then return "atras" end
    return current
end

return Movement
