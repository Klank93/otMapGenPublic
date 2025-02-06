-- script for testing new solutions
MAP_CONFIGURATION = {
    schemaFile = 'test1.lua',
    saveMapFilename = 'test70',
    logToFile = true,
    mainPos = {x = 145, y = 145, z = 7},
    mapSizeX = 70,
    mapSizeY = 70,
	mapSizeZ = 1, -- no multi-floor for now
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

local script = {}

loadSchemaFile() -- loads the schema file from map configuration with specific global ITEMS_TABLE

function script.run()
	------ Base stuff

	print('> 1 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')

	local generatedMap = GroundMapper.new(mainPos, mapSizeX, mapSizeY, mapSizeZ, wpMinDist)

	generatedMap:doMainGround(ITEMS_TABLE)

	print('> 2 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')

	local cursor = Cursor.new(mainPos)
	local wayPointer = WayPointer.new(generatedMap, cursor, wayPoints)
	wayPoints = wayPointer:createWaypointsAlternatively(wayPointsCount)

	print('> 3 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')

	print('Length: ' .. #wayPoints)
	--sortWaypoints(wayPoints)
	--print(dumpVar(wayPoints))

	-- wayPointer:createPathBetweenWps(ITEMS_TABLE)
	wayPointer:createPathBetweenWpsTSP(ITEMS_TABLE)
	-- wayPointer:createPathBetweenWpsTSPMS(ITEMS_TABLE)

	local roomBuilder = DungeonRoomBuilder.new(wayPoints)
	roomBuilder:createRooms(ITEMS_TABLE, ROOM_SHAPES)

	print('> 4 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')

	local wallAutoBorder = WallAutoBorder.new(generatedMap)
	wallAutoBorder:doWalls(
		ITEMS_TABLE[1][1],
		ITEMS_TABLE[0][1],
		TOMB_SAND_WALL_BORDER
	)

	print('> 5 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')

	local marker = Marker.new(generatedMap)
	marker:createMarkersAlternatively(
		ITEMS_TABLE[1][1],
		32,
		6
	)

	print('> 6 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')

	generatedMap:doGround2(
		marker.markersTab,
		cursor,
		ITEMS_TABLE[1][1],
		ITEMS_TABLE[12][1],
		1,
		6
	)

	print('> 7 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')

	------ repeat createMarkers & doGround2

	marker:createMarkersAlternatively(
		ITEMS_TABLE[1][1],
		20,
		6
	)

	print('> 8 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')

	generatedMap:doGround2(
		marker.markersTab,
		cursor,
		ITEMS_TABLE[1][1],
		ITEMS_TABLE[12][1],
		1,
		6
	)

	print('> 9 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')

	generatedMap:correctGround(ITEMS_TABLE[1][1], ITEMS_TABLE[12][1])

	print('> 10 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')

	addRotatedTab(BRUSH_BORDER_SHAPES, 9)

	marker:createMarkersAlternatively(
		0,
		56,
		4
	)

	print('> 11 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')

	local brush = Brush.new()
	brush:doCarpetBrush(
		marker.markersTab,
		ITEMS_TABLE[0][1],
		BRUSH_BORDER_SHAPES,
		SAND_BASE_BRUSH
	) -- WARNING! it has to be executed before the base autoBorder, otherwise there are issues with stackpos

	print('> 12 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')

	local groundAutoBorder = GroundAutoBorder.new(generatedMap)
	groundAutoBorder:doGround(
		ITEMS_TABLE[12][1],
		ITEMS_TABLE[1][1],
		ITEMS_TABLE[0][1],
		SAND_GROUND_BASE_BORDER
	)

	print('> 13 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')

	groundAutoBorder:correctBorders(
		ITEMS_TABLE[0][1],
		SAND_GROUND_BASE_BORDER,
		TOMB_SAND_WALL_BORDER,
		ITEMS_TABLE[12][1],
		BORDER_CORRECT_SHAPES,
		30
	)

	print('> 14 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')

	--local groundRandomizer = GroundRandomizer.new(generatedMap)
	--groundRandomizer:randomize(ITEMS_TABLE, 40)

	------ Detailing Map

	local startTime = os.clock()
	local detailer = Detailer.new(generatedMap, wayPoints)
	detailer:createDetailsInRooms(ROOM_SHAPES, ITEMS_TABLE, TOMB_SAND_WALL_BORDER)

	print('> 15 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')

	detailer:createDetailsOnMap(ITEMS_TABLE[11][1], 4)
	detailer:createDetailsOnMap(ITEMS_TABLE[8][1], 10)
	detailer:createDetailsOnMap(ITEMS_TABLE[8][2], 4)
	detailer:createDetailsOnMap(ITEMS_TABLE[8][3], 1)
	detailer:createDetailsOnMap(ITEMS_TABLE[9][2], 4)
	detailer:createDetailsOnMap(ITEMS_TABLE[9][1], 2)

	detailer:createHangableDetails(
		ITEMS_TABLE[0][1],
		TOMB_SAND_WALL_BORDER,
		ITEMS_TABLE,
		15
	)
	print("Combined creation of the details done, execution time: " .. os.clock() - startTime)

	print('> 16 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')

	if (PRECREATION_TABLE_MODE and RUNNING_MODE == 'tfs') then
		local mapCreator = MapCreator.new(generatedMap)
		mapCreator:drawMap()

		print('> 17 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')
	end
end

return script
