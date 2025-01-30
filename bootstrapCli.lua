ROOT_PATH = ""

------------------------------
-- Config Load
------------------------------
dofile('config.lua')
local prefix = ">> "

local dirCommand = {'find ', ' -maxdepth 1 -type f'}
if (jit ~= nil and jit.os == "Windows") or package.config:sub(1,1) == '\\' then -- running on windows
    dirCommand = {'dir "', '" /b /aa'}
end

local folders = {
    'lib/externalResources',
    'lib',
    'lib/classes/tools',
    'lib/classes',
    'lib/data',
    'lib/data/borders',
    'lib/data/brushes',
    'lib/data/shapes',
	'lib/commonScripts'
}
local filesCount = 0
for i = 1, #folders do
    if (DEBUG_OUTPUT) then
        print(prefix .. 'Loading ' .. MAP_GEN_CFG.generatorName .. ': ' .. folders[i] .. '... ')
    end

    for dir in io.popen(dirCommand[1] .. ROOT_PATH .. folders[i] .. '/' .. dirCommand[2]):lines() do
        filesCount = filesCount + 1
        local filePath = ROOT_PATH .. folders[i] .. '/' .. dir
        print('Loading file: ' .. filePath)
        dofile(filePath)
    end

    if (DEBUG_OUTPUT) then
        print(filesCount .. ' file(s) loaded.')
    end

    filesCount = 0
end

PRECREATION_TABLE_MODE = true
RETURNVALUE_NOERROR = 1
