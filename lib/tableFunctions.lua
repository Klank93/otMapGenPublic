function arrayKeyExists(lookup) -- php like function
    -- usage
    -- print(arrayKeyExists("tbl.A.B")) -- true
    -- print(arrayKeyExists("tbl.X.Y")) -- false
    local c, a = pcall(loadstring("return " .. lookup .. " ~= nil"))
    return c and a
end

function inArray(tab, val) -- php like function
    for index, value in ipairs(tab) do
        if (type(val) == "table" and type(value) == "table") then -- compares two tables e.g. positions
            for index2, value2 in pairs(value) do
                if (val[index2] ~= value2) then
                    return false
                end
            end
        else
            if value == val then -- most common scenario
                return true
            end
        end
    end

    return false
end

function isset(t, ...) -- php like function, there is a chance it does not fully correctly
    local keys = {...}
    local current = t
    for i = 1, #keys do
        if type(current) ~= "table" or current[keys[i]] == nil then
            return false
        end
        current = current[keys[i]]
    end

    return true
end

function isEmpty(t, ...) -- php like function
    local keys = {...}
    local tables = {t}  -- This will store references to all tables we traverse

    -- Traverse through each key, ensuring each level exists
    for i = 1, #keys do
        local key = keys[i]

        -- Check if the current level is a table and contains the given key
        if type(tables[i][key]) ~= "table" then
            return true
        end

        -- Add the next table in the hierarchy to the list for potential later removal
        table.insert(tables, tables[i][key])
    end

    -- Check if the last table is empty
    local lastTable = tables[#tables]
	if (lastTable == nil) then return false end -- todo: not sure about that
    for _, v in pairs(lastTable) do
        if v ~= nil then
            return false
        end
    end

    -- Cascade removal of empty tables
    for i = #keys, 1, -1 do
        local parentTable = tables[i]
        local key = keys[i]

        -- Remove the empty table
        parentTable[key] = nil

        -- If the current level is not empty, stop the removal process
        if next(parentTable) ~= nil then
            break
        end
    end

    return true
end

function arrayValues(t) -- return the array of values with indexes starting with 1, 2, 3, etc...
    local values = {}
    for _, value in pairs(t) do
        table.insert(values, value)
    end

    return values
end

function flattenArray(t) -- return the flatten array of values under multilevel arrays
    local values = {}

    local function flatten(t)
        for _, value in pairs(t) do
            if type(value) == "table" then
                flatten(value)
            else
                table.insert(values, value)
            end
        end
    end

    flatten(t)
    return values
end

function arrayMerge(...) -- php like function
    local mergedTable = {}

    -- Iterate over each table passed as an argument
    for _, t in ipairs({...}) do
        -- Ensure the argument is a table
        if type(t) == "table" then
            -- Iterate over each element in the table
            for key, value in pairs(t) do
                -- If the key is numeric, append it; otherwise, overwrite it
                if type(key) == "number" then
                    table.insert(mergedTable, value)
                else
                    mergedTable[key] = value
                end
            end
        end
    end

    return mergedTable
end

function tableRotate(brush, shapeId, resultTab, degreesStep)
    -- degreesStep determines the angle; 0 - 0, 1 - 90, 2 - 180, 3 - 270
    local pom = {}
    local pom2 = {}

    local tabWidth = brush[shapeId].width
    local tabHeight = brush[shapeId].height

    pom = brush[shapeId].shape
    --[[
    for a = 1, tabHeight do
        local b = 1
        print("POM  i - " .. a .. ": " .. pom[a][b] .. ", " .. pom[a][b+1] .. ", " .. pom[a][b+2] .. ", " .. pom[a][b+3].. ", " .. pom[a][b+4])
    end
    ]]--
    for i = 1, tabHeight  do
        pom2[i] = {}
        for j = 1, tabWidth  do
            pom2[i][j] = 0
        end
    end
    if (degreesStep == 1) then
        for i = 1, tabHeight do
            for j = 1, tabWidth do
                local number = ((tabWidth + 1) - i)
                pom2[j][number] = pom[i][j]
            end
        end

        resultTab = pom2
    elseif (degreesStep == 2) then -- transformation by the axis of symmetry
        local pom3 = {}
        for i = 1, tabHeight do
            for j = 1, tabWidth do -- row
                local number = ((tabHeight + 1) - i)
                pom2[number][j] = pom[i][j]
            end
        end
        for i = 1, tabHeight  do
            pom3[i] = {}
            for j = 1, tabWidth  do
                pom3[i][j] = 0
            end
        end
        pom = pom2 -- znow moze byc problem z pomami, byc moze to-do pom3
        for i = 1, tabHeight do
            for j = 1, tabWidth do -- column
                local number = ((tabWidth + 1) - j)
                pom3[i][number] = pom2[i][j]
            end
        end

        resultTab = pom3
    elseif (degreesStep == 3) then
        for i = 1, tabHeight do
            for j = 1, tabWidth do
                local number2 = ((tabWidth + 1) - j)
                pom2[number2][i] = pom[i][j]
            end
        end

        resultTab = pom2
    end

    --[[
    for a = 1, tabHeight do
        local b = 1
        print("Result  i - " .. a .. ": " .. resultTab[a][b] .. ", " .. resultTab[a][b+1] .. ", " .. resultTab[a][b+2] .. ", " .. resultTab[a][b+3].. ", " .. resultTab[a][b+4])
    end
    ]]--

    -- it has to modify id of the borders accordingly, old ones would not work
    if (degreesStep == 1) then
        for i = 1, tabHeight do
            for j = 1, tabWidth do
                local resultTabItem = resultTab[i][j]
                switchTab = {
                    [1] = 2,
                    [2] = 3,
                    [3] = 4,
                    [4] = 1,
                    --
                    [5] = 6,
                    [6] = 8,
                    [7] = 5,
                    [8] = 7,
                    --
                    [9] = 10,
                    [10] = 12,
                    [11] = 9,
                    [12] = 11
                }

                resultTab[i][j] = switchTab[resultTabItem]
            end
        end
    elseif(degreesStep == 2) then
        for i = 1, tabHeight do
            for j = 1, tabWidth do
                local resultTabItem = resultTab[i][j]
                switchTab = {
                    [1] = 3,
                    [2] = 4,
                    [3] = 1,
                    [4] = 2,
                    --
                    [5] = 8,
                    [6] = 7,
                    [7] = 6,
                    [8] = 5,
                    --
                    [9] = 12,
                    [10] = 11,
                    [11] = 10,
                    [12] = 9
                }

                resultTab[i][j] = switchTab[resultTabItem]
            end
        end
    elseif(degreesStep == 3) then
        for i = 1, tabHeight do
            for j = 1, tabWidth do
                local resultTabItem = resultTab[i][j]

                switchTab = {
                    [1] = 4,
                    [2] = 1,
                    [3] = 2,
                    [4] = 3,
                    --
                    [5] = 7,
                    [6] = 5,
                    [7] = 8,
                    [8] = 6,
                    --
                    [9] = 11,
                    [10] = 9,
                    [11] = 12,
                    [12] = 10
                }

                resultTab[i][j] = switchTab[resultTabItem]
            end
        end
    end

    return resultTab
end

function addRotatedTab(borderShapes, shapeId)
    for i = 1, 3 do
        local tab = {}
        tab.width = borderShapes[shapeId].width
        tab.height = borderShapes[shapeId].height
        tab.shape = tableRotate(borderShapes, 9, tab, i)
        --for a = 1, tab.height do
        --		print(" " .. tab.shape[a][1]  .. "  " .. tab.shape[a][2]  .. "  " .. tab.shape[a][3]  .. "  " .. tab.shape[a][4])
        --end

        --print("\n\n")
        table.insert(borderShapes, 9+i, tab)
    end
end

-- Function to return the point from the array,
-- which is nearest to the middle of all points from the table
function findCentralWayPoint(wayPoints)
    local sumX, sumY, sumZ = 0, 0, 0
    local n = #wayPoints

    for i = 1, n do
        local point = wayPoints[i]["pos"]
        sumX = sumX + point.x
        sumY = sumY + point.y
        sumZ = sumZ + point.z
    end

    local centerX, centerY, centerZ = sumX / n, sumY / n, sumZ / n
    local centralPointIndex = nil
    local minDist = math.huge

    for i = 1, n do
        local point = wayPoints[i]["pos"]
        local dist = math.sqrt(
			(point.x - centerX)^2 + (point.y - centerY)^2 + (point.z - centerZ)^2
        )
        if dist < minDist then
            minDist = dist
            centralPointIndex = i
        end
    end

    return centralPointIndex
end

function getRandomArrayItems(mapTilesTab, chance)
    -- Function to randomly shuffle a table
    local function shuffleTable(t)
        local n = #t
        for i = n, 2, -1 do
            local j = math.random(i)
            t[i], t[j] = t[j], t[i]
        end
    end

    -- Copy the input table to avoid modifying the original
    local itemsCopy = {}
    for i = 1, #mapTilesTab do
        itemsCopy[i] = mapTilesTab[i]
    end

    -- Shuffle the copied table
    shuffleTable(itemsCopy)

    -- Calculate the number of mapTilesTab to return based on the chance
    local numberOfItemsToReturn = math.ceil((chance / 100) * #itemsCopy)

    -- Create a result table containing the required number of random mapTilesTab
    local result = {}
    for i = 1, numberOfItemsToReturn do
        table.insert(result, itemsCopy[i])
    end

    return result
end
