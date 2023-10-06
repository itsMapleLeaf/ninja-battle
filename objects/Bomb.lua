Bomb = GameObject:extend()

local gravity = 1000

local function bombFilter(item, other)
	if other:is(MapBlock) then
		return 'slide'
	end
	return 'cross'
end

local function playerFilter(other)
	return other:is(Player)
end

function Bomb:new(x, y, xvel, world)
	GameObject.new(self, x, y, 18, 18, world)

	self.xvel = xvel
	self.blastRadius = 90
	self.onGround = false

	timer.add(3, self.explode, self)
end

function Bomb:update(dt)
	self.xvel = util.interpolate(self.xvel, 0, dt * 1.5)
	self.yvel = self.yvel + gravity * dt

	local fx = self.x + self.xvel * dt
	local fy = self.y + self.yvel * dt

	local cols
	self.x, self.y, cols = self.world:move(self, fx, fy, bombFilter)

	local bounced = self:resolveVelocity(cols, 0.5)
	if bounced then
		if not self.onGround then
			Sounds.bombBounce:stop()
			Sounds.bombBounce:play()
		end
		self.onGround = true
	else
		self.onGround = false
	end
end

function Bomb:explode()
	local cx, cy = self:getCenter()
	local players = self.world:queryRect(
		cx - self.blastRadius,
		cy - self.blastRadius,
		self.blastRadius * 2,
		self.blastRadius * 2,
		playerFilter)

	for i = 1, #players do
		local player = players[i]
		local px, py = player:getCenter()
		if util.distance(px, py, cx, cy) < self.blastRadius then
			player:damage(util.sign(player.x - self.x) * 5, 5)
		end
	end

	signals.trigger('bombExploded')

	self:destroy()
	Sounds.explosion:stop()
	Sounds.explosion:play()
end

function Bomb:draw()
	love.graphics.draw(Images.bomb, self.x - 2, self.y - 2)
end
