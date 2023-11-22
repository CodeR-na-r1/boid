Boid = {}
Boid.__index = Boid

function Boid:create(x, y)
    local boid = {}
    setmetatable(boid, Boid)
    boid.position = Vector:create(x, y)
    boid.velocity = Vector:create(math.random(-10, 10) / 10, math.random(-10, 10) / 10)
    boid.acceleration = Vector:create(0, 0)
    boid.r = 5
    boid.vertices = {0, - boid.r * 2, -boid.r, boid.r * 2, boid.r, 2 * boid.r}
    boid.maxSpeed = 4
    boid.maxForce = 0.1

    boid.countSep = 1
    boid.countAlign = 1
    boid.countCoh = 1

    boid.maxCountSep = 1
    boid.maxCountAlign = 1
    boid.maxCountCoh = 1

    return boid
end

function Boid:update(boids)

    if isSep then
        local sep = self:separate(boids)
        -- sep:mul(4)
        self:applyForce(sep)
    else
        self.countSep = self.maxCountSep
    end

    if isAlign then
        local align = self:isAlign(boids)
        -- sep:mul(4)
        self:applyForce(align)
    else
        self.countAlign = self.maxCountAlign
    end

    if isCoh then
        local coh = self:isCohesion(boids)
        -- sep:mul(4)
        self:applyForce(coh)
    else
        self.countCoh = self.maxCountCoh
    end

    self.velocity:add(self.acceleration)
    self.velocity:limit(self.maxSpeed)
    self.position:add(self.velocity)
    self.acceleration:mul(0)
    self:borders()
end

function Boid:applyForce(force)
    self.acceleration:add(force)
end

function Boid:seek(target)
    local desired = target - self.position
    desired:norm()
    desired:mul(self.maxSpeed)
    local steer = desired - self.velocity
    steer:limit(self.maxForce)
    return steer
end

function Boid:separate(boids)

    local separation = 25.
    local steer = Vector:create(0, 0)
    local count = 0

    for i=0, #boids do

        local boid = boids[i]
        local d = self.position:distTo(boid.position)

        if d > 0 and d < separation then

            local diff = self.position - boid.position
            diff:norm()
            diff:div(d)
            steer:add(diff)
            count = count + 1
        end
    end

    if count > 0 then
        steer:div(count)
    end

    self.countSep = count
    if count > self.maxCountSep then
        self.maxCountSep = count
    end

    if steer:mag() > 0 then

        steer:norm()

        steer:mul(self.maxSpeed)
        steer:sub(self.velocity)

        steer:limit(self.maxForce)
    end

    return steer
end

function Boid:isAlign(boids)

    local align = 25.
    local steer = Vector:create(0, 0)
    local count = 0

    steer:add(self.velocity)
    for i=0, #boids do

        local boid = boids[i]
        local d = self.position:distTo(boid.position)

        if d > 0 and d < align then

            local diff =  boid.velocity
            -- diff:norm()
            -- diff:div(d)
            steer:add(diff)
            count = count + 1
        end
    end

    if count > 0 then
        steer:div(count)
    end

    self.countAlign = count
    if count > self.maxCountAlign then
        self.maxCountAlign = count
    end

    if steer:mag() > 0 then

        steer:norm()

        steer:mul(self.maxSpeed)
        steer:sub(self.velocity)

        steer:limit(self.maxForce)
    end

    return steer

end

function Boid:isCohesion(boids)

    local cohesion = 200.
    
    local steer = Vector:create(0, 0)
    local count = 0

    for i=0, #boids do

        local boid = boids[i]
        local d = self.position:distTo(boid.position)

        if d > 0 and d < cohesion then

            local diff =  boid.position
            -- diff:norm()
            -- diff:div(d)
            steer:add(diff)
            count = count + 1
        end
    end

    if count > 0 then
        steer:div(count)
    end

    self.countCoh = count
    if count > self.maxCountCoh then
        self.maxCountCoh = count
    end

    return self:seek(steer)

    -- if steer:mag() > 0 then

    --     steer:norm()

    --     steer:mul(self.maxSpeed)
    --     steer:sub(self.velocity)

    --     steer:limit(self.maxForce)
    -- end

    -- return steer

end

function Boid:borders()
    if self.position.x < -self.r then
        self.position.x = width - self.r
    end
    if self.position.x > width + self.r then
        self.position.x = self.r
    end

    if self.position.y < -self.r then
        self.position.y = height - self.r
    end
    if self.position.y > height + self.r then
        self.position.y = self.r
    end
end

function Boid:draw()
    r, g, b, a = love.graphics.getColor()

    -- print("curr")
    -- print(self.countCoh)
    -- print("max")
    -- print(self.maxCountCoh)

    love.graphics.setColor(self.countSep / self.maxCountSep,
                           self.countAlign / self.maxCountAlign,
                           self.countCoh / self.maxCountCoh)

    local theta = self.velocity:heading() + math.pi / 2
    love.graphics.push()
    love.graphics.translate(self.position.x, self.position.y)
    love.graphics.rotate(theta)
    love.graphics.polygon("fill", self.vertices)
    love.graphics.pop()

    love.graphics.setColor(r, g, b, a)
end