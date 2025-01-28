-- bit32 = bit
function bit32Band(a, b)
    local result = 0
    local bitval = 1
    while a > 0 and b > 0 do
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

--SPECIAL CHARACTERS
NODE_START = 0xfe
NODE_END = 0xff
ESCAPE_CHAR = 0xfd

--OTBM NODE TYPES
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

--OTBM ATTR TYPES
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

function lchar(i) s="" while i>0 do s=s..string.char(i%256) i=math.floor(i/256) end return s end

function format(s,size)
    local len = #s
    for x=1,size/8-len do
        s=s.."\0"
    end
    return s
end

function writeData(f,data,size,unescape)
    local thestr
    if type(data) == "string" then
        thestr = format(data,size)
    elseif type(data) == "number" then
        thestr = format(lchar(data),size)
    elseif type(data) == "table" then
        for k,v in pairs(data) do
            print(k,v)
        end
        return
    else
        print(data)
        return
    end
    for x=1,size/8 do
        local c = thestr:sub(x,x)
        --print(#thestr,size,string.byte(c))
        --if c == string.char(0x0D) then error("daonde") end
        if unescape and (c==string.char(NODE_START) or c==string.char(NODE_END) or c==string.char(ESCAPE_CHAR)) then
            f:write(string.char(ESCAPE_CHAR))
        end

        f:write(c)
    end
end

function addU8(f,data)
    writeData(f,data,8,true)
end
function addByte(f,data)
    writeData(f,data,8,false)
end
function addU16(f,data)
    writeData(f,data,16,true)
end
function addU32(f,data)
    writeData(f,data,32,false)
end
function addString(f,data)
    if #data > 0xffff then
        return false
    end
    addU16(f,#data)
    writeData(f,data,#data*8,false)
end

function startNode(f,c) --c is a char
    writeData(f,NODE_START,8,false)
    writeData(f,c,8,true)
end

function endNode(f)
    writeData(f,NODE_END,8,false)
end

WIDTH = 2048 --put here the dimensions of your map
HEIGHT = 2048 --
ITEMDWMAJORVERSION = 2
ITEMDWMINORVERSION = 8

function saveMap3(name, frompos, topos) --e.g. "map.otbm"
    f = io.open(name,"wb")
    addU32(f,0); --version
    startNode(f,0)
    addU32(f,0); --version again :O
    addU16(f,WIDTH)
    addU16(f,HEIGHT)
    addU32(f,ITEMDWMAJORVERSION)
    addU32(f,ITEMDWMINORVERSION)

    startNode(f,OTBM_MAP_DATA)
    --addByte(f,OTBM_ATTR_DESCRIPTION)
    --addString(f,"Created with saveMap script, a translation of Remere's")
    local first = true
    local l_x=-1
    local l_y=-1
    local l_Z=-1
    for z=frompos.z,topos.z do
        for x=frompos.x,topos.x do
            local prog = (x - frompos.x) * 100 / (topos.x - frompos.x)
            print("Saving " .. name .. ", level " .. z + 1 - frompos.z .. "/" .. topos.z - frompos.z + 1 .. "(" .. math.floor(prog) .. "%) ... [" .. math.floor((prog + 100 * (z - frompos.z)) / (topos.z - frompos.z + 1)) .. "%]")

            for y=frompos.y,topos.y do

                if x<l_x or x>=l_x+256 or y<l_y or y>=l_y+256 or z~=l_z then
                    if not first then
                        endNode(f)
                    end
                    first = false
                    --start new node
                    startNode(f,OTBM_TILE_AREA)

                    l_x=bit32Band(x,0xff00)
                    l_y=bit32Band(y,0xff00)
                    l_z=z
                    addU16(f,l_x)
                    addU16(f,l_y)
                    addU8(f,l_z)
                end
                startNode(f,OTBM_TILE)

                addU8(f,bit32Band(x,0xff))
                addU8(f,bit32Band(y,0xff))

                for stackpos=0,10 do
                    local pos = {x=x,y=y,z=z,stackpos=stackpos}
                    local thing = getTileThingByPosMock(pos)

                    if (thing.itemid==0 and stackpos==0) then --no tile, so we can skip it
                        break
                    end
                    if thing.itemid > 0 and stackpos ~= 253 then --TODO: save item counts, save containers
                        addByte(f,OTBM_ATTR_ITEM)
                        addU16(f,thing.itemid)
                    end
                end

                endNode(f)
            end
        end
    end
    if not first then
        endNode(f)
    end

    endNode(f)
    endNode(f)
    f:close()
    print("Done")
end