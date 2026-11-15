local Iso = {}

function Iso.view(tiled, screenW, screenH)
    local tw, th = tiled.tilewidth, tiled.tileheight
    local lift = tiled.tilesets[1].tileheight - th
    local span = tiled.width + tiled.height
    return {
        tw = tw,
        th = th,
        lift = lift,
        ox = math.floor((screenW - span * tw / 2) / 2) + tiled.height * tw / 2,
        oy = math.floor((screenH - span * th / 2 - lift) / 2) + lift,
    }
end

function Iso.cellTop(view, x, y)
    return view.ox + (x - y) * view.tw / 2, view.oy + (x + y - 2) * view.th / 2
end

function Iso.surfaceTop(view, x, y)
    local sx, sy = Iso.cellTop(view, x, y)
    return sx, sy - view.lift
end

function Iso.image(view, x, y, imageHeight)
    local sx, sy = Iso.cellTop(view, x, y)
    return sx - view.tw / 2, sy + view.th - imageHeight
end

function Iso.toScreen(view, cell, px, py)
    local u, v = px / cell, py / cell
    return view.ox + (u - v) * view.tw / 2, view.oy + (u + v) * view.th / 2 - view.lift
end

function Iso.depth(cell, px, py)
    return (px + py) / cell
end

return Iso
