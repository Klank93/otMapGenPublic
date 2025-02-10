DungeonRoomBuilder = {}
DungeonRoomBuilder.__index = DungeonRoomBuilder

function DungeonRoomBuilder.new(map, wayPoints)
    local instance = setmetatable({}, DungeonRoomBuilder)
	instance.map = map
    instance.wayPoints = wayPoints

    return instance
end

function DungeonRoomBuilder:createRooms(itemsTab, roomShapes, currentFloor)
    local startTime = os.clock()
	local wayPoints = self.wayPoints
	if (self.map.sizeZ > 1 and
		currentFloor ~= nil and
		self.wayPoints[currentFloor] ~= nil
	) then
		wayPoints = self.wayPoints[currentFloor]
	end

    for a = 1, #wayPoints do
        local randValue = math.random(1,#roomShapes)
        local pom = {}
        local evenHeight = (roomShapes[randValue].height % 2)
        local evenWidth = (roomShapes[randValue].width % 2)

        pom.x = wayPoints[a]["pos"].x
        pom.y = wayPoints[a]["pos"].y
        pom.z = wayPoints[a]["pos"].z

		wayPoints[a]["room_shape"] = randValue
		wayPoints[a]["room_height"] = roomShapes[randValue].height
		wayPoints[a]["room_width"] = roomShapes[randValue].width

        if (evenHeight == 0) then -- even height of the room
            pom.y = (pom.y - (roomShapes[randValue].height / 2) + 1 ) -- + math.random(0,1)
        elseif (evenHeight == 1) then
            pom.y = (pom.y - (roomShapes[randValue].height / 2) + 0.5)
        end

        if (evenWidth == 0) then -- even width of the room
            pom.x = (pom.x - (roomShapes[randValue].width / 2) + 1 ) -- + math.random(0,1)
        elseif (evenWidth == 1) then
            pom.x = (pom.x - (roomShapes[randValue].width / 2) + 0.5)
        end

        for i=1, roomShapes[randValue].height do
            for j=1, roomShapes[randValue].width do
                if (roomShapes[randValue].shape[i][j] ~= 0) then
                    doCreateItemMock(itemsTab[1][1], 1, pom)
                end
                pom.x = pom.x + 1
            end
            pom.x = pom.x - roomShapes[randValue].width
            pom.y = pom.y + 1
        end
    end

    print("Rooms created, execution time: " .. os.clock() - startTime)
end
