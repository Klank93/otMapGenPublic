-- old: "generation_tomb_small.lua"
MAP_CONFIGURATION = {
    schemaFile = 'sandTomb1.lua',
    saveMapFilename = 'sandTomb70',
    mainPos = {x = 145, y = 145, z = 7},
    mapSizeX = 70,
    mapSizeY = 70,
	mapSizeZ = 3, -- if set to greater than 1 => multi floor
    wpMinDist = 11,
    wayPointsCount = 18
}
LOG_TO_FILE = MAP_GEN_CFG.logToFile -- can be overridden for specific script
DEBUG_OUTPUT = MAP_GEN_CFG.debugOutput -- can be overridden for specific script

local mainPos = {
    x = MAP_CONFIGURATION.mainPos.x,
    y = MAP_CONFIGURATION.mainPos.y,
    z = MAP_CONFIGURATION.mainPos.z
}
local mapSizeX = MAP_CONFIGURATION.mapSizeX
local mapSizeY = MAP_CONFIGURATION.mapSizeY
local mapSizeZ = MAP_CONFIGURATION.mapSizeZ
local wpMinDist = MAP_CONFIGURATION.wpMinDist
local wayPointsCount = MAP_CONFIGURATION.wayPointsCount
local wayPoints = {}
local generatedMap = GroundMapper

local script = {}

loadSchemaFile() -- loads the schema file from map configuration with specific global ITEMS_TABLE

function script.run()
	local promotedWaypoints = {}
	generatedMap = GroundMapper.new(mainPos, mapSizeX, mapSizeY, mapSizeZ, wpMinDist)
	for currentFloor = mainPos.z - (mapSizeZ - 1), mainPos.z do -- multi-floor (it's working in ascending order, from upper floors to lower ones)
		print('\n###########################>>>> Processing Floor: ' .. currentFloor)

		------ Base stuff
		generatedMap:doMainGround(ITEMS_TABLE, currentFloor)

		if (promotedWaypoints[currentFloor] ~= nil) then -- necessary addition for multi floor
			wayPoints[currentFloor] = arrayMerge({}, promotedWaypoints[currentFloor])
		end

		local cursor = Cursor.new(mainPos)
		local wayPointer = WayPointer.new(generatedMap, cursor, wayPoints)
		wayPoints = wayPointer:createWaypointsAlternatively(wayPointsCount, currentFloor)

		--print('Length: ' .. #wayPoints)
		--sortWaypoints(wayPoints)
		--print(dumpVar(wayPoints))

		wayPointer:createPathBetweenWps(ITEMS_TABLE, currentFloor)

		local dungeonRoomBuilder = DungeonRoomBuilder.new(generatedMap, wayPoints)
		dungeonRoomBuilder:createRooms(ITEMS_TABLE, ROOM_SHAPES, currentFloor)

		local wallAutoBorder = WallAutoBorder.new(generatedMap, wayPoints)
		wallAutoBorder:doWalls(
			ITEMS_TABLE[1][1],
			ITEMS_TABLE[0][1],
			TOMB_SAND_WALL_BORDER,
			currentFloor
		)

		local marker = Marker.new(generatedMap)
		marker:createMarkersAlternatively(
			ITEMS_TABLE[1][1],
			30,
			7,
			currentFloor
		)
		generatedMap:doGround2(
			marker.markersTab,
			cursor,
			ITEMS_TABLE[1][1],
			ITEMS_TABLE[12][1],
			1,
			2
		)

		------ repeat createMarkersAlternatively & doGround2

		marker:createMarkersAlternatively(
			ITEMS_TABLE[1][1],
			20,
			6,
			currentFloor
		)
		generatedMap:doGround2(
			marker.markersTab,
			cursor,
			ITEMS_TABLE[1][1],
			ITEMS_TABLE[12][1],
			1,
			3
		)

		generatedMap:correctGround(ITEMS_TABLE[1][1], ITEMS_TABLE[12][1])

		local groundAutoBorder = GroundAutoBorder.new(generatedMap)
		groundAutoBorder:doGround(
			ITEMS_TABLE[12][1],
			ITEMS_TABLE[1][1],
			ITEMS_TABLE[0][1],
			SAND_GROUND_BASE_BORDER,
			currentFloor
		)
		groundAutoBorder:correctBorders(
			ITEMS_TABLE[0][1],
			SAND_GROUND_BASE_BORDER,
			TOMB_SAND_WALL_BORDER,
			ITEMS_TABLE[12][1],
			BORDER_CORRECT_SHAPES,
			40,
			currentFloor
		)

		addRotatedTab(BRUSH_BORDER_SHAPES, 9)
		marker:createMarkersAlternatively(
			0,
			70,
			4,
			currentFloor
		)
		local brush = Brush.new()
		brush:doCarpetBrush(
			marker.markersTab,
			ITEMS_TABLE[0][1],
			BRUSH_BORDER_SHAPES,
			SAND_BASE_BRUSH
		)

		------ Detailing Map

		local detailer = Detailer.new(generatedMap, wayPoints)
		detailer:createDetailsInRooms(ROOM_SHAPES, ITEMS_TABLE, TOMB_SAND_WALL_BORDER, currentFloor)

		detailer:createDetailsOnMap(ITEMS_TABLE[11][1], 4, currentFloor)
		detailer:createDetailsOnMap(ITEMS_TABLE[8][1], 10, currentFloor)
		detailer:createDetailsOnMap(ITEMS_TABLE[8][2], 4, currentFloor)
		detailer:createDetailsOnMap(ITEMS_TABLE[8][3], 1, currentFloor)
		detailer:createDetailsOnMap(ITEMS_TABLE[9][2], 4, currentFloor)
		detailer:createDetailsOnMap(ITEMS_TABLE[9][1], 2, currentFloor)

		detailer:createHangableDetails(
			ITEMS_TABLE[0][1],
			TOMB_SAND_WALL_BORDER,
			ITEMS_TABLE,
			15,
			currentFloor
		)

		--local groundRandomizer = GroundRandomizer.new(generatedMap)
		--groundRandomizer:randomize(ITEMS_TABLE, 40)

		-- multi-floor
		if (currentFloor ~= mainPos.z) then
			-- Central Points
			--promotedWaypoints[currentFloor + 1] = {
			--	wayPointer:getCentralWaypointForNextFloor(promotedWaypoints, wayPoints, currentFloor)
			--}
			--promotedWaypoints[currentFloor + 1] = {
			--	wayPointer:getCentralWaypointForNextFloor(promotedWaypoints, wayPoints, currentFloor, true)
			--}

			-- External Points
			promotedWaypoints[currentFloor + 1] = {
				WayPointer:getExternalWaypointForNextFloor(promotedWaypoints, wayPoints, currentFloor)
			}
			--promotedWaypoints[currentFloor + 1] = {
			--	WayPointer:getExternalWaypointForNextFloor(promotedWaypoints, wayPoints, currentFloor, math.random(1,4))
			--}
		else
			print("No waypoints to promote for next floor - last floor processed.")
		end
	end

	local elevator = ElevationBuilder.new(generatedMap, promotedWaypoints, TOMB_SAND_WALL_BORDER)
	elevator:createDesertRamps("random", 4837)

	if (PRECREATION_TABLE_MODE and RUNNING_MODE == 'tfs') then
		local mapCreator = MapCreator.new(generatedMap)
		mapCreator:drawMap()
	end

	return generatedMap
end

function script.getMap()
	return GroundMapper.new(mainPos, mapSizeX, mapSizeY, mapSizeZ, wpMinDist)
end

return script
