-- old: "generation_map2 - dobra.lua"
MAP_CONFIGURATION = {
    schemaFile = 'darkWallTomb1.lua',
    saveMapFilename = 'darkWallTomb100',
    mainPos = {x = 145, y = 145, z = 7},
    mapSizeX = 100,
    mapSizeY = 100,
	mapSizeZ = 1, -- no multi-floor for now
    wpMinDist = 13,
    wayPointsCount = 30
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

	local generatedMap = GroundMapper.new(mainPos, mapSizeX, mapSizeY, mapSizeZ, wpMinDist)

	generatedMap:doMainGround(ITEMS_TABLE)

	local cursor = Cursor.new(mainPos)
	local wayPointer = WayPointer.new(generatedMap, cursor)
	wayPoints = wayPointer:createWaypointsAlternatively(wayPointsCount)

	--print('Length: ' .. #wayPoints)
	--sortWaypoints(wayPoints)
	--print(dumpVar(wayPoints))

	wayPointer:createPathBetweenWpsTSP(ITEMS_TABLE)
	--wayPointer:createPathBetweenWpsTSPMS(ITEMS_TABLE)

	local dungeonRoomBuilder = DungeonRoomBuilder.new(wayPoints)
	dungeonRoomBuilder:createRooms(ITEMS_TABLE, ROOM_SHAPES)

	local wallAutoBorder = WallAutoBorder.new(generatedMap)
	wallAutoBorder:doWalls(
		ITEMS_TABLE[1][1],
		ITEMS_TABLE[0][1],
		BLACK_WALL_BORDER
	)

	wallAutoBorder:createArchways(BLACK_WALL_BORDER) -- todo: most likely does not work

	local marker = Marker.new(generatedMap)
	marker:createMarkersAlternatively(
			ITEMS_TABLE[1][1],
			75,
			6
	)
	-- todo: doGround can work incorrectly, differences in original files \/
	generatedMap:doGround2(
		marker.markersTab,
		cursor,
		ITEMS_TABLE[1][1],
		ITEMS_TABLE[12][1],
		1,
		6
	)

	-- todo: can work incorrectly, differences in original files \/
	generatedMap:correctGround(
		ITEMS_TABLE[1][1],
		ITEMS_TABLE[12][1]
	)

	local groundAutoBorder = GroundAutoBorder.new(generatedMap)
	groundAutoBorder:doGround(
		ITEMS_TABLE[12][1],
		ITEMS_TABLE[1][1],
		ITEMS_TABLE[0][1],
		SAND_GROUND_BASE_BORDER
	)
	groundAutoBorder:correctBorders(
		ITEMS_TABLE[0][1],
		SAND_GROUND_BASE_BORDER,
		BLACK_WALL_BORDER,
		ITEMS_TABLE[12][1],
		BORDER_CORRECT_SHAPES,
		30
	)

	addRotatedTab(BRUSH_BORDER_SHAPES, 9)
	marker:createMarkersAlternatively(
		ITEMS_TABLE[1][1],
		100,
		4
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
	detailer:createDetailsInRooms(ROOM_SHAPES, ITEMS_TABLE, BLACK_WALL_BORDER)

	detailer:createDetailsOnMap(ITEMS_TABLE[11][1], 4)
	detailer:createDetailsOnMap(ITEMS_TABLE[8][1], 10)
	detailer:createDetailsOnMap(ITEMS_TABLE[8][2], 4)
	detailer:createDetailsOnMap(ITEMS_TABLE[8][3], 1)
	detailer:createDetailsOnMap(ITEMS_TABLE[9][2], 4)
	detailer:createDetailsOnMap(ITEMS_TABLE[9][1], 2)

	detailer:createHangableDetails(
		ITEMS_TABLE[0][1],
		BLACK_WALL_BORDER,
		ITEMS_TABLE,
		15
	)

	local groundRandomizer = GroundRandomizer.new(generatedMap)
	groundRandomizer:randomize(ITEMS_TABLE, 30)

	if (PRECREATION_TABLE_MODE and RUNNING_MODE == 'tfs') then
		local mapCreator = MapCreator.new(generatedMap)
		mapCreator:drawMap()
	end
end

return script
