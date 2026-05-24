--[[
    MODULE: TSFX SDK - ox_target Interact Adapter

    Maps to ox_target exports.
--]]

---@class OxTargetAdapter : InteractAdapterClass
OxTargetAdapter = setmetatable({}, { __index = InteractAdapterClass })
OxTargetAdapter.__index = OxTargetAdapter

function OxTargetAdapter:addBoxZone(params)
    exports.ox_target:addBoxZone({
        name = params.name,
        coords = params.coords,
        size = params.size,
        rotation = params.rotation or 0,
        debug = params.debug,
        drawSprite = params.drawSprite,
        options = params.options,
    })
end

function OxTargetAdapter:addSphereZone(params)
    exports.ox_target:addSphereZone({
        name = params.name,
        coords = params.coords,
        radius = params.radius,
        debug = params.debug,
        drawSprite = params.drawSprite,
        options = params.options,
    })
end

function OxTargetAdapter:addEntityZone(entity, params)
    exports.ox_target:addEntityZone(entity, {
        name = params.name,
        debug = params.debug,
        drawSprite = params.drawSprite,
        options = params.options,
    })
end

function OxTargetAdapter:removeZone(name)
    exports.ox_target:removeZone(name)
end
