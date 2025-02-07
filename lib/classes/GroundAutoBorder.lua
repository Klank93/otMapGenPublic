GroundAutoBorder = {}
GroundAutoBorder.__index = GroundAutoBorder
--- Extends the AutoBorder class

function GroundAutoBorder.new(map)
    local instance = setmetatable(GroundAutoBorder, AutoBorder)
    instance.map = map

    return instance
end

function GroundAutoBorder:doGround(ground1, ground2, badGround, border, currentFloor)
    -- todo: lastly stackposes were changed from 1 to 2, for running via CLI purposes (otherwise they were deleting walls)
    -- todo: has to be checked doesn't it cause the other issues
	currentFloor = currentFloor or self.map.mainPos.z
    local startTime = os.clock()
    local pom = {}
    pom.x = self.map.mainPos.x
    pom.y = self.map.mainPos.y
    pom.z = currentFloor

    for i = self.map.mainPos.y, self.map.mainPos.y + self.map.sizeY do
        for j = self.map.mainPos.x, self.map.mainPos.x + self.map.sizeX do
			local itemId
			local getThing = getThingFromPosMock(
			{x = pom.x, y = pom.y, z = pom.z, stackpos = 0}
            )
			if getThing ~= nil then
				itemId = getThing.itemid
			end

            local nw = 0
            local ne = 0
            local sw = 0
            local se = 0
            -----	-------
            if (itemId == ground1) then
                if (getThingFromPosMock(
					{x = pom.x, y = pom.y - 1, z = pom.z, stackpos = 0}).itemid == ground2
                ) then
                    if (getThingFromPosMock(
						{x = pom.x + 1, y = pom.y - 1, z = pom.z, stackpos = 0}).itemid == ground1
                    ) then
                        doCreateItemMock(
							border[12][1],
							1,
							{x = pom.x, y = pom.y - 1, z = pom.z}
                        )
                    elseif (getThingFromPosMock(
						{x = pom.x - 1, y = pom.y - 1, z = pom.z, stackpos = 0}).itemid == ground1
                    ) then
                        doCreateItemMock(
							border[11][1],
							1,
							{x = pom.x, y = pom.y - 1, z = pom.z}
                        )
                    else
                        doCreateItemMock(
							border[3][1],
							1,
							{x = pom.x, y = pom.y - 1, z = pom.z}
                        )
                    end
                    -- external top corners
                    if (getThingFromPosMock({x = pom.x + 1, y = pom.y, z = pom.z, stackpos = 0}).itemid ~= ground1) then
                        if (getThingFromPosMock({x = pom.x + 1, y = pom.y - 1, z = pom.z, stackpos = 0}).itemid ~= badGround) then
                            doCreateItemMock(
								border[7][1],
								1,
								{x = pom.x + 1, y = pom.y - 1, z = pom.z}
                            )
                            ne = 1
                            --doCreateItemMock(2349, 1, {x = pom.x + 1, y = pom.y - 1, z = pom.z, stackpos = 1})
                        end
                    end
                    if (getThingFromPosMock({x = pom.x - 1, y = pom.y, z = pom.z, stackpos = 0}).itemid ~= ground1) then
                        if (getThingFromPosMock({x = pom.x - 1, y = pom.y - 1, z = pom.z, stackpos = 0}).itemid ~= badGround) then
                            doCreateItemMock(
								border[8][1],
								1,
								{x = pom.x - 1, y = pom.y - 1, z = pom.z}
                            )
                            nw = 1
                        end
                    end
                end

                if (getThingFromPosMock({x = pom.x, y = pom.y + 1, z = pom.z, stackpos = 0}).itemid == ground2) then
                    if (getThingFromPosMock({x = pom.x - 1, y = pom.y + 1, z = pom.z, stackpos = 0}).itemid == ground1) then
                        doCreateItemMock(
							border[9][1],
							1,
							{x = pom.x, y = pom.y + 1, z = pom.z}
                        )
                    elseif (getThingFromPosMock({x = pom.x + 1, y = pom.y + 1, z = pom.z, stackpos = 0}).itemid == ground1) then
                        doCreateItemMock(
							border[10][1],
							1,
							{x = pom.x, y = pom.y + 1, z = pom.z}
                        )
                    else
                        doCreateItemMock(
							border[1][1],
							1,
							{x = pom.x, y = pom.y + 1, z = pom.z}
                        )
                    end
                    -- external bottom corners
                    if (getThingFromPosMock({x = pom.x + 1, y = pom.y, z = pom.z, stackpos = 0}).itemid ~= ground1) then
                        -- todo: to check
                        if (getThingFromPosMock({x = pom.x + 1, y = pom.y + 1, z = pom.z, stackpos = 0}).itemid ~= badGround) then
                            doCreateItemMock(
								border[5][1],
								1,
								{x = pom.x + 1, y = pom.y + 1, z = pom.z}
                            )
                            se = 1
                        end

                    end
                    if (getThingFromPosMock({x = pom.x - 1, y = pom.y, z = pom.z, stackpos = 0}).itemid ~= ground1) then
                        -- todo: to check
                        if (getThingFromPosMock({x = pom.x - 1, y = pom.y + 1, z = pom.z, stackpos = 0}).itemid ~= badGround) then
                            doCreateItemMock(
								border[6][1],
								1,
								{x = pom.x - 1, y = pom.y + 1, z = pom.z}
                            )
                            sw = 1
                        end
                    end
                end

                if (getThingFromPosMock({x = pom.x - 1, y = pom.y, z = pom.z, stackpos = 0}).itemid == ground2) then
                    if ((getThingFromPosMock({x = pom.x - 1, y = pom.y - 1, z = pom.z, stackpos = 0}).itemid ~= ground1)
                            and (getThingFromPosMock({x = pom.x - 1, y = pom.y + 1, z = pom.z, stackpos = 0}).itemid ~= ground1)) then
                        doCreateItemMock(
							border[2][1],
							1,
							{x = pom.x - 1, y = pom.y, z = pom.z}
                        )

                    end
                    if (nw == 0) then
                        if (getThingFromPosMock({x = pom.x, y = pom.y - 1, z = pom.z, stackpos = 0}).itemid ~= ground1) then
                            if (getThingFromPosMock({x = pom.x - 1, y = pom.y - 1, z = pom.z, stackpos = 0}).itemid ~= badGround) then
                                doCreateItemMock(
									border[8][1],
									1,
									{x = pom.x - 1, y = pom.y - 1, z = pom.z}
                                )  -- unlucky corner
                            end
                        end
                    end
                    if (sw == 0) then
                        if (getThingFromPosMock({x = pom.x, y = pom.y + 1, z = pom.z, stackpos = 0}).itemid ~= ground1) then  -- nowe
                            -- todo: to check
                            if (getThingFromPosMock({x = pom.x - 1, y = pom.y + 1, z = pom.z, stackpos = 0}).itemid ~= badGround) then
                                doCreateItemMock(
									border[6][1],
									1,
									{x = pom.x - 1, y = pom.y + 1, z = pom.z}
                                )
                            end
                        end
                    end
                end

                if (getThingFromPosMock({x = pom.x + 1, y = pom.y, z = pom.z, stackpos = 0}).itemid == ground2) then
                    if ((getThingFromPosMock({x = pom.x + 1, y = pom.y - 1, z = pom.z, stackpos = 0}).itemid ~= ground1)
                            and (getThingFromPosMock({x = pom.x + 1, y = pom.y + 1, z = pom.z, stackpos = 0}).itemid ~= ground1)) then
                        doCreateItemMock(
							border[4][1],
							1,
							{x = pom.x + 1, y = pom.y, z = pom.z}
                        )
                    end

                    if (se == 0) then
                        if (getThingFromPosMock({x = pom.x, y = pom.y + 1, z = pom.z, stackpos = 0}).itemid ~= ground1) then
                            -- todo: to check, probably does not work as expected
                            if (getThingFromPosMock({x = pom.x + 1, y = pom.y + 1, z = pom.z, stackpos = 0}).itemid ~= badGround) then
                                doCreateItemMock(
									border[5][1],
									1,
									{x = pom.x + 1, y = pom.y + 1, z = pom.z}
                                )
                            end
                        end
                    end
                    if (ne == 0) then
                        if (getThingFromPosMock({x = pom.x, y = pom.y - 1, z = pom.z, stackpos = 0}).itemid ~= ground1) then
                            -- todo: to check, probably does not work as expected (new?)
                            if (getThingFromPosMock({x = pom.x + 1, y = pom.y - 1, z = pom.z, stackpos = 0}).itemid ~= badGround) then
                                doCreateItemMock(
									border[7][1],
									1,
									{x = pom.x + 1, y = pom.y - 1, z = pom.z}
                                )
                            end
                        end
                    end
                end
            end
            pom.x = pom.x + 1
        end
        pom.x = self.map.mainPos.x
        pom.y = pom.y + 1
    end

    print("Bordering ground on floor: " .. currentFloor .. " done, execution time: " .. os.clock() - startTime)
