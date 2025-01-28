MapCreator = {}
MapCreator.__index = MapCreator

function MapCreator.new(map)
    local instance = setmetatable({}, MapCreator)
    instance.map = map

    return instance
end

function MapCreator:drawMap()
    if not (PRECREATION_TABLE_MODE) then
        do return end
    end

    local startTime = os.clock()

    for i = self.map.mainPos.x, self.map.mainPos.x + self.map.sizeX do -- todo: watchout, there was an issue with additional 1 sqm
        for j = self.map.mainPos.y, self.map.mainPos.y + self.map.sizeY do -- todo: watchout, there was an issue with additional 1 sqm
            if (CLI_FINAL_MAP_TABLE[i][j][7][1].itemid ~= nil) then
                for key, value in pairs(CLI_FINAL_MAP_TABLE[i][j][7]) do
                    doCreateItem(
                            CLI_FINAL_MAP_TABLE[i][j][7][key].itemid,
                            CLI_FINAL_MAP_TABLE[i][j][7][key].typeOrCount,
                            {x = i, y = j, z = 7, stackpos = (key - 1)}
                    )
                end
            end
        end
    end

    print("Map tiles created, execution time: " .. os.clock() - startTime)
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
