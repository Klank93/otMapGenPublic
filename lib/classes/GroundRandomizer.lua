GroundRandomizer = {}
GroundRandomizer.__index = GroundRandomizer

function GroundRandomizer.new(map)
    local instance = setmetatable({}, GroundRandomizer)
    instance.map = map

    return instance
end

function GroundRandomizer:randomize(itemsTab, chance, currentFloor)
    -- chance 1-100, 100-100%
	currentFloor = currentFloor or self.map.mainPos.z
    local startTime = os.clock()
    local pom = {}
    pom.x = self.map.mainPos.x
    pom.y = self.map.mainPos.y
    pom.z = currentFloor

    for i = self.map.mainPos.y, self.map.mainPos.y + self.map.sizeY do
        for j = self.map.mainPos.x, self.map.mainPos.x + self.map.sizeX do
            local getitem = getThingFromPosMock(
                    {x = pom.x, y = pom.y, z = pom.z, stackpos = 0}
            )
            local randChance = math.random(1, 100)
            if (getitem.itemid == itemsTab[1][1]) then
                if (randChance <= chance) then
                    doCreateItemMock(
						itemsTab[1][math.random(2, #itemsTab[1])],
						1,
						{x = pom.x, y = pom.y, z = pom.z}
                    )
                end
            end
            pom.x = pom.x + 1
        end
        pom.x = self.map.mainPos.x
        pom.y = pom.y + 1
    end
    print("Ground randomizer done, execution time: " .. os.clock() - startTime)
end

function GroundRandomizer:randomizeByIds(groundsTab, chance, currentFloor)
	currentFloor = currentFloor or self.map.mainPos.z
    local startTime = os.clock()
    local pom = {}
    pom.x = self.map.mainPos.x
    pom.y = self.map.mainPos.y
    pom.z = currentFloor

    for i = self.map.mainPos.y, self.map.mainPos.y + self.map.sizeY do
        for j = self.map.mainPos.x, self.map.mainPos.x + self.map.sizeX do
            local getitem = getThingFromPosMock(
			{x = pom.x, y = pom.y, z = pom.z, stackpos = 0}
            )
            local randomChance = math.random(1, 100)
            if (getitem.itemid == groundsTab[1]) then
                if (randomChance <= chance) then
                    doCreateItemMock(
						groundsTab[math.random(2, #groundsTab)],
						1,
						{x = pom.x, y = pom.y, z = pom.z}
                    )
                end
            end
            pom.x = pom.x + 1
        end
        pom.x = self.map.mainPos.x
        pom.y = pom.y + 1
    end
    print("Ground randomizer done, execution time: " .. os.clock() - startTime)
end
