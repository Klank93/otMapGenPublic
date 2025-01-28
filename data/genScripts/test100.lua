-- script for testing new solutions
MAP_CONFIGURATION = {
    schemaFile = 'test1.lua',
    saveMapFilename = 'test100',
    logToFile = true,
    mainPos = {x = 155, y = 155, z = 7},
    mapSizeX = 100,
    mapSizeY = 100,
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
local wpMinDist = MAP_CONFIGURATION.wpMinDist
local wayPointsCount = MAP_CONFIGURATION.wayPointsCount
local wayPoints = {}

loadSchemaFile() -- loads the schema file from map configuration with specific global ITEMS_TABLE

------ Base stuff

print('> 1 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')

local cursor = Cursor.new(mainPos)
local map = GroundMapper.new(mainPos, mapSizeX, mapSizeY, wpMinDist)

map:doMainGround(ITEMS_TABLE)

print('> 2 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')

local wayPointer = WayPointer.new(map, cursor)
wayPointer:createWaypointsAlternatively(wayPoints, wayPointsCount)

print('> 3 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')

print('Length: ' .. #wayPoints)
--sortWaypoints(wayPoints)
--print(dumpVar(wayPoints))

-- wayPointer:createPathBetweenWps(ITEMS_TABLE)
wayPointer:createPathBetweenWpsTSP(ITEMS_TABLE)
-- wayPointer:createPathBetweenWpsTSPMS(ITEMS_TABLE)

-- do return end

local roomBuilder = DungeonRoomBuilder.new(wayPoints)
roomBuilder:createRooms(ITEMS_TABLE, ROOM_SHAPES)

print('> 4 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')

local wallAutoBorder = WallAutoBorder.new(map)
wallAutoBorder:doWalls(
        ITEMS_TABLE[1][1],
        ITEMS_TABLE[0][1],
        TOMB_SAND_WALL_BORDER
)

print('> 5 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')

local marker = Marker.new(map)
marker:createMarkersAlternatively(
        ITEMS_TABLE[1][1],
        35,
        6
)

print('> 6 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')

map:doGround2(
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
        75,
        6
)

print('> 8 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')

map:doGround2(
        marker.markersTab,
        cursor,
        ITEMS_TABLE[1][1],
        ITEMS_TABLE[12][1],
        1,
        6
)

print('> 9 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')

map:correctGround(ITEMS_TABLE[1][1], ITEMS_TABLE[12][1])

print('> 10 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')

addRotatedTab(BRUSH_BORDER_SHAPES, 9)

marker:createMarkersAlternatively(
        0, -- todo: "0" does not work with CLI, because of the bug in isWalkable function (doCreateItemMock actually)
        100,
        4
)

print('> 11 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')

local brush = Brush.new()
brush:doBrush(
        marker.markersTab,
        ITEMS_TABLE[0][1],
        BRUSH_BORDER_SHAPES,
        SAND_BASE_BRUSH
) -- it has to be executed before the base autoBorder, otherwise there are issues with stackpos

print('> 12 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')

local groundAutoBorder = GroundAutoBorder.new(map)
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

--local groundRandomizer = GroundRandomizer.new(map)
--groundRandomizer:randomize(ITEMS_TABLE, 40)

------ Detailing Map

local detailer = Detailer.new(map, wayPoints)
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

print('> 16 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')
