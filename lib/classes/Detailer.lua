Detailer = {}
Detailer.__index = Detailer

function Detailer.new(map, wayPoints)
    local instance = setmetatable({}, Detailer)
    instance.map = map
    instance.wayPoints = wayPoints
    instance.alreadyUsedTilesForDetails = {}

    return instance
end

function Detailer:createDetailsInRooms(rmsh, itemsTab, wallBorder)
    local startTime = os.clock()
    for a=1, #self.wayPoints do
        local pillar = math.random(1,#itemsTab[5]) -- chooses pillars for specific room
        local fountain = math.random(1,#itemsTab[17])
        local pom = {}
        local heightEven = (self.wayPoints[a][4] % 2)
        local widthEven = (self.wayPoints[a][5] % 2)
        local shapeId = self.wayPoints[a][3]
        local height = self.wayPoints[a][4]
        local width = self.wayPoints[a][5]

        pom.x = self.wayPoints[a][1].x
        pom.y = self.wayPoints[a][1].y
        pom.z = self.wayPoints[a][1].z

        -- sets pom
        if (heightEven == 0) then -- even height of the room
            pom.y = (pom.y - (height / 2) + 1 ) -- + math.random(0,1)
        elseif (heightEven == 1) then
            pom.y = (pom.y - (height / 2) + 0.5)
        end

        if (widthEven == 0) then -- even width of the room
            pom.x = (pom.x - (width / 2) + 1 ) -- + math.random(0,1)
        elseif (widthEven == 1) then
            pom.x = (pom.x - (width / 2) + 0.5)
        end

        for i=1, height do
            for j=1, width do
                local valueInShapeTable = rmsh[shapeId].shape[i][j]
                if (valueInShapeTable == 2) then
                    -- if there are minimum two walls around, there is need to check if it's doing well
                    if (math.random(1,3) == 1) then
                        local itemsTabItemId = itemsTab[2][math.random(1,#itemsTab[2])]
                        -- doCreateItemMock(itemsTabItemId, 1, pom)
                        local pom2 = {}
                        local counter = 0
                        pom2.x = pom.x - 1
                        pom2.y = pom.y - 1
                        pom2.z = pom.z
    
                        for i1 = 0,2 do
                            for j1 = 0,2 do
                                local identify = getThingFromPosMock(
                                        {x = pom2.x + j1, y = pom2.y + i1, z = pom2.z, stackpos = 1}
                                ).itemid
                                if (pom == pom2) then
                                    break
                                end
                                if ((identify == wallBorder[1][1])
                                        or (identify == wallBorder[2][1])
                                        or (identify == wallBorder[3][1])
                                        or (identify == wallBorder[4][1])
                                ) then
                                    counter = counter + 1
                                end
                            end
                        end
                        if (counter > 2) then
                            doCreateItemMock(itemsTabItemId, 1, pom)
                            --print("2 id - " .. itemsTabItemId)
                        end
                    end
                elseif (valueInShapeTable == 3) then
                    --- poprawki sprawdzania do okola pol, petla po height - 4, 
                    --- width - 3, tworzy jesli licznik >= 4 i (pom ~= pom2 oraz pom2.y+1)
                    local rand = math.random(1,#itemsTab[3])
                    local itemsTabItem11 = itemsTab[3][rand][1]
                    local itemsTabItem12 = itemsTab[3][rand][2]
                    local pom2 = {}
                    local counter = 0
                    pom2.x = pom.x - 1
                    pom2.y = pom.y
                    pom2.z = pom.z

                    for i1 = 0,1 do
                        local identify = getThingFromPosMock(
                                {x = pom2.x, y = pom2.y + i1, z = pom2.z, stackpos = 1}
                        ).itemid
                        if ((identify == wallBorder[1][1])
                                or (identify == wallBorder[2][1])
                                or (identify == wallBorder[3][1])
                                or (identify == wallBorder[4][1])
                        ) then
                            counter = counter + 1
                        end
                    end

                    pom2.x = pom.x + 1
                    pom2.y = pom.y

                    for i1 = 0,1 do
                        local identify = getThingFromPosMock(
                                {x = pom2.x, y = pom2.y + i1, z = pom2.z, stackpos = 1}
                        ).itemid
                        if ((identify == wallBorder[1][1])
                                or (identify == wallBorder[2][1])
                                or (identify == wallBorder[3][1])
                                or (identify == wallBorder[4][1])
                        ) then
                            counter = counter + 1
                        end
                    end
                    if (counter >= 2) then  -- test
                        --print("Counter 3 : " .. counter)
                        doCreateItemMock(itemsTabItem11, 1, pom)
                        doCreateItemMock(
                                itemsTabItem12,
                                1,
                                {x = pom.x, y = pom.y + 1, z = pom.z}
                        )
                    end
                elseif (valueInShapeTable == 4) then
                    --- poprawki sprawdzania do okola pol, petla po height - 3,
                    --- width - 4, tworzy jesli licznik >= 4 i (pom ~= pom2 oraz pom2.x+1)
                    local rand = math.random(1,#itemsTab[4])
                    local itemsTabItem21 = itemsTab[4][rand][1]
                    local itemsTabItem22 = itemsTab[4][rand][2]

                    local pom2 = {}
                    local counter = 0
                    pom2.x = pom.x
                    pom2.y = pom.y - 1
                    pom2.z = pom.z

                    for i1 = 0,1 do
                        local identify = getThingFromPosMock(
                                {x = pom2.x + i1, y = pom2.y, z = pom2.z, stackpos = 1}
                        ).itemid
                        if ((identify == wallBorder[1][1])
                                or (identify == wallBorder[2][1])
                                or (identify == wallBorder[3][1])
                                or (identify == wallBorder[4][1])
                        ) then
                            counter = counter + 1
                        end
                    end

                    pom2.x = pom.x
                    pom2.y = pom.y + 1

                    for i1 = 0,1 do
                        local identify = getThingFromPosMock(
                                {x = pom2.x + i1, y = pom2.y, z = pom2.z, stackpos = 1}
                        ).itemid
                        if ((identify == wallBorder[1][1])
                                or (identify == wallBorder[2][1])
                                or (identify == wallBorder[3][1])
                                or (identify == wallBorder[4][1])
                        ) then
                            counter = counter + 1
                        end
                    end

                    if (counter >= 2) then
                        --	print("Licznik 4 : " .. counter)
                        doCreateItemMock(itemsTabItem21, 1, pom)
                        doCreateItemMock(
                                itemsTabItem22,
                                1,
                                {x = pom.x + 1, y = pom.y, z = pom.z}
                        )
                    end
                elseif (valueInShapeTable == 5) then
                    local rand = math.random(1,#itemsTab[5][pillar])
                    local itemsTabItem3 = itemsTab[5][pillar][rand]

                    -- checks 8 tiles around the pom
                    local pom2 = {}
                    local counter = 0
                    pom2.x = pom.x - 1
                    pom2.y = pom.y - 1
                    pom2.z = pom.z

                    for i1 = 0,2 do
                        for j1 = 0,2 do
                            --	local identify = getThingFromPosMock({x = pom2.x + j1, y = pom2.y + i1, z = pom2.z, stackpos = 1}).itemid
                            if (pom == pom2) then
                                pom2.x = pom2.x + 1
                                break
                            end
                            if not (isWalkable(pom2)) then
                                counter = counter + 1
                            end
                            pom2.x = pom2.x + 1
                        end
                        pom2.x = pom.x - 1
                        pom2.y = pom2.y + 1
                    end
                    if (counter > 2) then
                        doCreateItemMock(itemsTabItem3, 1, pom)
                    end
                elseif (valueInShapeTable == 6) then
                    local rand = math.random(1,#itemsTab[5][pillar])
                    local itemsTabItem3 = itemsTab[5][pillar][rand]
                    doCreateItemMock(itemsTabItem3, 1, pom)
                elseif (valueInShapeTable == 15) then
                    if not (isWalkable({x = pom.x, y = pom.y - 1, z = pom.z, stackpos = 1})) then
                        local statue1 = math.random(1,#itemsTab[15]) -- this and below can be connected
                        local rand = math.random(1,#itemsTab[15][statue1])
                        local itemsTabItem4 = itemsTab[15][statue1][rand]

                        doCreateItemMock(itemsTabItem4, 1, pom)
                        -- print("rm: ".. a .. "  15: STWORZYLO")
                    else
                        -- print("rm: ".. a .. "  15: NIE STWORZYLO")
                    end
                elseif (valueInShapeTable == 16) then
                    if not (isWalkable({x = pom.x - 1, y = pom.y, z = pom.z, stackpos = 1})) then
                        local statue1 = math.random(1,#itemsTab[16]) -- this and below can be connected
                        local rand = math.random(1,#itemsTab[16][statue1])
                        local itemsTabItem4 = itemsTab[16][statue1][rand]

                        doCreateItemMock(itemsTabItem4, 1, pom)
                        -- print("rm: ".. a .. "  16: STWORZYLO")
                    else
                        -- print("rm: ".. a .. "  16: NIE STWORZYLO")
                    end
                elseif (valueInShapeTable == 17) then
                    --local rand = math.random(1,#itemsTab[17][fountain])
                    local pom3 = {}
                    local counter = 0
                    pom3.x = pom.x - 1
                    pom3.y = pom.y - 1
                    pom3.z = pom.z

                    for i1 = 0,3 do
                        local identify = getThingFromPosMock(
                                {x = pom3.x + i1, y = pom3.y, z = pom3.z, stackpos = 1}
                        ).itemid
                        local identify2 = getThingFromPosMock(
                                {x = pom3.x + i1, y = pom3.y + 3, z = pom3.z, stackpos = 1}
                        ).itemid
                        if ((identify == wallBorder[1][1])
                                or (identify == wallBorder[2][1])
                                or (identify == wallBorder[3][1])
                                or (identify == wallBorder[4][1])
                        ) then
                            counter = counter + 1
                        elseif ((identify2 == wallBorder[1][1])
                                or (identify2 == wallBorder[2][1])
                                or (identify2 == wallBorder[3][1])
                                or (identify2 == wallBorder[4][1])
                        ) then
                            counter = counter + 1
                        end
                    end

                    pom3.x = pom.x - 1
                    pom3.y = pom.y

                    for i1 = 0,1 do
                        local identify = getThingFromPosMock(
                                {x = pom3.x , y = pom3.y + i1, z = pom3.z, stackpos = 1}
                        ).itemid
                        local identify2 = getThingFromPosMock(
                                {x = pom3.x + 3, y = pom3.y + i1, z = pom3.z, stackpos = 1}
                        ).itemid
                        if ((identify == wallBorder[1][1])
                                or (identify == wallBorder[2][1])
                                or (identify == wallBorder[3][1])
                                or (identify == wallBorder[4][1])
                        ) then
                            counter = counter + 1
                        elseif ((identify2 == wallBorder[1][1])
                                or (identify2 == wallBorder[2][1])
                                or (identify2 == wallBorder[3][1])
                                or (identify2 == wallBorder[4][1])
                        ) then
                            counter = counter + 1
                        end
                    end

                    if ((counter >= 4) or (counter == 0)) then
                        local pom2 = {}
                        pom2.x = pom.x
                        pom2.y = pom.y
                        pom2.z = pom.z
                        for ai = 1, 2 do
                            for aj = 1,2 do
                                local itemsTabItem5 = itemsTab[17][fountain][ai][aj]
                                doCreateItemMock(itemsTabItem5, 1, pom2)
                                pom2.x = pom2.x + 1
                            end
                            pom2.x = pom2.x - 2
                            pom2.y = pom2.y + 1
                        end
                        --print("Licznik 17 : " .. counter)
                    end
                elseif (valueInShapeTable == 23 and itemsTab[23] ~= nil) then
                    local statue1 = math.random(1,#itemsTab[23]) -- this and below can be connected
                    local rand = math.random(1,#itemsTab[23][statue1])
                    local itemsTabItem6 = itemsTab[23][statue1][rand]
                    doCreateItemMock(itemsTabItem6, 1, pom)
                elseif (valueInShapeTable == 24 and itemsTab[24] ~= nil) then
                    local statue2 = math.random(1,#itemsTab[24]) -- this and below can be connected
                    local rand = math.random(1,#itemsTab[24][statue2])
                    local itemsTabItem6 = itemsTab[24][statue2][rand]
                    doCreateItemMock(itemsTabItem6, 1, pom)
                end
                pom.x = pom.x + 1
            end
            pom.x = pom.x - width
            pom.y = pom.y + 1
        end
    end
    print("Making details in rooms done, execution time: " .. os.clock() - startTime)
end

function Detailer:createDetailsOnMap(itemsTab, chance) -- chance is int, percentage in range 1%-100%
    -- add details, trashes on the walkable tiles, which have less than 3 stackpos items on it
    -- todo: refactor, takes to much time
    local startTime = os.clock()
    local pom = {}
    local randomChance = 0
    pom.x = self.map.mainPos.x
    pom.y = self.map.mainPos.y
    pom.z = self.map.mainPos.z

    for i = self.map.mainPos.y, self.map.mainPos.y + self.map.sizeY do
        for j = self.map.mainPos.x, self.map.mainPos.x + self.map.sizeX do
            if (isWalkable(pom)) then
                local state = true
                for stack_i = 0, 8 do
                    local mapItem = getThingFromPosMock(
                            {x = pom.x, y = pom.y, z = pom.z, stackpos = stack_i}
                    )
                    if (mapItem.uid == 0) then
                        -- print("Stack - " .. stack_i)
                        if (stack_i > 2) then
                            state = false
                        end
                        break
                    end
                end

                if (state == true) then
                    local state2 = true
                    randomChance = math.random(1,100)
                    local item = itemsTab[math.random(1,#itemsTab)]
                    if (randomChance <= chance) then
                        -- checking details around the pom,
                        -- to prevent situation when we have the same details nearby
                        local pom2 = {}
                        pom2.x = pom.x - 1
                        pom2.y = pom.y - 1
                        pom2.z = pom.z
                        for yi = 0,2 do
                            for xj = 0,2 do
                                if (pom2 ~= pom) then
                                    for stack_xi = 0, 5 do
                                        local mapItem = getThingFromPosMock(
                                                {x = pom2.x, y = pom2.y, z = pom2.z, stackpos = stack_xi}
                                        )
                                        if (mapItem.itemid == item) then
                                            state2 = false
                                            --	print("The same item is already nearby, x - " .. pom2.x .. ", y - " .. pom2.y)
                                            break
                                        end
                                    end
                                end
                                pom2.x = pom2.x + 1
                            end

                            if state2 == false then
                                break
                            end
                            pom2.x = pom.x - 1
                            pom2.y = pom2.y + 1
                        end

                        if state2 == true then
                            doCreateItemMock(item, 1, pom)
                        end
                    end
                end
            end

            pom.x = pom.x + 1
        end
        pom.x = self.map.mainPos.x
        pom.y = pom.y + 1
    end
    print("Creating details on map done, execution time: " .. os.clock() - startTime)
end

function Detailer:createDetailsOnMapAlternatively(itemsTab, chance) -- chance is int, percentage in range 1%-100%
    -- add details, trashes on the walkable tiles, which have less than 3 stackpos items on it
    local startTime = os.clock()
    local acceptedMapTilesTab = {}

    for i = self.map.mainPos.y, self.map.mainPos.y + self.map.sizeY do
        for j = self.map.mainPos.x, self.map.mainPos.x + self.map.sizeX do
            local currentPos = {x = j, y = i, z = self.map.mainPos.z}
            local isWalkable = isWalkable(
                    currentPos
            ) -- todo: always returns false in CLI
            if (isWalkable and not inArray(self.alreadyUsedTilesForDetails, currentPos)) then
                table.insert(
                        acceptedMapTilesTab,
                        currentPos
                ) -- todo: no multi-floor
            end
        end
    end

    local tilesToAddDetails = getRandomArrayItems(acceptedMapTilesTab, chance)
    for i = 1, #tilesToAddDetails do
        local detailItem = itemsTab[math.random(1,#itemsTab)]
        doCreateItemMock(
                detailItem,
                1,
                tilesToAddDetails[i]
        )
        table.insert(
                self.alreadyUsedTilesForDetails,
                tilesToAddDetails[i]
        )
    end

    print("Creating " .. #tilesToAddDetails ..
            " details on map alternatively done, execution time: " ..
            os.clock() - startTime
    )
end

function Detailer:createHangableDetails(
        mainGroundItemId,
        wallBorder,
        itemsTab,
        chance
) -- chance is int, percentage in range 1%-100%
    local startTime = os.clock()
    local pom = {}
    pom.x = self.map.mainPos.x
    pom.y = self.map.mainPos.y
    pom.z = self.map.mainPos.z

    for i = self.map.mainPos.y, self.map.mainPos.y + self.map.sizeY - 1 do -- todo: can be out of map (CLI in original version crashes, out of tab)
        for j = self.map.mainPos.x, self.map.mainPos.x + self.map.sizeX - 1 do -- todo: can be out of map (CLI in original version crashes, out of tab)
            --print(dumpVar({x = pom.x, y = pom.y, z = pom.z, stackpos = 0}))
            --print('Test ' .. dumpVar(getThingFromPosMock({x = pom.x, y = pom.y, z = pom.z, stackpos = 0})))
            if (getThingFromPosMock(
                    {x = pom.x, y = pom.y, z = pom.z, stackpos = 0})
                    .itemid == mainGroundItemId
            ) then
                local mapItem = getThingFromPosMock(
                        {x = pom.x, y = pom.y, z = pom.z, stackpos = 1}
                )
                local randomChance = math.random(1,100)
                for ax = 1, #wallBorder[1] do
                    if (mapItem.itemid == wallBorder[1][ax]) then
                        if (randomChance <= chance) then
                            doCreateItemMock(
                                    itemsTab[18][math.random(1,#itemsTab[18])],
                                    1,
                                    pom
                            )
                            --	print("1 Created x:  " .. pom.x .. ",  y:  " .. pom.y ..  ",  itemid - ")
                        end
                    end
                end
                for ax = 1, #wallBorder[2] do
                    if (mapItem.itemid == wallBorder[2][ax]) then
                        if (randomChance <= chance) then
                            doCreateItemMock(
                                    itemsTab[19][math.random(1,#itemsTab[19])],
                                    1,
                                    pom
                            )
                            --	print("2 Created x:  " .. pom.x .. ",  y:  " .. pom.y ..  ",  itemid - ")
                        end
                    end
                end
                for ax = 1, #wallBorder[4] do
                    if (mapItem.itemid == wallBorder[4][ax]) then
                        if (randomChance <= chance) then
                            if (math.random(1,2) == 1) then
                                doCreateItemMock(
                                        itemsTab[18][math.random(1,#itemsTab[18])],
                                        1,
                                        pom
                                )
                                --	print("3 Created x:  " .. pom.x .. ",  y:  " .. pom.y ..  ",  itemid - ")
                            else
                                doCreateItemMock(
                                        itemsTab[19][math.random(1,#itemsTab[19])],
                                        1,
                                        pom
                                )
                                --	print("4 Created x:  " .. pom.x .. ",  y:  " .. pom.y ..  ",  itemid - ")
                            end
                        end
                    end
                end
            end
            pom.x = pom.x + 1
        end

        pom.x = pom.x - self.map.sizeX
        pom.y = pom.y + 1
    end
    print("Creating details on walls done, execution time: " .. os.clock() - startTime)
end

function Detailer:createDetailsInCave(
        markersTab,
        itemsTab,
        detailsSpawnSize,
        chance
)
    local startTime = os.clock()
    local walkableTabY = {}
    for i = 1, detailsSpawnSize do
        table.insert(walkableTabY , i, 0)
    end

    for ai = 1, #markersTab do
        local pom_tab = {}
        for i = 1, detailsSpawnSize do
            table.insert(pom_tab, i, {})
            for j = 1, detailsSpawnSize do
                table.insert(
                        pom_tab[i],
                        j,
                        itemsTab[1][math.random(1, #itemsTab[1])]
                )
            end
        end

        --[[
            print("__________________________________________")
            for i = 1, detailsSpawnSize do
                print("1: " .. pom_tab[i][1] .. " , 2: ".. pom_tab[i][2] .. " , 3: " .. pom_tab[i][3] .. ", 4: " .. pom_tab[i][4])
            end
        ]]--

        local pom = {}
        pom.x = markersTab[ai][1].x
        pom.y = markersTab[ai][1].y
        pom.z = markersTab[ai][1].z

        local hw_even = (detailsSpawnSize % 2)
        -- sets the pom
        if (hw_even == 0) then -- even height of the room
            pom.x = (pom.x - (detailsSpawnSize / 2) + 1 )
            pom.y = (pom.y - (detailsSpawnSize / 2) + 1 ) -- + math.random(0,1)
        elseif (hw_even == 1) then
            pom.x = (pom.x - (detailsSpawnSize / 2) + 0.5)
            pom.y = (pom.y - (detailsSpawnSize / 2) + 0.5)
        end

        for bi = 1, detailsSpawnSize do
            local walkableX = 0
            local pom2 = {}
            local pom3 = {}
            pom3.x = pom.x
            pom3.y = pom.y
            pom3.z = pom.z

            for bj = 1, detailsSpawnSize do
                if (isWalkable(pom)) then
                    walkableX = walkableX + 1
                end
                -- doCreateItemMock(2148, 1, pom)

                if (bi == 1) then
                    pom2.x = pom.x
                    pom2.y = pom.y
                    pom2.z = pom.z
                    for dj = 1, detailsSpawnSize do
                        if (isWalkable(pom2)) then
                            walkableTabY[bj] = walkableTabY[bj] + 1
                        end
                        --	doCreateItemMock(2159, 1, pom2)
                        pom2.y = pom2.y + 1
                    end
                end

                pom.x = pom.x + 1
            end

            if (walkableX >= 3) then
                for cj = 1, detailsSpawnSize do
                    if (walkableTabY[cj] >= 2 and
                            isWalkable(pom3) and
                            walkableX > 0 and
                            math.random(1,100) <= chance
                    ) then
                        doCreateItemMock(
                                pom_tab[bi][cj],
                                1,
                                pom3
                        )
                        walkableX = walkableX - 3
                        walkableTabY[cj] = walkableTabY[cj] - 3
                    end
                    pom3.x = pom3.x + 1
                end
            end

            pom.x = pom.x - detailsSpawnSize
            pom.y = pom.y + 1
        end

        for azi = 1, detailsSpawnSize do
            walkableTabY[azi] = 0
        end
    end
end
