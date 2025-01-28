-- Define the TSP class
-- tsp simulated annealing algorithm
TSPSA = {}
TSPSA.__index = TSPSA

-- Constructor for the TSPSA class
function TSPSA.new(wayPoints)
    local instance = setmetatable({}, TSPSA)
    instance.wayPoints = wayPoints
    instance.bestPath = nil
    instance.minDistance = math.huge
    return instance
end

-- Method to calculate the distance between two points (ignoring z coordinate)
function TSPSA:distance(point1, point2)
    return math.sqrt((point1[1].x - point2[1].x)^2 + (point1[1].y - point2[1].y)^2)
end

-- Method to calculate the total distance of a given path
function TSPSA:calculateTotalDistance(path)
    local totalDistance = 0
    for i = 1, #path - 1 do
        totalDistance = totalDistance + self:distance(
                self.wayPoints[path[i]],
                self.wayPoints[path[i + 1]]
        )
    end
    totalDistance = totalDistance + self:distance(
            self.wayPoints[path[#path]],
            self.wayPoints[path[1]]
    )
    return totalDistance
end

-- Method to solve the TSPSA using simulated annealing
function TSPSA:solve()
    local function copyPath(path)
        local newPath = {}
        for i, v in ipairs(path) do
            newPath[i] = v
        end
        return newPath
    end

    local function swapTwoCities(path)
        local i, j = math.random(1, #path), math.random(1, #path)
        path[i], path[j] = path[j], path[i]
    end

    local n = #self.wayPoints
    local currentPath = {}
    for i = 1, n do table.insert(currentPath, i) end

    local currentDistance = self:calculateTotalDistance(currentPath)
    local bestPath = copyPath(currentPath)
    local bestDistance = currentDistance

    local temperature = 10000
    local coolingRate = 0.003

    while temperature > 1 do
        local newPath = copyPath(currentPath)
        swapTwoCities(newPath)

        local newDistance = self:calculateTotalDistance(newPath)
        if newDistance < currentDistance or
                math.exp((currentDistance - newDistance) / temperature) > math.random()
        then
            currentPath = newPath
            currentDistance = newDistance
        end

        if currentDistance < bestDistance then
            bestPath = copyPath(currentPath)
            bestDistance = currentDistance
        end

        temperature = temperature * (1 - coolingRate)
    end

    self.bestPath = bestPath
    self.minDistance = bestDistance

    return self.bestPath, self.minDistance
end

-- Method to print the result
function TSPSA:printResult()
    print("Best path:")
    for _, index in pairs(self.bestPath) do
        local point = self.wayPoints[index][1]
        print(string.format("Waypoint: %s - (%d, %d, %d)", index, point.x, point.y, point.z))
    end
    print("Minimum distance: " .. self.minDistance)
end