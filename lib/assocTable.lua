local function f1(t, k)
    t[k] = {}
    return t[k]
end

local function f2(t, k)
    t[k] = setmetatable({}, {__index = f1})
    return t[k]
end

local function f3(t, k)
    t[k] = setmetatable({}, {__index = f2})
    return t[k]
end

local function f4(t, k)
    t[k] = setmetatable({}, {__index = f3})
    return t[k]
end

function newFlexibleTable()
    return setmetatable({}, { __index = f4 })
end

CLI_FINAL_MAP_TABLE = newFlexibleTable()

-- Function to read the last item on tile, with the highest stackpos
function getLastValue(t, pos)
    if pos == nil then
        error('Pos argument is nil. Something went wrong')
    end
    local layer = t[pos.x] and t[pos.x][pos.y] and t[pos.x][pos.y][pos.z]
    if not layer then
        return nil
    end
    local lastStackPos = nil
    for stackPos in pairs(layer) do
        if not lastStackPos or stackPos > lastStackPos then
            lastStackPos = stackPos
        end
    end
    return lastStackPos and layer[lastStackPos] or nil
end

-- Function to get the last index of the last item on the tile (last stackpos)
function getLastStackPos(t, pos)
    if pos == nil then
        error('Pos argument is nil. Something went wrong')
    end
    local layer = t[pos.x] and t[pos.x][pos.y] and t[pos.x][pos.y][pos.z]
    if not layer then
        return nil
    end
    local lastStackPos = nil
    for stackPos in pairs(layer) do
        if not lastStackPos or stackPos > lastStackPos then
            lastStackPos = stackPos
        end
    end
    if lastStackPos == nil or lastStackPos == 0 then
        lastStackPos = 0
    --else
    --    lastStackPos = lastStackPos -1
    end

    return lastStackPos
end

function removeLastValue(t, pos)
    local layer = t[pos.x] and t[pos.x][pos.y] and t[pos.x][pos.y][pos.z]
    if not layer then
        return false
    end
    local maxStackPos = getLastStackPos(t, pos)
    if maxStackPos then
        layer[maxStackPos] = nil
        -- Removal of empty tables, if they are empty after removal of the value
        --if next(layer) == nil then
        --    t[pos.x][pos.y][pos.z] = nil
        --    if next(t[pos.x][pos.y]) == nil then
        --        t[pos.x][pos.y] = nil
        --        if next(t[x]) == nil then
        --            t[x] = nil
        --        end
        --    end
        --end

        return true
    end

    return false
end