local Collision = {}

function Collision.blocked(grid, cell, box, x, y)
    local left, top = x - box.w / 2, y - box.h / 2
    local right, bottom = left + box.w, top + box.h
    for ty = math.floor(top / cell) + 1, math.ceil(bottom / cell) do
        for tx = math.floor(left / cell) + 1, math.ceil(right / cell) do
            if grid:solid(tx, ty) then return true end
        end
    end
    return false
end

local function stepX(grid, cell, box, x, y, mx)
    local nx = x + mx
    if not Collision.blocked(grid, cell, box, nx, y) then return nx end
    if mx > 0 then
        nx = math.floor((nx + box.w / 2) / cell) * cell - box.w / 2
    else
        nx = math.ceil((nx - box.w / 2) / cell) * cell + box.w / 2
    end
    if Collision.blocked(grid, cell, box, nx, y) then return x end
    return nx
end

local function stepY(grid, cell, box, x, y, my)
    local ny = y + my
    if not Collision.blocked(grid, cell, box, x, ny) then return ny end
    if my > 0 then
        ny = math.floor((ny + box.h / 2) / cell) * cell - box.h / 2
    else
        ny = math.ceil((ny - box.h / 2) / cell) * cell + box.h / 2
    end
    if Collision.blocked(grid, cell, box, x, ny) then return y end
    return ny
end

function Collision.move(grid, cell, box, x, y, mx, my)
    local steps = math.max(1, math.ceil(math.max(math.abs(mx), math.abs(my)) / (cell / 4)))
    for _ = 1, steps do
        if mx ~= 0 then x = stepX(grid, cell, box, x, y, mx / steps) end
        if my ~= 0 then y = stepY(grid, cell, box, x, y, my / steps) end
    end
    return x, y
end

return Collision
