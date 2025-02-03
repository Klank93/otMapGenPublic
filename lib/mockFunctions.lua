-- Mock functions used internally in the tool
-- replace their mocks for your specific application or replace them with the ones
-- from specific TFS server accordingly

UNIQUE_UIDS = {}
math.randomseed(os.time()) -- sets a seed for the pseudo-random generator

--local function randomUid(t, from, to) -- old function backup, was causing stack overflow because of recursive loop in case of CLI usage
--    local num = math.random(from, to)
--    if t[num] then num = randomUid(t, from, to) end
--    t[num] = num
--
--    return num
--end

local nextUid = 100000 -- Initial uids value, can be changed
local function randomUid() -- new function, fixed an issue with stack overflow, most likely causes an issue with up to few error notes when opening map in map editor, errors - "Unknown tile attribute at <pos>"
    -- Function to generate unique uid and adding it to global UNIQUE_UIDS
    nextUid = nextUid + 1
    UNIQUE_UIDS[nextUid] = nextUid

    return nextUid
end

-- Function to remove uid from global UNIQUE_UIDS
local function removeUid(val)
    for i, v in pairs(UNIQUE_UIDS) do
        if v == val then
            UNIQUE_UIDS[i] = nil
            break
        end
    end
end

local function doCreateNoTileItem(itemId, count, pos) -- watch-out TFS 1.x only!
	local tile = Tile(pos)
	if not tile then
		Game.createTile(pos, true) -- Creates new Tile, if it does not exist
	end

	local item = Game.createItem(itemId, count, pos)
	if item then
		return item:getUniqueId()
	end
end

---

 doCreateItemMock = function(itemId, typeOrCount, pos)
     if (itemId == nil) then
         error('Incorrect data, itemId is nil')
     end
     if (typeOrCount == nil) then
         error('Incorrect data, typeOrCount is nil')
     end
     if (pos == nil or
        pos.x == nil or
        pos.y == nil or
        pos.z == nil
     ) then
         error('Incorrect data, pos is nil or some of its coordinates')
     end

     local stackPos
     local uid
     if not (PRECREATION_TABLE_MODE) then
		 doCreateNoTileItem(itemId, typeOrCount, pos) -- workaround for multi-floor purpose, for lower TFS versions than 1.X comment this and uncomment below (you will lose multi-floor feature)
         --doCreateItem(itemId, typeOrCount, pos) -- tfs function call, depends on tfs version
         stackPos = pos.stackpos or 0
     else
         local currentLastStackPos = getLastStackPos(
                 CLI_FINAL_MAP_TABLE,
                 {x = pos.x, y = pos.y, z = pos.z}
         )
         if (isGround(itemId)) then
             stackPos = 1
         elseif (pos.stackpos == nil) then
             stackPos = currentLastStackPos + 1
         else
             stackPos = pos.stackpos + 1
         end

         uid = randomUid(UNIQUE_UIDS, 1000, 99999999)
         CLI_FINAL_MAP_TABLE[pos.x][pos.y][pos.z][stackPos] = {
             ["itemid"] = itemId,
             ["typeOrCount"] = typeOrCount,
             ["uid"] = uid
         }

         currentLastStackPos = getLastStackPos(
                 CLI_FINAL_MAP_TABLE,
                 {x = pos.x, y = pos.y, z = pos.z}
         )
     end

     if (LOG_TO_FILE and DEBUG_OUTPUT) then
         logger:debug(
			 getFunctionCallerInfo(3) ..
					 'Created itemId: %s, uid: %s, type/count: %s, on {x = %s, y = %s, z = %s, stackpos = %s}',
			 itemId,
			 uid or 'nil',
			 typeOrCount,
			 pos.x,
			 pos.y,
			 pos.z,
			 stackPos
         )
     end
 end

