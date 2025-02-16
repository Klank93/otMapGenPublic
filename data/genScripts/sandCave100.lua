-- script for testing new solutions
MAP_CONFIGURATION = {
    schemaFile = 'sandCave1.lua',
    saveMapFilename = 'sandCave100',
    logToFile = true,
    mainPos = {x = 145, y = 145, z = 7},
    mapSizeX = 100,
    mapSizeY = 100,
	mapSizeZ = 3, -- if set to greater than 1 => multi floor
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
local generatedMap = GroundMapper

local script = {}

loadSchemaFile() -- loads the schema file from map configuration with specific global ITEMS_TABLE

function script.run()
	local promotedWaypoints = {}
	generatedMap = CaveGroundMapper.new(mainPos, mapSizeX, mapSizeY, mapSizeZ, wpMinDist)
	for currentFloor = mainPos.z - (mapSizeZ - 1), mainPos.z do -- multi-floor (it's working in ascending order, from upper floors to lower ones)
		print('\n###########################>>>> Processing Floor: ' .. currentFloor)

		------ Base stuff
		generatedMap:doMainGround(ITEMS_TABLE, currentFloor)

		if (promotedWaypoints[currentFloor] ~= nil) then -- necessary addition for multi floor
			wayPoints[currentFloor] = arrayMerge({}, promotedWaypoints[currentFloor])
		end

		local cursor = Cursor.new(mainPos)
		local brush = Brush.new()
		local caveWayPointer = CaveWayPointer.new(generatedMap, cursor, wayPoints, brush)
		wayPoints = caveWayPointer:createWaypointsAlternatively(wayPointsCount, currentFloor)

		--print('Length: ' .. #wayPoints)
		--sortWaypoints(wayPoints)
		--print(dumpVar(wayPoints))

		--caveWayPointer:createPathBetweenWpsTSP(ITEMS_TABLE, 5)
		caveWayPointer:createPathBetweenWpsTSPMS(ITEMS_TABLE, 5, 3, currentFloor)

		local caveRoomBuilder = CaveRoomBuilder.new(generatedMap, wayPoints)
		caveRoomBuilder:createRooms(ITEMS_TABLE, 11, 11, currentFloor)

		generatedMap:correctCaveShapes(
			ITEMS_TABLE[0][1],
			ITEMS_TABLE[1][1],
			CAVE_LINE_SHAPES,
			currentFloor
		) -- todo: method completely not optimised, terrible performance

		generatedMap:correctBackgroundShapes(
			ITEMS_TABLE[0][1],
			ITEMS_TABLE[1][1],
			CAVE_BACKGROUND_CORRECT_SHAPES,
			currentFloor
		) -- todo: method completely not optimised, terrible performance

		local groundAutoBorder = GroundAutoBorder.new(generatedMap)
		groundAutoBorder:doGround(
			ITEMS_TABLE[0][1],
			ITEMS_TABLE[1][1],
			ITEMS_TABLE[0][1],
			CAVE_BASE_BORDER,
			currentFloor
		)

		local marker = Marker.new(generatedMap)
		marker:createMarkersAlternatively(
			ITEMS_TABLE[1][1],
			50,
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

		------ repeat createMarkersAlternatively & doGround2

		marker:createMarkersAlternatively(
			ITEMS_TABLE[1][1],
			30,
			6,
			currentFloor
		)
		generatedMap:doGround2(
			marker.markersTab,
			cursor,
			ITEMS_TABLE[1][1],
			ITEMS_TABLE[12][1],
			2,
			4
		)

		generatedMap:correctGround(ITEMS_TABLE[1][1], ITEMS_TABLE[12][1], currentFloor)

		groundAutoBorder:doGround(
			ITEMS_TABLE[12][1],
			ITEMS_TABLE[1][1],
			ITEMS_TABLE[0][1],
			SAND_GROUND_BASE_BORDER,
			currentFloor
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
			30,
			currentFloor
		)

		addRotatedTab(BRUSH_BORDER_SHAPES, 9)
		marker:createMarkersAlternatively(
			ITEMS_TABLE[1][1],
			110,
			4,
			currentFloor
		)
		brush:doCarpetBrush(
			marker.markersTab,
			ITEMS_TABLE[0][1],
			BRUSH_BORDER_SHAPES,
			SAND_BASE_BRUSH
		)

		------ Detailing Map

		marker:createMarkersAlternatively(
			ITEMS_TABLE[1][1],
			55,
			6,
			currentFloor
		)
		local detailer = Detailer.new(generatedMap, wayPoints)
		detailer:createDetailsInCave(
			marker.markersTab,
			ITEMS_TABLE[10],
			4,
			25
		)

		detailer:createDetailsOnMap(ITEMS_TABLE[11][1], 4, currentFloor)
		detailer:createDetailsOnMap(ITEMS_TABLE[8][1], 10, currentFloor)
		detailer:createDetailsOnMap(ITEMS_TABLE[8][2], 4, currentFloor)
		detailer:createDetailsOnMap(ITEMS_TABLE[8][3], 1, currentFloor)
		detailer:createDetailsOnMap(ITEMS_TABLE[9][2], 4, currentFloor)
		detailer:createDetailsOnMap(ITEMS_TABLE[9][1], 2, currentFloor)

		local groundRandomizer = GroundRandomizer.new(generatedMap)
		groundRandomizer:randomizeByIds(ITEMS_TABLE[1], 40, currentFloor)
		groundRandomizer:randomizeByIds(ITEMS_TABLE[0], 40, currentFloor)

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
	elevator:createCaveRopeSpots() -- todo: issue, if there are already some borders/brushes on elevation pos, it deletes them

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
