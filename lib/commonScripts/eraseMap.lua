function eraseMap()
	local mainPos = {
		x = MAP_CONFIGURATION.mainPos.x,
		y = MAP_CONFIGURATION.mainPos.y,
		z = MAP_CONFIGURATION.mainPos.z
	}
	local mapSizeX = MAP_CONFIGURATION.mapSizeX
	local mapSizeY = MAP_CONFIGURATION.mapSizeY
	local wpMinDist = MAP_CONFIGURATION.wpMinDist

	local generatedMap = GroundMapper.new(mainPos, mapSizeX, mapSizeY, wpMinDist)
	generatedMap:eraseMap()
end
