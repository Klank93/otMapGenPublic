WallAutoBorder = {}
WallAutoBorder.__index = WallAutoBorder
--- Extends the AutoBorder class

function WallAutoBorder.new(map)
    local instance = setmetatable(WallAutoBorder, AutoBorder)
    instance.map = map

    return instance
end

function WallAutoBorder:doWalls(ground1, ground2, border, currentFloor)
    print("Bordering walls...")
    local startTime = os.clock()
    local pom = {}
    pom.x = self.map.mainPos.x
    pom.y = self.map.mainPos.y
    pom.z = currentFloor or self.map.mainPos.z

    for i = self.map.mainPos.y, self.map.mainPos.y + self.map.sizeY do
        for j = self.map.mainPos.x, self.map.mainPos.x + self.map.sizeX do
            local itemId = getThingFromPosMock(
                    {x = pom.x, y = pom.y, z = pom.z, stackpos = 0}
            ).itemid

            if (itemId == ground1) then
                if (getThingFromPosMock(
                        {x = pom.x, y = pom.y + 1, z = pom.z, stackpos = 0}
                ).itemid == ground2) then
                    if (getThingFromPosMock(
                            {x = pom.x + 1, y = pom.y, z = pom.z, stackpos = 0}
                    ).itemid == ground2) then
                        doCreateItemMock(
                                border[4][1],
                                1,
                                {x = pom.x, y = pom.y, z = pom.z}
                        )
                    else
                        doCreateItemMock(
                                border[1][1],
                                1,
                                {x = pom.x, y = pom.y, z = pom.z}
                        )
                    end
                    --[[ experimental, first four conditions check the cross from ground1,
                        next two check by axis ground 2
                        case when e.g.
                        g1 ,g1 ,G2!
                        g1 ,g1 ,g1
                        G2!,g1 ,g1
                    ]]--
                elseif (getThingFromPosMock({x = pom.x, y = pom.y + 1, z = pom.z, stackpos = 0}).itemid == ground1) then
                    if (getThingFromPosMock({x = pom.x + 1, y = pom.y, z = pom.z, stackpos = 0}).itemid == ground1) then
                        if (getThingFromPosMock({x = pom.x, y = pom.y - 1, z = pom.z, stackpos = 0}).itemid == ground1) then
                            if (getThingFromPosMock({x = pom.x - 1, y = pom.y, z = pom.z, stackpos = 0}).itemid == ground1) then

                                if (getThingFromPosMock({x = pom.x - 1, y = pom.y + 1, z = pom.z, stackpos = 0}).itemid == ground2) then
                                    if (getThingFromPosMock({x = pom.x + 1, y = pom.y - 1, z = pom.z, stackpos = 0}).itemid == ground2) then
                                        doCreateItemMock(
                                                border[4][1],
                                                1,
                                                {x = pom.x, y = pom.y, z = pom.z}
                                        )
                                    end
                                end
                            end
                        end
                    end
                end
            end

            if ((itemId == ground1) and (getThingFromPosMock({x = pom.x + 1, y = pom.y, z = pom.z, stackpos = 0}).itemid == ground2)) then
                if (getThingFromPosMock({x = pom.x, y = pom.y + 1, z = pom.z, stackpos = 0}).itemid ~= ground2) then
                    doCreateItemMock(
                            border[2][1],
                            1,
                            {x = pom.x, y = pom.y, z = pom.z}
                    )
                end
            end
            if ((itemId == ground1) and (getThingFromPosMock({x = pom.x, y = pom.y - 1, z = pom.z, stackpos = 0}).itemid == ground2)) then
                if (getThingFromPosMock({x = pom.x + 1, y = pom.y - 1, z = pom.z, stackpos = 0}).itemid == ground1) then
                    doCreateItemMock(
                            border[4][1],
                            1,
                            {x = pom.x, y = pom.y - 1, z = pom.z}
                    )
                else
                    doCreateItemMock(
                            border[1][1],
                            1,
                            {x = pom.x, y = pom.y-1, z = pom.z}
                    )
                end
            end
            if ((itemId == ground1) and (getThingFromPosMock({x = pom.x - 1, y = pom.y, z = pom.z, stackpos = 0}).itemid == ground2)) then
                if (getThingFromPosMock({x = pom.x - 1, y = pom.y + 1, z = pom.z, stackpos = 0}).itemid ~= ground1) then
                    doCreateItemMock(
                            border[2][1],
                            1,
                            {x = pom.x - 1, y = pom.y, z = pom.z}
                    )
                end
            end

            -- "pillars"
            if ((itemId == ground1) and (getThingFromPosMock({x = pom.x + 1, y = pom.y + 1, z = pom.z, stackpos = 0}).itemid == ground2)) then
                if ((getThingFromPosMock({x = pom.x + 1, y = pom.y, z = pom.z, stackpos = 0}).itemid == ground1 )
                        and ( getThingFromPosMock({x = pom.x, y = pom.y + 1, z = pom.z, stackpos = 0}).itemid == ground1 )) then
                    doCreateItemMock(
                            border[3][1],
                            1,
                            {x = pom.x, y = pom.y, z = pom.z}
                    )
                end
            end
            if ((itemId == ground1) and (getThingFromPosMock({x = pom.x - 1, y = pom.y - 1, z = pom.z, stackpos = 0}).itemid == ground2)) then
                if ((getThingFromPosMock({x = pom.x - 1, y = pom.y, z = pom.z, stackpos = 0}).itemid == ground2 )
                        and ( getThingFromPosMock({x = pom.x, y = pom.y - 1, z = pom.z, stackpos = 0}).itemid == ground2 )) then
                    doCreateItemMock(
                            border[3][1],
                            1,
                            {x = pom.x - 1, y = pom.y - 1, z = pom.z}
                    )
                end
            end
            pom.x = pom.x + 1
        end
        pom.x = self.map.mainPos.x
        pom.y = pom.y + 1
    end

    print("Bordering walls done, execution time: " .. os.clock() - startTime)
