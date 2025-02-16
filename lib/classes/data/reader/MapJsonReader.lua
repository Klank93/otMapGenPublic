local json = require(ROOT_PATH .. 'lib/externalResources/json/dkjson')

MapJsonReader = {}
MapJsonReader.__index = MapJsonReader

function MapJsonReader.new(map)
	local instance = setmetatable({}, MapJsonReader)
	instance.map = map
	return instance
end

function MapJsonReader:load(filename)
	local filePath = ROOT_PATH .. 'generatedFiles/json/' .. filename
	print('# Loading map from: ' .. filePath)

	local file = io.open(filePath, "r")
	if not file then
		return false, "Cannot open input stream file"
	end

	local content = file:read("*a")
	file:close()

	local data, _, err = json.decode(content, 1, nil)
	if err then
		return false, "JSON decoding error: " .. err
	end

	local map = self:deserializeMapData(data['map'])
	print("# Map: " .. filename .. " loading finished.")

	return map
end

function MapJsonReader:deserializeMapData(serializedData)
	local mapData = {}

	for x, xData in pairs(serializedData) do
		mapData[tonumber(x)] = {}
		for y, yData in pairs(xData) do
			mapData[tonumber(x)][tonumber(y)] = {}
			for z, zData in pairs(yData) do
				mapData[tonumber(x)][tonumber(y)][tonumber(z)] = {}

				for _, stackEntry in ipairs(zData) do
					local stackpos = stackEntry.stackpos
					local item = stackEntry.item
					mapData[tonumber(x)][tonumber(y)][tonumber(z)][stackpos] = item
				end
			end
		end
	end

	return mapData
end
