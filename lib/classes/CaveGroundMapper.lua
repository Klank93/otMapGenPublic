-- todo: methods of this class are completely not optimised
CaveGroundMapper = {}
CaveGroundMapper.__index = CaveGroundMapper

function CaveGroundMapper.new(mainPos, sizeX, sizeY, wpMinDist, wpMaxDist) -- todo: add more params, if needed
    local instance = setmetatable(CaveGroundMapper, GroundMapper)
    instance.mainPos = mainPos
    instance.pos = {x = mainPos.x, y = mainPos.y, z = mainPos.z} -- todo: maybe not needed?
    instance.sizeX = sizeX
    instance.sizeY = sizeY
    instance.wpMinDist = wpMinDist
    instance.wpMaxDist = wpMaxDist or 0 -- for middle/large maps the value can be set, other way keep 0 todo: does not work
    instance.wayPoints = {}

    return instance
end

function CaveGroundMapper:correctCaveShapes(
        mainGroundItemId,
        groundItemId,
        backGroundShapes
)
    local startTime = os.clock()
    local step = 1
    local length = 0
    local pom = {}
    pom.x = self.mainPos.x
    pom.y = self.mainPos.y
    pom.z = self.mainPos.z

    for i = self.mainPos.y, self.mainPos.y + self.sizeY do
        for j = self.mainPos.x, self.mainPos.x + self.sizeX do
            step = 1

            if(getThingFromPosMock(
                    {x = pom.x, y = pom.y, z = pom.z, stackpos = 0}
                ).itemid == groundItemId
            ) then
                for tabId = 1, 2 do
                    local state = true
                    length = 0

                    repeat
                        if (tabId == 1) then
                            if ((getThingFromPosMock(
                                    {x = pom.x + length, y = pom.y, z = pom.z, stackpos = 0}
                                ).itemid == groundItemId)  and (getThingFromPosMock(
                                        {x = pom.x + length, y = pom.y - 1, z = pom.z, stackpos = 0}
                                ).itemid == mainGroundItemId)
                            ) then
                                length = length + 1
                            else
                                state = false
                            end
                        elseif (tabId == 2) then
                            if ((getThingFromPosMock(
                                    {x = pom.x + length, y = pom.y, z = pom.z, stackpos = 0}
                                ).itemid == groundItemId)  and (getThingFromPosMock(
                                        {x = pom.x + length, y = pom.y + 1, z = pom.z, stackpos = 0}
                                ).itemid == mainGroundItemId) 
                            ) then
                                length = length + 1
                            else
                                state = false
                            end
                        end
                    until (state == false)

                    if (length >= 3) then
                        local counter = 0
                        local pom2 = {}
                        if (tabId == 1) then
                            pom2.x = pom.x
                            pom2.y = pom.y - 1
                        elseif (tabId == 2) then
                            pom2.x = pom.x
                            pom2.y = pom.y
                        end

                        pom2.z = pom.z

                        if (length > 1) then
                            step = length
                            if (length > 6) then
                                length = 6
                                step = 6
                            end
                            --	print ("Step: " .. step)
                        end

                        for ai = 1, #backGroundShapes[tabId][length][1] do
                            for aj = 1, #backGroundShapes[tabId][length][1][ai] do
                                local mapItemItemId = getThingFromPosMock(
                                        {x = pom2.x, y = pom2.y, z = pom2.z, stackpos = 0}
                                ).itemid

                                if (backGroundShapes[tabId][length][1][ai][aj] == 0) then
                                    if (mapItemItemId == groundItemId) then
                                        --doCreateItemMock(2148, 1, pom2)
                                        counter = counter + 1
                                    end
                                end
                                if (backGroundShapes[tabId][length][1][ai][aj] == 1) then
                                    if (mapItemItemId == mainGroundItemId) then
                                        --doCreateItemMock(2148, 1, pom2)
                                        counter = counter + 1
                                    end
                                end
                                pom2.x = pom2.x + 1
                            end
                            pom2.x = pom2.x - (length)
                            pom2.y = pom2.y + 1
                        end

                        if (counter == (length*2)) then
                            if (tabId == 1) then
                                pom2.x = pom.x
                                pom2.y = pom.y - 1
                            elseif (tabId == 2) then
                                pom2.x = pom.x
                                pom2.y = pom.y
                            end
                            --	doCreateItemMock(2178, 1, pom)
                            local shapeIndex = math.random(2,#backGroundShapes[tabId][length])

                            for ai = 1, #backGroundShapes[tabId][length][shapeIndex] do
                                for aj = 1, #backGroundShapes[tabId][length][shapeIndex][ai] do

                                    if (backGroundShapes[tabId][length][shapeIndex][ai][aj] == 2) then
                                        if not ((getThingFromPosMock(
                                                {x = pom.x - 1, y = pom.y, z = pom.z, stackpos = 0}
                                            ).itemid == mainGroundItemId)
                                            or (getThingFromPosMock(
                                                    {x = pom.x + length, y = pom.y, z = pom.z, stackpos = 0}
                                            ).itemid == mainGroundItemId)
                                        ) then
                                            doCreateItemMock(mainGroundItemId, 1, pom2)
                                            --print("ID ".. tabId .. "  Pos :  x - " .. pom2.x .. ", y - " .. pom2.y)
                                        else
                                            if (length <= 4) then
                                                if (getThingFromPosMock(
                                                        {x = pom.x - 1, y = pom.y, z = pom.z, stackpos = 0}
                                                    ).itemid == mainGroundItemId
                                                ) then
                                                    doCreateItemMock(mainGroundItemId, 1, pom)
                                                else
                                                    doCreateItemMock(
                                                            mainGroundItemId,
                                                            1,
                                                            {x = pom.x + length - 1, y = pom.y, z = pom.z}
                                                    )
                                                    --	print("ID ".. tabId .. "  Pos :  x - " .. pom2.x .. ", y - " .. pom2.y)
                                                end
                                            else
                                                doCreateItemMock(mainGroundItemId, 1, pom2)
                                            end
                                        end
                                    elseif (backGroundShapes[tabId][length][shapeIndex][ai][aj] == 3) then
                                        doCreateItemMock(groundItemId, 1, pom2)
                                        --print("ID ".. tabId .. "  Pos :  x - " .. pom2.x .. ", y - " .. pom2.y)
                                    elseif (backGroundShapes[tabId][length][shapeIndex][ai][aj] == 4) then
                                        if (math.random(1,100) <= 30) then
                                            doCreateItemMock(mainGroundItemId, 1, pom2)
                                        end
                                    end

                                    pom2.x = pom2.x + 1
                                end
                                pom2.x = pom2.x -(length)
                                pom2.y = pom2.y + 1
                            end
                        end
                    end
                end
            end

            pom.x = pom.x + step
        end
        pom.x = self.mainPos.x
        pom.y = pom.y + 1
    end
    --------------------------------------------------
    print("Part I Done, execution time: " .. os.clock() - startTime)

    step = 1
    length = 0

    pom.x = self.mainPos.x
    pom.y = self.mainPos.y
    pom.z = self.mainPos.z

    for i = self.mainPos.x, self.mainPos.x + self.sizeX do
        for j = self.mainPos.y, self.mainPos.y + self.sizeY do
            step = 1
            if (getThingFromPosMock(
                    {x = pom.x, y = pom.y, z = pom.z, stackpos = 0}
                ).itemid == groundItemId
            ) then
                for tabId = 3, 4 do
                    local state = true
                    length = 0

                    repeat
                        if (tabId == 3) then
                            if ((getThingFromPosMock(
                                    {x = pom.x, y = pom.y + length, z = pom.z, stackpos = 0}
                                    ).itemid == groundItemId)
                                and (getThingFromPosMock(
                                        {x = pom.x + 1, y = pom.y + length, z = pom.z, stackpos = 0}
                                    ).itemid == mainGroundItemId)
                            ) then
                                length = length + 1
                            else
                                state = false
                            end
                        elseif (tabId == 4) then
                            if ((getThingFromPosMock(
                                    {x = pom.x, y = pom.y + length, z = pom.z, stackpos = 0}
                                    ).itemid == groundItemId)
                                and (getThingFromPosMock(
                                        {x = pom.x - 1, y = pom.y + length, z = pom.z, stackpos = 0}
                                ).itemid == mainGroundItemId)
                            ) then
                                length = length + 1
                            else
                                state = false
                            end
                        end
                    until (state == false)

                    if (length >= 3) then
                        local counter = 0
                        local pom2 = {}
                        if (tabId == 3) then
                            pom2.x = pom.x
                            pom2.y = pom.y
                        elseif (tabId == 4) then
                            pom2.x = pom.x - 1
                            pom2.y = pom.y
                        end

                        pom2.z = pom.z

                        if (length > 1) then
                            step = length
                            if (length > 6) then
                                length = 6
                                step = 6
                            end
                            --print ("Step: " .. step)
                        end


                        for ai = 1, #backGroundShapes[tabId][length][1][1] do
                            for aj = 1, #backGroundShapes[tabId][length][1] do
                                local mapItemItemId = getThingFromPosMock(
                                        {x = pom2.x, y = pom2.y, z = pom2.z, stackpos = 0}
                                ).itemid

                                if (backGroundShapes[tabId][length][1][aj][ai] == 0) then
                                    if ( mapItemItemId == groundItemId ) then
                                        --doCreateItemMock(2148, 1, pom2)
                                        counter = counter + 1
                                    end
                                end
                                if (backGroundShapes[tabId][length][1][aj][ai] == 1) then
                                    if (mapItemItemId == mainGroundItemId) then
                                        --	doCreateItemMock(2148, 1, pom2)
                                        counter = counter + 1
                                    end
                                end
                                pom2.y = pom2.y + 1
                            end
                            pom2.y = pom2.y - (length)
                            pom2.x = pom2.x + 1
                        end

                        if (counter == (length*2)) then
                            if (tabId == 3) then
                                pom2.x = pom.x
                                pom2.y = pom.y
                            elseif (tabId == 4) then
                                pom2.x = pom.x - 1
                                pom2.y = pom.y
                            end
                            --doCreateItemMock(2178, 1, pom)

                            local shapeIndex = math.random(2,#backGroundShapes[tabId][length])

                            for ai = 1, #backGroundShapes[tabId][length][shapeIndex][1] do
                                for aj = 1, #backGroundShapes[tabId][length][shapeIndex] do
                                    if (backGroundShapes[tabId][length][shapeIndex][aj][ai] == 2) then
                                        if not((getThingFromPosMock(
                                                {x = pom.x, y = pom.y - 1, z = pom.z, stackpos = 0}
                                                ).itemid == mainGroundItemId)
                                            or (getThingFromPosMock(
                                                {x = pom.x, y = pom.y + length, z = pom.z, stackpos = 0}
                                            ).itemid == mainGroundItemId)
                                        ) then
                                            doCreateItemMock(mainGroundItemId, 1, pom2)
                                            --	print("ID ".. tabId .. "  Pos :  x - " .. pom2.x .. ", y - " .. pom2.y)
                                        else
                                            if (length <= 4) then
                                                if (getThingFromPosMock(
                                                        {x = pom.x, y = pom.y - 1, z = pom.z, stackpos = 0}
                                                    ).itemid == mainGroundItemId
                                                ) then
                                                    doCreateItemMock(mainGroundItemId, 1, pom)
                                                else
                                                    doCreateItemMock(
                                                            mainGroundItemId,
                                                            1,
                                                            {x = pom.x, y = pom.y + length - 1, z = pom.z}
                                                    )
                                                    --	print("ID ".. tabId .. "  Pos :  x - " .. pom2.x .. ", y - " .. pom2.y)
                                                end
                                            else
                                                doCreateItemMock(mainGroundItemId, 1, pom2)
                                            end
                                        end
                                    elseif (backGroundShapes[tabId][length][shapeIndex][aj][ai] == 3) then
                                        doCreateItemMock(groundItemId, 1, pom2)
                                        --print("ID ".. tabId .. "  Pos :  x - " .. pom2.x .. ", y - " .. pom2.y)
                                    elseif (backGroundShapes[tabId][length][shapeIndex][aj][ai] == 4) then
                                        if (math.random(1,100) <= 30) then
                                            doCreateItemMock(mainGroundItemId, 1, pom2)
                                        end
                                    end

                                    pom2.y = pom2.y + 1
                                end
                                pom2.y = pom2.y -(length)
                                pom2.x = pom2.x + 1
                            end
                        end
                    end
                end
            end

            pom.y = pom.y + step
        end
        pom.y = self.mainPos.y
        pom.x = pom.x + 1
    end


    print("Part II Done, execution time: " .. os.clock() - startTime)

    pom.x = self.mainPos.x
    pom.y = self.mainPos.y
    pom.z = self.mainPos.z

    for i = self.mainPos.y, self.mainPos.y + self.sizeY do
        for j = self.mainPos.x, self.mainPos.x + self.sizeX do
            if (getThingFromPosMock(
                    {x = pom.x, y = pom.y, z = pom.z, stackpos = 0}
                ).itemid == groundItemId
            ) then
                if (getThingFromPosMock(
                        {x = pom.x + 1, y = pom.y, z = pom.z, stackpos = 0}
                    ).itemid == mainGroundItemId
                ) then
                    local pom2 = {}
                    for tabId = 1,2 do
                        local counter = 0
                        if (tabId == 1) then
                            pom2.x = pom.x - 2
                        else
                            pom2.x = pom.x
                        end
                        pom2.y = pom.y
                        pom2.z = pom.z
                        for ai = 1, #backGroundShapes[5][tabId][1] do
                            for aj = 1, #backGroundShapes[5][tabId][1][ai] do
                                if (backGroundShapes[5][tabId][1][ai][aj] == 0) then
                                    if (getThingFromPosMock(pom2).itemid == groundItemId)  then
                                        counter = counter + 1
                                    else
                                        break
                                    end
                                elseif (backGroundShapes[5][tabId][1][ai][aj] == 1) then
                                    if (getThingFromPosMock(pom2).itemid == mainGroundItemId)  then
                                        counter = counter + 1
                                    else
                                        break
                                    end
                                end

                                pom2.x = pom2.x + 1
                            end
                            pom2.x = pom2.x - 4
                            pom2.y = pom2.y + 1
                        end

                        if (counter == 12) then
                            if (math.random(1,100) <= 30) then
                                if (tabId == 1) then
                                    pom2.x = pom.x - 2
                                else
                                    pom2.x = pom.x
                                end
                                pom2.y = pom.y
                                pom2.z = pom.z

                                local shapeIndex = math.random(2, #backGroundShapes[5][tabId])
                                for ai = 1, #backGroundShapes[5][tabId][shapeIndex] do
                                    for aj = 1, #backGroundShapes[5][tabId][shapeIndex][ai] do
                                        if (backGroundShapes[5][tabId][shapeIndex][ai][aj] == 2) then
                                            doCreateItemMock(mainGroundItemId, 1, pom2)
                                        elseif (backGroundShapes[5][tabId][shapeIndex][ai][aj] == 3) then
                                            doCreateItemMock(groundItemId, 1, pom2)
                                        end
                                        pom2.x = pom2.x + 1
                                    end
                                    pom2.x = pom2.x - #backGroundShapes[5][tabId][shapeIndex][ai]
                                    pom2.y = pom2.y + 1
                                end
                            end
                        end
                    end

                elseif (getThingFromPosMock(
                        {x = pom.x - 1, y = pom.y, z = pom.z, stackpos = 0}
                    ).itemid == mainGroundItemId
                ) then
                    local pom2 = {}
                    for tabId = 3,4 do
                        local counter = 0
                        if (tabId == 3) then
                            pom2.x = pom.x - 1
                        else
                            pom2.x = pom.x - 3
                        end
                        pom2.y = pom.y
                        pom2.z = pom.z
                        for ai = 1, #backGroundShapes[5][tabId][1] do
                            for aj = 1, #backGroundShapes[5][tabId][1][ai] do
                                if (backGroundShapes[5][tabId][1][ai][aj] == 0) then
                                    if (getThingFromPosMock(pom2).itemid == groundItemId)  then
                                        counter = counter + 1
                                    else
                                        break
                                    end
                                elseif (backGroundShapes[5][tabId][1][ai][aj] == 1) then
                                    if (getThingFromPosMock(pom2).itemid == mainGroundItemId)  then
                                        counter = counter + 1
                                    else
                                        break
                                    end
                                end

                                pom2.x = pom2.x + 1
                            end
                            pom2.x = pom2.x - #backGroundShapes[5][tabId][1][ai]
                            pom2.y = pom2.y + 1
                        end

                        if (counter == 12) then
                            if (math.random(1,100) <= 30) then
                                if (tabId == 3) then
                                    pom2.x = pom.x - 1
                                else
                                    pom2.x = pom.x - 3
                                end
                                pom2.y = pom.y
                                pom2.z = pom.z

                                local shapeIndex = math.random(2, #backGroundShapes[5][tabId])
                                for ai = 1, #backGroundShapes[5][tabId][shapeIndex] do
                                    for aj = 1, #backGroundShapes[5][tabId][shapeIndex][ai] do
                                        if (backGroundShapes[5][tabId][shapeIndex][ai][aj] == 2) then
                                            doCreateItemMock(mainGroundItemId, 1, pom2)
                                        elseif (backGroundShapes[5][tabId][shapeIndex][ai][aj] == 3) then
                                            doCreateItemMock(groundItemId, 1, pom2)
                                        end
                                        pom2.x = pom2.x + 1
                                    end
                                    pom2.x = pom2.x - 4
                                    pom2.y = pom2.y + 1
                                end
                            end
                        end
                    end
                end
            end
            pom.x = pom.x + 1
        end
        pom.x = self.mainPos.x
        pom.y = pom.y + 1
    end
    print("Part III Done, execution time: " .. os.clock() - startTime)

    print("Correction of the cave shape done, execution time: " .. os.clock() - startTime)
end

function CaveGroundMapper:correctBackgroundShapes(
        mainGroundItemId,
        groundItemId,
        correctBackgroundShapes
)
    local startTime = os.clock()
    local pom = {}
    pom.x = self.mainPos.x
    pom.y = self.mainPos.y
    pom.z = self.mainPos.z

    for i = self.mainPos.y, self.mainPos.y + self.sizeY do
        for j = self.mainPos.x, self.mainPos.x + self.sizeX do
            local mapItemItemId = getThingFromPosMock(
                    {x = pom.x, y = pom.y, z = pom.z, stackpos = 0}
            ).itemid
            if (mapItemItemId == groundItemId) then
                for id = 1, 4 do
                    local counter = 0
                    local pom2 = {}
                    pom2.x = pom.x - 1
                    pom2.y = pom.y - 1
                    pom2.z = pom.z
                    for ai = 1, #correctBackgroundShapes[id] do
                        for aj = 1, #correctBackgroundShapes[id][ai] do
                            local mapItem2ItemId = getThingFromPosMock(
                                    {x = pom2.x, y = pom2.y, z = pom2.z, stackpos = 0}
                            ).itemid

                            if (correctBackgroundShapes[id][ai][aj] == 0) then
                                if ( mapItem2ItemId == groundItemId ) then
                                    counter = counter + 1
                                end
                            end
                            if (correctBackgroundShapes[id][ai][aj] == 1) then
                                if (mapItem2ItemId == mainGroundItemId) then
                                    counter = counter + 1
                                end
                            end
                            pom2.x = pom2.x + 1
                        end
                        pom2.x = pom.x - 1
                        pom2.y = pom2.y + 1
                    end

                    if (counter == 9) then
                        --print("Counter : " .. counter)
                        if (id == 1) then
                            doCreateItemMock(
                                    groundItemId,
                                    1,
                                    {x = pom.x + math.pow(-1, math.random(0,1)), y = pom.y, z = pom.z}
                            )
                            -- print("ID 1  Pos :  x - " .. pom.x .. ", y - " .. pom.y)
                            --	break
                        elseif (id == 3) then
                            doCreateItemMock(
                                    groundItemId,
                                    1,
                                    {x = pom.x + math.pow(-1, math.random(0,1)), y = pom.y, z = pom.z}
                            )
                            --	print("ID 3  Pos :  x - " .. pom.x .. ", y - " .. pom.y)
                            --	break
                        elseif (id == 2) then
                            doCreateItemMock(
                                    groundItemId, 
                                    1,
                                    {x = pom.x, y = pom.y + math.pow(-1, math.random(0,1)), z = pom.z}
                            )
                            --	print("ID 2  Pos :  x - " .. pom.x .. ", y - " .. pom.y)
                            --	break
                        elseif (id == 4) then
                            doCreateItemMock(
                                    groundItemId,
                                    1,
                                    {x = pom.x, y = pom.y + math.pow(-1, math.random(0,1)), z = pom.z}
                            )
                            --	print("ID 4  Pos :  x - " .. pom.x .. ", y - " .. pom.y)
                            --	break
                        end
                    end
                end
            end

            pom.x = pom.x + 1
        end
        pom.x = self.mainPos.x
        pom.y = pom.y + 1
    end

    print("Correction of the background I, execution time: " .. os.clock() - startTime)

    pom.x = self.mainPos.x
    pom.y = self.mainPos.y
    pom.z = self.mainPos.z
    for i = self.mainPos.y, self.mainPos.y + self.sizeY do
        for j = self.mainPos.x, self.mainPos.x + self.sizeX do
            local mapItemItemId = getThingFromPosMock(
                    {x = pom.x, y = pom.y, z = pom.z, stackpos = 0}
            ).itemid
            if (mapItemItemId == groundItemId) then
                for id = 7, 10 do
                    local counter = 0
                    local pom2 = {}
                    if (id <= 8) then
                        pom2.x = pom.x - 1
                        pom2.y = pom.y
                        pom2.z = pom.z
                    elseif (id == 9) then
                        pom2.x = pom.x - 1
                        pom2.y = pom.y - 1
                        pom2.z = pom.z
                    elseif (id == 10) then
                        pom2.x = pom.x + 1
                        pom2.y = pom.y - 1
                        pom2.z = pom.z
                    end

                    for ai = 1, #correctBackgroundShapes[id] do
                        for aj = 1, #correctBackgroundShapes[id][ai] do
                            local mapItem2ItemId = getThingFromPosMock(
                                    {x = pom2.x, y = pom2.y, z = pom2.z, stackpos = 0}
                            ).itemid

                            if (correctBackgroundShapes[id][ai][aj] == 0) then
                                if ( mapItem2ItemId == groundItemId ) then
                                    counter = counter + 1
                                end
                            end
                            if (correctBackgroundShapes[id][ai][aj] == 1) then
                                if (mapItem2ItemId == mainGroundItemId) then
                                    counter = counter + 1
                                end
                            end

                            pom2.x = pom2.x + 1
                        end
                        pom2.x = pom.x - 1
                        pom2.y = pom2.y + 1
                    end

                    if (counter == 6) then
                        --print("Counter : " .. counter)
                        if (id <= 8) then
                            doCreateItemMock(
                                    mainGroundItemId,
                                    1, 
                                    {x = pom.x, y = pom.y, z = pom.z}
                            )
                            doCreateItemMock(
                                    mainGroundItemId,
                                    1,
                                    {x = pom.x, y = pom.y + 1, z = pom.z}
                            )
                            --	print("ID 7|8  Pos :  x - " .. pom.x .. ", y - " .. pom.y)
                        else
                            doCreateItemMock(
                                    mainGroundItemId,
                                    1,
                                    {x = pom.x, y = pom.y, z = pom.z}
                            )
                            if id == 9 then
                                doCreateItemMock(
                                        mainGroundItemId,
                                        1,
                                        {x = pom.x - 1, y = pom.y, z = pom.z}
                                )
                                --		print("ID 9  Pos :  x - " .. pom.x .. ", y - " .. pom.y)
                            else
                                doCreateItemMock(
                                        mainGroundItemId,
                                        1,
                                        {x = pom.x + 1, y = pom.y, z = pom.z}
                                )
                                --		print("ID 10  Pos :  x - " .. pom.x .. ", y - " .. pom.y)
                            end
                        end
                    end

                end

            end

            pom.x = pom.x + 1
        end
        pom.x = self.mainPos.x
        pom.y = pom.y + 1
    end

    print("Correction of the background II, execution time: " .. os.clock() - startTime)
    
    pom.x = self.mainPos.x
    pom.y = self.mainPos.y
    pom.z = self.mainPos.z
    for i = self.mainPos.y, self.mainPos.y + self.sizeY do
        for j = self.mainPos.x, self.mainPos.x + self.sizeX do
            local mapItemItemId = getThingFromPosMock(
                    {x = pom.x, y = pom.y, z = pom.z, stackpos = 0}
            ).itemid
            if (mapItemItemId == groundItemId) then
                for id = 5, 6 do
                    local counter = 0
                    local pom2 = {}
                    if (id == 5) then
                        pom2.x = pom.x - 1
                        pom2.y = pom.y
                        pom2.z = pom.z
                    elseif (id == 6) then
                        pom2.x = pom.x - 1
                        pom2.y = pom.y - 1
                        pom2.z = pom.z
                    end
                    for ai = 1, #correctBackgroundShapes[id] do
                        for aj = 1, #correctBackgroundShapes[id][ai] do
                            local mapItem2ItemId = getThingFromPosMock({x = pom2.x, y = pom2.y, z = pom2.z, stackpos = 0}).itemid
                            if (correctBackgroundShapes[id][ai][aj] == 0) then
                                if ( mapItem2ItemId == groundItemId ) then
                                    counter = counter + 1
                                end
                                --end
                            elseif (correctBackgroundShapes[id][ai][aj] == 1) then
                                if (mapItem2ItemId == mainGroundItemId) then
                                    counter = counter + 1
                                end
                            end
                            pom2.x = pom2.x + 1
                        end
                        pom2.x = pom.x - 1
                        pom2.y = pom2.y + 1
                    end

                    if (counter == 4) then
                        --print("Counter : " .. counter)
                        if (id == 5) then
                            if math.random(0,1) == 0 then
                                doCreateItemMock(
                                        mainGroundItemId,
                                        1,
                                        {x = pom.x, y = pom.y, z = pom.z}
                                )
                            else
                                doCreateItemMock(
                                        mainGroundItemId,
                                        1,
                                        {x = pom.x - 1, y = pom.y + 1, z = pom.z}
                                )
                            end
                            --	print("ID 5  Pos :  x - " .. pom.x .. ", y - " .. pom.y)
                        else
                            if math.random(0,1) == 0 then
                                doCreateItemMock(
                                        mainGroundItemId,
                                        1,
                                        {x = pom.x, y = pom.y, z = pom.z}
                                )
                            else
                                doCreateItemMock(
                                        mainGroundItemId,
                                        1,
                                        {x = pom.x - 1, y = pom.y - 1, z = pom.z}
                                )
                            end
                            --	print("ID 6  Pos :  x - " .. pom.x .. ", y - " .. pom.y)
                        end
                    end
                end
            end
            pom.x = pom.x + 1
        end
        pom.x = self.mainPos.x
        pom.y = pom.y + 1
    end

    print("Correction of the background III, execution time: " .. os.clock() - startTime)

    pom.x = self.mainPos.x
    pom.y = self.mainPos.y
    pom.z = self.mainPos.z
    for i = self.mainPos.y, self.mainPos.y + self.sizeY do
        for j = self.mainPos.x, self.mainPos.x + self.sizeX do
            local mapItemItemId = getThingFromPosMock({x = pom.x, y = pom.y, z = pom.z, stackpos = 0}).itemid
            if (mapItemItemId == groundItemId) then
                for id = 11, 12 do
                    local counter = 0
                    local pom2 = {}
                    if (id <= 11) then
                        pom2.x = pom.x - 1
                        pom2.y = pom.y
                        pom2.z = pom.z
                    elseif (id == 12) then
                        pom2.x = pom.x
                        pom2.y = pom.y - 1
                        pom2.z = pom.z
                    end

                    for ai = 1, #correctBackgroundShapes[id] do
                        for aj = 1, #correctBackgroundShapes[id][ai] do
                            local mapItem2ItemId = getThingFromPosMock(
                                    {x = pom2.x, y = pom2.y, z = pom2.z, stackpos = 0}
                            ).itemid

                            if (correctBackgroundShapes[id][ai][aj] == 0) then
                                if (mapItem2ItemId == groundItemId) then
                                    counter = counter + 1
                                end
                            end
                            if (correctBackgroundShapes[id][ai][aj] == 1) then
                                if (mapItem2ItemId == mainGroundItemId) then
                                    counter = counter + 1
                                end
                            end

                            pom2.x = pom2.x + 1
                        end
                        pom2.x = pom.x
                        pom2.y = pom2.y + 1
                    end

                    if (counter == 3) then
                        --	print("ID 11|12  Counter : " .. counter)
                        --if (id == 11) then
                        doCreateItemMock(
                                mainGroundItemId,
                                1,
                                pom
                        )
                        --end
                    end
                end
            end
            pom.x = pom.x + 1
        end
        pom.x = self.mainPos.x
        pom.y = pom.y + 1
    end

    --print("Correction of the background IV, execution time: " .. os.clock() - startTime)
    print("Correction of the backround done, execution time: " .. os.clock() - startTime)
end
