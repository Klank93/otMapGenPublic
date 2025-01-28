-- Define the TSP class
-- tsp heuristic nearest neighbor algorithm
TSP = {}
TSP.__index = TSP

-- Constructor for the TSP class
function TSP.new(wayPoints)
    local instance = setmetatable({}, TSP)
    instance.wayPoints = wayPoints
    instance.bestPath = nil
    instance.minDistance = math.huge
    return instance
end

-- Method to calculate the distance between two points (ignoring z coordinate)
function TSP:distance(point1, point2)
    return math.sqrt((point1[1].x - point2[1].x)^2 + (point1[1].y - point2[1].y)^2)
end

-- Method to solve the TSP using the nearest neighbor heuristic
function TSP:solve()
    local n = #self.wayPoints
    if n == 0 then return nil, 0 end

    local visited = {}
    for i = 1, n do visited[i] = false end

    local path = {1}  -- start from the first point
    visited[1] = true
    local totalDistance = 0

    for _ = 2, n do
        local last = path[#path]
        local nearest, nearestDist = nil, math.huge
        for i = 1, n do
            if not visited[i] then
                local dist = self:distance(self.wayPoints[last], self.wayPoints[i])
                if dist < nearestDist then
                    nearest, nearestDist = i, dist
                end
            end
        end
        table.insert(path, nearest)
        visited[nearest] = true
        totalDistance = totalDistance + nearestDist
    end

    -- Add the distance from the last point back to the start point
    totalDistance = totalDistance + self:distance(self.wayPoints[path[#path]], self.wayPoints[path[1]])

    self.bestPath = path
    self.minDistance = totalDistance

    return self.bestPath, self.minDistance
end

-- Method to print the result
function TSP:printResult()
    print("Best path:")
    for _, index in pairs(self.bestPath) do
        local point = self.wayPoints[index][1]
        print(string.format("Waypoint: %s - (%d, %d, %d)", index, point.x, point.y, point.z))
    end
    print("Minimum distance: " .. self.minDistance)
end