GroundMapper = {}
GroundMapper.__index = GroundMapper

function GroundMapper.new(mainPos, sizeX, sizeY, sizeZ, wpMinDist, wpMaxDist) -- todo: add more params, if needed
    local instance = setmetatable({}, GroundMapper)
    instance.mainPos = mainPos
    instance.pos = {x = mainPos.x, y = mainPos.y, z = mainPos.z} -- todo: maybe not needed?
    instance.sizeX = sizeX
    instance.sizeY = sizeY
	instance.sizeZ = sizeZ
    instance.wpMinDist = wpMinDist
    instance.wpMaxDist = wpMaxDist or 0 -- for middle/large maps the value can be set, other way keep 0 todo: does not work
    instance.wayPoints = {}

    return instance
end

function GroundMapper:doMainGround(itemTab, currentFloor) -- creates the background tiles
    local startTime = os.clock()
    local startX = self.mainPos.x
    local pom = {}
    pom.x = self.mainPos.x
    pom.y = self.mainPos.y
    pom.z = currentFloor or self.mainPos.z

    for i = self.mainPos.y, self.mainPos.y + self.sizeY do -- todo: watchout, there was an issue with additional 1 sqm
        pom.y = i
        for j = self.mainPos.x, self.mainPos.x + self.sizeX do -- todo: watchout, there was an issue with additional 1 sqm
            pom.x = j
            doCreateItemMock(itemTab[0][1], 1, pom)
        end
        pom.x = startX
    end

    print("Main ground created, floor: " .. self.mainPos.z .. ", execution time: " .. os.clock() - startTime)
end

function GroundMapper:doGround(
        -- it was changed between original "generation_map2 - dobra.lua"
        -- and "generation_tomb_small.lua"
        -- todo: check why
        markersTab,
        cursor,
        badGroundItemId,
        newGroundItemId,
        minPathSize,
        maxPathSize
    ) -- sometimes issues happen, for example goes on the mountains -> badGround
    local startTime = os.clock()
    local lastPos = {}
    local pathSize = 0

    for i = 1, #markersTab do
        pathSize = 0

        doCreateItemMock(newGroundItemId, 1, markersTab[i][1])
        cursor:setPos(markersTab[i][1].x, markersTab[i][1].y, markersTab[i][1].z)

        repeat
            lastPos.x = cursor.pos.x
            lastPos.y = cursor.pos.y
            lastPos.z = cursor.pos.z

            local dir = math.random(1,4)
            if (dir == 1) then
                cursor:up(1)
            elseif (dir == 3) then
                cursor:down(1)
            elseif (dir == 2) then
                cursor:right(1)
            elseif (dir == 4) then
                cursor:left(1)
            end

            local itemId = getThingFromPosMock(
                    {x = cursor.pos.x, y = cursor.pos.y, z = cursor.pos.z, stackpos = 0}
            ).itemid

            if (itemId ~= badGroundItemId) then
                if (itemId == newGroundItemId and pathSize ~= 0) then
                    print("Stuck in the new ground  Cr.x : " .. cursor.pos.x .. " , Cr. y : " .. cursor.pos.y)
                    cursor:setPos(lastPos.x, lastPos.y, lastPos.z)
                    print("Back  Cr.x : " .. cursor.pos.x .. " , Cr. y : " .. cursor.pos.y .. "\n")
                    -- todo: bug, sometimes infinitive loop happens
                else
                    doCreateItemMock(newGroundItemId, 1, cursor.pos)
                    print("--------------- New Ground Tile Created ---------------")
                    pathSize = pathSize + 1
                end
            else
                -- going into the mainGround, move back
                print("----- going into the mainGround, move back -----")
                cursor:setPos(lastPos.x, lastPos.y, lastPos.z)
            end

            if (pathSize > minPathSize) then
                if (math.random(minPathSize, maxPathSize) <= ((minPathSize + maxPathSize)/2)) then
                    break
                end
            end
        until pathSize >= maxPathSize
    end

    print("Ground created, execution time: " .. os.clock() - startTime)
end

