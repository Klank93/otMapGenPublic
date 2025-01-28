Marker = {}
Marker.__index = Marker

function Marker.new(map)
    local instance = setmetatable({}, Marker)
    instance.markersTab = {}
    instance.map = map

    return instance
end

function Marker:_cleanMarkers()
    print("Deleting old marker points, to delete count: " ..  #self.markersTab)

    for i = 1, #self.markersTab do
        self.markersTab[i] = nil
    end
end

function Marker:createMarkers(
        itemsTable,
        acceptedGroundItemId,
        markersAmount,
        minDistanceBetweenTwoMarkers
)
    local startTime = os.clock()
    local counter = 0
    local status = true

    print("Creating " .. markersAmount .. " markers...")
    self:_cleanMarkers()

    local minPos = {}
    local maxPos = {}

    if (acceptedGroundItemId == itemsTable[0][1]) then
        -- todo: it's some modification in comparison to original version of the code
        -- todo: check why (probably something with decrease working area of the map)
        minPos.x = (self.map.pos.x + (self.map.wpMinDist/2))
        minPos.y = (self.map.pos.y + (self.map.wpMinDist/2))
        minPos.z = self.map.pos.z

        maxPos.x = (self.map.pos.x - (self.map.wpMinDist/2)) + self.map.sizeX
        maxPos.y = (self.map.pos.y - (self.map.wpMinDist/2)) + self.map.sizeY
        maxPos.z = self.map.pos.z
    else
        -- todo: originally it was only this \/
        minPos.x = (self.map.pos.x + self.map.wpMinDist)
        minPos.y = (self.map.pos.y + self.map.wpMinDist)
        minPos.z = self.map.pos.z

        maxPos.x = (self.map.pos.x - self.map.wpMinDist) + self.map.sizeX
        maxPos.y = (self.map.pos.y - self.map.wpMinDist) + self.map.sizeY
        maxPos.z = self.map.pos.z
    end

    local i = 1
    repeat
        repeat -- shooting loop
            local xRand = math.random(minPos.x, maxPos.x)
            local yRand = math.random(minPos.y, maxPos.y)
            local randPos = {}
            randPos.x = xRand
            randPos.y = yRand
            randPos.z = self.map.pos.z -- todo: has to be refactored in case of multi-floor functionality
            local tab = {}

            table.insert(tab, 1, randPos)
            table.insert(tab, 2, true)

            counter = counter + 1
            if (counter > 5000) then -- safety-fuse
                print("----- Creating markers failed, repeating the procedure from scratch -----")
                status = false -- starts again
                counter = 0
                print("Markers - safety-fuse kaboom, marker nr - " .. i)
                break
            end

            for j = 1, #self.markersTab do
                if (i ~= j) then -- todo: to fix, for the first shot it does not check the ground
                    local pointDist = pointDistance(tab[1], self.markersTab[j][1])
                    if (pointDist < minDistanceBetweenTwoMarkers) then
                        tab[2] = false
                        break
                    end
                    if (getThingFromPosMock(
                            {x = tab[1].x, y = tab[1].y, z = tab[1].z, stackpos = 0}
                        ).itemid ~= acceptedGroundItemId
                    ) then --- POPRAWKA DLA WIELU MAIN GROUNDOW, zamienic na isWalkable(pos)
                        tab[2] = false
                        break
                    end
                end
            end

            if (tab[2]) then
                table.insert(self.markersTab, i, tab)
                -- print("SHOOTED i = " .. i .. " counter = " .. counter .. " tab.x - " .. tab[1].x ..", tab.y - " .. tab[1].y .. ", tab.z - " .. tab[1].z)
            end
        until tab[2] == true

        if (status == false) then
            break
        end
        counter = 0
        i = i + 1
    until (i > markersAmount)

    if (status == false) then
        self:createMarkers(
                itemsTable,
                acceptedGroundItemId,
                markersAmount,
                minDistanceBetweenTwoMarkers
        )
    else
        -- print(dumpVar(self.markersTab))
        print("Markers created, execution time: " .. os.clock() - startTime)
    end
end

function Marker:createMarkersAlternatively( -- performance improvement ~40% in comparison to original method
        acceptedGroundItemId, -- if set to 0, it will create markers on all walkable tiles (not on just one ground)
        -- otherwise only on the map tiles with ground itemid == acceptedGroundItemId
        markersAmount,
        minDistanceBetweenTwoMarkers
)
    local startTime = os.clock()
    local acceptedMapTilesTab = {}
    print("Creating " .. markersAmount .. " markers alternatively..., #acceptedMapTilesTab: " .. #acceptedMapTilesTab)
    self:_cleanMarkers()

    for i = self.map.pos.y, self.map.pos.y + self.map.sizeY - 1 do
        for j = self.map.pos.x, self.map.pos.x + self.map.sizeX - 1 do
            if (acceptedGroundItemId == 0) then
                local isWalkable = isWalkable(
                        {x = j, y = i, z = self.map.mainPos.z}
                ) -- todo: always returns false in CLI
                if (isWalkable) then
                    table.insert(
                            acceptedMapTilesTab,
                            {x = j, y = i, z = self.map.mainPos.z}
                    ) -- todo: no multi-floor
                end
            elseif (getThingFromPosMock(
                    {x = j, y = i, z = self.map.mainPos.z, stackpos = 0}
                ).itemid == acceptedGroundItemId
            ) then
                table.insert(
                        acceptedMapTilesTab,
                        {x = j, y = i, z = self.map.mainPos.z}
                ) -- todo: no multi-floor
            end
        end
    end

    print("Initial acceptedMapTilesTab length: " .. #acceptedMapTilesTab)

    local markersCounter = 1
    repeat
        -- print("Creating marker: " .. markersCounter .. ", memory usage: " .. round(collectgarbage("count"), 3) .. ' kB')
        -- print("Current acceptedMapTilesTab length: " .. #acceptedMapTilesTab .. ", wpCounter: " .. markersCounter)
        if (#acceptedMapTilesTab < 1) then
            error("Can not create more markers, with given parameters." ..
                    " Please, change the configuration, current count: " ..
                    #self.markersTab .. ' markersCounter: ' .. markersCounter ..
                    ", availableTiles: " .. #acceptedMapTilesTab
            )
            break
        end

        local randomIndex = math.random(1, #acceptedMapTilesTab)
        local randomPos = {
            x = acceptedMapTilesTab[randomIndex].x,
            y = acceptedMapTilesTab[randomIndex].y,
            z = self.map.mainPos.z
        } -- todo: no multi-floor

        local i = 1
        while i <= #acceptedMapTilesTab do
            if (pointDistance(randomPos, acceptedMapTilesTab[i]) < minDistanceBetweenTwoMarkers) then
                table.remove(acceptedMapTilesTab, i)
            else
                i = i + 1
            end
        end

        -- print("acceptedMapTilesTab count: " .. #acceptedMapTilesTab .. " after removal")
        -- doCreateItemMock(598, 1, {x = j, y = i, z = pos.z}) -- point the marker (lava tile)

        table.insert(self.markersTab, {randomPos, true}) -- true <- backward compatibility
        markersCounter = markersCounter + 1
        acceptedMapTilesTab = {unpack(acceptedMapTilesTab, 1, #acceptedMapTilesTab)}
    until markersCounter > markersAmount

    print("Available map tiles for potential new markers count: " .. #acceptedMapTilesTab .. " after the procedure.")
    -- /\ if #acceptedMapTilesTab is near to 0, reconsider decreasing
    -- the value of minDistanceBetweenTwoMarkers or increase the map size
    print("Markers created alternatively, execution time: ".. os.clock() - startTime)
end