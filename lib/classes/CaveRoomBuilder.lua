CaveRoomBuilder = {}
CaveRoomBuilder.__index = CaveRoomBuilder

function CaveRoomBuilder.new(map, wayPoints)
    local instance = setmetatable({}, CaveRoomBuilder)
	instance.map = map
    instance.wayPoints = wayPoints

    return instance
end

function CaveRoomBuilder:createRooms(
	itemsTab,
	approximatedWidth,
	approximatedHeight,
	currentFloor
)
    local startTime = os.clock()
	local wayPoints = self.wayPoints
	if (self.map.sizeZ > 1 and
		currentFloor ~= nil and
		self.wayPoints[currentFloor] ~= nil
	) then
		wayPoints = self.wayPoints[currentFloor]
	end

    for _, waypoint in pairs(wayPoints) do
        local newWidthMin = math.floor((approximatedWidth/3)*2)
        local newHeightMin = math.floor((approximatedHeight/3)*2)
        local newWidthMax = math.floor((approximatedWidth/3)*4)
        local newHeightMax = math.floor((approximatedHeight/3)*4)

        local newWidth = math.random(newWidthMin, newWidthMax)
        local newHeight = math.random(newHeightMin, newHeightMax)
        self:_createRoom(itemsTab, waypoint["pos"], newWidth, newHeight)
    end

    print("Rooms created, execution time: " .. os.clock() - startTime)
end

-- private
function CaveRoomBuilder:_createRoom(itemsTab, centerPos, width, height)
    --local startTime = os.clock()
    local pom = {}
    pom.x = centerPos.x
    pom.y = centerPos.y
    pom.z = centerPos.z

    local heightEven = (height % 2)
    local widthEven = (width % 2)
    local a = 0
    local b = 0
    -- sets the pom
    if (heightEven == 0) then -- even height of the room
        pom.y = (pom.y - (height / 2) + 1 ) -- + math.random(0,1)
        a = math.floor(height / 2)
    elseif (heightEven == 1) then
        pom.y = (pom.y - (height / 2) + 0.5)
        a = math.floor(height / 2)
    end

    if (widthEven == 0) then -- even width of the room
        pom.x = (pom.x - (width / 2) + 1 ) -- + math.random(0,1)
        b = math.floor(width / 2)
    elseif (widthEven == 1) then
        pom.x = (pom.x - (width / 2) + 0.5)
        b = math.floor(width / 2)
    end

    for i=1, height do
        for j=1, width do
            --	print("Pom.x^2 : " .. math.pow((centerPos.x - pom.x),2) .. ", a^2 : " .. math.pow(a,2) )
            --	print("Pom.y^2 : " .. math.pow((centerPos.y - pom.y),2) .. ", b^2 : " .. math.pow(b,2) )
            local expression = (
                (
                    (math.pow((centerPos.x - pom.x),2) / math.pow(a,2)) +
                            (math.pow((centerPos.y - pom.y),2) / math.pow(b,2))
                ) - 1
            ) -- expression most likely working

            -- print("Expression : " .. expression)
            if (expression <= 0) then
                doCreateItemMock(itemsTab[1][1], 1, pom)
            --else
            --    doCreateItemMock(231, 1, pom)
            end
            pom.x = pom.x + 1
        end
        pom.x = pom.x - width
        pom.y = pom.y + 1
    end

    -- doCreateItemMock(600, 1, centerPos) -- points the center, lava
    ---------------
    --print("Single room created, execution time: " .. os.clock() - startTime)
end