end

function GroundAutoBorder:doGround2(ground1, ground2, badGround1, badGround2, border, currentFloor)
    -- ground1 is the one by which it's bordering and for ground1 borders have to be chosen
	currentFloor = currentFloor or self.map.mainPos.z
    local startTime = os.clock()
    local pom = {}
    pom.x = self.map.mainPos.x
    pom.y = self.map.mainPos.y
    pom.z = currentFloor

    for i = self.map.mainPos.y, self.map.mainPos.y + self.map.sizeY do
        for j = self.map.mainPos.x, self.map.mainPos.x + self.map.sizeX do
            local mapItem = getThingFromPosMock(
				{x = pom.x, y = pom.y, z = pom.z, stackpos = 0}
            ).itemid
            local nw = 0
            local ne = 0
            local sw = 0
            local se = 0

            if (mapItem == ground1) then
                if (getThingFromPosMock(
					{x = pom.x, y = pom.y - 1, z = pom.z, stackpos = 0}
                ).itemid == ground2
                ) then
                    if (getThingFromPosMock(
						{x = pom.x + 1, y = pom.y - 1, z = pom.z, stackpos = 0}
                    ).itemid == ground1
                    ) then
                        doCreateItemMock(
							border[12][1],
							1,
							{x = pom.x, y = pom.y - 1, z = pom.z, stackpos = 1}
                        )
                    elseif (getThingFromPosMock(
						{x = pom.x - 1, y = pom.y - 1, z = pom.z, stackpos = 0}
                    ).itemid == ground1
                    ) then
                        doCreateItemMock(
							border[11][1],
							1,
							{x = pom.x, y = pom.y - 1, z = pom.z, stackpos = 1}
                        )
                    else
                        doCreateItemMock(
							border[3][1],
							1,
							{x = pom.x, y = pom.y - 1, z = pom.z, stackpos = 1}
                        )
                    end
                    -- external top corners
                    if (getThingFromPosMock(
						{x = pom.x + 1, y = pom.y, z = pom.z, stackpos = 0}
                    ).itemid ~= ground1
                    ) then
                        local test = getThingFromPosMock(
							{x = pom.x + 1, y = pom.y - 1, z = pom.z, stackpos = 0}
                        ).itemid
                        if ((test ~= badGround1) and (test ~= badGround2)) then
                            doCreateItemMock(
								border[7][1],
								1,
								{x = pom.x + 1, y = pom.y - 1, z = pom.z, stackpos = 1}
                            )
                            ne = 1
                            --doCreateItemMock(
                            --        2349,
                            --        1,
                            --        {x = pom.x + 1, y = pom.y - 1, z = pom.z, stackpos = 1}
                            --)
                        end
                    end
                    if (getThingFromPosMock(
						{x = pom.x - 1, y = pom.y, z = pom.z, stackpos = 0}
                    ).itemid ~= ground1
                    ) then
                        local test = getThingFromPosMock(
							{x = pom.x - 1, y = pom.y - 1, z = pom.z, stackpos = 0}
                        ).itemid
                        if ((test ~= badGround1) and (test ~= badGround2)) then
                            doCreateItemMock(
								border[8][1],
								1,
								{x = pom.x - 1, y = pom.y - 1, z = pom.z, stackpos = 1}
                            )
                            nw = 1
                        end
                    end
                end

                if (getThingFromPosMock(
					{x = pom.x, y = pom.y + 1, z = pom.z, stackpos = 0}
                ).itemid == ground2
                ) then
                    if (getThingFromPosMock(
						{x = pom.x - 1, y = pom.y + 1, z = pom.z, stackpos = 0}
                    ).itemid == ground1
                    ) then
                        doCreateItemMock(
							border[9][1],
							1,
							{x = pom.x, y = pom.y + 1, z = pom.z, stackpos = 1}
                        )
                    elseif (getThingFromPosMock(
                            {x = pom.x + 1, y = pom.y + 1, z = pom.z, stackpos = 0}
                    ).itemid == ground1
                    ) then
                        doCreateItemMock(
							border[10][1],
							1,
							{x = pom.x, y = pom.y + 1, z = pom.z, stackpos = 1}
                        )
                    else
                        doCreateItemMock(
							border[1][1],
							1,
							{x = pom.x, y = pom.y + 1, z = pom.z, stackpos = 1}
                        )
                    end
                    -- external bottom corners
                    if (getThingFromPosMock(
						{x = pom.x + 1, y = pom.y, z = pom.z, stackpos = 0}
                    ).itemid ~= ground1
                    ) then
                        -- to check
                        local test = getThingFromPosMock(
							{x = pom.x + 1, y = pom.y + 1, z = pom.z, stackpos = 0}
                        ).itemid
                        if ((test ~= badGround1) and (test ~= badGround2)) then
                            doCreateItemMock(
								border[5][1],
								1,
								{x = pom.x + 1, y = pom.y + 1, z = pom.z, stackpos = 1}
                            )
                            se = 1
                        end

                    end
                    if (getThingFromPosMock(
						{x = pom.x - 1, y = pom.y, z = pom.z, stackpos = 0}
                    ).itemid ~= ground1
                    ) then
                        -- to check
                        local test = getThingFromPosMock(
							{x = pom.x - 1, y = pom.y + 1, z = pom.z, stackpos = 0}
                        ).itemid
                        if ((test ~= badGround1) and (test ~= badGround2)) then
                            doCreateItemMock(
								border[6][1],
								1,
								{x = pom.x - 1, y = pom.y + 1, z = pom.z, stackpos = 1}
                            )
                            sw = 1
                        end
                    end
                end

                if (getThingFromPosMock(
					{x = pom.x - 1, y = pom.y, z = pom.z, stackpos = 0}
                ).itemid == ground2
                ) then
                    if ((getThingFromPosMock(
						{x = pom.x - 1, y = pom.y - 1, z = pom.z, stackpos = 0}
                    ).itemid ~= ground1) and (getThingFromPosMock(
						{x = pom.x - 1, y = pom.y + 1, z = pom.z, stackpos = 0}
                    ).itemid ~= ground1)
                    ) then
                        doCreateItemMock(
							border[2][1],
							1,
							{x = pom.x - 1, y = pom.y, z = pom.z, stackpos = 1}
                        )
                    end
                    if (nw == 0) then
                        if (getThingFromPosMock(
							{x = pom.x, y = pom.y - 1, z = pom.z, stackpos = 0}
                        ).itemid ~= ground1
                        ) then
                            local test = getThingFromPosMock(
								{x = pom.x - 1, y = pom.y - 1, z = pom.z, stackpos = 0}
                            ).itemid
                            if ((test ~= badGround1) and (test ~= badGround2)) then
                                doCreateItemMock(
									border[8][1],
									1,
									{x = pom.x - 1, y = pom.y - 1, z = pom.z, stackpos = 1}
                                )  -- unlucky corner
                            end
                        end
                    end
                    if (sw == 0) then
                        if (getThingFromPosMock(
							{x = pom.x, y = pom.y + 1, z = pom.z, stackpos = 0}
                        ).itemid ~= ground1
                        ) then  -- new
                            -- to check
                            local test = getThingFromPosMock(
								{x = pom.x - 1, y = pom.y + 1, z = pom.z, stackpos = 0}
                            ).itemid
                            if ((test ~= badGround1) and (test ~= badGround2)) then
                                doCreateItemMock(
									border[6][1],
									1,
									{x = pom.x - 1, y = pom.y + 1, z = pom.z, stackpos = 1}
                                )
                            end
                        end
                    end
                end

                if (getThingFromPosMock(
					{x = pom.x + 1, y = pom.y, z = pom.z, stackpos = 0}
                ).itemid == ground2
                ) then
                    if ((getThingFromPosMock(
						{x = pom.x + 1, y = pom.y - 1, z = pom.z, stackpos = 0}
                    ).itemid ~= ground1) and (getThingFromPosMock(
						{x = pom.x + 1, y = pom.y + 1, z = pom.z, stackpos = 0}
                    ).itemid ~= ground1)
                    ) then
                        doCreateItemMock(
							border[4][1],
							1,
							{x = pom.x + 1, y = pom.y, z = pom.z, stackpos = 1}
                        )
                    end

                    if (se == 0) then
                        if (getThingFromPosMock(
							{x = pom.x, y = pom.y + 1, z = pom.z, stackpos = 0}
                        ).itemid ~= ground1) then -- to check, probably does not work
                            local test = getThingFromPosMock(
								{x = pom.x + 1, y = pom.y + 1, z = pom.z, stackpos = 0}
                            ).itemid
                            if ((test ~= badGround1) and (test ~= badGround2)) then
                                doCreateItemMock(
									border[5][1],
									1,
									{x = pom.x + 1, y = pom.y + 1, z = pom.z, stackpos = 1}
                                )
                            end
                        end
                    end
                    if (ne == 0) then
                        if (getThingFromPosMock(
							{x = pom.x, y = pom.y - 1, z = pom.z, stackpos = 0}
                        ).itemid ~= ground1
                        ) then  -- to check, probably does not work NEW
                            local test = getThingFromPosMock(
								{x = pom.x + 1, y = pom.y - 1, z = pom.z, stackpos = 0}
                            ).itemid
                            if ((test ~= badGround1) and (test ~= badGround2)) then
                                doCreateItemMock(
									border[7][1],
									1,
									{x = pom.x + 1, y = pom.y - 1, z = pom.z, stackpos = 1}
                                )
                            end
                        end
                    end
                end

            end
            pom.x = pom.x + 1
        end
        pom.x = self.map.mainPos.x
        pom.y = pom.y + 1
    end

    print("Bordering2 ground on floor: " .. currentFloor .. " done, execution time: " .. os.clock() - startTime)
