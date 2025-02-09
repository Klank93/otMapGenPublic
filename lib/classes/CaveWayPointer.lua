CaveWayPointer = {}
CaveWayPointer.__index = CaveWayPointer

function CaveWayPointer.new(map, cursor, wayPoints, brush)
    local instance = setmetatable(CaveWayPointer, WayPointer)
    instance.map = map
    instance.cursor = cursor
    instance.wayPoints = wayPoints
    instance.brush = brush

    return instance
end

function CaveWayPointer:createPathBetweenWpsTSP(itemsTab, brushSize)
    local startTime = os.clock()
    local tsp = TSP.new(self.wayPoints)
    print("TSP running...")
    local bestPaths, minDistance = tsp:solve()

    if not bestPaths then return end

    print("Creating paths...")
    for _, path in ipairs(bestPaths) do
        for i = 1, #path - 1 do
            local point1 = self.wayPoints[path[i]][1]
            local point2 = self.wayPoints[path[i + 1]][1]

            self:_connectTwoPoints(itemsTab, point1, point2, brushSize)
        end
    end
    print("Paths created in " .. os.clock() - startTime .. " seconds.")
end

function CaveWayPointer:createPathBetweenWpsTSPMS(itemsTab, brushSize, travellersCount, currentFloor)
	currentFloor = currentFloor or self.map.mainPos.z
    local startTime = os.clock()
    -- Uses the TSP class for multiple salesmen, to find the most optimal paths between wayPoints

	local centralPoint = findCentralWayPoint(self.wayPoints[currentFloor])

    local tspms = TSPMS.new(self.wayPoints[currentFloor], travellersCount, centralPoint)
    print("TSPMS running...")
    local bestPaths, minDistances = tspms:solve()

    --print(dumpVar(bestPaths))

    print("Creating paths...")
    for _, path in ipairs(bestPaths) do
        for i = 1, #path - 1 do
            local point1 = self.wayPoints[currentFloor][path[i]]["pos"]
            local point2 = self.wayPoints[currentFloor][path[i + 1]]["pos"]

            self:_connectTwoPoints(itemsTab, point1, point2, brushSize)
        end
    end
    print("Paths created in " .. os.clock() - startTime .. " seconds.")
end

-- private
function CaveWayPointer:_connectTwoPoints(itemsTab, point1, point2, brushSize)
    local newPos = {}
    local dist = pointDistance2(point1, point2)
    local triesCount = math.floor(dist / (self.map.wpMinDist/2) ) -- const
    --print("Dist : " .. dist .. " how many tries : " .. triesCount)
    --print("Connects  :  x = " .. point1.x .. ", y = " .. point1.y .. ", z = " .. point1.z)

    if (triesCount >= 2) then
        local pos1 = {
            x = point1.x,
            y = point1.y,
            z = point1.z
        }
        local moveX = math.floor(-(pos1.x - point2.x) / triesCount)
        local moveY = math.floor(-(pos1.y - point2.y) / triesCount)

        --print("Move by x: " .. moveX .. " , move by y:" .. moveY)
        for k = 1, triesCount - 1 do
            local min1 = 0
            local max1 = 0
            if (moveX > moveY) then
                min1 = math.abs(math.floor(moveX/3))
                max1 = math.abs(math.floor(moveX/2))
            else
                min1 = math.abs(math.floor(moveY/3))
                max1 = math.abs(math.floor(moveY/2))
            end

            --print(" : min - " .. min1 .. ", max - " .. max1)

            local deflectionX = (
                    math.random(min1, max1) * math.pow(-1, math.random(0,1))
            )
            local deflectionY = (
                    math.random(min1, max1) * math.pow(-1, math.random(0,1))
            )

            --print("Odchylenie X: " .. deflectionX .. " , odchylenie Y : " .. deflectionY)

            newPos.x = ((pos1.x + moveX) + deflectionX)
            newPos.y = ((pos1.y + moveY) + deflectionY)
            newPos.z = pos1.z

            --print("Newpos  :  x = " .. newPos.x .. ", y = " .. newPos.y .. ", z = " .. newPos.z .. " ")

            if ((newPos.x > (self.map.mainPos.x + self.map.sizeX)) or
                    (newPos.x < (self.map.mainPos.x))
            ) then -- todo: bug, path out of the map
                print("\nExceeded X !!!!!!\n")
            elseif ((newPos.y > (self.map.mainPos.y + self.map.sizeY)) or
                    (newPos.y < (self.map.mainPos.y))
            ) then -- todo: bug, path out of the map
                print("\nExceeded Y !!!!!!\n")
            end

            self:_createPathBetweenTwoPoints(itemsTab, pos1, newPos, brushSize)

            pos1.x = newPos.x
            pos1.y = newPos.y
            pos1.z = newPos.z

            dist = pointDistance2(newPos, point2)
        end

        self:_createPathBetweenTwoPoints(itemsTab, pos1, point2, brushSize)
    else
        -- incorrect dist
        self:_createPathBetweenTwoPoints(itemsTab, point1, point2, brushSize)
    end
end

-- private
function CaveWayPointer:_createPathBetweenTwoPoints(itemsTab, pos1, pos2, brushSize)
    if self.brush == nil then
        error("Brush property is null. Could not create paths.")
    end
    local case = math.random(1,1)
    local pom = {}
    pom.x = pos1.x
    pom.y = pos1.y
    pom.z = pos1.z

    --doCreateItemMock(6353, 1, pos1)
    if (case == 1) then -- case moving at first by axis-x
        repeat
            local directionX = pom.x - pos2.x
            local directionY = pom.y - pos2.y

            if (directionX > 0) then -- left
                if (directionY > 0) then
                    pom.y = pom.y - 1 -- up
                    --	print("Up-Left")
                    self.brush:doBrushSquares(itemsTab[1], brushSize, pom)
                elseif (directionY < 0) then
                    pom.y = pom.y + 1 -- down
                    --	print("Down-Left")

                    self.brush:doBrushSquares(itemsTab[1], brushSize, pom)
                end
                pom.x = pom.x - 1
                --	print("Left")
                self.brush:doBrushSquares(itemsTab[1], brushSize, pom)
            elseif (directionX < 0) then -- right
                if (directionY > 0) then
                    pom.y = pom.y - 1 -- up
                    --	print("Up-Right")

                    self.brush:doBrushSquares(itemsTab[1], brushSize, pom)
                elseif (directionY < 0) then
                    pom.y = pom.y + 1 -- down
                    --	print("Down-Right")

                    self.brush:doBrushSquares(itemsTab[1], brushSize, pom)
                end
                pom.x = pom.x + 1
                --	print("Right")
                self.brush:doBrushSquares(itemsTab[1], brushSize, pom)
            else -- x in the same line
                if (directionY > 0) then
                    pom.y = pom.y - 1 -- up
                    --	print("Up")
                elseif (directionY < 0) then
                    pom.y = pom.y + 1 -- down
                    --	print("Down")
                end

                self.brush:doBrushSquares(itemsTab[1], brushSize, pom)
            end
        until (pom.x == pos2.x and pom.y == pos2.y)
    end
    --doCreateItemMock(6353, 1, pos1)
end
