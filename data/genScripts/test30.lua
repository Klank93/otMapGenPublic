-- script for testing new solutions
MAP_CONFIGURATION = {
    schemaFile = 'test1.lua',
    saveMapFilename = 'test30',
    logToFile = true,
    mainPos = {x = 145, y = 145, z = 7},
    mapSizeX = 30,
    mapSizeY = 30,
	mapSizeZ = 4, -- if set to greater than 1 => multi floor
    wpMinDist = 6,
    wayPointsCount = 3
}
LOG_TO_FILE = true --MAP_GEN_CFG.logToFile -- can be overridden for specific script
DEBUG_OUTPUT = true --MAP_GEN_CFG.debugOutput -- can be overridden for specific script

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
local generatedMap

local script = {}

loadSchemaFile() -- loads the schema file from map configuration with specific global ITEMS_TABLE

function script.run()
	local promotedWaypoints = {}
	generatedMap = GroundMapper.new(mainPos, mapSizeX, mapSizeY, mapSizeZ, wpMinDist)
	for currentFloor = mainPos.z - (mapSizeZ - 1), mainPos.z do -- multi-floor (it's working in ascending order, from upper floors to lower ones)
		print('\n###########################>>>> Processing Floor: ' .. currentFloor)

		------ Base stuff
		print('> 1 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')

		generatedMap:doMainGround(ITEMS_TABLE, currentFloor)

		print('> 2 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')

		if (promotedWaypoints[currentFloor] ~= nil) then -- necessary addition for multi floor
			wayPoints[currentFloor] = arrayMerge({}, promotedWaypoints[currentFloor])
		end

		local cursor = Cursor.new(mainPos)
		local wayPointer = WayPointer.new(generatedMap, cursor, wayPoints)
		wayPoints = wayPointer:createWaypointsAlternatively(wayPointsCount, currentFloor)

		print('> 3 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')

		-- wayPointer:createPathBetweenWps(ITEMS_TABLE)
		wayPointer:createPathBetweenWpsTSP(ITEMS_TABLE, 3, currentFloor) -- exact one
		-- wayPointer:createPathBetweenWpsTSPMS(ITEMS_TABLE)

		local roomBuilder = DungeonRoomBuilder.new(generatedMap, wayPoints[currentFloor])
		roomBuilder:createRooms(ITEMS_TABLE, ROOM_SHAPES)

		print('> 4 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')

		local wallAutoBorder = WallAutoBorder.new(generatedMap)
		wallAutoBorder:doWalls(
			ITEMS_TABLE[1][1],
			ITEMS_TABLE[0][1],
			TOMB_SAND_WALL_BORDER,
			currentFloor
		)

		print('> 5 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')

		local marker = Marker.new(generatedMap)
		marker:createMarkersAlternatively(
			ITEMS_TABLE[1][1],
			5,
			4,
			currentFloor
		)

		print('> 6 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')

		generatedMap:doGround2(
			marker.markersTab,
			cursor,
			ITEMS_TABLE[1][1],
			ITEMS_TABLE[12][1],
			1,
			4
		)

		print('> 7 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')

		------ repeat createMarkers & doGround2

		marker:createMarkersAlternatively(
			ITEMS_TABLE[1][1],
			4,
			4,
			currentFloor
		)

		print('> 8 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')

		generatedMap:doGround2(
			marker.markersTab,
			cursor,
			ITEMS_TABLE[1][1],
			ITEMS_TABLE[12][1],
			1,
			4
		)

		print('> 9 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')

		generatedMap:correctGround(ITEMS_TABLE[1][1], ITEMS_TABLE[12][1], currentFloor) -- todo: most likely does not work in CLI mode

		print('> 10 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')

		local groundAutoBorder = GroundAutoBorder.new(generatedMap)
		groundAutoBorder:doGround(
			ITEMS_TABLE[12][1],
			ITEMS_TABLE[1][1],
			ITEMS_TABLE[0][1],
			SAND_GROUND_BASE_BORDER,
			currentFloor
		)

		print('> 11 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')

		groundAutoBorder:correctBorders(
			ITEMS_TABLE[0][1],
			SAND_GROUND_BASE_BORDER,
			TOMB_SAND_WALL_BORDER,
			ITEMS_TABLE[12][1],
			BORDER_CORRECT_SHAPES,
			45,
			currentFloor
		)

		print('> 12 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')

		addRotatedTab(BRUSH_BORDER_SHAPES, 9)

		marker:createMarkersAlternatively(
			0,
			4,
			4,
			currentFloor
		)

		print('> 13 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')

		local brush = Brush.new()
		brush:doCarpetBrush(
			marker.markersTab,
			ITEMS_TABLE[0][1],
			BRUSH_BORDER_SHAPES,
			SAND_BASE_BRUSH
		)

		print('> 14 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')

		--local groundRandomizer = GroundRandomizer.new(generatedMap)
		--groundRandomizer:randomize(ITEMS_TABLE, 40)

		------ Detailing Map

		local startTime = os.clock()
		local detailer = Detailer.new(generatedMap, wayPoints[currentFloor])
		detailer:createDetailsInRooms(ROOM_SHAPES, ITEMS_TABLE, TOMB_SAND_WALL_BORDER)

		print('> 15 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')

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
		print("Combined creation of the details done, execution time: " .. os.clock() - startTime)

		print('> 16 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')

		-- multi-floor
		if (currentFloor ~= mainPos.z) then
			-- Central Points
			promotedWaypoints[currentFloor + 1] = {
				wayPointer:getCentralWaypointForNextFloor(promotedWaypoints, wayPoints, currentFloor)
			}
			--promotedWaypoints[currentFloor + 1] = {
			--	wayPointer:getCentralWaypointForNextFloor(promotedWaypoints, wayPoints, currentFloor, true)
			--}

			print('> 17 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')
		else
			print("No waypoints to promote for next floor - last floor processed.")
		end
	end

	local elevator = ElevationBuilder.new(generatedMap, promotedWaypoints, TOMB_SAND_WALL_BORDER)
	--elevator:createRopeLadders("north") -- just example
	elevator:createDesertRamps("random", 4837)

	print('> 18 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')

	if (PRECREATION_TABLE_MODE and RUNNING_MODE == 'tfs') then
		local mapCreator = MapCreator.new(generatedMap)
		mapCreator:drawMap()

		print('> 19 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')
	end
end

return script
