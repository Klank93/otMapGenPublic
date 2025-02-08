WayPointer = {}
WayPointer.__index = WayPointer

function WayPointer.new(map, cursor, wayPoints)
    local instance = setmetatable({}, WayPointer)
    instance.map = map
    instance.cursor = cursor
    instance.wayPoints = defaultParam(wayPoints, {})

    return instance
end

function WayPointer:createWaypoints(wp, pointsAmount, initialTime, currentFloor) -- legacy function, deprecated
    local startTime = defaultParam(initialTime, os.clock())
    local status = true
    local counter = 0
    local safetyFuse = (self.map.sizeX * self.map.sizeY * 200)
    -- it gives sqm^2 of the maps 100 times, so theoretically in every sqm of the map it will shoot 100 times

    local minPos = {}
    minPos.x = (self.map.pos.x + self.map.wpMinDist)
    minPos.y = (self.map.pos.y + self.map.wpMinDist)
    minPos.z = currentFloor

    local maxPos = {}
    maxPos.x = (self.map.pos.x - self.map.wpMinDist) + self.map.sizeX
    maxPos.y = (self.map.pos.y - self.map.wpMinDist) + self.map.sizeY
    maxPos.z = currentFloor

	-------------------
	if (wp[currentFloor] == nil) then
		wp[currentFloor] = {}
	end

    local i = 1
    repeat
        repeat -- shooting loop
            local xRand = math.random(minPos.x, maxPos.x)
            local yRand = math.random(minPos.y, maxPos.y)
            local randomPos = {}
            randomPos.x = xRand
            randomPos.y = yRand
            randomPos.z = currentFloor
            local tab = {
				["pos"] = randomPos,
				['result'] = true,
				[3] = 0, -- defines room shape number
				[4] = 0, -- defines room height
				[5] = 0 -- defines room width
			}

            counter = counter + 1
            if (counter > safetyFuse) then
                -- safety condition to prevent the situation when the structure of the rooms(their points)
                -- is bad and there is not possibile to shoot next point in the given area (map)
                print("----- Creating waypoints failed, repeating the procedure from scratch -----")
                status = false -- starts again
                print("i = " .. i .. ", counter = " .. counter)
                counter = 0
                break
            end
            --[[
            if (counter % 20000 == 0 ) then
                print("TAB : x - " .. tab["pos"].x .. ", y - " .. tab["pos"].y .. ", z - " .. tab["pos"].z .. ", III : " .. tab[3] .. ", IV : " .. tab[4] .. ", V : " .. tab[5])
            end
            ]]--
            if (i ~= 1) then
                local minimumDist = 999999
                for j = 1, #wp[currentFloor] do
                    if (i ~= j) then
                        local pointDist = pointDistance(tab["pos"], wp[currentFloor][j]["pos"])
                        if (pointDist < self.map.wpMinDist) then
                            tab["result"] = false
                            break
                        else
                            if (minimumDist > pointDist) then
                                minimumDist = pointDist
                            end
                        end
                    end
                end

                if (self.map.wpMaxDist ~= 0 ) then
                    -- wpMaxDist equal to 0 turns off the limitations of max distance between rooms
                    -- todo: one issue, loop j=i
                    if (minimumDist > self.map.wpMaxDist) then
                        --	print("Minimum incorrect for i =" .. i .. ", value: " .. minimumDist)
                        tab["result"] = false
                    end
                end
            end


            if (tab["result"]) then
                table.insert(wp[currentFloor], i, tab)
                -- print("SHOOTED i = " .. i .. " counter = " .. counter .. " wp.x - " .. wp[i][1].x ..", wp.y - " .. wp[i][1].y .. ", wp.z - " .. wp[i][1].z)
            end
        until tab["result"] == true

        if (status == false) then
            break
        end

        counter = 0
        i = i + 1
    until (i > pointsAmount)

    if (status == false) then
        local a = #wp[currentFloor]
        repeat
            table.remove(wp[currentFloor], a)
            a = a - 1
        until (a == 0)
        self:createWaypoints(wp, pointsAmount, startTime, currentFloor)
    else
        self.wayPoints = wp[currentFloor]
        print("Waypoints created, execution time: ".. os.clock() - startTime)
    end
