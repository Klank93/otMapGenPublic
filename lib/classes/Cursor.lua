Cursor = {}
Cursor.__index = Cursor

function Cursor.new(pos) -- todo: add params, if needed
    local instance = setmetatable({}, Cursor)
    instance.pos = defaultParam(
            {x = pos.x, y = pos.y, z = pos.z},
            {x = 0, y = 0, z = 0}
    )

    return instance
end

function Cursor:up(step)
    self.pos.y = self.pos.y - step
    if self.pos.y <= 0 then
        print('Cursor pos.y out of the map.')
        --self.pos.y = self.pos.y - step

        return false
    end
end

function Cursor:upWest(step)
    self.pos.y = self.pos.y - step
    self.pos.x = self.pox.x - step
    if self.pos.y <= 0 or self.pos.x <= 0 then
        print('Cursor pos.y or pos.x out of the map.')
        --self.pos.y = self.pos.y + step
        --self.pos.x = self.pos.x + step

        return false
    end
end

function Cursor:upEast(step)
    self.pos.y = self.pos.y - step
    self.pos.x = self.pox.x + step
    if self.pos.y <= 0 then
        print('Cursor pos.y out of the map.')
        --self.pos.y = self.pos.y + step
        --self.pos.x = self.pos.x - step

        return false
    end
end

function Cursor:down(step)
    self.pos.y = self.pos.y + step
end

function Cursor:downWest(step)
    self.pos.y = self.pos.y + step
    self.pos.x = self.pos.x - step
    --if self.pos.x <= 0 then
    --    print('Cursor pos.x out of the map.')
    --    self.pos.y = self.pos.y - step
    --    self.pos.x = self.pos.x + step
    --
    --    return false
    --end
end

function Cursor:downEast(step)
    self.pos.y = self.pos.y + step
    self.pos.x = self.pos.x + step
end

function Cursor:right(step)
    self.pos.x = self.pos.x + step
end

function Cursor:left(step)
    self.pos.x = self.pos.x - step
    if self.pos.x <= 0 then
        print("Cursor pos.x of the map x")

        return false
    end
end

function Cursor:setPos(newX, newY, newZ)
    self.pos.x = newX
    self.pos.y = newY
    self.pos.z = newZ
end