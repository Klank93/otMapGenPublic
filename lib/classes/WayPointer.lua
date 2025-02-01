WayPointer = {}
WayPointer.__index = WayPointer

function WayPointer.new(map, cursor, wayPoints)
    local instance = setmetatable({}, WayPointer)
    instance.map = map
    instance.cursor = cursor
    instance.wayPoints = defaultParam(wayPoints, {})

    return instance
end

function WayPointer:createWaypoints(wp, pointsAmount, initialTime)
    local startTime = defaultParam(initialTime, os.clock())
    local status = true
    local counter = 0
    local safetyFuse = (self.map.sizeX * self.map.sizeY * 200)
    -- it gives sqm^2 of the maps 100 times, so theoretically in every sqm of the map it will shoot 100 times

    local minPos = {}
    minPos.x = (self.map.pos.x + self.map.wpMinDist)
    minPos.y = (self.map.pos.y + self.map.wpMinDist)
    minPos.z = self.map.pos.z

    local maxPos = {}
    maxPos.x = (self.map.pos.x - self.map.wpMinDist) + self.map.sizeX
    maxPos.y = (self.map.pos.y - self.map.wpMinDist) + self.map.sizeY
    maxPos.z = self.map.pos.z

    -------------------
    local i = 1
    repeat
        repeat -- shooting loop
            local xRand = math.random(minPos.x, maxPos.x)
            local yRand = math.random(minPos.y, maxPos.y)
            local randomPos = {}
            randomPos.x = xRand
            randomPos.y = yRand
            randomPos.z = self.map.pos.z
            local tab = {}

            table.insert(tab, 1, randomPos)
            table.insert(tab, 2, true)
            table.insert(tab, 3, 0) -- todo: what's the point of it?
            table.insert(tab, 4, 0) -- todo: what's the point of it?
            table.insert(tab, 5, 0) -- todo: what's the point of it?

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
                print("TAB : x - " .. tab[1].x .. ", y - " .. tab[1].y .. ", z - " .. tab[1].z .. ", III : " .. tab[3] .. ", IV : " .. tab[4] .. ", V : " .. tab[5])
            end
            ]]--
            if (i ~= 1) then
                local minimumDist = 999999
                for j=1, #wp do
                    if (i ~= j) then
                        local pointDist = pointDistance(tab[1], wp[j][1])
                        if (pointDist < self.map.wpMinDist) then
                            tab[2] = false
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
                        tab[2] = false
                    end
                end
            end


            if (tab[2]) then
                table.insert(wp, i, tab)
                -- print("SHOOTED i = " .. i .. " counter = " .. counter .. " wp.x - " .. wp[i][1].x ..", wp.y - " .. wp[i][1].y .. ", wp.z - " .. wp[i][1].z)
            end
        until tab[2] == true

        if (status == false) then
            break
        end

        counter = 0
        i = i + 1
    until (i > pointsAmount)

    if (status == false) then
        a = #wp
        repeat
            table.remove(wp, a)
            a = a - 1
        until (a == 0)
        self:createWaypoints(wp, pointsAmount, startTime)
    else
        self.wayPoints = wp
        print("Waypoints created, execution time: ".. os.clock() - startTime)
    end
end

