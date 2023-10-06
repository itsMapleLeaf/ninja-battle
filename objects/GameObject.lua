GameObject = Object:extend()

function GameObject:new(x, y, width, height, world)
	self.x = x
	self.y = y
	self.width = width
	self.height = height
	self.world = world

	self.xvel = 0
	self.yvel = 0

	world:add(self, self:getRect())
end

function GameObject:getRect()
	return self.x, self.y, self.width, self.height
end

function GameObject:getCenter()
	return self.x + self.width/2, self.y + self.height/2
end

function GameObject:setPosition(x, y)
	self.x = x
	self.y = y
end

function GameObject:setWorldPosition(x, y)
	self:setPosition(x, y)
	self.world:update(self, x, y)
end

function GameObject:update(dt)
	self:setPosition(self.x + self.xvel * dt, self.y + self.yvel * dt)
end

function GameObject:resolveVelocity(cols, bounce)
	local hitWall = false
	for i=1, #cols do
		local col = cols[i]
		if col.type ~= 'cross' then
			local nx, ny = col.normal.x, col.normal.y
			if nx ~= 0 and nx ~= util.sign(self.xvel) then
				self.xvel = -self.xvel * (bounce or 0)
				hitWall = true
			end
			if ny ~= 0 and ny ~= util.sign(self.yvel) then
				self.yvel = -self.yvel * (bounce or 0)
				hitWall = true
			end
		end
	end
	return hitWall
end

function GameObject:destroy()
	self.world:remove(self)
end

function GameObject:drawRect()
	love.graphics.rectangle('line', self:getRect())
end

function GameObject:draw()
	self:drawRect()
end
