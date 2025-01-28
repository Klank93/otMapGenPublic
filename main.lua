executionArgs = {...}
if (executionArgs[2] == 'cli') then
    require "lib/modules/logging/file"
else
    require "data/talkactions/scripts/otMapGen/lib/modules/logging/file"
end

local rootPath = ''
logger = nil

--function onSay(cid, words, param, param2)
function onSay(player, words, param) -- todo: mess, to refactor (there is also some bug here with input params, but dont remember now what exactly)
    local params = explode(removeWhitespace(param), ",")
    if (params[1] ~= nil) then
        local generalStartTime = os.clock()
        logger = logging.file(
                rootPath .. 'logs/' .. params[1] .. "-%s.log",
                "%Y_%m_%d-" .. generalStartTime,
                "%date::%level: %message\n"
        )

        if (RUNNING_MODE == 'tfs') then
            TFS_CID = player:getId() -- cid / player:getId(), depending on TFS version
            TFS_MESSAGE_CLASSES = MESSAGE_EVENT_DEFAULT
        end
        if (params[2] == 'tableMode') then -- simulates running through CLI in TFS todo: bug in running in CLI
            PRECREATION_TABLE_MODE = true
            RETURNVALUE_NOERROR = 1
        end

        local generationScriptFilePath = rootPath .. 'data/genScripts/' .. params[1] .. '.lua'
        print("# Executing script: " .. generationScriptFilePath .. ", logIdentifier: " .. generalStartTime)

        dofile(generationScriptFilePath)

        local endMessage = "# General execution time: " .. os.clock() - generalStartTime
        if (LOG_TO_FILE) then
            endMessage = endMessage .. ", logIdentifier: " .. generalStartTime
        end

        if (params[2] == "save" or params[3] == "save") then
            --separate logging process
            logger = logging.file(
                    rootPath .. 'logs/' .. params[1] .. "-saving-map-%s.log",
                    "%Y_%m_%d-" .. generalStartTime,
                    "%date::%level: %message\n"
            )
        -- SAVING MAP START \/
            local filename = rootPath .. 'generatedFiles/' ..
                    MAP_CONFIGURATION.saveMapFilename ..
                    string.format('-%s.otbm', os.date('%S'))
            local mainPos = MAP_CONFIGURATION.mainPos
            local mapSizeX = MAP_CONFIGURATION.mapSizeX
            local mapSizeY = MAP_CONFIGURATION.mapSizeY
            local fromPos = {x = mainPos.x - 5, y = mainPos.y - 5, z = 7}
            local toPos = {x = mainPos.x + mapSizeX + 5, y = mainPos.y + mapSizeY + 5, z = mainPos.z}

            print('Running saving map: ' .. filename)
            --local mapSaver = setmetatable({}, MapSaver)
            --mapSaver:saveMap(filename, fromPos, toPos, name) -- NOT WORKING
            --saveMap2(filename, fromPos, toPos) -- OLD CORE FUNCTIONAL, WORKING
            saveMap3(filename, fromPos, toPos) -- RESOURCE FUNCTIONAL WORKING
            print('Saving map: ' .. filename .. ' finished.')
        -- SAVING MAP END /\
        end

        print(endMessage)
    end
end

TFS_CID = nil
TFS_MESSAGE_CLASSES = nil
if (executionArgs[2] == 'cli') then
    -- allows execution from CLI directly
    -- example command: "Lua main.lua test70 cli"

    RUNNING_MODE = 'cli'
    dofile('bootstrapCli.lua')
    onSay(cid, {}, executionArgs[1], nil)
else
    RUNNING_MODE = 'tfs'
    rootPath = 'data/talkactions/scripts/otMapGen/'
    dofile(rootPath .. 'bootstrap.lua')
end