getThingFromPosMock = function(pos)
    local stackPos
    local result
    if not (PRECREATION_TABLE_MODE) then
        result = getThingfromPos(pos) -- tfs function call, depends on tfs version
		if result.uid ~= 0 and DEBUG_OUTPUT then
			local thing = getThingPos(result.uid)
			if type(thing) == "table" then
				stackPos = thing.stackpos
			end
		end
    else
        if (isEmpty(CLI_FINAL_MAP_TABLE, pos.x, pos.y, pos.z)) then
            result = {
                ["actionid"] = 0,
                ["uid"] = 0,
                ["itemid"] = 0,
                ["type"] = 0
            }
            stackPos = 0
        elseif (pos.stackpos ~= nil and
			not isEmpty(CLI_FINAL_MAP_TABLE, pos.x, pos.y, pos.z, pos.stackpos + 1)
        ) then
            result = CLI_FINAL_MAP_TABLE[pos.x][pos.y][pos.z][pos.stackpos + 1]
            stackPos = pos.stackpos + 1
        elseif (pos.stackpos == nil and
                not isEmpty(CLI_FINAL_MAP_TABLE, pos.x, pos.y, pos.z, getLastStackPos(CLI_FINAL_MAP_TABLE, pos))
        ) then
            local lastStackPos = getLastStackPos(CLI_FINAL_MAP_TABLE, pos)
            result = CLI_FINAL_MAP_TABLE[pos.x][pos.y][pos.z][lastStackPos]

            stackPos = lastStackPos
        else -- not existing stackpos todo: to verify is that ok
            result = {
                ["actionid"] = 0,
                ["uid"] = 0,
                ["itemid"] = 0,
                ["type"] = 0
            }
            stackPos = 0
        end
    end

    if (LOG_TO_FILE and DEBUG_OUTPUT) then
        local itemId = 'nil'
        if (result and result.itemid ~= nil) then
            itemId = result.itemid
        end

		logger:debug(
			getFunctionCallerInfo(3) .. 'Got itemId: %s, from pos: {x = %s, y = %s, z = %s, stackpos = %s}',
			itemId,
			pos.x,
			pos.y,
			pos.z,
			stackPos or 'nil'
		)
    end

    return result
end

getTileThingByPosMock = function(pos)
    local result = {
        ["actionid"] = 0,
        ["uid"] = 0,
        ["itemid"] = 0,
        ["type"] = 0
    }
    if not (PRECREATION_TABLE_MODE) then
        result = getTileThingByPos(pos) -- tfs function call, depends on tfs version
    else
        local item = getThingFromPosMock(pos)
        if (item.itemid ~= nil and item.uid ~= nil) then
            result = {
                ["actionid"] = 0,
                --["uid"] = item.itemuid,
                ["uid"] = item.uid,
                ["itemid"] = item.itemid,
                ["type"] = item.typeOrCount
            }
        end
    end

    return result
end

doPlayerSendTextMessageMock = function(cid, messageClasses, message)
    if (RUNNING_MODE == 'tfs') then
		if (type(cid)) then
			return doPlayerSendTextMessage(cid, messageClasses, message) -- tfs function call, depends on tfs version
		else
			return cid:sendTextMessage(messageClasses, message) -- todo: to confirm is that the only one to replace
		end
    else
        print(message)
    end
end

queryTileAddThingMock = function(uid, pos)
    local result
    if not (PRECREATION_TABLE_MODE) then
        result = queryTileAddThing(uid, pos) -- tfs function call, depends on tfs version
    else
        if (isEmpty(CLI_FINAL_MAP_TABLE, pos.x, pos.y, pos.z)) then -- not existing position
            result = 0
        else
            -- check all the items on the tile, if they are walkable
            local tileItems = {}
            for index, item in pairs(CLI_FINAL_MAP_TABLE[pos.x][pos.y][pos.z]) do -- todo: most likely incorrectly checks items from
                table.insert(tileItems, item.itemid)
            end

            local unwalkableItems = arrayMerge(
                    ITEMS_TABLE[0],
                    UNWALKABLE_ITEMS,
                    flattenArray(TOMB_SAND_WALL_BORDER),
                    flattenArray(BLACK_WALL_BORDER),
                    flattenArray(CAVE_BASE_BORDER)
            )

            result = 1 -- assume success RETURNVALUE_NOERROR = 1
            for i = 1, #tileItems do
                if (inArray(unwalkableItems, tileItems[i])) then
                    result = 0 -- error
                    break
                end
            end
        end
    end

    if (LOG_TO_FILE and DEBUG_OUTPUT) then
        local isWalkableStr = 'walkable'
        if (result == 0) then
            isWalkableStr = 'unwalkable'
        end
        logger:debug(
			getFunctionCallerInfo(3) .. 'Tile pos: {x = %s, y = %s, z = %s} is %s, returned: %s',
			pos.x,
			pos.y,
			pos.z,
			isWalkableStr,
			result
        )
    end

    return result
end

