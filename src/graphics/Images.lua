local Images = {}

local cache = {}

function Images.load(path)
    if not path then return nil end
    if cache[path] == nil then
        if love.filesystem.getInfo(path) then
            local image = love.graphics.newImage(path)
            image:setFilter("nearest", "nearest")
            cache[path] = image
        else
            cache[path] = false
        end
    end
    return cache[path] or nil
end

function Images.drawStanding(image, x, y, h, shade)
    shade = shade or 1
    local iw, ih = image:getDimensions()
    local scale = h / ih
    if scale >= 1 then scale = math.floor(scale) end
    love.graphics.setColor(shade, shade, shade, 1)
    love.graphics.draw(image, math.floor(x - iw * scale / 2), math.floor(y - ih * scale), 0, scale, scale)
end

return Images
