-- not recommended, creates ugly shapes
do return end

-- Definition of class TSPMS
-- tsp heuristic nearest neighbor algorithm with multiple travellers
TSPMS = {}
TSPMS.__index = TSPMS

-- Constructor for the TSPMS class
function TSPMS.new(wayPoints, numSalesmen, startPoint)
    local instance = setmetatable({}, TSPMS)
    instance.wayPoints = wayPoints
    instance.numSalesmen = numSalesmen
    instance.startPoint = startPoint
    instance.bestPaths = {}
    instance.minDistances = {}
    for i = 1, numSalesmen do
        table.insert(instance.bestPaths, {})
        table.insert(instance.minDistances, 0)
    end
    return instance
end

-- Method to solve the TSPMS for multiple salesmen
function TSPMS:solve()
    local n = #self.wayPoints
    if n == 0 then return nil, 0 end

    local visited = {}
    for i = 1, n do visited[i] = false end
    visited[self.startPoint] = true

    local currentSalesman = 1
    local currentPoint = self.startPoint

    while true do
        local nearestNeighbor = nil
        local minDistance = math.huge

        for i = 1, n do
            if not visited[i] then
                local dist = pointDistance(self.wayPoints[currentPoint][1], self.wayPoints[i][1])
                if dist < minDistance then
                    nearestNeighbor = i
                    minDistance = dist
                end
            end
        end

        if nearestNeighbor == nil then
            break
        end

        table.insert(self.bestPaths[currentSalesman], nearestNeighbor)
        self.minDistances[currentSalesman] = self.minDistances[currentSalesman] + minDistance
        visited[nearestNeighbor] = true
        currentPoint = nearestNeighbor

        currentSalesman = currentSalesman % self.numSalesmen + 1
    end

    return self.bestPaths, self.minDistances
end

-- Method to print the result
function TSPMS:printResult()
    for i = 1, self.numSalesmen do
        print(string.format("Best path for salesman %d:", i))
        for _, index in pairs(self.bestPaths[i]) do
            local point = self.wayPoints[index][1]
            print(string.format(
                    "Waypoint: %s - (x = %d, y = %d, z = %d)",
                    index,
                    point.x,
                    point.y,
                    point.z
                )
            )
        end
        print("Minimum distance: " .. self.minDistances[i])
    end
end