MapLuaSaver = {}
MapLuaSaver.__index = MapLuaSaver

function MapLuaSaver.new(rootPath, map, mapData)
	local instance = setmetatable({}, MapLuaSaver)
	instance.rootPath = rootPath
	instance.map = map
	instance.mapData = mapData

	return instance
end
