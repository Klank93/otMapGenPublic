function loadSchemaFile()
    local schemaFolder = 'data/schemas/'
    -- load specific schema file
    local schemaFilePath = ROOT_PATH .. schemaFolder .. MAP_CONFIGURATION.schemaFile
    print('# Loading schema file: ' ..schemaFilePath)
    dofile(schemaFilePath)
end

function defaultParam(value, defaultValue)
    if value == nil then
        return defaultValue
    end

    return value
end

function getFileName()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("^.*/(.*).lua$") or str
end

function getFunctionCallerInfo(level)
    local level = level or 2
    local debugInfo = debug.getinfo(level)
    local source = debugInfo ~= nil and debugInfo.source or "unknown"
    local name = debugInfo ~= nil and debugInfo.name or "unknown"
    local currentline = debugInfo ~= nil and debugInfo.currentline or "unknown"
    return source .. '::' ..
            name .. '::' ..
            currentline .. ': '
end

function dumpVar(data)
    -- cache of tables already printed, to avoid infinite recursive loops
    local tableCache = {}
    local buffer = getFunctionCallerInfo(3)
    --local padder = "    "
    local padder = "  "

    local function _dumpVar(d, depth)
        local t = type(d)
        local str = tostring(d)
        if (t == "table") then
            if (tableCache[str]) then
                -- table already dumped before, so we dont
                -- dump it again, just mention it
                buffer = buffer.."<"..str..">\n"
            else
                tableCache[str] = (tableCache[str] or 0) + 1
                buffer = buffer.."("..str..") {\n"
                for k, v in pairs(d) do
                    buffer = buffer..string.rep(padder, depth+1).."["..k.."] => "
                    _dumpVar(v, depth+1)
                end
                buffer = buffer..string.rep(padder, depth).."}\n"
            end
        elseif (t == "number") then
            buffer = buffer.."("..t..") "..str.."\n"
        else
            buffer = buffer.."("..t..") \""..str.."\"\n"
        end
    end
    _dumpVar(data, 0)
    return buffer
end

function pointDistance(pos1, pos2, isPrintingEnabled)
    isPrintingEnabled = defaultParam(isPrintingEnabled, false)
    local distX = math.abs(pos1.x - pos2.x)
    local distY = math.abs(pos1.y - pos2.y)

    local result = math.sqrt((distX * distX) + (distY * distY))
    return round(result,2)
end

function pointDistance2(pos1, pos2, isPrintingEnabled)
    isPrintingEnabled = defaultParam(isPrintingEnabled, false)
    local distX = math.abs(pos1.x - pos2.x)
    local distY = math.abs(pos1.y - pos2.y)

    local result = distX + distY
    return result
end

function isWalkable(pos) -- ORIGINAL FUNCTION CHECKS ALL THE STACKPOSES
    local geItemUid = getThingFromPosMock(
            {x = pos.x, y = pos.y, z = pos.z, stackpos = 0}
        ).uid
    local result = queryTileAddThingMock(
            geItemUid,
            {x = pos.x, y = pos.y, z = pos.z}
    )
    if result == RETURNVALUE_NOERROR then
        --print('Walkable: ' .. dumpVar(pos))

        return true
    else
        return false
    end
end

function sortWaypoints(wp)
    local pom = {}

    for i=1, #wp do
        for j=1, #wp do
            if (i ~= j) then
                if ((wp[i][1].x <= wp[j][1].x)) then
                    if (wp[i][1].x == wp[j][1].x) then
                        if ((wp[i][1].y < wp[j][1].y)) then
                            pom = wp[i][1]
                            wp[i][1] = wp[j][1]
                            wp[j][1] = pom
                        end
                    else
                        pom = wp[i][1]
                        wp[i][1] = wp[j][1]
                        wp[j][1] = pom
                    end
                end
            end

        end
    end
end

function printWaypoints(wp, cid)
    for i=1, #wp do
        x = wp[i][1].x
        y = wp[i][1].y
        z = wp[i][1].z
        rm_sh = wp[i][3]
        rm_h = wp[i][4]
        rm_w = wp[i][5]
        local msg = "[".. i .."] = {{ x = ".. x ..", y = ".. y ..", z = ".. z .. " }, " ..
                "room_shape = "..rm_sh..",   rm_h = " ..rm_h.. ",   rm_w =" ..rm_w.."}"
        doPlayerSendTextMessageMock(TFS_CID, TFS_MESSAGE_CLASSES, msg)
        print(msg)
    end
end

function removeAllItemsFromPos(pos)
    for index = 1, 253 do
        pos.stackpos = index
        local currentItem = getThingFromPosMock(pos)
        if currentItem.itemid > 0 then
            doRemoveItemMock(currentItem.uid, pos)
        end
    end

    return true
end

function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function addMissingTableElements(destinationTable, sourceTable) -- combines two tables,
    -- the first one is being populated of the element from the second, no duplicates
    for k, v in pairs(sourceTable) do
        if destinationTable[k] == nil then
            destinationTable[k] = v
        end
    end
end

function makeSquare(itemId, pos) -- to point some position, only for testing purposes
    for i = pos.y - 1, pos.y + 1 do
        for j = pos.x - 1, pos.x + 1 do
            doCreateItemMock(itemId, 1, {x = j, y = i, z = pos.z})
        end
    end
end

function isGround(itemId)
    if (inArray(ITEMS_TABLE[0], itemId) or
            inArray(ITEMS_TABLE[1], itemId) or
            inArray(ITEMS_TABLE[12], itemId)
    ) then
        return true
    end

    return false
end

function explode(inputstr, sep)
    if sep == nil then
        sep = "%s"  -- space is default separator
    end

    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end

    return t
end

function removeWhitespace(inputstr)
    local result = inputstr:gsub("%s+", "")
    return result
end
