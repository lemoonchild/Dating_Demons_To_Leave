local stub = { drawn = {} }

local font = {}
function font:getHeight() return 14 end
function font:getWidth(text) return #tostring(text) * 7 end

function stub.install()
    local drawn = stub.drawn
    local function record(text)
        if type(text) == "string" then drawn[#drawn + 1] = text end
    end

    love = {
        graphics = {
            newFont = function() return font end,
            print = record, printf = record,
            rectangle = function() end, line = function() end,
            setColor = function() end, setFont = function() end,
            push = function() end, pop = function() end,
            origin = function() end, translate = function() end,
            captureScreenshot = function() end,
        },
        mouse = { getPosition = function() return 0, 0 end, isDown = function() return false end },
        keyboard = { isDown = function() return false end },
        event = { quit = function() end },
        math = { random = function(n) return math.random(n) end },
        filesystem = { getSaveDirectory = function() return "/tmp" end },
    }
    return love
end

function stub.clear()
    stub.drawn = {}
    love.graphics.print = function(t) if type(t) == "string" then stub.drawn[#stub.drawn + 1] = t end end
    love.graphics.printf = love.graphics.print
end

function stub.find(pattern)
    for _, text in ipairs(stub.drawn) do
        if text:find(pattern) then return text end
    end
end

return stub
