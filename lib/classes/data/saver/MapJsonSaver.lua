local json = require(ROOT_PATH .. 'lib/externalResources/json/dkjson')

MapJsonSaver = {}
MapJsonSaver.__index = MapJsonSaver

function MapJsonSaver.new(map, mapData)
	local instance = setmetatable({}, MapJsonSaver)
	instance.map = map
	instance.mapData = mapData

	return instance
end

function MapJsonSaver:serializeMapData()
	local serializedData = {
		['map'] = {}
	}

	for x, xData in pairs(self.mapData) do
		serializedData['map'][x] = {}
		for y, yData in pairs(xData) do
			serializedData['map'][x][y] = {}
			for z, zData in pairs(yData) do
				serializedData['map'][x][y][z] = {}

				-- Zamiast trzymać `stackpos` jako indeks, zamień go na klucz
				for stackpos, itemData in ipairs(zData) do
					table.insert(serializedData['map'][x][y][z], {
						stackpos = stackpos,
						item = itemData
					})
				end
			end
		end
	end

	return serializedData
end

function MapJsonSaver:save(generalStartTime)
	local filename = ROOT_PATH .. 'generatedFiles/json/' ..
		MAP_CONFIGURATION.saveMapFilename ..
		string.format('-%s.json', generalStartTime)
	print('# Running saving map: ' .. filename)

	local file = io.open(filename, "w")
	if not file then return false, "Cannot output stream file" end

	local serializedData = self:serializeMapData()

	file:write(json.encode(serializedData, { indent = true })) -- Użycie indentacji dla czytelności
	file:close()

	print('# Saving map: ' .. filename .. ' finished.')

	return true
end

