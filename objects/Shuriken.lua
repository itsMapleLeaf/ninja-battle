Shuriken = GameObject:extend()

local function crossFilter() return 'cross' end

function Shuriken:new(x, y, dir, world, owner)
	GameObject.new(self, x - 6, y - 6, 12, 12, world)

	self.dir = dir
	self.owner = owner

	self.speed = 400
	self.rotation = 0
	self.stuck = false
	self.opacity = 1
end

function Shuriken:update(dt)
	if not self.stuck then
		self.xvel = self.speed * self.dir
		self.rotation = self.rotation + 30 * dt * self.dir

		local fx = self.x + self.xvel * dt
		local fy = self.y + self.yvel * dt

		self.x, self.y, cols = self.world:move(self, fx, fy, crossFilter)

		for i=1, #cols do
			local col = cols[i]
			if col.other:is(MapBlock) then
				self:getStuck()
			end

			if col.other:is(Player) and col.other ~= self.owner then
				col.other:damage(self.dir)
				self:destroy()
			end
		end

		if self.x < 0 - self.width or self.x > Gameplay.map.width then
			self:destroy()
		end
	else
		self.xvel = 0
	end
end

function Shuriken:getStuck()
	self.stuck = true
	flux.to(self, 1, { opacity = 0 }):delay(5):oncomplete(function()
		if self.world:hasItem(self) then
			self:destroy()
		end
	end)
end

function Shuriken:draw()
	local image = Images.shuriken
	local x,y = self:getCenter()
	local w,h = image:getDimensions()

	love.graphics.setColor(255, 255, 255, 255 * self.opacity)
	love.graphics.draw(image, x, y, self.rotation, 1, 1, w/2, h/2)
	love.graphics.setColor(255, 255, 255)
end
