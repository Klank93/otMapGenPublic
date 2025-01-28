do return end
-- todo: does not work (unsuccessful try of rewrite the functional code to OOP)

-- bit32 = bit
function bit32Band(a, b)
    local result = 0
    local bitval = 1
    while a > 0 or b > 0 do
        local abit = a % 2
        local bbit = b % 2
        if abit == 1 and bbit == 1 then
            result = result + bitval
        end
        a = math.floor(a / 2)
        b = math.floor(b / 2)
        bitval = bitval * 2
    end
    return result
end

-- Special Characters
NODE_START = 0xfe
NODE_END = 0xff
ESCAPE_CHAR = 0xfd

-- OTBM Node Types
OTBM_ROOTV1 = 1
OTBM_MAP_DATA = 2
OTBM_ITEM_DEF = 3
OTBM_TILE_AREA = 4
OTBM_TILE = 5
OTBM_ITEM = 6
OTBM_TILE_SQUARE = 7
OTBM_TILE_REF = 8
OTBM_SPAWNS = 9
OTBM_SPAWN_AREA = 10
OTBM_MONSTER = 11
OTBM_TOWNS = 12
OTBM_TOWN = 13
OTBM_HOUSETILE = 14

-- OTBM Attribute Types
OTBM_ATTR_DESCRIPTION = 1
OTBM_ATTR_EXT_FILE = 2
OTBM_ATTR_TILE_FLAGS = 3
OTBM_ATTR_ACTION_ID = 4
OTBM_ATTR_UNIQUE_ID = 5
OTBM_ATTR_TEXT = 6
OTBM_ATTR_DESC = 7
OTBM_ATTR_TELE_DEST = 8
OTBM_ATTR_ITEM = 9
OTBM_ATTR_DEPOT_ID = 10
OTBM_ATTR_EXT_SPAWN_FILE = 11
OTBM_ATTR_RUNE_CHARGES = 12
OTBM_ATTR_EXT_HOUSE_FILE = 13
OTBM_ATTR_HOUSEDOORID = 14
OTBM_ATTR_COUNT = 15
OTBM_ATTR_DURATION = 16
OTBM_ATTR_DECAYING_STATE = 17
OTBM_ATTR_WRITTENDATE = 18
OTBM_ATTR_WRITTENBY = 19
OTBM_ATTR_SLEEPERGUID = 20
OTBM_ATTR_SLEEPSTART = 21
OTBM_ATTR_CHARGES = 22

MapSaver = {}
MapSaver.__index = MapSaver

function MapSaver:lchar(i)
    local s = ""
    while i > 0 do
        s = s .. string.char(i % 256)
        i = math.floor(i / 256)
    end
    return s
end

function MapSaver:format(s, size)
    local len = #s
    for x = 1, size / 8 - len do
        s = s .. "\0"
    end
    return s
end

function MapSaver:writeData(f, data, size, unescape)
    local thestr
    if type(data) == "string" then
        thestr = self:format(data, size)
    elseif type(data) == "number" then
        thestr = self:format(self:lchar(data), size)
    elseif type(data) == "table" then
        for k, v in pairs(data) do
            print(k, v)
        end
        return
    else
        print(data)
        return
    end
    for x = 1, size / 8 do
        local c = thestr:sub(x, x)
        if unescape and (c == string.char(NODE_START) or c == string.char(NODE_END) or c == string.char(ESCAPE_CHAR)) then
            f:write(string.char(ESCAPE_CHAR))
        end
        f:write(c)
    end
end

function MapSaver:addU8(f, data)
    self:writeData(f, data, 8, true)
end

function MapSaver:addU16(f, data)
    self:writeData(f, data, 16, true)
end

function MapSaver:addU32(f, data)
    self:writeData(f, data, 32, true)
end

function MapSaver:addString(f, data)
    self:writeData(f, data, #data * 8, true)
end

function MapSaver:startNode(f, nodeType)
    f:write(string.char(NODE_START))
    f:write(string.char(nodeType))
end

function MapSaver:endNode(f)
    f:write(string.char(NODE_END))
end

function MapSaver:addByte(f, data)
    f:write(string.char(data))
end

function MapSaver:saveMap(filename, fromPos, toPos, name)
    local f = assert(io.open(filename, "wb"))

    self:startNode(f, OTBM_ROOTV1)
    self:addU32(f, 0)  -- version
    self:addU16(f, 1)  -- OTBM version
    self:addU16(f, 842)  -- client version (842)

    self:startNode(f, OTBM_MAP_DATA)
    self:addString(f, name)

    self:startNode(f, OTBM_ATTR_DESCRIPTION)
    self:addString(f, "Created with saveMap script, a translation of Remere's")

    local first = true
    local l_x = -1
    local l_y = -1
    local l_z = -1

    for z = fromPos.z, toPos.z do
        for x = fromPos.x, toPos.x do
            local prog = (x - fromPos.x) * 100 / (toPos.x - fromPos.x)
            print("Saving " .. name .. ", level " .. z + 1 - fromPos.z .. "/" .. toPos.z - fromPos.z + 1 .. "(" .. math.floor(prog) .. "%) ... [" .. math.floor((prog + 100 * (z - fromPos.z)) / (toPos.z - fromPos.z + 1)) .. "%]")

            for y = fromPos.y, toPos.y do
                if x < l_x or x >= l_x + 256 or y < l_y or y >= l_y + 256 or z ~= l_z then
                    if not first then
                        self:endNode(f)
                    end
                    first = false
                    self:startNode(f, OTBM_TILE_AREA)
                    l_x = bit32Band(x, 0xff00)
                    l_y = bit32Band(y, 0xff00)
                    l_z = z
                    self:addU16(f, l_x)
                    self:addU16(f, l_y)
                    self:addU8(f, l_z)
                end
                self:startNode(f, OTBM_TILE)
                self:addU8(f, bit32Band(x, 0xff))
                self:addU8(f, bit32Band(y, 0xff))

                for stackpos = 0, 10 do
                    local pos = {x = x, y = y, z = z, stackpos = stackpos}
                    local thing = getTileThingByPosMock(pos)
                    if thing.itemid == 0 and stackpos == 0 then
                        break
                    end
                    if thing.itemid > 0 and stackpos ~= 253 then
                        self:addByte(f, OTBM_ATTR_ITEM)
                        self:addU16(f, thing.itemid)
                    end
                end
                self:endNode(f)
            end
        end
    end
    if not first then
        self:endNode(f)
    end

    self:endNode(f)
    self:endNode(f)
    f:close()
    print("Done")
end
