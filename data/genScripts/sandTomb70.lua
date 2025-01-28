-- old: "generation_tomb_small.lua"
MAP_CONFIGURATION = {
    schemaFile = 'sandTomb1.lua',
    saveMapFilename = 'sandTomb70',
    mainPos = {x = 155, y = 155, z = 7},
    mapSizeX = 70,
    mapSizeY = 70,
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

wayPointer:createPathBetweenWps(ITEMS_TABLE)

local dungeonRoomBuilder = DungeonRoomBuilder.new(wayPoints)
dungeonRoomBuilder:createRooms(ITEMS_TABLE, ROOM_SHAPES)

local wallAutoBorder = WallAutoBorder.new(map)
wallAutoBorder:doWalls(
        ITEMS_TABLE[1][1],
        ITEMS_TABLE[0][1],
        TOMB_SAND_WALL_BORDER
)

wallAutoBorder:createArchways(TOMB_SAND_WALL_BORDER) -- todo: most likely does not work

local marker = Marker.new(map)
marker:createMarkersAlternatively(
        ITEMS_TABLE[1][1],
        35,
        6
)
map:doGround2(
        marker.markersTab,
        cursor,
        ITEMS_TABLE[1][1],
        ITEMS_TABLE[12][1],
        1,
        6
)

------ repeat createMarkersAlternatively & doGround2

marker:createMarkersAlternatively(
        ITEMS_TABLE[1][1],
        20,
        6
)
map:doGround2(
        marker.markersTab,
        cursor,
        ITEMS_TABLE[1][1],
        ITEMS_TABLE[12][1],
        1,
        6
)

map:correctGround(ITEMS_TABLE[1][1], ITEMS_TABLE[12][1])

addRotatedTab(BRUSH_BORDER_SHAPES, 9)
marker:createMarkersAlternatively(
        ITEMS_TABLE[1][1],
        72,
        4
)
local brush = Brush.new()
brush:doBrush(
        marker.markersTab,
        ITEMS_TABLE[0][1],
        BRUSH_BORDER_SHAPES,
        SAND_BASE_BRUSH
) -- it has to be executed before the base autoBorder, otherwise there are issues with stackpos

local groundAutoBorder = GroundAutoBorder.new(map)
groundAutoBorder:doGround(
        ITEMS_TABLE[12][1],
        ITEMS_TABLE[1][1],
        ITEMS_TABLE[0][1],
        SAND_GROUND_BASE_BORDER
)
groundAutoBorder:correctBorders(
        ITEMS_TABLE[0][1],
        SAND_GROUND_BASE_BORDER,
        TOMB_SAND_WALL_BORDER,
        ITEMS_TABLE[12][1],
        BORDER_CORRECT_SHAPES,
        30
)

--local groundRandomizer = GroundRandomizer.new(map)
--groundRandomizer:randomize(ITEMS_TABLE, 40)

------ Detailing Map

local detailer = Detailer.new(map, wayPoints)
detailer:createDetailsInRooms(ROOM_SHAPES, ITEMS_TABLE, TOMB_SAND_WALL_BORDER)

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


------ Additional Actions (old step 4) \/ not need for simple tomb


--map:correctGround(ITEMS_TABLE[0][1], ITEMS_TABLE[22][1])
---- not exactly sure what was the reason of it /\ and why it is being run twice
--
--groundAutoBorder:doGround2( -- most likely creates the border for main and second not walkable ground
--        ITEMS_TABLE[0][1], -- base red mountain not-walkable ground
--        ITEMS_TABLE[22][1], -- sand yellow mountain not-walkable ground
--        ITEMS_TABLE[1][1],
--        ITEMS_TABLE[12][1],
--        RED_MOUNTAIN_TOP_BORDER
--)
--
--local groundRandomizer = GroundRandomizer.new(map)
--groundRandomizer:randomize(ITEMS_TABLE, 40)

--map:eraseMap()
