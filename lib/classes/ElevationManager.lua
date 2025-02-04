ElevationManager = {}
ElevationManager.__index = ElevationManager

function ElevationManager.new(map, elevationWaypoints, wallBorder)
	local instance = setmetatable({}, ElevationManager)
	instance.map = map
	instance.waypoints = elevationWaypoints or {}
	instance.wallBorder = wallBorder

	return instance
end

function ElevationManager:createRopeLadders()
	local startTime = os.clock()
	for currentFloor, wayPoints in pairs(self.waypoints) do
		for _, waypoint in pairs(wayPoints) do
			self:_createElevationItems(waypoint.pos, ROPE_LADDER_SCHEMA, "north")
		end
	end

	print("Creating elevations between floors done, execution time: " .. os.clock() - startTime)
end

function ElevationManager:createDesertRamps()
	local startTime = os.clock()
	for currentFloor, wayPoints in pairs(self.waypoints) do
		for _, waypoint in pairs(wayPoints) do
			local directions = {"north","east","south","south"} -- random directions
			self:_createElevationItems(waypoint.pos, DESERT_RAMP_SCHEMA, directions[math.random(1, #directions)])
		end
	end

	print("Creating elevations between floors done, execution time: " .. os.clock() - startTime)
end

function ElevationManager:_createElevationItems(mainPos, elevationSchema, direction)
	if not inArray({"north","east","south","south"}, direction) then
		error("Incorrect direction argument value.")
	end

	if (elevationSchema["upper"][direction] == nil or
		elevationSchema["lower"][direction] == nil
	) then
		error("There is no elevation schema for given direction declared.")
	end

	local processFloor = function (pos, wallBorder, schema)
		for i = -1, 1 do
			for j = -1, 1 do
				local tmpPos = {x = pos.x + j, y = pos.y + i, z = pos.z}
				if (type(schema["schema"][i + 2][j + 2]) == "number") then
					if (schema["schema"][i + 2][j + 2] == 0) then
						removeAllUnwalkableItems(tmpPos, wallBorder)
					else
						removeAllItemsFromPos(tmpPos, false)
						doCreateItemMock(schema.itemId[schema["schema"][i + 2][j + 2]], 1, tmpPos)
					end
				end
			end
		end
	end

	processFloor({x = mainPos.x, y = mainPos.y, z = mainPos.z - 1}, self.wallBorder, elevationSchema["upper"][direction])
	processFloor({x = mainPos.x, y = mainPos.y, z = mainPos.z}, self.wallBorder, elevationSchema["lower"][direction])
end