function GroundMapper:doGround2(
        markersTab,
        cursor,
        goodGroundItemId,
        newGroundItemId,
        minPathSize,
        maxPathSize
)
    local startTime = os.clock()
    local lastPos = {}
    local pathSize = 0

    for i = 1, #markersTab do
        pathSize = 0
        doCreateItemMock(newGroundItemId, 1, markersTab[i][1])
        cursor:setPos(markersTab[i][1].x, markersTab[i][1].y, markersTab[i][1].z)

        local safetyFuse = 0
        repeat
            if (safetyFuse > 30) then -- todo: issues with infinitive loops ?
                -- print("Creating ground - safety-fuse kaboom, break the loop. Marker i = " .. i)
                break
            end

            lastPos.x = cursor.pos.x
            lastPos.y = cursor.pos.y
            lastPos.z = cursor.pos.z

            local dir = math.random(1,4)
            if (dir == 1) then
                cursor:up(1)
            elseif (dir == 3) then
                cursor:down(1)
            elseif (dir == 2) then
                cursor:right(1)
            elseif (dir == 4) then
                cursor:left(1)
            end

            local itemId = getThingFromPosMock(
                    {x = cursor.pos.x, y = cursor.pos.y, z = cursor.pos.z, stackpos = 0}
            ).itemid
            if (itemId == goodGroundItemId) then
                doCreateItemMock(newGroundItemId, 1, cursor.pos)
                pathSize = pathSize + 1
            else
                -- print('Wrong itemId: ' .. itemId .. ', when goodItemId: ' .. goodGroundItemId .. ' - move back')
                -- going into the wrong ground, move back
                cursor:setPos(lastPos.x, lastPos.y, lastPos.z)
                safetyFuse = safetyFuse + 1
            end

            if (pathSize > minPathSize) then
                if (math.random(minPathSize, maxPathSize) <= ((minPathSize + maxPathSize)/2)) then
                    break
                end
            end
        until pathSize >= maxPathSize
    end

    print("Ground created, execution time: " .. os.clock() - startTime)
end

function GroundMapper:correctGround(
	mainGround,
	newGround,
	currentFloor
)
	currentFloor = currentFloor or self.mainPos.z
    local startTime = os.clock()
    local pom = {}
    pom.x = self.mainPos.x
    pom.y = self.mainPos.y
    pom.z = currentFloor

    for i = self.mainPos.y, self.mainPos.y + self.sizeY do
        for j = self.mainPos.x, self.mainPos.x + self.sizeX do
            local itemId = getThingFromPosMock(
                    {x = pom.x, y = pom.y, z = pom.z, stackpos = 0}
            ).itemid

            if (itemId == mainGround) then
                if ((getThingFromPosMock(
                        {x = pom.x, y = pom.y - 1, z = pom.z, stackpos = 0}
                    ).itemid == newGround) and (getThingFromPosMock(
                        {x = pom.x, y = pom.y + 1, z = pom.z, stackpos = 0}
                    ).itemid == newGround)
                ) then
                    doCreateItemMock(newGround, 1, pom)
                end
                if ((getThingFromPosMock(
                        {x = pom.x - 1, y = pom.y, z = pom.z, stackpos = 0}
                    ).itemid == newGround) and (getThingFromPosMock(
                        {x = pom.x + 1, y = pom.y, z = pom.z, stackpos = 0})
                        .itemid == newGround)
                ) then
                    doCreateItemMock(newGround, 1, pom)
                end
            end
            pom.x = pom.x + 1
        end
        pom.x = self.mainPos.x
        pom.y = pom.y + 1
    end

    print("Correction of the groundId ".. newGround .." on floor: " .. currentFloor .. " done, execution time: " .. os.clock() - startTime)
end

function GroundMapper:eraseMap()
    local startTime = os.clock()
	local removedItems = 0

    for i = self.mainPos.y, self.mainPos.y + self.sizeY do
		for j = self.mainPos.x, self.mainPos.x + self.sizeX do
			for k = self.mainPos.z - (self.sizeZ - 1), self.mainPos.z do
				removedItems = removedItems + removeAllItemsFromPos({x = j, y = i, z = k}, true)
			end
        end
    end

	CLI_FINAL_MAP_TABLE = newFlexibleTable()
    print("Map erased, items removed: " .. removedItems .. ", execution time: " .. os.clock() - startTime)
end