end

function WallAutoBorder:createArchways(wallBorder)
    local startTime = os.clock()

    for a=1, #self.map.wayPoints do
        local pom = {}
        local heightEven = (self.map.wayPoints[a][4] % 2)
        local widthEven = (self.map.wayPoints[a][5] % 2)
        local height = self.map.wayPoints[a][4]
        local width = self.map.wayPoints[a][5]

        pom.x = self.map.wayPoints[a][1].x
        pom.y = self.map.wayPoints[a][1].y
        pom.z = self.map.wayPoints[a][1].z

        -- sets the pom
        if (heightEven == 0) then -- even height of the room
            pom.y = (pom.y - (height / 2))
        elseif (heightEven == 1) then
            pom.y = (pom.y - (height / 2) - 0.5)
        end

        if (widthEven == 0) then -- even width of the room
            pom.x = (pom.x - (width / 2))
        elseif (widthEven == 1) then
            pom.x = (pom.x - (width / 2) - 0.5)
        end

        for i = 1, width + 2 do
            for j = 1, height + 2 do
                local pomitem1 = getThingFromPosMock(
                        {x = pom.x, y = pom.y, z = pom.z, stackpos = 1
                        })

                if (pomitem1.itemid == wallBorder[4][1]) then
                    local pomitem2 = getThingFromPosMock(
                            {x = pom.x + 3, y = pom.y, z = pom.z, stackpos = 1}
                    )
                    local pomitem3 = getThingFromPosMock(
                            {x = pom.x, y = pom.y + 3, z = pom.z, stackpos = 1}
                    )

                    if ( (pomitem2.itemid  == wallBorder[2][1]) and (getThingFromPosMock(
                            {x = pom.x + 4, y = pom.y, z = pom.z, stackpos = 1}
                    ).itemid == wallBorder[1][1])
                    ) then
                        local state = true
                        local pom2 = {}
                        pom2.x = pom.x
                        pom2.y = pom.y - 1
                        pom2.z = pom.z
                        for i1 = 1, 2 do
                            if not((getThingFromPosMock(
                                    {x = pom2.x, y = pom2.y, z = pom2.z, stackpos = 1}
                            ).itemid == wallBorder[2][1]) and  (getThingFromPosMock(
                                    {x = pom2.x + 3, y = pom2.y, z = pom2.z, stackpos = 1}
                            ).itemid == wallBorder[2][1])
                            ) then
                                state = false
                            end
                            pom2.y = pom2.y - 1
                        end
                        if (state == true) then
                            --doCreateItemMock(
                            --        wallBorder[5][1],
                            --        1,
                            --        {x = pom.x + 1, y = pom.y, z = pom.z}
                            --)
                            --doCreateItemMock(
                            --        wallBorder[5][2],
                            --        1,
                            --        {x = pom.x + 2, y = pom.y, z = pom.z}
                            --)
                            --doTransformItem(
                            --        pomitem2.uid,
                            --        wallBorder[4][1]
                            --)

                            doCreateItemMock(
                                    wallBorder[5][1],
                                    1,
                                    {x = pom.x + 1, y = pom.y, z = pom.z}
                            )
							if (wallBorder[5][3] ~= nil) then
								doCreateItemMock(
									wallBorder[5][3],
									1,
									{x = pom.x + 2, y = pom.y, z = pom.z}
								)
							else
								print('There is no middle, vertical archway.')
							end
                            doCreateItemMock(
                                    wallBorder[5][2],
                                    1,
                                    {x = pom.x + 3, y = pom.y, z = pom.z}
                            )
                        end
                        -- "variation" below
                    elseif ((pomitem3.itemid  == wallBorder[1][1]) and (getThingFromPosMock(
                            {x = pom.x, y = pom.y + 4, z = pom.z, stackpos = 1}
                    ).itemid == wallBorder[2][1])
                    ) then
                        local state = true
                        local pom2 = {}
                        pom2.x = pom.x - 1
                        pom2.y = pom.y
                        pom2.z = pom.z
                        for i1 = 1, 2 do
                            if not ((getThingFromPosMock(
                                    {x = pom2.x, y = pom2.y, z = pom2.z, stackpos = 1}
                            ).itemid == wallBorder[1][1] ) and  (getThingFromPosMock(
                                    {x = pom2.x, y = pom2.y + 3, z = pom2.z, stackpos = 1}
                            ).itemid == wallBorder[1][1])
                            ) then
                                state = false
                            end
                            pom2.x = pom2.x - 1
                        end
                        if (state == true) then
                            --doCreateItemMock(
                            --        wallBorder[6][1],
                            --        1,
                            --        {x = pom.x, y = pom.y + 1, z = pom.z}
                            --)
                            --doCreateItemMock(
                            --        wallBorder[6][2],
                            --        1,
                            --        {x = pom.x, y = pom.y + 2, z = pom.z}
                            --)
                            --doTransformItem(
                            --        pomitem3.uid,
                            --        wallBorder[4][1]
                            --)

                            doCreateItemMock(
                                    wallBorder[6][1],
                                    1,
                                    {x = pom.x, y = pom.y + 1, z = pom.z})
							if (wallBorder[6][3] ~= nil) then
								doCreateItemMock(
									wallBorder[6][3],
									1,
									{x = pom.x, y = pom.y + 2, z = pom.z}
								)
							else
								print('There is no middle, vertical archway.')
							end
                            doCreateItemMock(
                                    wallBorder[6][2],
                                    1,
                                    {x = pom.x, y = pom.y + 3, z = pom.z}
                            )
                        end
                    end
                elseif (pomitem1.itemid == wallBorder[1][1]) then
                    local pomitem2 = getThingFromPosMock(
                            {x = pom.x + 3, y = pom.y, z = pom.z, stackpos = 1}
                    )
                    local pomitem3 = getThingFromPosMock(
                            {x = pom.x, y = pom.y + 3, z = pom.z, stackpos = 1}
                    )

                    if (pomitem2.itemid  == wallBorder[3][1]) then
                        local state = true
                        local pom2 = {}
                        pom2.x = pom.x
                        pom2.y = pom.y + 1
                        pom2.z = pom.z
                        for i1 = 1, 2 do
                            if not ((getThingFromPosMock(
                                    {x = pom2.x, y = pom2.y, z = pom2.z, stackpos = 1}
                            ).itemid == wallBorder[2][1] ) and  (getThingFromPosMock(
                                    {x = pom2.x + 3, y = pom2.y, z = pom2.z, stackpos = 1}
                            ).itemid == wallBorder[2][1])
                            ) then
                                state = false
                            end
                            pom2.y = pom2.y + 1
                        end
                        if (state == true) then
                            --doCreateItemMock(
                            --        wallBorder[5][1],
                            --        1,
                            --        {x = pom.x + 1, y = pom.y, z = pom.z}
                            --)
                            --doCreateItemMock(
                            --        wallBorder[5][2],
                            --        1,
                            --        {x = pom.x + 2, y = pom.y, z = pom.z}
                            --)
                            --doTransformItem(
                            --        pomitem2.uid,
                            --        wallBorder[1][1]
                            --)

                            doCreateItemMock(
                                    wallBorder[5][1],
                                    1,
                                    {x = pom.x + 1, y = pom.y, z = pom.z}
                            )
							if (wallBorder[5][3] ~= nil) then
								doCreateItemMock(
									wallBorder[5][3],
									1,
									{x = pom.x + 2, y = pom.y, z = pom.z}
								)
							else
								print('There is no middle, horizontal archway.')
							end
                            doCreateItemMock(
                                    wallBorder[5][2],
                                    1,
                                    {x = pom.x + 3, y = pom.y, z = pom.z}
                            )
                        end
                    elseif (pomitem3.itemid  == wallBorder[1][1]) then
                        if ((getThingFromPosMock(
                                {x = pom.x - 1, y = pom.y, z = pom.z, stackpos = 1}
                        ).itemid == wallBorder[2][1] ) and (getThingFromPosMock(
                                {x = pom.x - 1, y = pom.y + 3, z = pom.z, stackpos = 1}
                        ).itemid == wallBorder[3][1])
                        ) then
                            local state = true
                            local pom2 = {}
                            pom2.x = pom.x + 1
                            pom2.y = pom.y
                            pom2.z = pom.z

                            for i1 = 1, 2 do
                                if not ((getThingFromPosMock(
                                        {x = pom2.x, y = pom2.y, z = pom2.z, stackpos = 1}
                                ).itemid == wallBorder[1][1] ) and (getThingFromPosMock(
                                        {x = pom2.x, y = pom2.y + 3, z = pom2.z, stackpos = 1}
                                ).itemid == wallBorder[1][1])
                                ) then
                                    state = false
                                end
                                pom2.x = pom2.x + 1
                            end
                            if (state == true) then
                                --doCreateItemMock(
                                --        wallBorder[6][1],
                                --        1,
                                --        {x = pom.x - 1, y = pom.y + 1, z = pom.z}
                                --)
                                --doCreateItemMock(
                                --        wallBorder[6][2],
                                --        1,
                                --        {x = pom.x - 1, y = pom.y + 2, z = pom.z}
                                --)
                                --doTransformItem(
                                --        getThingFromPosMock(
                                --                {x = pom.x - 1, y = pom.y + 3, z = pom.z, stackpos = 1}
                                --        ).uid,
                                --        wallBorder[2][1]
                                --)

                                doCreateItemMock(
                                        wallBorder[6][1],
                                        1,
                                        {x = pom.x - 1, y = pom.y + 1, z = pom.z}
                                )
								if (wallBorder[6][3] ~= nil) then
									doCreateItemMock(
										wallBorder[6][3],
										1,
										{x = pom.x - 1, y = pom.y + 2, z = pom.z}
									)
								else
									print('There is no middle, vertical archway.')
								end
                                doCreateItemMock(
                                        wallBorder[6][2],
                                        1,
                                        {x = pom.x - 1, y = pom.y + 3, z = pom.z}
                                )
                            end
                        end
                    end
                end
                pom.x = pom.x + 1
            end
            pom.x = pom.x - height - 1
            pom.y = pom.y + 1
        end
    end

    print("Creating archways done, execution time: " .. os.clock() - startTime)
end
