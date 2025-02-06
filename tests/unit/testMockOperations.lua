ROOT_PATH = ""

local dirCommand = {'find ', ' -maxdepth 1 -type f'}
dirCommand = {'dir "', '" /b /aa'}

local folders = {
    'lib',
    'lib/data',
    'lib/data/borders',
    'lib/data/brushes',
    'lib/data/shapes'
}

for i = 1, #folders do
    for dir in io.popen(dirCommand[1] .. ROOT_PATH .. folders[i] .. '/' .. dirCommand[2]):lines() do
        local filePath = ROOT_PATH .. folders[i] .. '/' .. dir
        print('Loading file: ' .. filePath)
        dofile(filePath)
    end
end

require('data/schemas/test1') -- ITEMS_TABLE
local lu = require('lib/externalResources/unit/luaunit')

PRECREATION_TABLE_MODE = true
LOG_TO_FILE = false
DEBUG_OUTPUT = false

-- todo: /\ move above init code to another, separate file

TestMockOperations = {}

function TestMockOperations:testAddGetRemoveItem1()
    -- init testTab
    CLI_FINAL_MAP_TABLE = newFlexibleTable()
    -- init items
    local mapItems = {
        {["item"] = { ["itemid"] = 419, ["typeOrCount"] = 1}, ["pos"] = {x = 1045, y = 1045, z = 7}},
    }
    for i, mapItem in ipairs(mapItems) do
        doCreateItemMock(mapItem.item.itemid, mapItem.item.typeOrCount, mapItem.pos)
    end

    local borderItemToAdd = { ["item"] = {["itemid"] = 4766, ["typeOrCount"] = 1}, ["pos"] = {x = 1045, y = 1045, z = 7} }
    doCreateItemMock(
            borderItemToAdd.item.itemid,
            borderItemToAdd.item.typeOrCount,
            borderItemToAdd.pos
    )

    local walkableStonesItemToAdd = {["item"] = {["itemid"] = 3652, ["typeOrCount"] = 1}, ["pos"] = {x = 1045, y = 1045, z = 7}}
    doCreateItemMock(
            walkableStonesItemToAdd.item.itemid,
            walkableStonesItemToAdd.item.typeOrCount,
            walkableStonesItemToAdd.pos
    )
    local mapBorderItem = getThingFromPosMock({x = 1045, y = 1045, z = 7, stackpos = 1})

    local deletionResult = false
    if (doRemoveItemMock(mapBorderItem.uid,{x = 1045, y = 1045, z = 7})) then
        deletionResult = true
    end

    local finalMapTable = CLI_FINAL_MAP_TABLE[1045][1045][7]
    lu.assertEquals(
            deletionResult,
            true
    )
    lu.assertEquals(
            {finalMapTable[1].itemid, finalMapTable[2].itemid},
            {mapItems[1].item.itemid, walkableStonesItemToAdd.item.itemid}
    )
    lu.assertEquals(
            {[finalMapTable[1].uid] = finalMapTable[1].uid, [finalMapTable[2].uid] = finalMapTable[2].uid},
            UNIQUE_UIDS
    )
end

function TestMockOperations:testGetThingFromPos1()
    -- init testTab
    CLI_FINAL_MAP_TABLE = newFlexibleTable()
    -- init items
    local mapItems = {
        {["item"] = {["itemid"] = 407, ["typeOrCount"] = 1}, ["pos"] = {x = 1045, y = 1045, z = 7}}, -- black marble tile
        {["item"] = {["itemid"] = 3656, ["typeOrCount"] = 1}, ["pos"] = {x = 1045, y = 1045, z = 7}}, -- single grey stone
        {["item"] = {["itemid"] = 1905, ["typeOrCount"] = 1}, ["pos"] = {x = 1045, y = 1045, z = 7}}, -- bloodspot
    }
    local testPos
    local mapItem
    for i, mapItem in ipairs(mapItems) do
        doCreateItemMock(mapItem.item.itemid, mapItem.item.typeOrCount, mapItem.pos)
    end

    testPos = {x = 100, y = 100, z = 7} -- not existing position test
    mapItem = getThingFromPosMock(testPos)
    lu.assertEquals(
            mapItem,
            {
                ["actionid"] = 0,
                ["uid"] = 0,
                ["itemid"] = 0,
                ["type"] = 0
            }
    )

    testPos = {x = 1045, y = 1045, z = 7, stackpos = 0} -- ground item test
    mapItem = getThingFromPosMock(testPos)
    lu.assertEquals(
            {mapItem.itemid, mapItem.typeOrCount},
            {mapItems[1].item.itemid, mapItems[1].item.typeOrCount}
    )

    testPos = {x = 1045, y = 1045, z = 7, stackpos = 1} -- middle stackpos test
    mapItem = getThingFromPosMock(testPos)
    lu.assertEquals(
            {mapItem.itemid, mapItem.typeOrCount},
            {mapItems[2].item.itemid, mapItems[2].item.typeOrCount}
    )

    testPos = {x = 1045, y = 1045, z = 7, stackpos = 5} -- not existing stackpos todo: to verify is that ok
    mapItem = getThingFromPosMock(testPos)
    lu.assertEquals(
            mapItem,
            {
                ["actionid"] = 0,
                ["uid"] = 0,
                ["itemid"] = 0,
                ["type"] = 0
            }
    )

    testPos = {x = 1045, y = 1045, z = 7} -- stackpos not defined, but items on the pos exist
    mapItem = getThingFromPosMock(testPos)
    lu.assertEquals(
            {mapItem.itemid, mapItem.typeOrCount},
            {mapItems[3].item.itemid, mapItems[3].item.typeOrCount}
    )
