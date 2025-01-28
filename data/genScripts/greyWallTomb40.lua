-- old: "generation_map2 - dobra.lua"
MAP_CONFIGURATION = {
    schemaFile = 'greyWallTomb1.lua',
    saveMapFilename = 'greyWallTomb40',
	logToFile = true,
    mainPos = {x = 155, y = 155, z = 7},
	mapSizeX = 40,
	mapSizeY = 40,
	wpMinDist = 8,
	wayPointsCount = 7
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
local wpMinDist = MAP_CONFIGURATION.wpMinDist
local wayPointsCount = MAP_CONFIGURATION.wayPointsCount
local wayPoints = {}

loadSchemaFile() -- loads the schema file from map configuration with specific global ITEMS_TABLE

------ Base stuff

local cursor = Cursor.new(mainPos)
local map = GroundMapper.new(mainPos, mapSizeX, mapSizeY, wpMinDist)

map:doMainGround(ITEMS_TABLE)

local wayPointer = WayPointer.new(map, cursor)
wayPointer:createWaypointsAlternatively(wayPoints, wayPointsCount)

--print('Length: ' .. #wayPoints)
--sortWaypoints(wayPoints)
--print(dumpVar(wayPoints))

wayPointer:createPathBetweenWpsTSP(ITEMS_TABLE)
--wayPointer:createPathBetweenWpsTSPMS(ITEMS_TABLE)

local dungeonRoomBuilder = DungeonRoomBuilder.new(wayPoints)
dungeonRoomBuilder:createRooms(ITEMS_TABLE, ROOM_SHAPES)

local wallAutoBorder = WallAutoBorder.new(map)
wallAutoBorder:doWalls(
	ITEMS_TABLE[1][1],
	ITEMS_TABLE[0][1],
	GREY_WALL_BORDER
)

wallAutoBorder:createArchways(GREY_WALL_BORDER) -- todo: most likely does not work

local marker = Marker.new(map)
marker:createMarkersAlternatively(
	ITEMS_TABLE[1][1],
	12,
	5
)
-- todo: doGround can work incorrectly, differences in original files \/
map:doGround2(
	marker.markersTab,
	cursor,
	ITEMS_TABLE[1][1],
	ITEMS_TABLE[12][1],
	1,
	6
)

-- todo: can work incorrectly, differences in original files \/
map:correctGround(
	ITEMS_TABLE[1][1],
	ITEMS_TABLE[12][1]
)

addRotatedTab(BRUSH_BORDER_SHAPES, 9)

marker:createMarkersAlternatively(
	ITEMS_TABLE[1][1],
	20,
	4
)
local brush = Brush.new()
brush:doBrush(
	marker.markersTab,
	ITEMS_TABLE[0][1],
	BRUSH_BORDER_SHAPES,
	GRAVEL_BRONZE_BASE_BRUSH
) -- it has to be executed before the base autoBorder, otherwise there are issues with stackpos

local groundAutoBorder = GroundAutoBorder.new(map)
groundAutoBorder:doGround(
	ITEMS_TABLE[12][1],
	ITEMS_TABLE[1][1],
	ITEMS_TABLE[0][1],
	DIRT_GROUND_BASE_BORDER
)
groundAutoBorder:correctBorders(
	ITEMS_TABLE[0][1],
	DIRT_GROUND_BASE_BORDER,
	GREY_WALL_BORDER,
	ITEMS_TABLE[12][1],
	BORDER_CORRECT_SHAPES,
	30
)

------ Detailing Map

local detailer = Detailer.new(map, wayPoints)
detailer:createDetailsInRooms(ROOM_SHAPES, ITEMS_TABLE, GREY_WALL_BORDER)

detailer:createDetailsOnMap(ITEMS_TABLE[11][1], 4)
detailer:createDetailsOnMap(ITEMS_TABLE[8][1], 10)
detailer:createDetailsOnMap(ITEMS_TABLE[8][2], 4)
detailer:createDetailsOnMap(ITEMS_TABLE[8][3], 1)
detailer:createDetailsOnMap(ITEMS_TABLE[9][2], 4)
detailer:createDetailsOnMap(ITEMS_TABLE[9][1], 2)

detailer:createHangableDetails(
	ITEMS_TABLE[0][1],
	GREY_WALL_BORDER,
	ITEMS_TABLE,
	15
)

local groundRandomizer = GroundRandomizer.new(map)
groundRandomizer:randomize(ITEMS_TABLE, 30)

if (PRECREATION_TABLE_MODE and RUNNING_MODE == 'tfs') then
	local mapCreator = MapCreator.new(map)
	mapCreator:drawMap()
end