end

function WayPointer:createWaypointsAlternatively(pointsAmount, currentFloor) -- performance improvement ~40% in comparison to original method
	currentFloor = currentFloor or self.map.mainPos.z
	if (self.wayPoints ~= nil and
		self.wayPoints[currentFloor] ~= nil and
		#self.wayPoints[currentFloor] > 0
	) then
		-- multi-floor, respect waypoints already present
		pointsAmount = pointsAmount - #self.wayPoints[currentFloor]
	else
		self.wayPoints[currentFloor] = {}
	end

    -- does not handle the wpMaxDist
    local startTime = os.clock()
    local availableMapTilesTab = {}
    for i = self.map.pos.y + 9, self.map.pos.y + self.map.sizeY - 9 do -- 9 is safety offset, to prevent the situation where room exceeds map area todo: should be dynamic
        for j = self.map.pos.x + 9, self.map.pos.x + self.map.sizeX - 9 do -- 9 is safety offset, to prevent the situation where room exceeds map area todo: should be dynamic
			table.insert(
				availableMapTilesTab,
				{x = j, y = i, z = currentFloor}
			)
        end
    end

    -- print("Initial availableMapTilesTab length: " .. #availableMapTilesTab)
    local wpCounter = 1
    repeat
        -- print("Creating waypoint: " .. wpCounter .. ", memory usage: " .. round(collectgarbage("count"), 3) .. ' kB')
        -- print("Current availableMapTilesTab length: " .. #availableMapTilesTab .. ", wpCounter: " .. wpCounter)
        if (#availableMapTilesTab < 1) then
            error("Can not create more waypoints, with given wpMinDist parameter." ..
                    " Please, change the configuration")
            break
        end
        local randomIndex = math.random(1, #availableMapTilesTab)
        local randomPos = {
            x = availableMapTilesTab[randomIndex].x,
            y = availableMapTilesTab[randomIndex].y,
            z = currentFloor
        }

        local i = 1
        while i <= #availableMapTilesTab do
            if (pointDistance(randomPos, availableMapTilesTab[i]) < self.map.wpMinDist) then
                table.remove(availableMapTilesTab, i)
            else
                i = i + 1
            end
        end

        -- print("availableMapTilesTab count: " .. #availableMapTilesTab .. " after removal")
        -- makeSquare(419, randomPos) -- points the waypoint

        table.insert(self.wayPoints[currentFloor], {["pos"] = randomPos, ["result"] = true}) -- true <- backward compatibility (some legacy)
        wpCounter = wpCounter + 1
    until wpCounter > pointsAmount

    print("Available map tiles for potential new wayPoints count: " .. #availableMapTilesTab .. " after the procedure. Floor: " .. currentFloor)
    -- /\ if #availableMapTilesTab is near to 0, reconsider decreasing the value of wpMinDist or increase the map size
    print("Waypoints created alternatively, execution time: ".. os.clock() - startTime)

	if (self.map.sizeZ == 1) then -- todo: an issue when we have multi-floor gen script and we set in it mapSizeZ = 1
		return self.wayPoints[currentFloor] -- backward compatibility
	else
		return self.wayPoints
	end
end

function WayPointer:createPathBetweenWps(itemsTab, currentFloor) -- old, initial own, custom implementation (without tsp usage), deprecated
	currentFloor = currentFloor or self.map.mainPos.z
	local startTime = os.clock()
    local minDist = 9999
    -- distance between first point and the second, before starting loop
    local point1 = self.wayPoints[currentFloor][1]["pos"]
    local point2 = self.wayPoints[currentFloor][2]["pos"]

    print("Creating paths...")
    for i=1, #self.wayPoints[currentFloor] do
        for j=i+1, #self.wayPoints[currentFloor] do
            -- loop checking all distances for point "i"
            -- with the rest of the points
            if (minDist >= pointDistance2(
                    self.wayPoints[currentFloor][i]["pos"],
                    self.wayPoints[currentFloor][j]["pos"]
                )
            ) then
                -- todo: to reconsider is the a point to add equal case
                minDist = pointDistance2(
					self.wayPoints[currentFloor][i]["pos"],
					self.wayPoints[currentFloor][j]["pos"]
                )
                point1 = self.wayPoints[currentFloor][i]["pos"]
                point2 = self.wayPoints[currentFloor][j]["pos"]
                -- print("Connection i-" ..i.. " z  j-" ..j.. ", distance between them: "..minDist)
            end
        end
        minDist = 9999
        --print('__________ Connecting: ')
        --print(dumpVar(point1))
        --print(dumpVar(point2))
        self:_createPathBetweenTwoPoints(itemsTab, point1, point2, currentFloor)
    end
    print("Paths between waypoints created, execution time: " .. os.clock() - startTime)
end

-- private
function WayPointer:_createPathBetweenTwoPoints(itemsTab, pos1, pos2, currentFloor)
    -- todo: BUG, something in this function sometimes goes outside the expected ground area
    -- todo: most likely in fact it does not create paths as expected
    local case = math.random(1,2)
    local pom = 0
    local cr = self.cursor
    local brush = Brush.new()

    if (case == 1) then -- case one, moving firstly by x-axis
        cr:setPos(pos1.x, pos1.y, pos1.z)

        repeat -- moving by x-axis
            pom = cr.pos.x - pos2.x
            if (pom < 0) then
                cr:right(1)
                for i=1, #self.wayPoints[currentFloor] do
                    if (cr.pos ~= self.wayPoints[currentFloor][i]["pos"]) then
                        brush:doBrushLines(itemsTab, 3, cr.pos, 0)
                    end
                end
            elseif (pom > 0) then
                cr:left(1)
                for i=1, #self.wayPoints[currentFloor] do
                    if (cr.pos ~= self.wayPoints[currentFloor][i]["pos"]) then
                        brush:doBrushLines(itemsTab, 3, cr.pos, 0)
                    end
                end
            elseif (pom == 0)then
                break
            end
        until (cr.pos.x == pos2.x)

        brush:doBrushSquares(itemsTab, 3, cr.pos)
        -- doCreateItemMock(598, 1, cr.pos) -- points the crossing

        cr:setPos(pos2.x, pos1.y, pos1.z)

        repeat -- moving by y-axis
            pom = cr.pos.y - pos2.y
            if (pom < 0) then
                cr:down(1)
                for i=1, #self.wayPoints[currentFloor] do
                    if (cr.pos ~= self.wayPoints[currentFloor][i]["pos"]) then
                        brush:doBrushLines(itemsTab, 3, cr.pos, 1)
                    end
                end
            elseif (pom > 0) then
                cr:up(1)
                for i=1, #self.wayPoints[currentFloor] do
                    if (cr.pos ~= self.wayPoints[currentFloor][i]["pos"]) then
                        brush:doBrushLines(itemsTab, 3, cr.pos, 1)
                    end
                end
            elseif (pom == 0)then
                break
            end
        until (cr.pos.y == pos2.y)

        brush:doBrushSquares(itemsTab, 3, cr.pos)
        --doCreateItemMock(598, 1, cr.pos) -- points the crossing

    else

        cr:setPos(pos2.x, pos1.y, pos1.z)

        repeat -- moving by y-axis
            pom = cr.pos.y - pos2.y
            if (pom < 0) then
                cr:down(1) -- todo: there can be an issue in method, with parameters
                for i=1, #self.wayPoints[currentFloor] do
                    if (cr.pos ~= self.wayPoints[currentFloor][i]["pos"]) then
                        brush:doBrushLines(itemsTab, 3, cr.pos, 1)
                    end
                end
            elseif (pom > 0) then
                cr:up(1)
                for i=1, #self.wayPoints[currentFloor] do
                    if (cr.pos ~= self.wayPoints[currentFloor][i]["pos"]) then
                        brush:doBrushLines(itemsTab, 3, cr.pos, 1)
                    end
                end
            elseif (pom == 0) then
                break
            end
        until (cr.pos.y == pos2.y)

        brush:doBrushSquares(itemsTab, 3, cr.pos)

        --doCreateItemMock(598, 1, cr.pos) -- points the crossing

        cr:setPos(pos1.x, pos1.y, pos1.z)

        repeat -- moving by x-axis
            pom = cr.pos.x - pos2.x
            if (pom < 0) then
                cr:right(1)
                for i=1, #self.wayPoints[currentFloor] do
                    if (cr.pos ~= self.wayPoints[currentFloor][i]["pos"]) then
                        brush:doBrushLines(itemsTab, 3, cr.pos, 0)
                    end
                end
            elseif (pom > 0) then
                cr:left(1)
                for i=1, #self.wayPoints[currentFloor] do
                    if (cr.pos ~= self.wayPoints[currentFloor][i]["pos"]) then
                        brush:doBrushLines(itemsTab, 3, cr.pos, 0)
                    end
                end
            elseif (pom == 0) then
                break
            end
        until (cr.pos.x == pos2.x)

        brush:doBrushSquares(itemsTab, 3, cr.pos)
        --doCreateItemMock(598, 1, cr.pos) -- points the crossing
    end
end

function WayPointer:createPathBetweenWpsTSP(itemsTab, brushSize, currentFloor)
	currentFloor = currentFloor or self.map.mainPos.z
	brushSize = brushSize or 3
    local startTime = os.clock()
    local tsp = TSP.new(self.wayPoints[currentFloor])
    -- looks like original TSP is actually faster than TSPSA,
    -- TSPSA efficiency can not be easily predicted
    print("TSP running for floor: " .. currentFloor .. "...")
    local bestPaths, minDistance = tsp:solve()
    if not bestPaths then return print("TSP could not generate best paths.") end

    print("Creating paths for floor: " .. currentFloor .. "...")
    for i = 1, #bestPaths - 1 do
        local pos1 = self.wayPoints[currentFloor][bestPaths[i]]["pos"]
        local pos2 = self.wayPoints[currentFloor][bestPaths[i + 1]]["pos"]
        self:_createPathBetweenTwoPointsTSP(itemsTab, pos1, pos2, brushSize, currentFloor)
    end

    -- Connect the last point to the first to complete the cycle
    --local lastPos = self.wayPoints[currentFloor][bestPaths[#bestPaths]]["pos"]
    --local firstPos = self.wayPoints[currentFloor][bestPaths[1]]["pos"]
    --self:_createPathBetweenTwoPointsTSP(itemsTab, lastPos, firstPos)
    print("Paths between waypoints for floor: " .. currentFloor .. " created, execution time: " .. os.clock() - startTime)
end

function WayPointer:createPathBetweenWpsTSPMS(itemsTab, brushSize)
    local startTime = os.clock()
    local travellersCounts = 3
    local centralPoint = findCentralWayPoint(self.wayPoints)
    local tspms = TSPMS.new(self.wayPoints, travellersCounts, centralPoint)
    print("TSPMS running...")
    local bestPaths, minDistance = tspms:solve()
    if not bestPaths then return print("TSPMS could not generate best paths.") end

    print("Creating paths...")

    for i = 1, travellersCounts do
        for j = 1, #bestPaths - 1 do
            local pos1 = self.wayPoints[bestPaths[i][j]][1]
            local pos2 = self.wayPoints[bestPaths[i][j + 1]][1]

            self:_createPathBetweenTwoPointsTSP(itemsTab, pos1, pos2, brushSize)
        end
    end

    print("Paths between waypoints created, execution time: " .. os.clock() - startTime)
end

function WayPointer:getCentralWaypointForNextFloor(promotedWaypoints, wayPoints, currentFloor, isRandomQuadrant)
	-- todo: issue, it can rarely create two stairs on close floor, at the same positions (e.g. elevation between floors: 5,6,7...)
	-- return wayPoint nearest to the center, from random quadrant if requested
	if (isRandomQuadrant == true) then
		return self:_promoteCentralWaypoint(promotedWaypoints, wayPoints, currentFloor, math.random(1,4))
	end

	return self:_promoteClosestToCenter(promotedWaypoints, wayPoints, currentFloor)
end

function WayPointer:getExternalWaypointForNextFloor(promotedWaypoints, wayPoints, currentFloor, quadrantNumber)
	-- todo: issue, it can rarely create two stairs on close floor, at the same positions (e.g. elevation between floors: 5,6,7...)
	-- return wayPoint further from the center, from specific quadrant if requested
	if (quadrantNumber ~= nil) then
		return self:_promoteExternalWaypoint(promotedWaypoints, wayPoints, currentFloor, quadrantNumber)
	end

	return self:_promoteFurtherFromCenter(promotedWaypoints, wayPoints, currentFloor)
end

function WayPointer:_createPathBetweenTwoPointsTSP(itemsTab, pos1, pos2, brushSize, currentFloor)
    local cr = self.cursor
	cr.z = currentFloor -- watch out
    local brush = Brush.new()

    local function moveCursorAndBrush(startPos, endPos, axis)
        local step = (startPos < endPos) and 1 or -1
        local currentPos = startPos

        while currentPos ~= endPos do
            currentPos = currentPos + step
            if axis == "x" then
                cr:setPos(currentPos, cr.pos.y, cr.pos.z)
            else
                cr:setPos(cr.pos.x, currentPos, cr.pos.z)
            end

            for i = 1, #self.wayPoints[currentFloor] do
                if cr.pos ~= self.wayPoints[currentFloor][i]["pos"] then
                    brush:doBrushLines(itemsTab, brushSize, cr.pos, (axis == "x") and 0 or 1)
                end
            end
        end

        brush:doBrushSquares(itemsTab, brushSize, cr.pos)
    end

    cr:setPos(pos1.x, pos1.y, pos1.z)

    -- Move along x-axis
    moveCursorAndBrush(pos1.x, pos2.x, "x")

    -- Move along y-axis
    moveCursorAndBrush(pos1.y, pos2.y, "y")
end

function WayPointer:_promoteCentralWaypoint(promotedWaypoints, wayPoints, currentFloor, quadrantNumber)
	if #wayPoints[currentFloor] == 0 then
		error("Empty input wayPoints array.")
	end
	local centerX, centerY = self:_getCentralAxes(wayPoints[currentFloor])

	for _, waypoint in ipairs(wayPoints[currentFloor]) do
		local centralPoint = nil
		local x, y = waypoint.pos.x, waypoint.pos.y
		if quadrantNumber == 1 and x >= centerX and y <= centerY then
			centralPoint = waypoint
		elseif quadrantNumber == 2 and x <= centerX and y <= centerY then
			centralPoint = waypoint
		elseif quadrantNumber == 3 and x <= centerX and y >= centerY then
			centralPoint = waypoint
		elseif quadrantNumber == 4 and x >= centerX and y >= centerY then
			centralPoint = waypoint
		end

		-- todo: fix

		if (centralPoint ~= nil) then
			return {
				["pos"] = {
					x = centralPoint.pos.x,
					y = centralPoint.pos.y,
					z = centralPoint.pos.z + 1
				},
				["room_shape"] = nil,
				["room_height"] = nil,
				["room_width"] = nil
			}
		end
	end

	error("Could not get central waypoint for given quadrant: " ..
		dumpVar(quadrantNumber, true)
	)
end

function WayPointer:_promoteClosestToCenter(promotedWaypoints, wayPoints, currentFloor)
	if #wayPoints[currentFloor] == 0 then
		error("Empty input wayPoints array.")
	end

	local centerX, centerY = self:_getCentralAxes(wayPoints[currentFloor])
	local closestPointToCenter = nil
	local minDistance = math.huge

	-- Find the closest point to the center
	for _, point in ipairs(wayPoints[currentFloor]) do
		local x, y = point.pos.x, point.pos.y
		local distance = math.sqrt((x - centerX)^2 + (y - centerY)^2)

		if distance < minDistance then
			minDistance = distance
			closestPointToCenter = point
		end
	end

	return {
		["pos"] = {
			x = closestPointToCenter.pos.x,
			y = closestPointToCenter.pos.y,
			z = closestPointToCenter.pos.z + 1
		},
		["room_shape"] = nil,
		["room_height"] = nil,
		["room_width"] = nil
	}
end

function WayPointer:_promoteExternalWaypoint(promotedWaypoints, wayPoints, currentFloor, quadrantNumber)
	if #wayPoints[currentFloor] == 0 then
		error("Empty input wayPoints array.")
	end

	local centerX, centerY = self:_getCentralAxes(wayPoints[currentFloor])
	local farthestPoint = nil
	local maxDistance = -math.huge

	-- Determine the farthest point in the specified quadrant
	for _, point in ipairs(wayPoints[currentFloor]) do
		local x, y = point.pos.x, point.pos.y
		local distance = math.sqrt((x - centerX)^2 + (y - centerY)^2)

		-- Check if the point is in the specified quadrant
		local inQuadrant = false
		if quadrantNumber == 1 and x >= centerX and y <= centerY then
			inQuadrant = true
		elseif quadrantNumber == 2 and x <= centerX and y <= centerY then
			inQuadrant = true
		elseif quadrantNumber == 3 and x <= centerX and y >= centerY then
			inQuadrant = true
		elseif quadrantNumber == 4 and x >= centerX and y >= centerY then
			inQuadrant = true
		end

		-- If the point is in the quadrant and is the farthest found so far, update the farthest point
		if inQuadrant and distance > maxDistance then
			maxDistance = distance
			farthestPoint = point
		end
	end

	return {
		["pos"] = {
			x = farthestPoint.pos.x,
			y = farthestPoint.pos.y,
			z = farthestPoint.pos.z + 1
		},
		["room_shape"] = nil,
		["room_height"] = nil,
		["room_width"] = nil
	}
end

function WayPointer:_promoteFurtherFromCenter(promotedWaypoints, wayPoints, currentFloor)
	if #wayPoints[currentFloor] == 0 then
		error("Empty input wayPoints array.")
	end

	local centerX, centerY = self:_getCentralAxes(wayPoints[currentFloor])
	local farthestPoint = nil
	local maxDistance = -math.huge

	-- Find the further point from the center
	for _, point in ipairs(wayPoints[currentFloor]) do
		local x, y = point.pos.x, point.pos.y
		local distance = math.sqrt((x - centerX)^2 + (y - centerY)^2)

		if distance > maxDistance then
			maxDistance = distance
			farthestPoint = point
		end
	end

	return {
		["pos"] = {
			x = farthestPoint.pos.x,
			y = farthestPoint.pos.y,
			z = farthestPoint.pos.z + 1
		},
		["room_shape"] = nil,
		["room_height"] = nil,
		["room_width"] = nil
	}
end

function WayPointer:_getCentralAxes(points)
	local centerX, centerY = 0, 0
	local totalX, totalY, count = 0, 0, 0

	-- Calculate the center of all waypoints if central point selection is enabled
	for _, point in ipairs(points) do
		totalX = totalX + point.pos.x
		totalY = totalY + point.pos.y
		count = count + 1
	end

	if count > 0 then
		centerX = totalX / count
		centerY = totalY / count

		return totalX / count, totalY / count
	end

	return nil, nil
end
