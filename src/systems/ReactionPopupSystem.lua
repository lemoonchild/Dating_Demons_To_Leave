local ReactionPopupSystem = { name = "reactionPopup" }

local fonts = {}

local LIFE = 1.6
local RISE = 70

function ReactionPopupSystem.setup(scene)
    fonts.popup = love.graphics.newFont(26)
end

function ReactionPopupSystem.unload(scene)
    fonts = {}
end

function ReactionPopupSystem.update(scene, dt)
    local world = scene.world

    for _, entity in ipairs(world:query("reactionApplied")) do
        local applied = world:getComponent(entity, "reactionApplied")
        for _, target in ipairs(world:query("position", "demonSprite")) do
            if world:getComponent(target, "demonSprite").demonId == applied.demonId then
                local pos = world:getComponent(target, "position")
                world:spawn({
                    position = { x = pos.x, y = pos.y - 110 },
                    popup = {
                        text = ("%+d"):format(applied.affinity),
                        life = LIFE,
                        good = applied.affinity >= 0,
                        crit = applied.crit,
                    },
                })
            end
        end
    end

    for _, entity in ipairs(world:query("position", "popup")) do
        local popup = world:getComponent(entity, "popup")
        popup.life = popup.life - dt
        if popup.life <= 0 then
            world:destroyEntity(entity)
        else
            local pos = world:getComponent(entity, "position")
            pos.y = pos.y - RISE * dt
        end
    end
end

function ReactionPopupSystem.draw(scene)
    local world = scene.world
    local camera = world:resource("camera")

    love.graphics.push()
    love.graphics.translate(-camera.x, -camera.y)
    love.graphics.setFont(fonts.popup)

    for _, entity in ipairs(world:query("position", "popup")) do
        local popup = world:getComponent(entity, "popup")
        local pos = world:getComponent(entity, "position")
        local alpha = math.min(1, popup.life / (LIFE * 0.5))

        if popup.crit then
            love.graphics.setColor(1, 0.85, 0.3, alpha)
        elseif popup.good then
            love.graphics.setColor(0.5, 1, 0.5, alpha)
        else
            love.graphics.setColor(1, 0.45, 0.4, alpha)
        end
        love.graphics.printf(popup.text, pos.x - 60, pos.y, 120, "center")
    end

    love.graphics.pop()
    love.graphics.setColor(1, 1, 1, 1)
end

return ReactionPopupSystem
