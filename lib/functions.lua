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
        return true
    else
        return false
    end
end

function sortWaypoints(wp)
    local pom = {}

	for floor, wayPoints in pairs(wp) do
		for i=1, #wayPoints do
			for j=1, #wayPoints do
				if (i ~= j) then
					if ((wp[floor][i]["pos"].x <= wp[floor][j]["pos"].x)) then
						if (wp[floor][i]["pos"].x == wp[floor][j]["pos"].x) then
							if ((wp[floor][i]["pos"].y < wp[floor][j]["pos"].y)) then
								pom = wp[floor][i]["pos"]
								wp[floor][i]["pos"] = wp[floor][j]["pos"]
								wp[floor][j]["pos"] = pom
							end
						else
							pom = wp[floor][i]["pos"]
							wp[floor][i]["pos"] = wp[floor][j]["pos"]
							wp[floor][j]["pos"] = pom
						end
					end
				end
			end
		end
	end
end

function printWaypoints(wp)
	for floor, wayPoints in pairs(wp) do
		for i, wayPoint in pairs(wayPoints) do
			local x = wayPoint["pos"].x
			local y = wayPoint["pos"].y
			local z = wayPoint["pos"].z
			local rm_sh = wayPoint["room_shape"]
			local rm_h = wayPoint["room_height"]
			local rm_w = wayPoint["room_width"]
			local msg = "Floor: " .. floor .. " [".. i .."] = {{ x = ".. x ..", y = ".. y ..", z = ".. z .. " }, " ..
				"room_shape = ".. rm_sh ..",   rm_h = " .. rm_h .. ",   rm_w =" .. rm_w .."}"
			doPlayerSendTextMessageMock(TFS_CID, TFS_MESSAGE_CLASSES, msg)
			print(msg)
		end
	end
end

function removeAllItemsFromPos(pos, withGround)
	local removedItems = 0
	local lastStackPos = 1
	if withGround == true then lastStackPos = 0 end
    for index = 15, lastStackPos, -1 do
        pos.stackpos = index
        local currentItem = getThingFromPosMock(pos)
		if currentItem ~= nil and currentItem.itemid > 0 then
			if not (inArray(ITEMS_TABLE[0], currentItem.itemid)) then
				if (isGround(currentItem.itemid)) then
					doTransformItemMock(currentItem.uid, ITEMS_TABLE[0][math.random(1, #ITEMS_TABLE[0])], currentItem, pos)
				else
					if (doRemoveItemMock(currentItem.uid, pos)) then
						removedItems = removedItems + 1
					end
				end
			end
		end
    end

	return removedItems
end

function getPosItems(pos, withGround)
	local posItemIds = {}
	local lastStackPos = 1
	if withGround == true then lastStackPos = 0 end
	for stackpos = 15, lastStackPos, -1 do
		local possibleItem = getThingFromPosMock({x = pos.x, y = pos.y, z = pos.z, stackpos = stackpos})
		-- no usage of Tile:getItems() for TFS backward compatibility
		if (possibleItem ~= nil and possibleItem.itemid > 0) then
			table.insert(posItemIds, possibleItem)
		end
	end

	return posItemIds
end

removeAllUnwalkableItems = function (pos, wallBorder) -- deletes all items which are unwalkable from pos except walls
	-- todo: some issue, sometimes it does not remove all unwalkable items
	local posItems = getPosItems(pos, false)
	for _, item in pairs(posItems) do
		if (not inArray(flattenArray(wallBorder), item.itemid) and
			inArray(UNWALKABLE_ITEMS, item.itemid)
		) then
			doRemoveItemMock(item.uid, {x = pos.x, y = pos.y, z = pos.z})
		end
	end
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

function explode(inputstr, sep) -- php like function
    if sep == nil then
        sep = "%s"  -- space is default separator
    end

    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end

    return t
end

function implode(delimiter, tableData) -- php like function
	if type(tableData) ~= "table" then
		error("Second argument must be a table")
	end

	local result = {}
	for _, value in ipairs(tableData) do
		table.insert(result, tostring(value)) -- Ensure all values are strings
	end

	return table.concat(result, delimiter)
end


function removeWhitespace(inputstr)
    local result = inputstr:gsub("%s+", "")
    return result
end