end

function TestMockOperations:testQueryTileAddThing1()
    -- init testTab
    CLI_FINAL_MAP_TABLE = newFlexibleTable()
    -- init items
    local mapItems = {
        {["item"] = {["itemid"] = 407, ["typeOrCount"] = 1}, ["pos"] = {x = 1045, y = 1045, z = 7}}, -- black marble tile
        {["item"] = {["itemid"] = 3656, ["typeOrCount"] = 1}, ["pos"] = {x = 1045, y = 1045, z = 7}}, -- single grey stone
        {["item"] = {["itemid"] = 1905, ["typeOrCount"] = 1}, ["pos"] = {x = 1045, y = 1045, z = 7}}, -- bloodspot

        {["item"] = {["itemid"] = 8133, ["typeOrCount"] = 1}, ["pos"] = {x = 1046, y = 1046, z = 7}}, -- unwalkable, earth, red mountain

        {["item"] = {["itemid"] = 407, ["typeOrCount"] = 1}, ["pos"] = {x = 1047, y = 1047, z = 7}}, -- black marble tile
        {["item"] = {["itemid"] = 1062, ["typeOrCount"] = 1}, ["pos"] = {x = 1047, y = 1047, z = 7}}, -- unwalkable small corner wall

        {["item"] = {["itemid"] = 419, ["typeOrCount"] = 1}, ["pos"] = {x = 1047, y = 1047, z = 7}}, -- sandstone tile
        {["item"] = {["itemid"] = 4768, ["typeOrCount"] = 1}, ["pos"] = {x = 1047, y = 1047, z = 7}}, -- border
        {["item"] = {["itemid"] = 1061, ["typeOrCount"] = 1}, ["pos"] = {x = 1047, y = 1047, z = 7}}, -- unwalkable wall

        {["item"] = {["itemid"] = 352, ["typeOrCount"] = 1}, ["pos"] = {x = 1048, y = 1048, z = 7}}, -- dirt tile
        {["item"] = {["itemid"] = 5631, ["typeOrCount"] = 1}, ["pos"] = {x = 1048, y = 1048, z = 7}}, -- unwalkable dirt wall border
    }
    local testPos, mapItem, mapItemUid, result
    for i, mapItem in ipairs(mapItems) do
        doCreateItemMock(mapItem.item.itemid, mapItem.item.typeOrCount, mapItem.pos)
    end

    testPos = mapItems[1].pos
    mapItem = getThingFromPosMock(testPos)
    mapItemUid = mapItem.uid
    result = queryTileAddThingMock(mapItemUid, testPos)
    lu.assertEquals(result, 0) -- happy flow scenario, tile is walkable

    testPos = mapItems[4].pos
    mapItem = getThingFromPosMock(testPos)
    mapItemUid = mapItem.uid
    result = queryTileAddThingMock(mapItemUid, testPos)
    lu.assertEquals(result, 1) -- unhappy flow scenario, just ground on the tile,  tile is unwalkable

    testPos = mapItems[5].pos
    mapItem = getThingFromPosMock(testPos)
    mapItemUid = mapItem.uid
    result = queryTileAddThingMock(mapItemUid, testPos)
    lu.assertEquals(result, 1) -- unhappy flow scenario, tile is unwalkable

    testPos = mapItems[7].pos
    mapItem = getThingFromPosMock(testPos)
    mapItemUid = mapItem.uid
    result = queryTileAddThingMock(mapItemUid, testPos)
    lu.assertEquals(result, 1) -- unhappy flow scenario, tile is unwalkable

    testPos = mapItems[10].pos
    mapItem = getThingFromPosMock(testPos)
    mapItemUid = mapItem.uid
    result = queryTileAddThingMock(mapItemUid, testPos)
    lu.assertEquals(result, 1) -- unhappy flow scenario, tile is unwalkable
end

os.exit(lu.run())
