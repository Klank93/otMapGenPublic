function eraseMap()
	if (RUNNING_MODE ~= 'tfs') then
		error("Erasing map is available only for TFS mode.")
	end

	local mainPos = {
		x = MAP_CONFIGURATION.mainPos.x,
		y = MAP_CONFIGURATION.mainPos.y,
		z = MAP_CONFIGURATION.mainPos.z
	}
	local mapSizeX = MAP_CONFIGURATION.mapSizeX
	local mapSizeY = MAP_CONFIGURATION.mapSizeY
	local mapSizeZ = MAP_CONFIGURATION.mapSizeZ
	local wpMinDist = MAP_CONFIGURATION.wpMinDist

	local generatedMap = GroundMapper.new(mainPos, mapSizeX, mapSizeY, mapSizeZ, wpMinDist)
	generatedMap:eraseMap()
end
