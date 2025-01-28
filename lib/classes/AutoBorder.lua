AutoBorder = {}
AutoBorder.__index = AutoBorder

function AutoBorder.new(map)
    local instance = setmetatable({}, AutoBorder)
    instance.map = map

    return instance
end