function WayPointer:createWaypointsAlternatively(wp, pointsAmount) -- performance improvement ~40% in comparison to original method
    -- does not handle the wpMaxDist
    local startTime = os.clock()
    local availableMapTilesTab = {}
    for i = self.map.pos.y + 9, self.map.pos.y + self.map.sizeY - 9 do
        for j = self.map.pos.x + 9, self.map.pos.x + self.map.sizeX - 9 do
            table.insert(
                    availableMapTilesTab,
                    {x = j, y = i, z = self.map.mainPos.z}
            ) -- todo: no multi-floor
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
            z = self.map.mainPos.z
        } -- todo: no multi-floor

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

        table.insert(wp, {randomPos, true}) -- true <- backward compatibility
        wpCounter = wpCounter + 1
        --availableMapTilesTab = {unpack(availableMapTilesTab, 1, #availableMapTilesTab)} -- ai says, it's not needed
    until wpCounter > pointsAmount

    self.wayPoints = wp
    print("Available map tiles for potential new wayPoints count: " .. #availableMapTilesTab .. " after the procedure.")
    -- /\ if #availableMapTilesTab is near to 0, reconsider decreasing the value of wpMinDist or increase the map size
    print("Waypoints created alternatively, execution time: ".. os.clock() - startTime)
end

function WayPointer:createPathBetweenWps(itemsTab) -- old, initial own, custom implementation (without tsp usage)
    local startTime = os.clock()
    local minDist = 9999
    -- pointDistance2(self.wayPoints[1][1], self.wayPoints[2][1])
    -- distance between first point and the second, before starting loop
    local point1 = self.wayPoints[1][1]
    local point2 = self.wayPoints[2][1]

    print("Creating paths...")
    for i=1, #self.wayPoints do
        for j=i+1, #self.wayPoints do
            -- loop checking all distances for point "i"
            -- with the rest of the points
            if (minDist >= pointDistance2(
                    self.wayPoints[i][1],
                    self.wayPoints[j][1]
                )
            ) then
                -- todo: to reconsider is the a point to add equal case
                minDist = pointDistance2(
                        self.wayPoints[i][1],
                        self.wayPoints[j][1]
                )
                point1 = self.wayPoints[i][1]
                point2 = self.wayPoints[j][1]
                -- print("Connection i-" ..i.. " z  j-" ..j.. ", distance between them: "..minDist)
            end
        end
        minDist = 9999
        --print('__________ Connecting: ')
        --print(dumpVar(point1))
        --print(dumpVar(point2))
        self:_createPathBetweenTwoPoints(itemsTab, point1, point2)
    end
    print("Paths between waypoints created, execution time: " .. os.clock() - startTime)
end

-- private
function WayPointer:_createPathBetweenTwoPoints(itemsTab, pos1, pos2)
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
                for i=1, #self.wayPoints do
                    if (cr.pos ~= self.wayPoints[i][1]) then
                        brush:doBrushLines(itemsTab, 3, cr.pos, 0)
                    end
                end
            elseif (pom > 0) then
                cr:left(1)
                for i=1, #self.wayPoints do
                    if (cr.pos ~= self.wayPoints[i][1]) then
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
                for i=1, #self.wayPoints do
                    if (cr.pos ~= self.wayPoints[i][1]) then
                        brush:doBrushLines(itemsTab, 3, cr.pos, 1)
                    end
                end
            elseif (pom > 0) then
                cr:up(1)
                for i=1, #self.wayPoints do
                    if (cr.pos ~= self.wayPoints[i][1]) then
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
                for i=1, #self.wayPoints do
                    if (cr.pos ~= self.wayPoints[i][1]) then
                        brush:doBrushLines(itemsTab, 3, cr.pos, 1)
                    end
                end
            elseif (pom > 0) then
                cr:up(1)
                for i=1, #self.wayPoints do
                    if (cr.pos ~= self.wayPoints[i][1]) then
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
                for i=1, #self.wayPoints do
                    if (cr.pos ~= self.wayPoints[i][1]) then
                        brush:doBrushLines(itemsTab, 3, cr.pos, 0)
                    end
                end
            elseif (pom > 0) then
                cr:left(1)
                for i=1, #self.wayPoints do
                    if (cr.pos ~= self.wayPoints[i][1]) then
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

function WayPointer:createPathBetweenWpsTSP(itemsTab)
    local startTime = os.clock()
    local tsp = TSP.new(self.wayPoints)
    -- looks like original TSP is actually faster than TSPSA,
    -- TSPSA efficiency can not be easily predicted
    print("TSP running...")
    local bestPaths, minDistance = tsp:solve()

    if not bestPaths then return end

    print("Creating paths...")
    for i = 1, #bestPaths - 1 do
        local pos1 = self.wayPoints[bestPaths[i]][1]
        local pos2 = self.wayPoints[bestPaths[i + 1]][1]
        self:_createPathBetweenTwoPointsTSP(itemsTab, pos1, pos2)
    end

    -- Connect the last point to the first to complete the cycle
    --local lastPos = self.wayPoints[bestPaths[#bestPaths]][1]
    --local firstPos = self.wayPoints[bestPaths[1]][1]
    --self:_createPathBetweenTwoPointsTSP(itemsTab, lastPos, firstPos)
    print("Paths between waypoints created, execution time: " .. os.clock() - startTime)
end

function WayPointer:createPathBetweenWpsTSPMS(itemsTab)
    local startTime = os.clock()
    local travellersCounts = 3
    local centralPoint = findCentralWayPoint(self.wayPoints)
    local tspms = TSPMS.new(self.wayPoints, travellersCounts, centralPoint)
    print("TSPMS running...")
    local bestPaths, minDistance = tspms:solve()

    if not bestPaths then return end

    print("Creating paths...")

    for i = 1, travellersCounts do
        for j = 1, #bestPaths - 1 do
            local pos1 = self.wayPoints[bestPaths[i][j]][1]
            local pos2 = self.wayPoints[bestPaths[i][j + 1]][1]

            self:_createPathBetweenTwoPointsTSP(itemsTab, pos1, pos2)
        end
    end

    print("Paths between waypoints created, execution time: " .. os.clock() - startTime)
end

function WayPointer:_createPathBetweenTwoPointsTSP(itemsTab, pos1, pos2)
    local cr = self.cursor
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

            for i = 1, #self.wayPoints do
                if cr.pos ~= self.wayPoints[i][1] then
                    brush:doBrushLines(itemsTab, 3, cr.pos, (axis == "x") and 0 or 1)
                end
            end
        end

        brush:doBrushSquares(itemsTab, 3, cr.pos)
    end

    cr:setPos(pos1.x, pos1.y, pos1.z)

    -- Move along x-axis
    moveCursorAndBrush(pos1.x, pos2.x, "x")

    -- Move along y-axis
    moveCursorAndBrush(pos1.y, pos2.y, "y")
end