end

function GroundAutoBorder:correctBorders(
        badGroundItemId,
        border,
        wallBorder,
        groundItemId,
        shapesTab,
        chance,
		currentFloor
) -- todo: does not work in CLI mode (to confirm)
	currentFloor = currentFloor or self.map.mainPos.z
    local startTime = os.clock()
    local lengthX = 1
    local lengthY = 1
    local pom = {}
    pom.x = self.map.mainPos.x
    pom.y = self.map.mainPos.y
    pom.z = currentFloor

    for i = self.map.mainPos.y, self.map.mainPos.y + self.map.sizeY do
        for j = self.map.mainPos.x, self.map.mainPos.x + self.map.sizeX do
            local overStep = 1
            local mapItem = getThingFromPosMock(
				{x = pom.x, y = pom.y, z = pom.z, stackpos = 0}
            )

            if (mapItem.itemid ~= badGroundItemId) then -- does not check the background of map, like mountains
                mapItem = getThingFromPosMock({x = pom.x, y = pom.y, z = pom.z, stackpos = 1})

                if (mapItem.itemid == border[3][1]) then
                    if (getThingFromPosMock(
						{x = pom.x + 1, y = pom.y, z = pom.z, stackpos = 1}
                    ).itemid == border[3][1]
                    ) then
                        lengthX = 2
                    end

                    local pom2 = {}
                    if (lengthX == 2) then
                        if (math.random(1, 100) <= chance) then
                            pom2.x = pom.x
                            pom2.y = pom.y - 2
                            pom2.z = pom.z
                            local tab = shapesTab[1]
                            for ai = 1, tab.size do
                                for aj = 1, tab.size do
                                    for ax = 1, 12 do
                                        if (tab.shape[ai][aj] == ax) then
                                            if (getThingFromPosMock(
												{x = pom2.x, y = pom2.y, z = pom2.z, stackpos = 0}
                                            ).itemid ~= badGroundItemId) then
                                                if (getThingFromPosMock(
													{x = pom2.x, y = pom2.y, z = pom2.z, stackpos = 0}
                                                ).itemid ~= groundItemId) then
                                                    local mapItem2Pos =
                                                    {x = pom2.x, y = pom2.y, z = pom2.z, stackpos = 1}
                                                    local mapItem2 = getThingFromPosMock(mapItem2Pos)
                                                    if not ((mapItem2.itemid == wallBorder[1][1])
                                                            or (mapItem2.itemid == wallBorder[2][1])
                                                            or (mapItem2.itemid == wallBorder[3][1])
                                                            or (mapItem2.itemid == wallBorder[4][1])
                                                    ) then -- safety-fuse to prevent walls deletion
                                                        if (mapItem2.itemid == border[3][1]) then
                                                            doRemoveItemMock(mapItem2.uid, mapItem2Pos)
                                                        end
                                                    end
                                                    --print("south x - " .. pom2.x .. " y - " .. pom2.y .. " z - " .. pom2.z )
                                                    doCreateItemMock(
														border[ax][1],
														1,
														{x = pom2.x, y = pom2.y, z = pom2.z}
                                                    )
                                                end
                                            end
                                        end
                                    end
                                    pom2.x = pom2.x + 1
                                end
                                pom2.x = pom2.x - tab.size
                                pom2.y = pom2.y + 1
                            end
                        end
                    end
                elseif (mapItem.itemid == border[1][1]) then
                    if (getThingFromPosMock(
						{x = pom.x + 1, y = pom.y, z = pom.z, stackpos = 1}
                   		).itemid == border[1][1]
                    ) then
                        lengthX = 2
                        -- else
                        -- place for horns
                    end

                    local pom2 = {}
                    if (lengthX == 2) then
                        if (math.random(1, 100) <= chance) then
                            pom2.x = pom.x
                            pom2.y = pom.y
                            pom2.z = pom.z
                            local tab = shapesTab[9]
                            for ai = 1, tab.size do
                                for aj = 1, tab.size do
                                    for ax = 1, 12 do
                                        if (tab.shape[ai][aj] == ax) then
                                            if (getThingFromPosMock(
												{x = pom2.x, y = pom2.y, z = pom2.z, stackpos = 0}
                                            	).itemid ~= badGroundItemId
                                            ) then
                                                if (getThingFromPosMock(
													{x = pom2.x, y = pom2.y, z = pom2.z, stackpos = 0}
                                                	).itemid ~= groundItemId
                                                ) then
                                                    local mapItem2Pos =
                                                        {x = pom2.x, y = pom2.y, z = pom2.z, stackpos = 1}
                                                    local mapItem2 = getThingFromPosMock(mapItem2Pos)
                                                    if not ( (mapItem2.itemid == wallBorder[1][1])
                                                            or (mapItem2.itemid == wallBorder[2][1])
                                                            or (mapItem2.itemid == wallBorder[3][1])
                                                            or (mapItem2.itemid == wallBorder[4][1])
                                                    ) then -- safety-fuse to prevent walls deletion
                                                        if (mapItem2.itemid == border[1][1]) then
                                                            doRemoveItemMock(mapItem2.uid, mapItem2Pos)
                                                        end
                                                    end
                                                    --print("north x - " .. pom2.x .. " y - " .. pom2.y .. " z - " .. pom2.z )
                                                    doCreateItemMock(
														border[ax][1],
														1,
														{x = pom2.x, y = pom2.y, z = pom2.z}
                                                    )
                                                end
                                            end
                                        end
                                    end
                                    pom2.x = pom2.x + 1
                                end
                                pom2.x = pom2.x - tab.size
                                pom2.y = pom2.y + 1
                            end
                        end

                    end
                elseif (mapItem.itemid == border[4][1]) then
                    if (getThingFromPosMock(
						{x = pom.x, y = pom.y + 1, z = pom.z, stackpos = 1}
                    ).itemid == border[4][1]
                    ) then
                        lengthY = 2
                    end

                    local pom2 = {}
                    if (lengthY == 2) then
                        if (math.random(1, 100) <= chance) then
                            pom2.x = pom.x
                            pom2.y = pom.y
                            pom2.z = pom.z
                            local tab = shapesTab[5]
                            for ai = 1, tab.size do
                                for aj = 1, tab.size do
                                    for ax = 1, 12 do
                                        if (tab.shape[ai][aj] == ax) then
                                            if (getThingFromPosMock(
												{x = pom2.x, y = pom2.y, z = pom2.z, stackpos = 0}
                                            ).itemid ~= badGroundItemId
                                            ) then
                                                if (getThingFromPosMock(
													{x = pom2.x, y = pom2.y, z = pom2.z, stackpos = 0}
                                                ).itemid ~= groundItemId
                                                ) then
                                                    local mapItem2Pos =
                                                    {x = pom2.x, y = pom2.y, z = pom2.z, stackpos = 1}
                                                    local mapItem2 = getThingFromPosMock(mapItem2Pos)
                                                    if not ((mapItem2.itemid == wallBorder[1][1])
                                                            or (mapItem2.itemid == wallBorder[2][1])
                                                            or (mapItem2.itemid == wallBorder[3][1])
                                                            or (mapItem2.itemid == wallBorder[4][1])
                                                    ) then -- safety-fuse to prevent walls deletion
                                                        if (mapItem2.itemid == border[4][1]) then
                                                            doRemoveItemMock(mapItem2.uid, mapItem2Pos)
                                                        end
                                                    end
                                                    --print("east x - " .. pom2.x .. " y - " .. pom2.y .. " z - " .. pom2.z )
                                                    doCreateItemMock(
														border[ax][1],
														1,
														{x = pom2.x, y = pom2.y, z = pom2.z}
                                                    )
                                                end
                                            end
                                        end
                                    end
                                    pom2.x = pom2.x + 1
                                end
                                pom2.x = pom2.x - tab.size
                                pom2.y = pom2.y + 1
                            end
                            --print("\n")
                        end
                    end
                elseif (mapItem.itemid == border[2][1]) then
                    if (getThingFromPosMock(
						{x = pom.x, y = pom.y + 1, z = pom.z, stackpos = 1}
                    ).itemid == border[2][1]
                    ) then
                        lengthY = 2
                    end

                    local pom2 = {}
                    if (lengthY == 2) then
                        if (math.random(1, 100) <= chance) then
                            pom2.x = pom.x - 2
                            pom2.y = pom.y
                            pom2.z = pom.z
                            local tab = shapesTab[13]
                            for ai = 1, tab.size do
                                for aj = 1, tab.size do
                                    for ax = 1, 12 do
                                        if (tab.shape[ai][aj] == ax) then
                                            if (getThingFromPosMock(
												{x = pom2.x, y = pom2.y, z = pom2.z, stackpos = 0}
                                            ).itemid ~= badGroundItemId
                                            ) then
                                                if (getThingFromPosMock(
													{x = pom2.x, y = pom2.y, z = pom2.z, stackpos = 0}
                                                ).itemid ~= groundItemId
                                                ) then
                                                    local mapItem2Pos =
                                                    {x = pom2.x, y = pom2.y, z = pom2.z, stackpos = 1}
                                                    local mapItem2 = getThingFromPosMock(mapItem2Pos)
                                                    if not ((mapItem2.itemid == wallBorder[1][1])
                                                            or (mapItem2.itemid == wallBorder[2][1])
                                                            or (mapItem2.itemid == wallBorder[3][1])
                                                            or (mapItem2.itemid == wallBorder[4][1])
                                                    ) then -- safety-fuse to prevent walls deletion
                                                        if (mapItem2.itemid == border[2][1]) then
                                                            doRemoveItemMock(mapItem2.uid, mapItem2Pos)
                                                        end
                                                    end
                                                    --print("west x - " .. pom2.x .. " y - " .. pom2.y .. " z - " .. pom2.z )
                                                    doCreateItemMock(
														border[ax][1],
														1,
														{x = pom2.x, y = pom2.y, z = pom2.z}
                                                    )
                                                end
                                            end
                                        end
                                    end
                                    pom2.x = pom2.x + 1
                                end
                                pom2.x = pom2.x - tab.size
                                pom2.y = pom2.y + 1
                            end
                        end
                    end
                end
            end
            pom.x = pom.x + overStep
            lengthX = 1
            lengthY = 1
        end
        pom.x = self.map.mainPos.x
        pom.y = pom.y + 1
    end

    print("Corrections of borders on floor: " .. currentFloor .. " done, execution time: " .. os.clock() - startTime)
end
