-- script for testing new solutions
MAP_CONFIGURATION = {
    schemaFile = 'sandCave1.lua',
    saveMapFilename = 'sandCave100',
    logToFile = true,
    mainPos = {x = 145, y = 145, z = 7},
    mapSizeX = 100,
    mapSizeY = 100,
	mapSizeZ = 1, -- no multi-floor for now
    wpMinDist = 16,
    wayPointsCount = 16
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

	local generatedMap = CaveGroundMapper.new(mainPos, mapSizeX, mapSizeY, mapSizeZ, wpMinDist)

	generatedMap:doMainGround(ITEMS_TABLE)

	local cursor = Cursor.new(mainPos)
	local brush = Brush.new()
	local caveWayPointer = CaveWayPointer.new(generatedMap, cursor, wayPoints, brush)
	wayPoints = caveWayPointer:createWaypointsAlternatively(wayPointsCount)

	--print('Length: ' .. #wayPoints)
	sortWaypoints(wayPoints)
	--print(dumpVar(wayPoints))

	--caveWayPointer:createPathBetweenWpsTSP(ITEMS_TABLE, 5)
	caveWayPointer:createPathBetweenWpsTSPMS(ITEMS_TABLE, 5, 3)

	local caveRoomBuilder = CaveRoomBuilder.new(wayPoints)
	caveRoomBuilder:createRooms(ITEMS_TABLE, 11, 11)

	generatedMap:correctCaveShapes(
		ITEMS_TABLE[0][1],
		ITEMS_TABLE[1][1],
		CAVE_LINE_SHAPES
	) -- todo: method completely not optimised, terrible performance

	generatedMap:correctBackgroundShapes(
		ITEMS_TABLE[0][1],
		ITEMS_TABLE[1][1],
		CAVE_BACKGROUND_CORRECT_SHAPES
	) -- todo: method completely not optimised, terrible performance

	local groundAutoBorder = GroundAutoBorder.new(generatedMap)
	groundAutoBorder:doGround(
		ITEMS_TABLE[0][1],
		ITEMS_TABLE[1][1],
		ITEMS_TABLE[0][1],
		CAVE_BASE_BORDER
	)

	local marker = Marker.new(generatedMap)
	marker:createMarkersAlternatively(
		ITEMS_TABLE[1][1],
		55,
		6
	)
	generatedMap:doGround2(
		marker.markersTab,
		cursor,
		ITEMS_TABLE[1][1],
		ITEMS_TABLE[12][1],
		2,
		8
	)

	------ repeat createMarkersAlternatively & doGround2

	marker:createMarkersAlternatively(
		ITEMS_TABLE[1][1],
		30,
		6
	)
	generatedMap:doGround2(
		marker.markersTab,
		cursor,
		ITEMS_TABLE[1][1],
		ITEMS_TABLE[12][1],
		2,
		8
	)

	generatedMap:correctGround(ITEMS_TABLE[1][1], ITEMS_TABLE[12][1])

	addRotatedTab(BRUSH_BORDER_SHAPES, 9)
	marker:createMarkersAlternatively(
		ITEMS_TABLE[1][1],
		110,
		4
	)

	brush:doCarpetBrush(
		marker.markersTab,
		ITEMS_TABLE[0][1],
		BRUSH_BORDER_SHAPES,
		SAND_BASE_BRUSH
	) -- WARNING! it has to be executed before the base autoBorder, otherwise there are issues with stackpos

	groundAutoBorder:doGround(
		ITEMS_TABLE[12][1],
		ITEMS_TABLE[1][1],
		ITEMS_TABLE[0][1],
		SAND_GROUND_BASE_BORDER
	)

	local tmpWallBorderTable = { -- todo: refactor, should not be needed
		[1] = {999999},
		[2] = {999999},
		[3] = {999999},
		[4] = {999999}
	}
	-- todo: not need to pass TOMB_SAND_WALL_BORDER in this, cave generation case
	groundAutoBorder:correctBorders(
		ITEMS_TABLE[0][1],
		SAND_GROUND_BASE_BORDER,
		tmpWallBorderTable,
		ITEMS_TABLE[12][1],
		BORDER_CORRECT_SHAPES,
		30
	)

	------ Detailing Map

	marker:createMarkersAlternatively(
		ITEMS_TABLE[1][1],
		55,
		6
	)
	local detailer = Detailer.new(generatedMap, wayPoints)
	detailer:createDetailsInCave(
		marker.markersTab,
		ITEMS_TABLE[10],
		4,
		25
	)

	detailer:createDetailsOnMap(ITEMS_TABLE[11][1], 4)
	detailer:createDetailsOnMap(ITEMS_TABLE[8][1], 10)
	detailer:createDetailsOnMap(ITEMS_TABLE[8][2], 4)
	detailer:createDetailsOnMap(ITEMS_TABLE[8][3], 1)
	detailer:createDetailsOnMap(ITEMS_TABLE[9][2], 4)
	detailer:createDetailsOnMap(ITEMS_TABLE[9][1], 2)

	local groundRandomizer = GroundRandomizer.new(generatedMap)
	groundRandomizer:randomizeByIds(ITEMS_TABLE[1], 40)
	groundRandomizer:randomizeByIds(ITEMS_TABLE[0], 40)

	if (PRECREATION_TABLE_MODE and RUNNING_MODE == 'tfs') then
		local mapCreator = MapCreator.new(generatedMap)
		mapCreator:drawMap()
	end
end

return script
