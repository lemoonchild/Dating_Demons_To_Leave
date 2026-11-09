local Movement = {}

function Movement.direction(dx, dy)
    local length = math.sqrt(dx * dx + dy * dy)
    if length == 0 then return 0, 0 end
    return dx / length, dy / length
end

return Movement
