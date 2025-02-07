MapCreator = {}
MapCreator.__index = MapCreator

function MapCreator.new(map)
    local instance = setmetatable({}, MapCreator)
    instance.map = map

    return instance
end

function MapCreator:drawMap(currentFloor)
    if not (PRECREATION_TABLE_MODE) then
        do return end
    end

	local startTime = os.clock()
	PRECREATION_TABLE_MODE = false -- disable to be able to finally create actual map
	local drawning = function (i, j, floor)
		if (CLI_FINAL_MAP_TABLE[i][j][floor][1].itemid ~= nil) then
			for key, value in pairs(CLI_FINAL_MAP_TABLE[i][j][floor]) do
				doCreateItemMock(
					value.itemid,
					value.typeOrCount,
					{x = i, y = j, z = floor, stackpos = (key - 1)},
					value.stackPosSafe
				)
			end
		end
	end

	local startingFloor = self.map.mainPos.z - (self.map.sizeZ - 1)
	local endingFloor = self.map.mainPos.z
	if (currentFloor ~= nil) then
		startingFloor = currentFloor
		endingFloor = currentFloor
	end

	for k = startingFloor, endingFloor do
		print('Drawning floor: ' .. k)
		for i = self.map.mainPos.x, self.map.mainPos.x + self.map.sizeX do -- todo: watchout, there was an issue with additional 1 sqm
			for j = self.map.mainPos.y, self.map.mainPos.y + self.map.sizeY do -- todo: watchout, there was an issue with additional 1 sqm
				drawning(i, j, k)
			end
		end
	end

	if (currentFloor ~= nil) then
		print("Map tiles created for floor: " .. currentFloor .. ", execution time: " .. os.clock() - startTime)
	else
		print("Map tiles created, execution time: " .. os.clock() - startTime)
	end
end

function MapCreator:drawChunk(iterationStepsCountPerChunk) -- todo !!!
	local currentPos = {}

	-- Helper function to iterate over the table
	local function iterate(tbl, pos, depth)
		for k, v in pairs(tbl) do
			pos[depth] = k
			if type(v) == "table" then
				iterate(v, pos, depth + 1)
			else
				print(table.concat(pos, ", ") .. " = " .. tostring(v))
			end
		end
	end

	-- Iterating function, which go through all table elements
	function iterateNSteps(tbl, n)
		local steps = 0
		local pos = currentPos

		local function innerIterate(tbl, depth)
			for k, v in pairs(tbl) do
				pos[depth] = k
				if type(v) == "table" then
					innerIterate(v, depth + 1)
				else
					print(table.concat(pos, ", ") .. " = " .. tostring(v))
					steps = steps + 1
					if steps == n then
						currentPos = pos
						return true -- Stop after n iteration
					end
				end
			end
			return false
		end

		if not innerIterate(tbl, 1) then
			currentPos = {} -- Reset after finishing whole iteration
		end
	end

	addEvent(
		iterateNSteps(CLI_FINAL_MAP_TABLE, iterationStepsCountPerChunk)
	)
end
