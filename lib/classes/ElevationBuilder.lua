ElevationBuilder = {}
ElevationBuilder.__index = ElevationBuilder

function ElevationBuilder.new(map, elevationWaypoints, wallBorder)
	local instance = setmetatable({}, ElevationBuilder)
	instance.map = map
	instance.waypoints = elevationWaypoints or {}
	instance.wallBorder = wallBorder

	return instance
end

function ElevationBuilder:createRopeLadders(direction, upperFloorStairsGroundId)
	local startTime = os.clock()
	if (direction ~= "north") then
		error("Incorrect direction argument value. For ladders use always \"north\".")
	end
	self:_createElevation(ROPE_LADDER_SCHEMA, direction, upperFloorStairsGroundId)

	print("Creating elevations between floors done, execution time: " .. os.clock() - startTime)
end

function ElevationBuilder:createDesertRamps(direction, upperFloorStairsGroundId)
	local startTime = os.clock()
	self:_createElevation(DESERT_RAMP_SCHEMA, direction, upperFloorStairsGroundId)

	print("Creating elevations between floors done, execution time: " .. os.clock() - startTime)
end

function ElevationBuilder:createGreyMountainRamps(direction, upperFloorStairsGroundId)
	local startTime = os.clock()
	self:_createElevation(GREY_MOUNTAIN_RAMP_SCHEMA, direction, upperFloorStairsGroundId)

	print("Creating elevations between floors done, execution time: " .. os.clock() - startTime)
end

function ElevationBuilder:createRedMountainRamps(direction, upperFloorStairsGroundId)
	local startTime = os.clock()
	self:_createElevation(RED_MOUNTAIN_RAMP_SCHEMA, direction, upperFloorStairsGroundId)

	print("Creating elevations between floors done, execution time: " .. os.clock() - startTime)
end

function ElevationBuilder:_createElevation(elevationSchema, direction, upperFloorStairsGroundId)
	local availableDirections = {"north","east","south","south","random"}
	if not inArray(availableDirections, direction) then
		error("Incorrect direction argument value. Available directions: " .. implode(', ', availableDirections))
	end

	for currentFloor, wayPoints in pairs(self.waypoints) do
		for _, waypoint in pairs(wayPoints) do
			if (direction == 'random') then
				local directions = {"north","east","south","south"} -- random directions
				direction = directions[math.random(1, #directions)]
			end

			self:_createElevationItems(
				waypoint.pos,
				elevationSchema,
				direction,
				upperFloorStairsGroundId
			)
		end
	end
end

function ElevationBuilder:_createElevationItems(mainPos, elevationSchema, direction, upperFloorStairsGroundId)
	if (elevationSchema["upper"][direction] == nil or
		elevationSchema["lower"][direction] == nil
	) then
		error("There is no elevation schema for given direction declared.")
	end

	local processFloor = function (pos, wallBorder, schema, upperFloorStairsGroundId)
		for i = -1, 1 do
			for j = -1, 1 do
				local tmpPos = {x = pos.x + j, y = pos.y + i, z = pos.z}
				if (type(schema["schema"][i + 2][j + 2]) == "number") then
					if (schema["schema"][i + 2][j + 2] == 0) then
						removeAllUnwalkableItems(tmpPos, wallBorder)
					else
						removeAllItemsFromPos(tmpPos, false)
						if (upperFloorStairsGroundId ~= nil) then
							doCreateItemMock(upperFloorStairsGroundId, 1, tmpPos)
						else
							doCreateItemMock(schema.itemId[schema["schema"][i + 2][j + 2]], 1, tmpPos)
						end
					end
				end
			end
		end
	end

	processFloor(
		{x = mainPos.x, y = mainPos.y, z = mainPos.z - 1},
		self.wallBorder,
		elevationSchema["upper"][direction],
		upperFloorStairsGroundId
	)
	processFloor(
		{x = mainPos.x, y = mainPos.y, z = mainPos.z},
		self.wallBorder,
		elevationSchema["lower"][direction]
	)
end