doTransformItemMock = function (itemUid, newItemId, itemObject, itemPos)
	local result
	if not (PRECREATION_TABLE_MODE) then
		if (doTransformItem(itemUid, newItemId)) then -- tfs function call, depends on tfs version
			result = true
		end
	else
		if (itemPos.stackpos == nil) then -- todo: no errors handled (reconsider is this behavior expected)
			for stackpos, item in ipairs(CLI_FINAL_MAP_TABLE[itemPos.x][itemPos.y][itemPos.z]) do
				if item.uid == itemUid then
					CLI_FINAL_MAP_TABLE[itemPos.x][itemPos.y][itemPos.z][stackpos].itemid = newItemId
					result = true
				end
			end
		else
			CLI_FINAL_MAP_TABLE[itemPos.x][itemPos.y][itemPos.z][itemPos.stackpos].itemid = newItemId
			result = true
		end
	end

	if (LOG_TO_FILE and DEBUG_OUTPUT) then
		if (result) then
			logger:debug(
				getFunctionCallerInfo(3) .. 'Transformed Item with uid: %s, from itemId: %s, to itemId: %s, from pos: {x = %s, y = %s, z = %s, stackpos = %s}',
				itemUid,
				itemObject.itemid,
				newItemId,
				itemPos.x,
				itemPos.y,
				itemPos.z,
				itemPos.stackpos or 'nil'
			)
		else
			logger:debug(
				getFunctionCallerInfo(3) .. 'Could not transform Item with uid: %s, from itemId: %s, to itemId: %s, from pos: {x = %s, y = %s, z = %s, stackpos = %s}',
				itemUid,
				itemObject.itemid,
				newItemId,
				itemPos.x,
				itemPos.y,
				itemPos.z,
				itemPos.stackpos or 'nil'
			)
		end
	end
end

doRemoveItemMock = function(itemUid, itemPos)
    if (itemUid == nil or itemPos == nil) then
        print('itemUid: %s', dumpVar(itemUid))
        print('itemPos: %s', dumpVar(itemPos))
        error('Pos argument is nil. Something went wrong')
    end

    local isRemoved = false
    local stackPos = 'unknown'
    if not (PRECREATION_TABLE_MODE) then
		local thingPos
		if (DEBUG_OUTPUT == nil) then thingPos = getThingPos(itemUid) end

		if doRemoveItem(itemUid) then -- tfs function call, depends on tfs version
			isRemoved = true
			if (thingPos ~= nil) then stackPos = thingPos.stackpos end
		end
    else
        local lastStackPos = getLastStackPos(CLI_FINAL_MAP_TABLE, itemPos)
        if (itemPos.stackpos == nil) then
            for index, item in ipairs(CLI_FINAL_MAP_TABLE[itemPos.x][itemPos.y][itemPos.z]) do
                if (item.uid == itemUid and
                    not isGround(item.itemid)
                ) then
                    --CLI_FINAL_MAP_TABLE[itemPos.x][itemPos.y][itemPos.z][index] = nil
                    table.remove(CLI_FINAL_MAP_TABLE[itemPos.x][itemPos.y][itemPos.z], index)
                    removeUid(itemUid)
                    isRemoved = true
                    stackPos = lastStackPos
                end
            end
        else
            if (CLI_FINAL_MAP_TABLE[itemPos.x][itemPos.y][itemPos.z][itemPos.stackpos + 1] ~= nil and
                    CLI_FINAL_MAP_TABLE[itemPos.x][itemPos.y][itemPos.z][itemPos.stackpos + 1].uid == itemUid
            ) then
                --CLI_FINAL_MAP_TABLE[itemPos.x][itemPos.y][itemPos.z][itemPos.stackpos + 1] = nil
                table.remove(CLI_FINAL_MAP_TABLE[itemPos.x][itemPos.y][itemPos.z], itemPos.stackpos + 1)
                removeUid(itemUid)
                isRemoved = true
                stackPos = itemPos.stackpos + 1
            end
        end
    end

    if (LOG_TO_FILE and DEBUG_OUTPUT) then
		if isRemoved then
			logger:debug(
				getFunctionCallerInfo(3) .. 'Removed itemUid: %s, from pos: {x = %s, y = %s, z = %s, stackpos = %s}',
				itemUid,
				itemPos.x,
				itemPos.y,
				itemPos.z,
				stackPos
			)
		else
			logger:debug(
				getFunctionCallerInfo(3) .. 'Could not remove itemUid: %s, from pos: {x = %s, y = %s, z = %s, stackpos = %s}',
				itemUid,
				itemPos.x,
				itemPos.y,
				itemPos.z,
				stackPos
			)
		end
    end

    return isRemoved
end

addEventMock = function(callback, miliseconds, ...)
    if not (PRECREATION_TABLE_MODE) then
        addEvent(callback, miliseconds, ...) -- tfs function call, depends on tfs version
    else
        callback(...)
    end
end
