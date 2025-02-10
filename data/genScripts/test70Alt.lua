-- script for testing new solutions, EXPERIMENTAL script
MAP_CONFIGURATION = {
    schemaFile = 'test1.lua',
    saveMapFilename = 'test70Alt',
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
	print('> 1 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')

	local generatedMap = GroundMapper.new(mainPos, mapSizeX, mapSizeY, mapSizeZ, wpMinDist)
	local cursor = Cursor.new(mainPos)
	local wayPointer = WayPointer.new(generatedMap, cursor)
	local roomBuilder
	local wallAutoBorder = WallAutoBorder.new(generatedMap)
	local marker = Marker.new(generatedMap)
	local brush = Brush.new()
	local groundAutoBorder = GroundAutoBorder.new(generatedMap)
	--local groundRandomizer = GroundRandomizer.new(generatedMap) -- not needed in this script
	local detailer
	local mapCreator

	local startTime = os.clock()

	local function generateMap(step)
		print('Running step: ' .. step)
		if (step == 1) then
			doPlayerSendTextMessageMock(
				TFS_CID,
				TFS_MESSAGE_CLASSES,
				string.format(
						'Generation of the map, with schema: %s has started.',
						MAP_CONFIGURATION.saveMapFilename
				)
			)
			generatedMap:doMainGround(ITEMS_TABLE)

			print('> 2 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')
		elseif (step == 2) then
			wayPoints = wayPointer:createWaypointsAlternatively(wayPointsCount)
			print('> 3 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')

			print('Length: ' .. #wayPoints)
			--sortWaypoints(wayPoints)
			--print(dumpVar(wayPoints))
		elseif (step == 3) then
			-- wayPointer:createPathBetweenWps(ITEMS_TABLE)
			wayPointer:createPathBetweenWpsTSP(ITEMS_TABLE)
			-- wayPointer:createPathBetweenWpsTSPMS(ITEMS_TABLE)
		elseif (step == 4) then
			roomBuilder = DungeonRoomBuilder.new(generatedMap, wayPoints)
			roomBuilder:createRooms(ITEMS_TABLE, ROOM_SHAPES)
			print('> 4 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')
		elseif (step == 5) then
			wallAutoBorder:doWalls(
				ITEMS_TABLE[1][1],
				ITEMS_TABLE[0][1],
				TOMB_SAND_WALL_BORDER
			)
			print('> 5 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')
		elseif (step == 6) then
			marker:createMarkersAlternatively(
				ITEMS_TABLE[1][1],
				28,
				6
			)
			generatedMap:doGround2(
				marker.markersTab,
				cursor,
				ITEMS_TABLE[1][1],
				ITEMS_TABLE[12][1],
				1,
				6
			)
			print('> 6 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')
		elseif (step == 7) then
			marker:createMarkersAlternatively(
				ITEMS_TABLE[1][1],
				16,
				6
			)
			generatedMap:doGround2(
				marker.markersTab,
				cursor,
				ITEMS_TABLE[1][1],
				ITEMS_TABLE[12][1],
				1,
				6
			)
			print('> 7 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')
		elseif (step == 8) then
			generatedMap:correctGround(ITEMS_TABLE[1][1], ITEMS_TABLE[12][1])
			print('> 8 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')
		elseif (step == 9) then
			groundAutoBorder:doGround(
				ITEMS_TABLE[12][1],
				ITEMS_TABLE[1][1],
				ITEMS_TABLE[0][1],
				SAND_GROUND_BASE_BORDER
			)

			print('> 9 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')
		elseif (step == 10) then
			groundAutoBorder:correctBorders(
				ITEMS_TABLE[0][1],
				SAND_GROUND_BASE_BORDER,
				TOMB_SAND_WALL_BORDER,
				ITEMS_TABLE[12][1],
				BORDER_CORRECT_SHAPES,
				40
			)

			print('> 10 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')
		elseif (step == 11) then
			addRotatedTab(BRUSH_BORDER_SHAPES, 9)
			marker:createMarkersAlternatively(
				0,
				70,
				4
			)

			print('> 11 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')
		elseif (step == 12) then
			brush:doCarpetBrush(
				marker.markersTab,
				ITEMS_TABLE[0][1],
				BRUSH_BORDER_SHAPES,
				SAND_BASE_BRUSH
			)

			print('> 12 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')
		elseif (step == 13) then

			--groundRandomizer:randomize(ITEMS_TABLE, 40)
			print('> 13 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')
		elseif (step == 14) then
			detailer = Detailer.new(generatedMap, wayPoints)
			detailer:createDetailsInRooms(ROOM_SHAPES, ITEMS_TABLE, TOMB_SAND_WALL_BORDER)

			print('> 14 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')
		elseif (step == 15) then
			detailer:createDetailsOnMapAlternatively(ITEMS_TABLE[11][1], 4)
		elseif (step == 16) then
			detailer:createDetailsOnMapAlternatively(ITEMS_TABLE[8][1], 10)
		elseif (step == 17) then
			detailer:createDetailsOnMapAlternatively(ITEMS_TABLE[8][2], 4)
		elseif (step == 18) then
			detailer:createDetailsOnMapAlternatively(ITEMS_TABLE[8][3], 1)
		elseif (step == 19) then
			detailer:createDetailsOnMapAlternatively(ITEMS_TABLE[9][2], 4)
		elseif (step == 20) then
			detailer:createDetailsOnMapAlternatively(ITEMS_TABLE[9][1], 2)
		elseif (step == 21) then
			detailer:createHangableDetails(
				ITEMS_TABLE[0][1],
				TOMB_SAND_WALL_BORDER,
				ITEMS_TABLE,
				15
			)

			print('> 16 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')
		elseif (step == 22 and PRECREATION_TABLE_MODE and RUNNING_MODE == 'tfs') then
			mapCreator = MapCreator.new(generatedMap)
			mapCreator:drawMap()

			local diffTime = os.clock() - startTime
			doPlayerSendTextMessageMock( -- todo: does not work
				TFS_CID,
				TFS_MESSAGE_CLASSES,
				string.format(
						'Generation of the map, with schema: %s FINISHED in %s seconds.',
						MAP_CONFIGURATION.saveMapFilename,
						diffTime
				)
			)

			print('> 17 memory: ' .. round(collectgarbage("count"), 3) .. ' kB')
		end
	end

	local detailsCreationStartTime -- in case of addEvents, has to be removed
	for i = 1, 22 do
		if i == 14 then
			detailsCreationStartTime = os.clock()
		end
		generateMap(i) -- no addEvents
	end
	print("Combined creation of the details done, execution time: " .. os.clock() - detailsCreationStartTime) -- in case of addEvents, has to be removed
end

return script
